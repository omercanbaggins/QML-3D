import QtQuick
import QtQuick.Window
import QtQuick3D
import QtQuick3D.AssetUtils 

Window {
    visible: true
    width: 800
    height: 600
    title: "Qt Quick 3D - Multi-Mesh & Debugger"

    View3D {
        anchors.fill: parent

        environment: SceneEnvironment {
            clearColor: "#404040" 
            backgroundMode: SceneEnvironment.Color
        }

        // --- CAMERA ---
        PerspectiveCamera {
            id: camera
            z: 400 
            clipFar: 10000 
        }

        DirectionalLight {
            eulerRotation.x: -45
            eulerRotation.y: 45
            ambientColor: "#444444" 
        }

        // i get the values from mouse based on user input 
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            property int activeButton: Qt.NoButton

            property int lastX: 0
            property int lastY: 0
            property int current:0
            onPressed: (mouse) => {
                lastX = mouse.x
                lastY = mouse.y
                activeButton = mouse.button
            }
            

            onPositionChanged: (mouse) => {
                if (pressed) {
                     if (activeButton === Qt.RightButton) {
                       

                        let deltaX = mouse.x - lastX
                        lastX = mouse.x

                        baseMesh.eulerRotation.x += deltaX * 0.5
                        topMeshPivot.eulerRotation.x+= deltaX * 0.5
       
                   

                    }
                    else{
                                            
                        console.log(activeButton)
                        
                        let deltaY = mouse.y - lastY

                        // it rotates the pivot (there is no skeletal mesh animation we rotate the point where second mesh is attached to)
                        
                        current = topMeshPivot.position.y
                        if(current- deltaY>15 || current-deltaY<-15){
                            
                        }
                        else{
                            let angle = topMeshPivot.z *3.141/180.0
                            let forwardX = Math.cos(angle)
                            let forwardY = Math.sin(angle)
                            topMeshPivot.position.y -=  deltaY *0.5
                            //topMeshPivot.position.x -= forwardY * deltaY

                        }
                        

                        lastY = mouse.y
                    

                    }
                }
            }

            onWheel: (wheel) => {
                let zoomSpeed = 0.5; 
                camera.z -= wheel.angleDelta.y * zoomSpeed;  // zoom in zoom out logic

                if (camera.z < 250) {
                    camera.z = 250;
                } else if (camera.z > 5000) {
                    camera.z = 5000;
                }
            }

        }

        // --- VISUAL DEBUGGER ---
        Text {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 15
            color: "white"
            font.pixelSize: 20
            font.bold: true
            
            text: {
                if (topMesh.status === RuntimeLoader.Null) return "Status: NULL (Idle/Not started)";
                if (topMesh.status === RuntimeLoader.Loading) return "Status: LOADING...";
                if (topMesh.status === RuntimeLoader.Success) return "Status: SUCCESS! (Check scale/camera)";
                if (topMesh.status === RuntimeLoader.Error) return "Status: ERROR -> " + topMesh.errorString;
                return "Status: UNKNOWN";
            }
        }


        //mesh hierarchy
        Node {
            id: entireAssembly
            
            RuntimeLoader {
                id: baseMesh  //represents base mesh
                // UPDATE THIS PATH:
                source: "file:///C:/comapare/models/meshes/r_base.glb"  //folder and file name 
                
                scale: Qt.vector3d(100, 100, 100) 
            }

            // 2. The pivot node controlling the top mesh
            Node {
                id: topMeshPivot
                y:0 // if meshes pivot point is correctly adjusted make it 0. 
                
                // child mesh
                RuntimeLoader {
                    id: topMesh
                    // UPDATE THIS PATH:
                    source: "file:///C:/comapare/models/meshes/r_grabber.glb"
                    scale: Qt.vector3d(100, 100, 100) 

                }
            }
        }
    }
}
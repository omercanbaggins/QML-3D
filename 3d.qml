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
            
            property int lastX: 0
            property int lastY: 0

            onPressed: (mouse) => {
                lastX = mouse.x
                lastY = mouse.y
            }

            onPositionChanged: (mouse) => {
                if (pressed) {   
                    let deltaX = mouse.x - lastX
                    let deltaY = mouse.y - lastY

                    // it rotates the pivot (there is no skeletal mesh animation we rotate the point where second mesh is attached to)
                    topMeshPivot.eulerRotation.y += deltaX * 0.5
                    topMeshPivot.eulerRotation.x += deltaY * 0.5

                    lastX = mouse.x
                    lastY = mouse.y
                }
            }

            onWheel: (wheel) => {
                let zoomSpeed = 0.5; 
                camera.z -= wheel.angleDelta.y * zoomSpeed;  // zoom in zoom out logic

                if (camera.z < 50) {
                    camera.z = 50;
                } else if (camera.z > 2000) {
                    camera.z = 2000;
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
                source: "file:///C:/comapare/models/part1.glb"  //folder and file name 
                
                // scale: Qt.vector3d(100, 100, 100) 
            }

            // 2. The pivot node controlling the top mesh
            Node {
                id: topMeshPivot
                y:5 // if meshes pivot point is correctly adjusted make it 0. 
                
                // child mesh
                RuntimeLoader {
                    id: topMesh
                    // UPDATE THIS PATH:
                    source: "file:///C:/comapare/models/part2.glb"
                    
                }
            }
        }
    }
}
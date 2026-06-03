# Narrative
# --------
# Sample 15.3: Floating Action Button with Speed Dial
#
# Extracted from stzringqmltest.ring, block #46.

load "../../stzBase.ring"

pr()

# Use case: Quick actions menu


	new qApp {
	    oQML = new RingQML(NULL) {
	        loadContent(QML_15_3())
	    }
	    exec()
	}
	
	func QML_15_3
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
		import QtGraphicalEffects 1.15
	
	        Window {
	            visible: true
	            width: 450
	            height: 600
	            title: 'Floating Action Button'
	            
	            Rectangle {
	                anchors.fill: parent
	                color: '#ecf0f1'
	                
	                Text {
	                    text: '📱 FAB Speed Dial Example'
	                    font.pointSize: 18
	                    font.bold: true
	                    anchors.centerIn: parent
	                }
	                
	                Rectangle {
	                    id: fabOverlay
	                    anchors.fill: parent
	                    color: '#000000'
	                    opacity: fabExpanded ? 0.5 : 0
	                    visible: opacity > 0
	                    
	                    property bool fabExpanded: false
	                    
	                    Behavior on opacity {
	                        NumberAnimation { duration: 200 }
	                    }
	                    
	                    MouseArea {
	                        anchors.fill: parent
	                        onClicked: fabOverlay.fabExpanded = false
	                    }
	                }
	                
	                Column {
	                    id: speedDial
	                    anchors.right: parent.right
	                    anchors.bottom: fab.top
	                    anchors.rightMargin: 20
	                    anchors.bottomMargin: 15
	                    spacing: 15
	                    
	                    opacity: fabOverlay.fabExpanded ? 1 : 0
	                    visible: opacity > 0
	                    
	                    Behavior on opacity {
	                        NumberAnimation { duration: 200 }
	                    }
	                    
	                    Repeater {
	                        model: [
	                            { icon: '✏️', label: 'Edit', color: '#3498db' },
	                            { icon: '📷', label: 'Camera', color: '#9b59b6' },
	                            { icon: '📁', label: 'Files', color: '#27ae60' }
	                        ]
	                        
	                        Row {
	                            spacing: 15
	                            layoutDirection: Qt.RightToLeft
	                            
	                            Rectangle {
	                                width: 56
	                                height: 56
	                                color: modelData.color
	                                radius: 28
	                                
	                                scale: fabOverlay.fabExpanded ? 1 : 0
	                                
	                                Behavior on scale {
	                                    NumberAnimation { 
	                                        duration: 200 
	                                        easing.type: Easing.OutBack
	                                    }
	                                }
	                                
	                                Text {
	                                    text: modelData.icon
	                                    font.pointSize: 24
	                                    anchors.centerIn: parent
	                                }
	                                
	                                MouseArea {
	                                    anchors.fill: parent
	                                    onClicked: {
	                                        console.log('Action:', modelData.label)
	                                        fabOverlay.fabExpanded = false
	                                    }
	                                }
	                            }
	                            
	                            Rectangle {
	                                width: labelText.width + 20
	                                height: 35
	                                color: 'white'
	                                radius: 4
	                                anchors.verticalCenter: parent.verticalCenter
	                                
	                                scale: fabOverlay.fabExpanded ? 1 : 0
	                                
	                                Behavior on scale {
	                                    NumberAnimation { 
	                                        duration: 200 
	                                        easing.type: Easing.OutBack
	                                    }
	                                }
	                                
	                                Text {
	                                    id: labelText
	                                    text: modelData.label
	                                    font.pointSize: 12
	                                    anchors.centerIn: parent
	                                }
	                            }
	                        }
	                    }
	                }
	                
	                Rectangle {
	                    id: fab
	                    width: 64
	                    height: 64
	                    color: '#e74c3c'
	                    radius: 32
	                    anchors.right: parent.right
	                    anchors.bottom: parent.bottom
	                    anchors.margins: 20
	                    
	                    scale: fabMouse.pressed ? 0.9 : 1
	                    
	                    Behavior on scale {
	                        NumberAnimation { duration: 100 }
	                    }
	                    
	                    Text {
	                        text: fabOverlay.fabExpanded ? '✕' : '+'
	                        color: 'white'
	                        font.pointSize: 28
	                        anchors.centerIn: parent
	                        
	                        rotation: fabOverlay.fabExpanded ? 45 : 0
	                        
	                        Behavior on rotation {
	                            NumberAnimation { duration: 200 }
	                        }
	                    }
	                    
	                    MouseArea {
	                        id: fabMouse
	                        anchors.fill: parent
	                        onClicked: fabOverlay.fabExpanded = !fabOverlay.fabExpanded
	                    }
	                    
	                    layer.enabled: true
	                    layer.effect: DropShadow {
	                        horizontalOffset: 0
	                        verticalOffset: 2
	                        radius: 8
	                        samples: 16
	                        color: '#80000000'
	                    }
	                }
	            }
	        }
	    "
	
	#--> Floating action button
	#--> Speed dial expansion
	#--> Label hints for actions
	#--> Smooth animations


#===================================#
#   CONCLUSION AND BEST PRACTICES   #
#===================================#

`
CONGRATULATIONS! You've completed the RingQML journey!

KEY TAKEAWAYS:
==============

1. QML-FIRST THINKING
   - Start with QML's declarative structure
   - Design the UI visually and expressively
   - Let QML handle layout, binding, and reactivity

2. RING FOR ORCHESTRATION
   - Use Ring for business logic and data management
   - Ring.callFunc() connects QML events to Ring functions
   - Ring.getVar() and Ring.setVar() bridge data

3. SEPARATION OF CONCERNS
   - Keep QML in dedicated strings or .qml files
   - Keep Ring logic separate
   - Clear boundaries = maintainable code

4. MODERN UI PRINCIPLES
   - Use animations for polish
   - Provide immediate feedback
   - Think mobile-first, scale to desktop
   - Leverage binding for reactivity

5. ARCHITECTURAL PATTERNS
   - Component-based design
   - Data-driven UIs with models
   - State management for complex UIs
   - Clean API between Ring and QML

NEXT STEPS:
===========

1. Experiment with these samples
2. Combine patterns to build your own applications
3. Move QML to .qml files for larger projects
4. Explore Qt documentation for more QML features
5. Share your RingQML creations with the community!

RESOURCES:
=========

- RingQML Library: https://github.com/mohannad-aldulaimi/ringqml
- Ring Language: https://ring-lang.net/
- Qt QML Documentation: https://doc.qt.io/qt-5/qmlapplications.html
- Ring Community: https://groups.google.com/g/ring-lang

Happy coding with RingQML! 🎨🚀

pf()

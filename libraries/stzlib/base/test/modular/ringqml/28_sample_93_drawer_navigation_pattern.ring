# Narrative
# --------
# Sample 9.3: Drawer Navigation Pattern
#
# Extracted from stzringqmltest.ring, block #28.

load "../../../stzBase.ring"

# Use case: Modern mobile navigation


	new qApp {
	        oQML = new RingQML(NULL) {
	            loadContent(QML_9_3())
	        }
	        exec()
	}
	
	func QML_9_3
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 600
	            title: 'Drawer Navigation'
	            
	            Rectangle {
	                id: mainContainer
	                anchors.fill: parent
	                
	                // App Bar
	                Rectangle {
	                    id: appBar
	                    width: parent.width
	                    height: 60
	                    color: '#2c3e50'
	                    z: 2
	                    
	                    Row {
	                        anchors.fill: parent
	                        anchors.margins: 10
	                        spacing: 15
	                        
	                        Rectangle {
	                            width: 40
	                            height: 40
	                            color: 'transparent'
	                            anchors.verticalCenter: parent.verticalCenter
	                            
	                            Text {
	                                text: '☰'
	                                color: 'white'
	                                font.pointSize: 24
	                                anchors.centerIn: parent
	                            }
	                            
	                            MouseArea {
	                                anchors.fill: parent
	                                onClicked: drawer.visible = !drawer.visible
	                            }
	                        }
	                        
	                        Text {
	                            text: 'My Application'
	                            color: 'white'
	                            font.pointSize: 16
	                            font.bold: true
	                            anchors.verticalCenter: parent.verticalCenter
	                        }
	                    }
	                }
	                
	                // Content Area
	                Rectangle {
	                    anchors {
	                        top: appBar.bottom
	                        left: parent.left
	                        right: parent.right
	                        bottom: parent.bottom
	                    }
	                    color: '#ecf0f1'
	                    
	                    Text {
	                        id: contentText
	                        text: 'Home Screen\n\nTap menu icon to open drawer'
	                        anchors.centerIn: parent
	                        horizontalAlignment: Text.AlignHCenter
	                        font.pointSize: 14
	                    }
	                }
	                
	                // Drawer
	                Rectangle {
	                    id: drawer
	                    width: parent.width * 0.7
	                    height: parent.height
	                    color: 'white'
	                    visible: false
	                    z: 3
	                    
	                    Behavior on x {
	                        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
	                    }
	                    
	                    Column {
	                        anchors.fill: parent
	                        
	                        Rectangle {
	                            width: parent.width
	                            height: 150
	                            color: '#3498db'
	                            
	                            Text {
	                                text: 'Menu'
	                                color: 'white'
	                                font.pointSize: 24
	                                font.bold: true
	                                anchors.centerIn: parent
	                            }
	                        }
	                        
	                        Repeater {
	                            model: ['Home', 'Profile', 'Settings', 'About']
	                            
	                            Rectangle {
	                                width: parent.width
	                                height: 60
	                                color: itemMouse.containsMouse ? '#ecf0f1' : 'white'
	                                
	                                Text {
	                                    text: modelData
	                                    anchors.left: parent.left
	                                    anchors.leftMargin: 20
	                                    anchors.verticalCenter: parent.verticalCenter
	                                    font.pointSize: 14
	                                }
	                                
	                                MouseArea {
	                                    id: itemMouse
	                                    anchors.fill: parent
	                                    hoverEnabled: true
	                                    onClicked: {
	                                        contentText.text = modelData + ' Screen'
	                                        drawer.visible = false
	                                    }
	                                }
	                            }
	                        }
	                    }
	                }
	                
	                // Overlay when drawer is open
	                Rectangle {
	                    anchors.fill: parent
	                    color: '#000000'
	                    opacity: drawer.visible ? 0.5 : 0
	                    visible: opacity > 0
	                    z: 2
	                    
	                    Behavior on opacity {
	                        NumberAnimation { duration: 250 }
	                    }
	                    
	                    MouseArea {
	                        anchors.fill: parent
	                        onClicked: drawer.visible = false
	                    }
	                }
	            }
	        }
	    "
	
	#--> Drawer pattern is essential for mobile apps
	#--> Overlay dims background when drawer is open
	#--> Smooth animations create polished feel
	

#===============================================#
#   SECTION 10: COMPLETE APPLICATION EXAMPLE    #
#===============================================#

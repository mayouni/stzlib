# Narrative
# --------
# Sample 13.2: Popup and ToolTip
#
# Extracted from stzringqmltest.ring, block #39.

load "../../stzBase.ring"

pr()

# Use case: Contextual information and actions

	new qApp {
	    oQML = new RingQML(NULL) {
	        loadContent(QML_13_2())
	    }
	    exec()
	}
	
	func QML_13_2
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 500
	            height: 480
	            title: 'Popup & ToolTip'
	            
	            Column {
	                anchors.centerIn: parent
	                spacing: 30
	                
	                Text {
	                    text: 'Popup Examples'
	                    font.pointSize: 16
	                    font.bold: true
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	                
	                Row {
	                    spacing: 15
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    
	                    Button {
	                        text: 'Show Menu Popup'
	                        font.pointSize: 12
	                        onClicked: menuPopup.open()
	                        
	                        ToolTip.visible: hovered
	                        ToolTip.text: 'Click to open menu'
	                        ToolTip.delay: 500
	                    }
	                    
	                    Button {
	                        text: 'Show Notification'
	                        font.pointSize: 12
	                        onClicked: notificationPopup.open()
	                        
	                        ToolTip.visible: hovered
	                        ToolTip.text: 'Show a notification popup'
	                        ToolTip.delay: 500
	                    }
	                }
	                
	                Row {
	                    spacing: 10
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    
	                    Rectangle {
	                        width: 40
	                        height: 40
	                        color: '#3498db'
	                        radius: 20
	                        
	                        Text {
	                            text: '?'
	                            color: 'white'
	                            font.pointSize: 20
	                            anchors.centerIn: parent
	                        }
	                        
	                        ToolTip {
	                            visible: helpMouse.containsMouse
	                            text: 'This is a help icon\nHover to see this tooltip'
	                            delay: 200
	                        }
	                        
	                        MouseArea {
	                            id: helpMouse
	                            anchors.fill: parent
	                            hoverEnabled: true
	                        }
	                    }
	                    
	                    Rectangle {
	                        width: 40
	                        height: 40
	                        color: '#e74c3c'
	                        radius: 20
	                        
	                        Text {
	                            text: '!'
	                            color: 'white'
	                            font.pointSize: 20
	                            anchors.centerIn: parent
	                        }
	                        
	                        ToolTip {
	                            visible: warnMouse.containsMouse
	                            text: 'Warning: Be careful!'
	                            delay: 200
	                        }
	                        
	                        MouseArea {
	                            id: warnMouse
	                            anchors.fill: parent
	                            hoverEnabled: true
	                        }
	                    }
	                    
	                    Rectangle {
	                        width: 40
	                        height: 40
	                        color: '#27ae60'
	                        radius: 20
	                        
	                        Text {
	                            text: 'i'
	                            color: 'white'
	                            font.pointSize: 20
	                            anchors.centerIn: parent
	                        }
	                        
	                        ToolTip {
	                            visible: infoMouse.containsMouse
	                            text: 'Information available here'
	                            delay: 200
	                        }
	                        
	                        MouseArea {
	                            id: infoMouse
	                            anchors.fill: parent
	                            hoverEnabled: true
	                        }
	                    }
	                }
	            }
	            
	            Popup {
	                id: menuPopup
	                x: (parent.width - width) / 2
	                y: (parent.height - height) / 2
	                width: 200
	                height: 210
	                modal: true
	                focus: true
	                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
	                
	                Column {
	                    anchors.fill: parent
	                    spacing: 0
	                    
	                    Rectangle {
	                        width: parent.width
	                        height: 40
	                        color: '#34495e'
	                        
	                        Text {
	                            text: 'Menu Options'
	                            color: 'white'
	                            font.pointSize: 12
	                            font.bold: true
	                            anchors.centerIn: parent
	                        }
	                    }
	                    
	                    Repeater {
	                        model: ['Profile', 'Settings', 'Logout']
	                        
	                        Rectangle {
	                            width: parent.width
	                            height: 50
	                            color: itemMouse.containsMouse ? '#ecf0f1' : 'white'
	                            
	                            Text {
	                                text: modelData
	                                font.pointSize: 11
	                                anchors.centerIn: parent
	                            }
	                            
	                            MouseArea {
	                                id: itemMouse
	                                anchors.fill: parent
	                                hoverEnabled: true
	                                onClicked: {
	                                    console.log('Clicked:', modelData)
	                                    menuPopup.close()
	                                }
	                            }
	                            
	                            Rectangle {
	                                width: parent.width
	                                height: 1
	                                color: '#ecf0f1'
	                                anchors.bottom: parent.bottom
	                            }
	                        }
	                    }
	                }
	            }
	            
	            Popup {
	                id: notificationPopup
	                x: parent.width - width - 20
	                y: 20
	                width: 280
	                height: 100
	                modal: false
	                closePolicy: Popup.CloseOnEscape
	                
	                Rectangle {
	                    anchors.fill: parent
	                    color: '#27ae60'
	                    radius: 10
	                    
	                    Row {
	                        anchors.fill: parent
	                        anchors.margins: 15
	                        spacing: 15
	                        
	                        Text {
	                            text: '✓'
	                            color: 'white'
	                            font.pointSize: 30
	                            anchors.verticalCenter: parent.verticalCenter
	                        }
	                        
	                        Column {
	                            anchors.verticalCenter: parent.verticalCenter
	                            spacing: 5
	                            
	                            Text {
	                                text: 'Success!'
	                                color: 'white'
	                                font.pointSize: 14
	                                font.bold: true
	                            }
	                            
	                            Text {
	                                text: 'Operation completed'
	                                color: 'white'
	                                font.pointSize: 10
	                            }
	                        }
	                    }
	                }
	                
	                Timer {
	                    interval: 3000
	                    running: notificationPopup.visible
	                    onTriggered: notificationPopup.close()
	                }
	            }
	        }
	    "
	
	#--> Popup for custom overlays
	#--> ToolTip shows contextual help on hover
	#--> Non-modal popups for notifications


#========================================#
#   SECTION 14: DATA VISUALIZATION       #
#========================================#

pf()

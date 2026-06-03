# Narrative
# --------
# Sample 15.2: Bottom Sheet
#
# Extracted from stzringqmltest.ring, block #45.
#ERR Error (R11) : Error in class name, class not found: qapp

load "../../stzBase.ring"

pr()

# Use case: Modal content from bottom


	new qApp {
	    oQML = new RingQML(NULL) {
	        loadContent(QML_15_2())
	    }
	    exec()
	}
	
	func QML_15_2
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 700
	            title: 'Bottom Sheet'
	            
	            Rectangle {
	                anchors.fill: parent
	                color: '#ecf0f1'
	                
	                Column {
	                    anchors.centerIn: parent
	                    spacing: 20
	                    
	                    Text {
	                        text: 'Bottom Sheet Demo'
	                        font.pointSize: 18
	                        font.bold: true
	                        anchors.horizontalCenter: parent.horizontalCenter
	                    }
	                    
	                    Button {
	                        text: 'Show Options'
	                        font.pointSize: 13
	                        anchors.horizontalCenter: parent.horizontalCenter
	                        onClicked: bottomSheet.open()
	                    }
	                    
	                    Button {
	                        text: 'Show Share Sheet'
	                        font.pointSize: 13
	                        anchors.horizontalCenter: parent.horizontalCenter
	                        onClicked: shareSheet.open()
	                    }
	                }
	                
	                Rectangle {
	                    id: overlay
	                    anchors.fill: parent
	                    color: '#000000'
	                    opacity: bottomSheet.visible ? 0.5 : 0
	                    visible: opacity > 0
	                    
	                    Behavior on opacity {
	                        NumberAnimation { duration: 300 }
	                    }
	                    
	                    MouseArea {
	                        anchors.fill: parent
	                        onClicked: {
	                            bottomSheet.close()
	                            shareSheet.close()
	                        }
	                    }
	                }
	                
	                Rectangle {
	                    id: bottomSheet
	                    width: parent.width
	                    height: 300
	                    anchors.bottom: parent.bottom
	                    anchors.bottomMargin: visible ? 0 : -height
	                    color: 'white'
	                    radius: 20
	                    visible: false
	                    
	                    function open() {
	                        visible = true
	                    }
	                    
	                    function close() {
	                        visible = false
	                    }
	                    
	                    Behavior on anchors.bottomMargin {
	                        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
	                    }
	                    
	                    Column {
	                        anchors.fill: parent
	                        
	                        Rectangle {
	                            width: 40
	                            height: 5
	                            color: '#bdc3c7'
	                            radius: 2.5
	                            anchors.horizontalCenter: parent.horizontalCenter
	                            anchors.topMargin: 10
	                            y: 10
	                        }
	                        
	                        Text {
	                            text: 'Options'
	                            font.pointSize: 16
	                            font.bold: true
	                            anchors.horizontalCenter: parent.horizontalCenter
	                            topPadding: 30
	                        }
	                        
	                        Column {
	                            width: parent.width
	                            topPadding: 20
	                            
	                            Repeater {
	                                model: ['Edit', 'Share', 'Delete', 'Archive', 'Cancel']
	                                
	                                Rectangle {
	                                    width: parent.width
	                                    height: 50
	                                    color: optionMouse.containsMouse ? '#f8f9fa' : 'white'
	                                    
	                                    Text {
	                                        text: modelData
	                                        font.pointSize: 13
	                                        anchors.centerIn: parent
	                                        color: modelData === 'Delete' ? '#e74c3c' : '#2c3e50'
	                                    }
	                                    
	                                    MouseArea {
	                                        id: optionMouse
	                                        anchors.fill: parent
	                                        hoverEnabled: true
	                                        onClicked: {
	                                            console.log('Selected:', modelData)
	                                            bottomSheet.close()
	                                        }
	                                    }
	                                }
	                            }
	                        }
	                    }
	                }
	                
	                Rectangle {
	                    id: shareSheet
	                    width: parent.width
	                    height: 250
	                    anchors.bottom: parent.bottom
	                    anchors.bottomMargin: visible ? 0 : -height
	                    color: 'white'
	                    radius: 20
	                    visible: false
	                    
	                    function open() {
	                        visible = true
	                    }
	                    
	                    function close() {
	                        visible = false
	                    }
	                    
	                    Behavior on anchors.bottomMargin {
	                        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
	                    }
	                    
	                    Column {
	                        anchors.fill: parent
	                        anchors.margins: 20
	                        spacing: 20
	                        
	                        Text {
	                            text: 'Share via'
	                            font.pointSize: 16
	                            font.bold: true
	                        }
	                        
	                        GridView {
	                            width: parent.width
	                            height: 150
	                            cellWidth: 80
	                            cellHeight: 80
	                            
	                            model: ListModel {
	                                ListElement { name: 'Messages'; emoji: '💬' }
	                                ListElement { name: 'Email'; emoji: '📧' }
	                                ListElement { name: 'Copy'; emoji: '📋' }
	                                ListElement { name: 'More'; emoji: '⋯' }
	                            }
	                            
	                            delegate: Column {
	                                spacing: 5
	                                
	                                Rectangle {
	                                    width: 50
	                                    height: 50
	                                    color: '#ecf0f1'
	                                    radius: 25
	                                    anchors.horizontalCenter: parent.horizontalCenter
	                                    
	                                    Text {
	                                        text: emoji
	                                        font.pointSize: 24
	                                        anchors.centerIn: parent
	                                    }
	                                    
	                                    MouseArea {
	                                        anchors.fill: parent
	                                        onClicked: {
	                                            console.log('Share via:', name)
	                                            shareSheet.close()
	                                        }
	                                    }
	                                }
	                                
	                                Text {
	                                    text: name
	                                    font.pointSize: 10
	                                    anchors.horizontalCenter: parent.horizontalCenter
	                                }
	                            }
	                        }
	                    }
	                }
	            }
	        }
	    "
	
	#--> Bottom sheet modal pattern
	#--> Slide-up animation
	#--> Overlay dimming

pf()

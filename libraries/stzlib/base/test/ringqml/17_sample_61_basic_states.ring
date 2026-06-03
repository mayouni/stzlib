# Narrative
# --------
# Sample 6.1: Basic States
#
# Extracted from stzringqmltest.ring, block #17.
#ERR Error (R11) : Error in class name, class not found: qapp

load "../../stzBase.ring"

pr()

# Use case: Managing different UI configurations


	new qApp {
	        oQML = new RingQML(NULL) {
	            loadContent(QML_6_1())
	        }
	        exec()
	    }
	
	func QML_6_1
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 300
	            title: 'States'
	            
	            Rectangle {
	                id: statusCard
	                width: 350
	                height: 150
	                color: 'white'
	                radius: 10
	                border.width: 2
	                anchors.centerIn: parent
	                
	                state: 'normal'
	                
	                states: [
	                    State {
	                        name: 'normal'
	                        PropertyChanges {
	                            target: statusCard
	                            border.color: '#3498db'
	                        }
	                        PropertyChanges {
	                            target: statusText
	                            text: 'Normal Status'
	                            color: '#3498db'
	                        }
	                    },
	                    State {
	                        name: 'warning'
	                        PropertyChanges {
	                            target: statusCard
	                            border.color: '#27ae60'
	                        }
	                        PropertyChanges {
	                            target: statusText
	                            text: 'Warning Status'
	                            color: '#27ae60'
	                        }
	                    },
	                    State {
	                        name: 'error'
	                        PropertyChanges {
	                            target: statusCard
	                            border.color: '#e74c3c'
	                        }
	                        PropertyChanges {
	                            target: statusText
	                            text: 'Error Status'
	                            color: '#e74c3c'
	                        }
	                    }
	                ]
	                
	                transitions: [
	                    Transition {
	                        ColorAnimation { duration: 300 }
	                    }
	                ]
	                
	                Column {
	                    anchors.centerIn: parent
	                    spacing: 20
	                    
	                    Text {
	                        id: statusText
	                        font.pointSize: 16
	                        font.bold: true
	                        anchors.horizontalCenter: parent.horizontalCenter
	                    }
	                    
	                    Row {
	                        spacing: 10
	                        anchors.horizontalCenter: parent.horizontalCenter
	                        
	                        Button {
	                            text: 'Normal'
				    font.pointSize: 12
	                            onClicked: statusCard.state = 'normal'
	                        }
	                        Button {
	                            text: 'Warning'
				    font.pointSize: 12
	                            onClicked: statusCard.state = 'warning'
	                        }
	                        Button {
	                            text: 'Error'
				    font.pointSize: 12
	                            onClicked: statusCard.state = 'error'
	                        }
	                    }
	                }
	            }
	        }
	    "
	
	#--> States define different UI configurations
	#--> Transitions animate between states automatically
	#--> Clean way to manage complex UI variations

pf()

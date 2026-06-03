# Narrative
# --------
# Sample 2.4: Adaptive Layout - Mobile & Desktop Ready
#
# Extracted from stzringqmltest.ring, block #7.
#ERR Error (R11) : Error in class name, class not found: qapp

load "../../stzBase.ring"

pr()

# Use case: Responsive design based on window dimensions

	new qApp {
	        oQML = new RingQML(NULL) {
	            loadContent(QML_2_4())
	        }
	        exec()
	}

	func QML_2_4
	    return "
	        import QtQuick 2.15
	        import QtQuick.Window 2.15

	        Window {
	            visible: true
	            width: 600
	            height: 400
	            title: 'Adaptive Layout - Resize Window to See Magic!'

	            Rectangle {
	                anchors.fill: parent
	                color: '#ecf0f1'

	                // Dynamic layout based on width
	                Item {
	                    anchors.fill: parent
	                    
	                    Column {
	                        anchors.centerIn: parent
	                        spacing: 15
	                        visible: parent.width < 400
	                        
	                        Rectangle {
	                            width: 250
	                            height: 80
	                            color: '#e74c3c'
	                            radius: 5
	                            Text {
	                                text: 'Mobile Layout'
	                                color: 'white'
	                                font.pointSize: 16
	                                anchors.centerIn: parent
	                            }
	                        }
	                        
	                        Text {
	                            text: 'Vertical Stack\nfor Narrow Screens'
	                            font.pointSize: 14
	                            horizontalAlignment: Text.AlignHCenter
	                            anchors.horizontalCenter: parent.horizontalCenter
	                        }
	                    }
	                    
	                    Row {
	                        anchors.centerIn: parent
	                        spacing: 20
	                        visible: parent.width >= 400
	                        
	                        Rectangle {
	                            width: 150
	                            height: 100
	                            color: '#3498db'
	                            radius: 5
	                            Text {
	                                text: 'Desktop'
	                                color: 'white'
	                                font.pointSize: 16
	                                anchors.centerIn: parent
	                            }
	                        }

	                        Rectangle {
	                            width: 170
	                            height: 100
	                            color: '#27ae60'
	                            radius: 5
	                            Text {
	                                text: 'Wide Screen'
	                                color: 'white'
	                                font.pointSize: 16
	                                anchors.centerIn: parent
	                            }
	                        }
	                        
	                        Text {
	                            text: 'Horizontal Layout\nfor Wide Screens'
	                            font.pointSize: 14
	                            anchors.verticalCenter: parent.verticalCenter
	                        }
	                    }
	                }
	                
	                // Width indicator
	                Text {
	                    text: 'Width: ' + Math.round(parent.width) + 'px'
	                    anchors.bottom: parent.bottom
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    anchors.bottomMargin: 20
	                    font.pointSize: 12
	                    color: '#7f8c8d'
	                }
	            }
	        }
	    "
	
	#--> Visibility binding enables dynamic layout switching
	#--> Layout adapts based on window width
	#--> Essential pattern for mobile/desktop cross-platform apps
	#--> Resize the window to see the layout change!


#====================================#
#   SECTION 3: INTERACTIVE ELEMENTS  #
#====================================#

pf()

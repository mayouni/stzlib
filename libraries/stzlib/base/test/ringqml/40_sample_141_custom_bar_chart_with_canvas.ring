# Narrative
# --------
# Sample 14.1: Custom Bar Chart with Canvas
#
# Extracted from stzringqmltest.ring, block #40.

load "../../stzBase.ring"

# Use case: Simple data visualization

	new qApp {
	    oQML = new RingQML(NULL) {
	        loadContent(QML_14_1())
	    }
	    exec()
	}
	
	func QML_14_1
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 800
	            height: 450
	            title: 'Bar Chart Visualization'
	            
	            Column {
	                anchors.fill: parent
	                anchors.margins: 20
	                spacing: 15
	                
	                Text {
	                    text: 'Monthly Sales Report'
	                    font.pointSize: 18
	                    font.bold: true
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	                
	                ListModel {
	                    id: salesData
	                    ListElement { month: 'Jan'; value: 45 }
	                    ListElement { month: 'Feb'; value: 62 }
	                    ListElement { month: 'Mar'; value: 55 }
	                    ListElement { month: 'Apr'; value: 78 }
	                    ListElement { month: 'May'; value: 85 }
	                    ListElement { month: 'Jun'; value: 92 }
	                }
	                
	                Rectangle {
	                    width: parent.width
	                    height: 300
	                    color: 'white'
	                    border.color: '#ecf0f1'
	                    border.width: 2
	                    radius: 10
	                    
	                    Row {
	                        anchors.fill: parent
	                        anchors.margins: 30
	                        anchors.bottomMargin: 40
	                        spacing: (parent.width - 60) / (salesData.count + 1)
	                        
	                        Repeater {
	                            model: salesData
	                            
	                            Column {
	                                width: 60
	                                height: parent.height
	                                spacing: 10
	                                
	                                Item {
	                                    width: parent.width
	                                    height: parent.height - 40
	                                    
	                                    Rectangle {
	                                        id: bar
	                                        width: 50
	                                        height: (value / 100) * parent.height
	                                        anchors.bottom: parent.bottom
	                                        anchors.horizontalCenter: parent.horizontalCenter
	                                        
	                                        gradient: Gradient {
	                                            GradientStop { position: 0.0; color: '#667eea' }
	                                            GradientStop { position: 1.0; color: '#764ba2' }
	                                        }
	                                        
	                                        radius: 5
	                                        
	                                        Text {
	                                            text: value + '%'
	                                            color: 'white'
	                                            font.pointSize: 10
	                                            font.bold: true
	                                            anchors.centerIn: parent
	                                        }
	                                        
	                                        Behavior on height {
	                                            NumberAnimation { duration: 500; easing.type: Easing.OutBounce }
	                                        }
	                                    }
	                                }
	                                
	                                Text {
	                                    text: month
	                                    font.pointSize: 11
	                                    anchors.horizontalCenter: parent.horizontalCenter
	                                }
	                            }
	                        }
	                    }
	                }
	                
	                Row {
	                    spacing: 15
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    
	                    Button {
	                        text: 'Randomize Data'
	                        font.pointSize: 11
	                        onClicked: {
	                            for (var i = 0; i < salesData.count; i++) {
	                                salesData.setProperty(i, 'value', Math.random() * 100 )
	                            }
	                        }
	                    }
	                    
	                    Button {
	                        text: 'Reset Data'
	                        font.pointSize: 11
	                        onClicked: {
	                            salesData.setProperty(0, 'value', 45)
	                            salesData.setProperty(1, 'value', 62)
	                            salesData.setProperty(2, 'value', 55)
	                            salesData.setProperty(3, 'value', 78)
	                            salesData.setProperty(4, 'value', 85)
	                            salesData.setProperty(5, 'value', 92)
	                        }
	                    }
	                }
	            }
	        }
	    "
	
	#--> Custom bar chart using Rectangles
	#--> Animated data updates
	#--> Data-driven visualization

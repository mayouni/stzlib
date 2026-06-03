# Narrative
# --------
# Sample 14.3: Progress Visualizations
#
# Extracted from stzringqmltest.ring, block #42.

load "../../stzBase.ring"

pr()

# Use case: Multiple progress display styles


	new qApp {
	    oQML = new RingQML(NULL) {
	        loadContent(QML_14_3())
	    }
	    exec()
	}
	
	func QML_14_3
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 500
	            height: 600
	            title: 'Progress Visualizations'
	            
	            Column {
	                anchors.fill: parent
	                anchors.margins: 30
	                spacing: 35
	                
	                Text {
	                    text: 'Project Completion Status'
	                    font.pointSize: 18
	                    font.bold: true
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	                
	                Column {
	                    width: parent.width
	                    spacing: 20
	                    
	                    Text {
	                        text: 'Frontend Development'
	                        font.pointSize: 12
	                        font.bold: true
	                    }
	                    
	                    Rectangle {
	                        width: parent.width
	                        height: 30
	                        color: '#ecf0f1'
	                        radius: 15
	                        
	                        Rectangle {
	                            width: parent.width * 0.75
	                            height: parent.height
	                            color: '#27ae60'
	                            radius: 15
	                            
	                            Behavior on width {
	                                NumberAnimation { duration: 800; easing.type: Easing.OutCubic }
	                            }
	                            
	                            Text {
	                                text: '75%'
	                                color: 'white'
	                                font.pointSize: 11
	                                font.bold: true
	                                anchors.centerIn: parent
	                            }
	                        }
	                    }
	                }
	                
	                Column {
	                    width: parent.width
	                    spacing: 20
	                    
	                    Text {
	                        text: 'Backend API'
	                        font.pointSize: 12
	                        font.bold: true
	                    }
	                    
	                    Rectangle {
	                        width: parent.width
	                        height: 30
	                        color: '#ecf0f1'
	                        radius: 15
	                        
	                        Rectangle {
	                            width: parent.width * 0.60
	                            height: parent.height
	                            gradient: Gradient {
	                                GradientStop { position: 0.0; color: '#667eea' }
	                                GradientStop { position: 1.0; color: '#764ba2' }
	                            }
	                            radius: 15
	                            
	                            Behavior on width {
	                                NumberAnimation { duration: 800; easing.type: Easing.OutCubic }
	                            }
	                            
	                            Text {
	                                text: '60%'
	                                color: 'white'
	                                font.pointSize: 11
	                                font.bold: true
	                                anchors.centerIn: parent
	                            }
	                        }
	                    }
	                }
	                
	                Column {
	                    width: parent.width
	                    spacing: 20
	                    
	                    Text {
	                        text: 'Database Design'
	                        font.pointSize: 12
	                        font.bold: true
	                    }
	                    
	                    Rectangle {
	                        width: parent.width
	                        height: 30
	                        color: '#ecf0f1'
	                        radius: 15
	                        
	                        Rectangle {
	                            width: parent.width * 0.45
	                            height: parent.height
	                            color: '#f39c12'
	                            radius: 15
	                            
	                            Behavior on width {
	                                NumberAnimation { duration: 800; easing.type: Easing.OutCubic }
	                            }
	                            
	                            Text {
	                                text: '45%'
	                                color: 'white'
	                                font.pointSize: 11
	                                font.bold: true
	                                anchors.centerIn: parent
	                            }
	                        }
	                    }
	                }
	                
	                Row {
	                    spacing: 30
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    
	                    Column {
	                        spacing: 10
	                        
	                        Text {
	                            text: 'Overall Progress'
	                            font.pointSize: 11
	                            anchors.horizontalCenter: parent.horizontalCenter
	                        }
	                        
	                        Canvas {
	                            id: circularProgress
	                            width: 100
	                            height: 100
	                            
	                            property real progress: 0.60
	                            
	                            onPaint: {
	                                var ctx = getContext('2d')
	                                ctx.clearRect(0, 0, width, height)
	                                
	                                var centerX = width / 2
	                                var centerY = height / 2
	                                var radius = 40
	                                var lineWidth = 8
	                                
	                                ctx.beginPath()
	                                ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
	                                ctx.strokeStyle = '#ecf0f1'
	                                ctx.lineWidth = lineWidth
	                                ctx.stroke()
	                                
	                                ctx.beginPath()
	                                ctx.arc(centerX, centerY, radius, -Math.PI / 2, 
	                                       -Math.PI / 2 + (progress * 2 * Math.PI))
	                                ctx.strokeStyle = '#3498db'
	                                ctx.lineWidth = lineWidth
	                                ctx.lineCap = 'round'
	                                ctx.stroke()
	                            }
	                            
	                            Text {
	                                text: Math.round(circularProgress.progress * 100) + '%'
	                                font.pointSize: 16
	                                font.bold: true
	                                anchors.centerIn: parent
	                            }
	                        }
	                    }
	                }
	            }
	        }
	    "
	
	#--> Multiple progress bar styles
	#--> Circular progress with Canvas
	#--> Smooth animations : Resize the window to see

pf()

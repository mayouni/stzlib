# Narrative
# --------
# Sample 4.1: Gradients - Beautiful Color Transitions
#
# Extracted from stzringqmltest.ring, block #11.

load "../../../stzBase.ring"

# Use case: Linear and radial gradients

	new qApp {
		oQML = new RingQML(NULL)
		oQML.LoadContent(QML_4_1())
	
	        exec()
	}
	
	func QML_4_1
	    return "
	        import QtQuick 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 500
	            height: 400
	            title: 'Gradients'
	            
	            Row {
	                anchors.centerIn: parent
	                spacing: 20
	                
	                // Linear Gradient
	                Rectangle {
	                    width: 200
	                    height: 300
	                    radius: 10
	                    
	                    gradient: Gradient {
	                        GradientStop { position: 0.0; color: '#e74c3c' }
	                        GradientStop { position: 1.0; color: '#7b241c' }
	                    }
	                    
	                    Text {
	                        text: 'Linear\nGradient'
	                        color: 'white'
	                        font.pointSize: 16
	                        anchors.centerIn: parent
	                        horizontalAlignment: Text.AlignHCenter
	                    }
	                }
	                
	                // Radial Gradient Effect
	                Rectangle {
	                    width: 200
	                    height: 300
	                    radius: 10
	                    color: '#1b4f72'
	                    
	                    Rectangle {
	                        width: parent.width * 0.8
	                        height: parent.height * 0.8
	                        anchors.centerIn: parent
	                        radius: parent.radius
	                        gradient: Gradient {
	                            GradientStop { position: 0.0; color: '#ffffff' }
	                            GradientStop { position: 1.0; color: 'transparent' }
	                        }
	                        opacity: 0.3
	                    }
	                    
	                    Text {
	                        text: 'Radial\nEffect'
	                        color: 'white'
	                        font.pointSize: 16
	                        anchors.centerIn: parent
	                        horizontalAlignment: Text.AlignHCenter
	                    }
	                }
	            }
	        }
	    "
	
	#--> Gradients add depth and visual interest
	#--> GradientStops define color at specific positions
	#--> Modern UIs often use subtle gradients

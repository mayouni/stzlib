# Narrative
# --------
# Sample 5.2: Sequential Animation
#
# Extracted from stzringqmltest.ring, block #15.
#ERR Error (R11) : Error in class name, class not found: qapp

load "../../stzBase.ring"

pr()

# Use case: Choreographing multiple animations


	new qApp {
	        oQML = new RingQML(NULL) {
	            loadContent(QML_5_2())
	        }
	        exec()
	}

	func QML_5_2
	    return "
	        import QtQuick 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 400
	            title: 'Sequential Animation'
	            
	            Rectangle {
	                id: animBox
	                width: 60
	                height: 60
	                color: '#9b59b6'
	                radius: 30
	                x: 50
	                y: 50
	                
	                SequentialAnimation on color {
	                    loops: Animation.Infinite
	                    running: true
	                    
	                    ColorAnimation { to: '#e74c3c'; duration: 1000 }
	                    ColorAnimation { to: '#f39c12'; duration: 1000 }
	                    ColorAnimation { to: '#27ae60'; duration: 1000 }
	                    ColorAnimation { to: '#3498db'; duration: 1000 }
	                    ColorAnimation { to: '#9b59b6'; duration: 1000 }
	                }
	                
	                SequentialAnimation on scale {
	                    loops: Animation.Infinite
	                    running: true
	                    
	                    NumberAnimation { to: 1.5; duration: 1000; easing.type: Easing.InOutQuad }
	                    NumberAnimation { to: 1.0; duration: 1000; easing.type: Easing.InOutQuad }
	                }
	            }
	            
	            Text {
	                text: 'Breathing Circle'
	                anchors {
	                    horizontalCenter: parent.horizontalCenter
	                    bottom: parent.bottom
	                    bottomMargin: 40
	                }
	                font.pointSize: 14
	            }
	        }
	    "
	
	#--> SequentialAnimation chains animations
	#--> Multiple properties can animate simultaneously
	#--> Creates engaging, dynamic UIs

pf()

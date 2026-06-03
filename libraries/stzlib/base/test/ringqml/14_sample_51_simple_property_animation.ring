# Narrative
# --------
# Sample 5.1: Simple Property Animation
#
# Extracted from stzringqmltest.ring, block #14.

load "../../stzBase.ring"

# Use case: Animating position changes


	new qApp {
		oQML = new RingQML(NULL)
		oQML.LoadContent(QML_5_1())
	        exec()
	}

	func QML_5_1
	    return "
	        import QtQuick 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 500
	            height: 140
	            title: 'Property Animation'
	            
	            Rectangle {
	                id: box
	                width: 80
	                height: 80
	                color: '#e74c3c'
	                radius: 10
	                y: parent.height / 2 - height / 2
	                
	                Text {
	                    text: '→'
	                    color: 'white'
	                    font.pointSize: 24
	                    anchors.centerIn: parent
	                }
	                
	                // Continuous back-and-forth animation
	                SequentialAnimation on x {
	                    loops: Animation.Infinite
	                    running: true
	                    
	                    NumberAnimation {
	                        from: 50
	                        to: 370
	                        duration: 2000
	                        easing.type: Easing.InOutQuad
	                    }
	                    
	                    NumberAnimation {
	                        from: 370
	                        to: 50
	                        duration: 2000
	                        easing.type: Easing.InOutQuad
	                    }
	                }
	            }
	        }
	    "
	
	#--> SequentialAnimation creates back-and-forth motion
	#--> Easing functions control animation feel
	#--> Animations make UIs feel alive and responsive

# Narrative
# --------
# Sample 5.3: Rotation Animation
#
# Extracted from stzringqmltest.ring, block #16.
#ERR Error (R11) : Error in class name, class not found: qapp

load "../../stzBase.ring"

pr()

# Use case: Rotating elements smoothly


	new qApp {
	        oQML = new RingQML(NULL) {
	            loadContent(QML_5_3())
	        }
	        exec()
	}

	func QML_5_3
	    return "
	        import QtQuick 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 300
	            title: 'Rotation Animation'
	            
	            Rectangle {
	                width: 120
	                height: 120
	                color: 'transparent'
	                anchors.centerIn: parent
	                
	                Rectangle {
	                    width: 100
	                    height: 100
	                    color: '#3498db'
	                    radius: 10
	                    anchors.centerIn: parent
	                    
	                    RotationAnimation on rotation {
	                        from: 0
	                        to: 360
	                        duration: 2000
	                        loops: Animation.Infinite
	                        running: true
	                    }
	                    
	                    Text {
	                        text: '⚙'
	                        color: 'white'
	                        font.pointSize: 40
	                        anchors.centerIn: parent
	                    }
	                }
	            }
	        }
	    "
	
	#--> RotationAnimation rotates around element center
	#--> Perfect for loading indicators, spinners
	#--> Continuous rotation with loops: Animation.Infinite


#=====================================#
#   SECTION 6: STATES & TRANSITIONS   #
#=====================================#

pf()

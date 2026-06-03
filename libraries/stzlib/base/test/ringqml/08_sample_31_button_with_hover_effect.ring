# Narrative
# --------
# Sample 3.1: Button with Hover Effect
#
# Extracted from stzringqmltest.ring, block #8.
#ERR Error (R11) : Error in class name, class not found: qapp

load "../../stzBase.ring"

pr()

# Use case: Interactive visual feedback

	new qApp {
	    oQML = new RingQML(NULL)
	    oQML.LoadContent(QML_3_1())
	
	    exec()
	}
	
	func QML_3_1
	    return "
	        import QtQuick 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 300
	            title: 'Interactive Button'
	            
	            Rectangle {
	                id: button
	                width: 200
	                height: 60
	                color: mouseArea.containsMouse ? '#0b3c5d' : '#3498db'
	                radius: 8
	                anchors.centerIn: parent
	                
	                // Smooth color transition
	                Behavior on color {
	                    ColorAnimation { duration: 200 }
	                }
	                
	                Text {
	                    text: 'Hover Over Me'
	                    color: 'white'
	                    font.pointSize: 14
	                    anchors.centerIn: parent
	                }
	                
	                MouseArea {
	                    id: mouseArea
	                    anchors.fill: parent
	                    hoverEnabled: true
	                    cursorShape: Qt.PointingHandCursor
	                }
	            }
	        }
	    "
	
	#--> MouseArea detects user interaction
	#--> hoverEnabled allows hover state detection
	#--> Behavior on color creates smooth transitions

pf()

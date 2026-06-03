# Narrative
# --------
# Sample 1.3: Anchoring System - Relative Positioning
#
# Extracted from stzringqmltest.ring, block #3.

load "../../stzBase.ring"

pr()

# Use case: How QML handles layout without hardcoded positions

	new qApp {
		oQML = new RingQML(NULL)
		oQML.LoadContent(QML_1_3())
	
	        exec()
	}
	
	func QML_1_3
	    return "
	        import QtQuick 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 480
	            height: 300
	            title: 'Anchoring System'
	            color: '#ecf0f1'
	
	            Rectangle {
	                id: topBar
	                width: parent.width
	                height: 60
	                color: '#2c3e50'
	                anchors.top: parent.top
	                
	                Text {
	                    text: 'Top Bar'
	                    color: 'white'
			    font.pointSize: 16
	                    anchors.centerIn: parent
	                }
	            }
	            
	            Rectangle {
	                id: content
	                anchors {
	                    top: topBar.bottom
	                    left: parent.left
	                    right: parent.right
	                    bottom: parent.bottom
	                }
	                color: 'white'
	                
	                Text {
	                    text: 'Content Area - Fills Remaining Space'
			    font.pointSize: 16
	                    anchors.centerIn: parent
	                }
	            }
	        }
	    "
	
	#--> Anchoring creates responsive layouts that adapt to window size
	#--> Elements position themselves relative to parents and siblings
	#--> Resize the window to see how the elements adjust!


#===============================#
#   SECTION 2: LAYOUT MASTERY   #
#===============================#

pf()

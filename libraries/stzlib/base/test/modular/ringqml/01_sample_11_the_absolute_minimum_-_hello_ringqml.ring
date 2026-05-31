# Narrative
# --------
# Sample 1.1: The Absolute Minimum - Hello RingQML
#
# Extracted from stzringqmltest.ring, block #1.

load "../../../stzBase.ring"

# Use case: Basic structure, Window creation, Text display
*/
	new qApp {
		oQML = new RingQML(NULL)
		oQML.LoadContent(QML_1_1())
	
	        exec()
	}
	
	func QML_1_1
	    return "
	        import QtQuick 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 450
	            height: 300
	            title: 'Hello RingQML'
	            
	            Text {
	                text: 'Welcome to RingQML!'
	                font.pointSize: 24
	                anchors.centerIn: parent
	            }
	        }
	    "
	
	#--> A window appears with centered text
	#--> This is the minimal template for any RingQML application

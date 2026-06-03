# Narrative
# --------
# Sample 1.2: Understanding the Rectangle - The Building Block
#
# Extracted from stzringqmltest.ring, block #2.

load "../../stzBase.ring"

pr()

# Use case: Rectangle properties, color, dimensions

	new qApp {
	        oQML = new RingQML(NULL) {
	            loadContent(QML_1_2())
	        }
	        exec()
	}
	
	func QML_1_2
	    return "
	        import QtQuick 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 300
	            title: 'The Rectangle - QML Building Block'
	            
	            Rectangle {
	                width: 280
	                height: 150
	                color: '#21618c'
	                anchors.centerIn: parent
	                
	                Text {
	                    text: 'I am inside a Rectangle'
	                    color: 'white'
	                    font.pointSize: 14
	                    anchors.centerIn: parent
	                }
	            }
	        }
	    "
	
	#--> Rectangles are QML's most versatile visual element
	#--> They can contain other elements and serve as containers

pf()

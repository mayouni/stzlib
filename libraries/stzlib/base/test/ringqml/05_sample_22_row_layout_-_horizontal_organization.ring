# Narrative
# --------
# Sample 2.2: Row Layout - Horizontal Organization
#
# Extracted from stzringqmltest.ring, block #5.
#ERR Error (R11) : Error in class name, class not found: qapp

load "../../stzBase.ring"

pr()

# Use case: Horizontal arrangement of elements

	new qApp {
		oQML = new RingQML(NULL)
		oQML.LoadContent(QML_2_2())
	
	        exec()
	}
	
	func QML_2_2
	    return "
	        import QtQuick 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 500
	            height: 300
	            title: 'Row Layout'
	            
	            Row {
	                anchors.centerIn: parent
	                spacing: 10
	                
	                Rectangle {
	                    width: 80
	                    height: 80
	                    color: '#9b59b6'
	                    radius: 40
	                }
	                
	                Rectangle {
	                    width: 80
	                    height: 80
	                    color: '#3498db'
	                    radius: 40
	                }
	                
	                Rectangle {
	                    width: 80
	                    height: 80
	                    color: '#1abc9c'
	                    radius: 40
	                }
	            }
	        }
	    "
	
	#--> Row arranges children horizontally
	#--> Perfect for toolbars, button groups, navigation

pf()

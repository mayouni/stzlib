# Narrative
# --------
# Sample 2.1: Column Layout - Vertical Organization
#
# Extracted from stzringqmltest.ring, block #4.

load "../../../stzBase.ring"

# Use case: Automatic vertical stacking with spacing

	new qApp {
		oQML = new RingQML(NULL)
		oQML.LoadContent(QML_2_1())
	
	        exec()
	}
	
	func QML_2_1
	    return "
	        import QtQuick 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 400
	            title: 'Column Layout'
	            
	            Column {
	                anchors.centerIn: parent
	                spacing: 15
	                
	                Rectangle {
	                    width: 200
	                    height: 60
	                    color: '#e74c3c'
	                    radius: 5
	                    
	                    Text {
	                        text: 'First Item'
	                        color: 'white'
				font.pointSize: 16
	                        anchors.centerIn: parent
	                    }
	                }
	                
	                Rectangle {
	                    width: 200
	                    height: 60
	                    color: '#f39c12'
	                    radius: 5
	                    
	                    Text {
	                        text: 'Second Item'
	                        color: 'white'
				font.pointSize: 16
	                        anchors.centerIn: parent
	                    }
	                }
	                
	                Rectangle {
	                    width: 200
	                    height: 60
	                    color: '#27ae60'
	                    radius: 5
	                    
	                    Text {
	                        text: 'Third Item'
	                        color: 'white'
				font.pointSize: 16
	                        anchors.centerIn: parent
	                    }
	                }
	            }
	        }
	    "
	
	#--> Column automatically arranges children vertically
	#--> Spacing property controls the gap between elements

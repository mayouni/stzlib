# Narrative
# --------
# Sample 2.3: Grid Layout - Two-Dimensional Organization
#
# Extracted from stzringqmltest.ring, block #6.

load "../../stzBase.ring"

pr()

# Use case: Grid for structured 2D layouts

	new qApp {
		oQML = new RingQML(NULL)
		oQML.LoadContent(QML_2_3())
	
	        exec()
	}
	
	func QML_2_3
	    return "
	        import QtQuick 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 400
	            title: 'Grid Layout'
	            
	            Grid {
	                anchors.centerIn: parent
	                columns: 3
	                spacing: 10
	                
	                Repeater {
	                    model: 9
	                    
	                    Rectangle {
	                        width: 80
	                        height: 80
	                        color: Qt.hsla((index * 40) / 360, 0.7, 0.6, 1.0)
	                        radius: 5
	                        
	                        Text {
	                            text: (index + 1).toString()
	                            color: 'white'
	                            font.pointSize: 20
	                            anchors.centerIn: parent
	                        }
	                    }
	                }
	            }
	        }
	    "
	
	#--> Grid with columns property creates structured layouts
	#--> Repeater generates multiple elements from a model
	#--> Ideal for dashboards, calculators, image galleries

pf()

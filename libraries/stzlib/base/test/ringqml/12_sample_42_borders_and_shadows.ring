# Narrative
# --------
# Sample 4.2: Borders and Shadows
#
# Extracted from stzringqmltest.ring, block #12.
#ERR Error (R11) : Error in class name, class not found: qapp

load "../../stzBase.ring"

pr()

# Use case: Visual depth and emphasis

	new qApp {
		oQML = new RingQML(NULL)
		oQML.loadContent(QML_4_2())
	
	        exec()
	}
	
	func QML_4_2
	    return "
	        import QtQuick 2.15
	        import QtQuick.Window 2.15
	        import QtGraphicalEffects 1.15
	        
	        Window {
	            visible: true
	            width: 500
	            height: 300
	            title: 'Borders and Shadows'
	            color: '#ecf0f1'
	            
	            Row {
	                anchors.centerIn: parent
	                spacing: 30
	                
	                // Card with Border
	                Rectangle {
	                    width: 180
	                    height: 200
	                    color: 'white'
	                    radius: 10
	                    border.color: '#3498db'
	                    border.width: 2
	                    
	                    Text {
	                        text: 'Border\nCard'
	                        anchors.centerIn: parent
	                        horizontalAlignment: Text.AlignHCenter
	                        font.pointSize: 14
	                    }
	                }
	                
	                // Card with Shadow
	                Rectangle {
	                    id: shadowCard
	                    width: 180
	                    height: 200
	                    color: 'white'
	                    radius: 10
	                    
	                    layer.enabled: true
	                    layer.effect: DropShadow {
	                        transparentBorder: true
	                        radius: 8.0
	                        samples: 17
	                        color: '#80000000'
	                        verticalOffset: 3
	                    }
	                    
	                    Text {
	                        text: 'Shadow\nCard'
	                        anchors.centerIn: parent
	                        horizontalAlignment: Text.AlignHCenter
	                        font.pointSize: 14
	                    }
	                }
	            }
	        }
	    "
	
	#--> Borders add clear visual boundaries
	#--> DropShadow creates depth perception
	#--> Essential for card-based and modern material design

pf()

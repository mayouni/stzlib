# Narrative
# --------
# Sample 3.3: Slider Control
#
# Extracted from stzringqmltest.ring, block #10.
#ERR Error (R11) : Error in class name, class not found: qapp

load "../../stzBase.ring"

pr()

# Use case: Range input and value binding


	new qApp {
		oQML = new RingQML(NULL)
		oQML.LoadContent(QML_3_3())
	
	        exec()
	}

	func QML_3_3
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 400
	            title: 'Slider Control'
	            
	            Column {
	                anchors.centerIn: parent
	                spacing: 30
	                
	                Text {
	                    text: 'Adjust Rectangle Size'
	                    font.pointSize: 14
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	                
	                Slider {
	                    id: sizeSlider
	                    from: 50
	                    to: 200
	                    value: 100
	                    width: 300
	                }
	                
	                Rectangle {
	                    width: sizeSlider.value
	                    height: sizeSlider.value
	                    color: '#e74c3c'
	                    radius: 10
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    
	                    // Smooth size transition
	                    Behavior on width {
	                        NumberAnimation { duration: 100 }
	                    }
	                    Behavior on height {
	                        NumberAnimation { duration: 100 }
	                    }
	                    
	                    Text {
	                        text: Math.round(sizeSlider.value) + 'px'
	                        color: 'white'
	                        font.pointSize: 12
	                        anchors.centerIn: parent
	                    }
	                }
	            }
	        }
	    "
	
	#--> Slider provides range input
	#--> Direct binding (sizeSlider.value) updates rectangle size
	#--> Behavior adds smooth animation to changes


#==============================#
#   SECTION 4: VISUAL DESIGN   #
#==============================#

pf()

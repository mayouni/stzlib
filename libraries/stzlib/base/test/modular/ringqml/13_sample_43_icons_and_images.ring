# Narrative
# --------
# Sample 4.3: Icons and Images
#
# Extracted from stzringqmltest.ring, block #13.

load "../../../stzBase.ring"

# Use case: Visual elements beyond basic shapes


	new qApp {
		oQML = new RingQML(NULL)
		oQML.LoadContent(QML_4_3())

		exec()
	}

	func QML_4_3
	    return "
	        import QtQuick 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 520
	            height: 300
	            title: 'Visual Elements'
	            
	            Column {
	                anchors.centerIn: parent
	                spacing: 20
	                
	                // Icon using Unicode
	                Text {
	                    text: '★ ♥ ⚙ ✓ ⚠'
	                    font.pointSize: 40
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	                
	                // Emoji support
	                Text {
	                    text: '🎨 🚀 💡 🎯 ✨'
	                    font.pointSize: 30
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	                
	                Text {
	                    text: 'QML supports Unicode symbols and emoji!'
	                    font.pointSize: 14
	                    color: '#5f6a6a'
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	            }
	        }
	    "
	
	#--> QML has excellent Unicode and emoji support
	#--> Great for icons without external image files
	#--> For complex icons, use SVG or icon fonts


#====================================#
#   SECTION 5: ANIMATIONS & MOTION   #
#====================================#

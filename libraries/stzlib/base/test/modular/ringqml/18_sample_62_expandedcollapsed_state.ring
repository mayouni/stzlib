# Narrative
# --------
# Sample 6.2: Expanded/Collapsed State
#
# Extracted from stzringqmltest.ring, block #18.

load "../../../stzBase.ring"

# Use case: Toggling UI sections


	new qApp {
	        oQML = new RingQML(NULL) {
	            loadContent(QML_6_2())
	        }
	        exec()
	}
	
	func QML_6_2
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 400
	            title: 'Expand/Collapse'
	            
	            Rectangle {
	                id: panel
	                width: 300
	                height: collapsed ? 60 : 250
	                color: '#ecf0f1'
	                radius: 8
	                border.color: '#bdc3c7'
	                border.width: 1
	                anchors.centerIn: parent
	                
	                property bool collapsed: true
	                
	                Behavior on height {
	                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
	                }
	                
	                Column {
	                    anchors.fill: parent
	                    anchors.margins: 10
	                    spacing: 10
	                    
	                    Rectangle {
	                        width: parent.width
	                        height: 40
	                        color: 'transparent'
	                        
	                        Text {
	                            text: 'Panel Title'
	                            font.pointSize: 14
	                            font.bold: true
	                            anchors.left: parent.left
	                            anchors.verticalCenter: parent.verticalCenter
	                        }
	                        
	                        Button {
	                            text: panel.collapsed ? '▼' : '▲'
	                            anchors.right: parent.right
	                            anchors.verticalCenter: parent.verticalCenter
	                            onClicked: panel.collapsed = !panel.collapsed
	                        }
	                    }
	                    
	                    Rectangle {
	                        width: parent.width
	                        height: 170
	                        color: 'white'
	                        radius: 5
	                        visible: !panel.collapsed
	                        
	                        Text {
	                            text: 'Panel Content\n\nThis content is hidden\nwhen collapsed.'
				    font.pointSize: 14
	                            anchors.centerIn: parent
	                            horizontalAlignment: Text.AlignHCenter
	                        }
	                    }
	                }
	            }
	        }
	    "
	
	#--> Property binding controls visibility and size
	#--> Behavior animates property changes automatically
	#--> Common pattern for accordion UIs, collapsible panels


#=========================================#
#   SECTION 7: RING ↔ QML COMMUNICATION   #
#=========================================#

# Narrative
# --------
# Sample 12.2: GridView with Cards
#
# Extracted from stzringqmltest.ring, block #35.

load "../../../stzBase.ring"

# Use case: Grid layout of items (photo gallery, products)
#TODO Adjust the offset after the bar title


	new qApp {
	    oQML = new RingQML(NULL) {
	        loadContent(QML_12_2())
	    }
	    exec()
	}
	
	func QML_12_2
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 550
	            height: 600
	            title: 'Product Grid'
	            
	            Column {
	                anchors.fill: parent
	                
	                Rectangle {
	                    width: parent.width
	                    height: 60
	                    color: '#2c3e50'
	                    
	                    Text {
	                        text: 'Product Catalog'
	                        color: 'white'
	                        font.pointSize: 18
	                        font.bold: true
	                        anchors.centerIn: parent
	                    }
	                }
	                
	                GridView {
	                    id: productGrid
	                    width: parent.width
	                    height: parent.height - 60
	                    cellWidth: 180
	                    cellHeight: 220
	                    clip: true
	                    
	                    model: ListModel {
	                        ListElement { name: 'Laptop Pro'; price: 1299; emoji: '💻'; rating: 5 }
	                        ListElement { name: 'Wireless Mouse'; price: 49; emoji: '🖱'; rating: 4 }
	                        ListElement { name: 'Keyboard RGB'; price: 129; emoji: '⌨'; rating: 5 }
	                        ListElement { name: 'Monitor 4K'; price: 599; emoji: '🖥'; rating: 4 }
	                        ListElement { name: 'Headphones'; price: 199; emoji: '🎧'; rating: 5 }
	                        ListElement { name: 'Webcam HD'; price: 89; emoji: '📷'; rating: 3 }
	                        ListElement { name: 'USB Hub'; price: 35; emoji: '🔌'; rating: 4 }
	                        ListElement { name: 'Desk Lamp'; price: 45; emoji: '💡'; rating: 4 }
	                        ListElement { name: 'Phone Stand'; price: 25; emoji: '📱'; rating: 5 }
	                    }
	                    
	                    delegate: Rectangle {
	                        width: productGrid.cellWidth - 10
	                        height: productGrid.cellHeight - 10
	                        color: 'white'
	                        radius: 10
	                        border.color: cardMouse.containsMouse ? '#3498db' : '#ecf0f1'
	                        border.width: 2
	                        
	                        Behavior on border.color {
	                            ColorAnimation { duration: 200 }
	                        }
	                        
	                        Column {
	                            anchors.centerIn: parent
	                            spacing: 10
	                            
	                            Text {
	                                text: emoji
	                                font.pointSize: 48
	                                anchors.horizontalCenter: parent.horizontalCenter
	                            }
	                            
	                            Text {
	                                text: name
	                                font.pointSize: 12
	                                font.bold: true
	                                anchors.horizontalCenter: parent.horizontalCenter
	                            }
	                            
	                            Text {
	                                text: price
	                                font.pointSize: 16
	                                color: '#27ae60'
	                                font.bold: true
	                                anchors.horizontalCenter: parent.horizontalCenter
	                            }
	                            
	                            Row {
	                                spacing: 3
	                                anchors.horizontalCenter: parent.horizontalCenter
	                                
	                                Repeater {
	                                    model: 5
	                                    Text {
	                                        text: index < rating ? '★' : '☆'
	                                        color: index < rating ? '#f39c12' : '#bdc3c7'
	                                        font.pointSize: 10
	                                    }
	                                }
	                            }
	                        }
	                        
	                        MouseArea {
	                            id: cardMouse
	                            anchors.fill: parent
	                            hoverEnabled: true
	                            cursorShape: Qt.PointingHandCursor
	                        }
	                    }
	                }
	            }
	        }
	    "
	
	#--> GridView arranges items in grid layout
	#--> cellWidth and cellHeight control grid spacing
	#--> Perfect for catalogs, galleries, dashboards

# Narrative
# --------
# Sample 9.1: Custom Reusable Component
#
# Extracted from stzringqmltest.ring, block #26.

load "../../stzBase.ring"

pr()

# Use case: Component definition and reuse


	new qApp {
	        win = new QQuickView() {
	            setWidth(500)
		    setHeight(350)
	            oQML = new RingQML(win) {
	                NewComponent("ColorCard", GetColorCardComponent())
	                loadContent(QML_9_1())
	            }
	            show()
	        }
	        exec()
	}
	
	func GetColorCardComponent
	    return `
	        import QtQuick 2.15
	        
	        Rectangle {
	            id: card
	            width: 140
	            height: 100
	            radius: 10
	            
	            property string cardColor: '#3498db'
	            property string cardTitle: 'Card'
	            
	            color: cardColor
	            
	            Text {
	                text: cardTitle
	                color: 'white'
	                font.pointSize: 14
	                font.bold: true
	                anchors.centerIn: parent
	            }
	            
	            MouseArea {
	                anchors.fill: parent
	                hoverEnabled: true
	                onEntered: card.scale = 1.05
	                onExited: card.scale = 1.0
	            }
	            
	            Behavior on scale {
	                NumberAnimation { duration: 150 }
	            }
	        }
	    `
	
	func QML_9_1
	    return `
	        import QtQuick 2.15
	        
	        Rectangle {
	            width: 500
	            height: 400
	            color: '#ecf0f1'
	            
	            Column {
	                anchors.centerIn: parent
	                spacing: 20
	                
	                Text {
	                    text: 'Reusable Components'
	                    font.pointSize: 16
	                    font.bold: true
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	                
	                Grid {
	                    columns: 3
	                    spacing: 15
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    
	                    ColorCard {
	                        cardColor: '#e74c3c'
	                        cardTitle: 'Red'
	                    }
	                    
	                    ColorCard {
	                        cardColor: '#f39c12'
	                        cardTitle: 'Orange'
	                    }
	                    
	                    ColorCard {
	                        cardColor: '#f1c40f'
	                        cardTitle: 'Yellow'
	                    }
	                    
	                    ColorCard {
	                        cardColor: '#27ae60'
	                        cardTitle: 'Green'
	                    }
	                    
	                    ColorCard {
	                        cardColor: '#3498db'
	                        cardTitle: 'Blue'
	                    }
	                    
	                    ColorCard {
	                        cardColor: '#9b59b6'
	                        cardTitle: 'Purple'
	                    }
	                }
	            }
	        }
	    `
	
	#--> NewComponent() registers reusable QML components
	#--> Components have properties for customization
	#--> Promotes DRY principle and maintainability

pf()

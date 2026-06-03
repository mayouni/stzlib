# Narrative
# --------
# Sample 11.2: CheckBox and RadioButton
#
# Extracted from stzringqmltest.ring, block #31.
#ERR Error (R11) : Error in class name, class not found: qapp

load "../../stzBase.ring"

pr()

# Use case: Boolean and exclusive selections

	new qApp {
	    oQML = new RingQML(NULL) {
	        loadContent(QML_11_3())
	    }
	    exec()
	}
	
	func QML_11_3
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 680
	            title: 'CheckBox & RadioButton'
	            
	            Column {
	                anchors.fill: parent
	                anchors.margins: 30
	                spacing: 25
	                
	                Text {
	                    text: 'Order Configuration'
	                    font.pointSize: 16
	                    font.bold: true
	                }
	                
	                Rectangle {
	                    width: parent.width
	                    height: 1
	                    color: '#bdc3c7'
	                }
	                
	                Text {
	                    text: 'Select extras (multiple):'
	                    font.pointSize: 13
	                    font.bold: true
	                }
	                
	                Column {
	                    spacing: 10
	                    
	                    CheckBox {
	                        id: extraCheese
	                        text: 'Extra Cheese (+$2)'
	                        font.pointSize: 11
	                        checked: false
	                    }
	                    
	                    CheckBox {
	                        id: extraSauce
	                        text: 'Extra Sauce (+$1)'
	                        font.pointSize: 11
	                    }
	                    
	                    CheckBox {
	                        id: gluten
	                        text: 'Gluten Free (+$3)'
	                        font.pointSize: 11
	                    }
	                }
	                
	                Rectangle {
	                    width: parent.width
	                    height: 1
	                    color: '#bdc3c7'
	                }
	                
	                Text {
	                    text: 'Select size (one only):'
	                    font.pointSize: 13
	                    font.bold: true
	                }
	                
	                Column {
	                    spacing: 10
	                    
	                    RadioButton {
	                        id: sizeSmall
	                        text: 'Small ($10)'
	                        font.pointSize: 11
	                        checked: true
	                    }
	                    
	                    RadioButton {
	                        id: sizeMedium
	                        text: 'Medium ($15)'
	                        font.pointSize: 11
	                    }
	                    
	                    RadioButton {
	                        id: sizeLarge
	                        text: 'Large ($20)'
	                        font.pointSize: 11
	                    }
	                }
	                
	                Rectangle {
	                    width: parent.width
	                    height: 80
	                    color: '#3498db'
	                    radius: 10
	                    
	                    Column {
	                        anchors.centerIn: parent
	                        spacing: 5
	                        
	                        Text {
	                            text: 'Total: ' + calculateTotal()
	                            color: 'white'
	                            font.pointSize: 20
	                            font.bold: true
	                            anchors.horizontalCenter: parent.horizontalCenter
	                        }
	                        
	                        Text {
	                            text: getOrderSummary()
	                            color: 'white'
	                            font.pointSize: 10
	                            anchors.horizontalCenter: parent.horizontalCenter
	                        }
	                    }
	                }
	            }
	            
	            function calculateTotal() {
	                var total = 0
	                if (sizeSmall.checked) total = 10
	                if (sizeMedium.checked) total = 15
	                if (sizeLarge.checked) total = 20
	                
	                if (extraCheese.checked) total += 2
	                if (extraSauce.checked) total += 1
	                if (gluten.checked) total += 3
	                
	                return total
	            }
	            
	            function getOrderSummary() {
	                var extras = []
	                if (extraCheese.checked) extras.push('Cheese')
	                if (extraSauce.checked) extras.push('Sauce')
	                if (gluten.checked) extras.push('GF')
	                
	                return extras.length > 0 ? 'With: ' + extras.join(', ') : 'No extras'
	            }
	        }
	    "
	
	#--> CheckBox for multiple selections
	#--> RadioButton for exclusive choices
	#--> Calculated properties update automatically

pf()

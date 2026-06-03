# Narrative
# --------
# Sample 8.2: Computed Properties
#
# Extracted from stzringqmltest.ring, block #24.

load "../../stzBase.ring"

# Use case: Deriving values from other properties


	new qApp {
	        oQML = new RingQML(NULL) {
	            loadContent(QML_8_2())
	        }
	        exec()
	}
	
	func QML_8_2
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 350
	            title: 'Computed Properties'
	            
	            Rectangle {
	                anchors.fill: parent
	                color: '#ecf0f1'
	                
	                Column {
	                    anchors.centerIn: parent
	                    spacing: 20
	                    
	                    Text {
	                        text: 'BMI Calculator'
	                        font.pointSize: 16
	                        font.bold: true
	                        anchors.horizontalCenter: parent.horizontalCenter
	                    }
	                    
	                    Row {
	                        spacing: 10
	                        anchors.horizontalCenter: parent.horizontalCenter
	                        
	                        Text {
	                            text: 'Weight (kg):'
				    font.pointSize: 12
	                            anchors.verticalCenter: parent.verticalCenter
	                        }
	                        TextField {
	                            id: weightInput
	                            width: 100
				    font.pointSize: 12
	                            text: '70'
	                            validator: DoubleValidator { bottom: 0; top: 500 }
	                        }
	                    }
	                    
	                    Row {
	                        spacing: 10
	                        anchors.horizontalCenter: parent.horizontalCenter
	                        
	                        Text {
	                            text: 'Height (cm):'
				    font.pointSize: 12
	                            anchors.verticalCenter: parent.verticalCenter
	                        }
	                        TextField {
	                            id: heightInput
	                            width: 100
				    font.pointSize: 12
	                            text: '175'
	                            validator: DoubleValidator { bottom: 0; top: 300 }
	                        }
	                    }
	                    
	                    Rectangle {
	                        width: 250
	                        height: 80
	                        color: bmiValue < 18.5 ? '#3498db' : 
	                               bmiValue < 25 ? '#27ae60' :
	                               bmiValue < 30 ? '#f39c12' : '#e74c3c'
	                        radius: 10
	                        anchors.horizontalCenter: parent.horizontalCenter
	                        
	                        property real bmiValue: {
	                            var w = parseFloat(weightInput.text)
	                            var h = parseFloat(heightInput.text) / 100
	                            if (w > 0 && h > 0) {
	                                return w / (h * h)
	                            }
	                            return 0
	                        }
	                        
	                        Behavior on color {
	                            ColorAnimation { duration: 300 }
	                        }
	                        
	                        Column {
	                            anchors.centerIn: parent
	                            spacing: 5
	                            
	                            Text {
	                                text: 'BMI: ' + parent.parent.bmiValue.toFixed(1)
	                                font.pointSize: 20
	                                font.bold: true
	                                color: 'white'
	                                anchors.horizontalCenter: parent.horizontalCenter
	                            }
	                            
	                            Text {
	                                text: parent.parent.bmiValue < 18.5 ? 'Underweight' :
	                                      parent.parent.bmiValue < 25 ? 'Normal' :
	                                      parent.parent.bmiValue < 30 ? 'Overweight' : 'Obese'
	                                color: 'white'
	                                anchors.horizontalCenter: parent.horizontalCenter
	                            }
	                        }
	                    }
	                }
	            }
	        }
	    "
	
	#--> Computed properties derive values from inputs
	#--> Ternary operators enable conditional logic
	#--> All updates happen automatically through bindings

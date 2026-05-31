# Narrative
# --------
# Sample 7.2: Ring Function with Return Value
#
# Extracted from stzringqmltest.ring, block #20.

load "../../../stzBase.ring"

# Use case: Getting data back from Ring


	new qApp {
	        win = new QQuickView() {
	            setWidth(450)
		    setHeight(340)
	            oQML = new RingQML(win) {
	                loadContent(QML_7_2())
	            }
	            show()
	        }
	        exec()
	}
	
	func CalculateSum(n1, n2)
	    nSum = n1 + n2
	    ? "Ring calculated: " + n1 + " + " + n2 + " = " + nSum
	    return nSum
	
	func QML_7_2
	    return `
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        
	        Rectangle {
	            color: '#ecf0f1'
	            
	            Column {
	                anchors.centerIn: parent
	                spacing: 15
	                
	                Text {
	                    text: 'Ring Function with Return Value'
	                    font.pointSize: 14
	                    font.bold: true
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	                
	                Row {
	                    spacing: 10
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    
	                    TextField {
	                        id: input1
	                        width: 80
				font.pointSize: 16
	                        text: '5'
	                        validator: IntValidator {}
	                    }
	                    
	                    Text {
	                        text: '+'
	                        font.pointSize: 20
	                        anchors.verticalCenter: parent.verticalCenter
	                    }
	                    
	                    TextField {
	                        id: input2
	                        width: 80
				font.pointSize: 16
	                        text: '3'
	                        validator: IntValidator {}
	                    }
	                }
	                
	                Button {
	                    text: 'Calculate in Ring'
			    font.pointSize: 16
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    onClicked: {
	                        var result = Ring.callFunc("CalculateSum", 
	                            [parseInt(input1.text), parseInt(input2.text)])
	                        resultText.text = 'Result: ' + result
	                    }
	                }
	                
	                Text {
	                    id: resultText
	                    text: 'Result: -'
	                    font.pointSize: 16
	                    color: '#922b21'
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	            }
	        }
	    `
	
	#--> Ring functions can return values to QML
	#--> Return value captured in JavaScript variable
	#--> Enables powerful Ring computation from QML

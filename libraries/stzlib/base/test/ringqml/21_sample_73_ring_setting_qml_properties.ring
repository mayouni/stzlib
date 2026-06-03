# Narrative
# --------
# Sample 7.3: Ring Setting QML Properties
#
# Extracted from stzringqmltest.ring, block #21.

load "../../stzBase.ring"

# Use case: Ring controls QML elements

	nCounter = 0

	new qApp {
	        win = new QQuickView() {
	            setWidth(400)
		    setHeight(400)

	            oQML = new RingQML(win) {
	                loadContent(QML_7_3())
	            }

	            show()
	        }

	        exec()
	}

	func IncrementCounter
	    nCounter++
	    see "Counter incremented: " + nCounter + nl
	
	func QML_7_3
	    return `
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        
	        Rectangle {
	            width: 400
	            height: 300
	            color: '#ecf0f1'
	            
	            Column {
	                anchors.centerIn: parent
	                spacing: 20
	                
	                Text {
	                    text: 'Ring Variable Bridge'
	                    font.pointSize: 14
	                    font.bold: true
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	                
	                Rectangle {
	                    width: 200
	                    height: 100
	                    color: '#3498db'
	                    radius: 10
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    
	                    Text {
	                        id: counterDisplay
	                        text: '0'
	                        font.pointSize: 40
	                        color: 'white'
	                        anchors.centerIn: parent
	                    }
	                }
	                
	                Button {
	                    text: 'Increment via Ring'
			    font.pointSize: 12
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    onClicked: {
	                        Ring.callFunc("IncrementCounter", [])
	                        counterDisplay.text = Ring.getVar("nCounter")
	                    }
	                }
	            }
	        }
	    `
	
	#--> Ring.getVar() retrieves Ring variable values
	#--> Ring.setVar() can set Ring variables from QML
	#--> Creates a data bridge between Ring and QML

# Narrative
# --------
# Sample 7.1: Calling Ring from QML Button
#
# Extracted from stzringqmltest.ring, block #19.

load "../../stzBase.ring"

pr()

# Use case: QML triggers Ring logic


	new qApp {
	        win = new QQuickView() {
	            setWidth(400)
	            oQML = new RingQML(win) {
	                loadContent(QML_7_1())
	            }
	            show()
	        }
	        exec()
	    }
	
	func HandleButtonClick
	    ? "Button was clicked from QML"
	    ? "Ring code executed successfully"
	    ? "---------------------------------"
	
	func QML_7_1
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
	                    text: 'QML → Ring Communication'
	                    font.pointSize: 16
	                    font.bold: true
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	                
	                Button {
	                    text: 'Click to Call Ring Function'
			    font.pointSize: 12
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    onClicked: {
	                        Ring.callFunc("HandleButtonClick", [])
	                    }
	                }
	                
	                Text {
	                    text: 'Check console for output'
	                    font.pointSize: 12
	                    color: '#7f8c8d'
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	            }
	        }
	    `

	#--> Ring.callFunc() executes Ring functions from QML
	#--> First parameter is function name as string
	#--> Second parameter is array of arguments
	#--> Output: Console shows Ring execution confirmation

pf()

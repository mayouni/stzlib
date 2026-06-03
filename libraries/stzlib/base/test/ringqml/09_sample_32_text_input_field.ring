# Narrative
# --------
# Sample 3.2: Text Input Field
#
# Extracted from stzringqmltest.ring, block #9.

load "../../stzBase.ring"

pr()

# Use case: User text input and real-time updates


	new qApp {
	        oQML = new RingQML(NULL)
	        oQML.LoadContent(QML_3_2())

	        exec()
	}

	func QML_3_2
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 300
	            title: 'Text Input'
	            
	            Column {
	                anchors.centerIn: parent
	                spacing: 20
	                
	                TextField {
	                    id: inputField
	                    width: 300
	                    placeholderText: 'Type something...'
	                    font.pointSize: 12
	                }
	                
	                Text {
	                    text: 'You typed: ' + inputField.text
	                    font.pointSize: 14
	                    width: 300
	                    wrapMode: Text.WordWrap
	                }
	                
	                Text {
	                    text: 'Character count: ' + inputField.text.length
	                    color: '#7f8c8d'
	                    font.pointSize: 10
	                }
	            }
	        }
	    "
	
	#--> TextField provides user text input
	#--> Text binding (inputField.text) creates live updates
	#--> This is QML's reactivity in action!

pf()

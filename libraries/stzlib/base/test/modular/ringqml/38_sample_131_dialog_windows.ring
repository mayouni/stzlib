# Narrative
# --------
# Sample 13.1: Dialog Windows
#
# Extracted from stzringqmltest.ring, block #38.

load "../../../stzBase.ring"

# Use case: Modal dialogs for user decisions

	new qApp {
	    oQML = new RingQML(NULL) {
	        loadContent(QML_13_1())
	    }
	    exec()
	}
	
	func QML_13_1
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 300
	            title: 'Dialog Examples'
	            
	            Column {
	                anchors.centerIn: parent
	                spacing: 15
	                
	                Text {
	                    text: 'Dialog Patterns'
	                    font.pointSize: 16
	                    font.bold: true
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	                
	                Button {
	                    text: 'Show Confirmation Dialog'
	                    font.pointSize: 12
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    onClicked: confirmDialog.open()
	                }
	                
	                Button {
	                    text: 'Show Information Dialog'
	                    font.pointSize: 12
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    onClicked: infoDialog.open()
	                }
	                
	                Button {
	                    text: 'Show Custom Dialog'
	                    font.pointSize: 12
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    onClicked: customDialog.open()
	                }
	                
	                Text {
	                    id: resultText
	                    text: 'Action result will appear here'
	                    font.pointSize: 11
	                    color: '#7f8c8d'
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	            }
	            
	            Dialog {
	                id: confirmDialog
	                title: 'Confirm Action'
	                anchors.centerIn: parent
	                modal: true
	                
	                Column {
	                    spacing: 20
	                    
	                    Text {
	                        text: 'Are you sure you want to delete this item?'
	                        font.pointSize: 12
	                        wrapMode: Text.WordWrap
	                        width: 300
	                    }
	                }
	                
	                standardButtons: Dialog.Yes | Dialog.No
	                
	                onAccepted: {
	                    resultText.text = 'User clicked: Yes'
	                    resultText.color = '#27ae60'
	                }
	                
	                onRejected: {
	                    resultText.text = 'User clicked: No'
	                    resultText.color = '#e74c3c'
	                }
	            }
	            
	            Dialog {
	                id: infoDialog
	                title: 'Information'
	                anchors.centerIn: parent
	                modal: true
	                
	                Column {
	                    spacing: 15
	                    
	                    Text {
	                        text: 'ℹ️'
	                        font.pointSize: 40
	                        anchors.horizontalCenter: parent.horizontalCenter
	                    }
	                    
	                    Text {
	                        text: 'Operation completed successfully!'
	                        font.pointSize: 12
	                        wrapMode: Text.WordWrap
	                        width: 300
	                        horizontalAlignment: Text.AlignHCenter
	                    }
	                }
	                
	                standardButtons: Dialog.Ok
	                
	                onAccepted: {
	                    resultText.text = 'Info dialog closed'
	                    resultText.color = '#3498db'
	                }
	            }
	            
	            Dialog {
	                id: customDialog
	                title: 'Enter Your Name'
	                anchors.centerIn: parent
	                modal: true
	                
	                Column {
	                    spacing: 15
	                    
	                    TextField {
	                        id: nameInput
	                        placeholderText: 'Your name...'
	                        font.pointSize: 12
	                        width: 300
	                    }
	                }
	                
	                standardButtons: Dialog.Ok | Dialog.Cancel
	                
	                onAccepted: {
	                    if (nameInput.text.length > 0) {
	                        resultText.text = 'Hello, ' + nameInput.text + '!'
	                        resultText.color = '#9b59b6'
	                    }
	                    nameInput.text = ''
	                }
	                
	                onRejected: {
	                    nameInput.text = ''
	                }
	            }
	        }
	    "
	
	#--> Dialog provides modal popup windows
	#--> standardButtons adds common button sets
	#--> onAccepted/onRejected handle user choices

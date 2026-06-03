# Narrative
# --------
# Sample 7.4: Complete Ring-QML Interaction
#
# Extracted from stzringqmltest.ring, block #22.
#ERR Error (R11) : Error in class name, class not found: qapp

load "../../stzBase.ring"

pr()

# Use case: Bidirectional communication pattern


	$cUserName = "Guest"
	$aMessages = []
	
	new qApp {
	    win = new QQuickView() {
	        setWidth(500)
	        setHeight(400)
	        oQML = new RingQML(win) {
	            loadContent(QML_7_4())
	        }
	        show()
	    }
	    exec()
	}
	
	
	func UpdateUserName(cNewName)
	    $cUserName = cNewName
	    ? "$Username updated to: " + cNewName
	
	func SendMessage(cMessage)
	    if len(cMessage) > 0
	        $aMessages + ($cUserName + ": " +cMessage)
	        ? "Message added: " + cMessage
	    ok
	    return $aMessages
	
	func QML_7_4
	    return `
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        
	        Rectangle {
	            width: 500
	            height: 400
	            color: '#ecf0f1'
	            
	            Column {
	                anchors.fill: parent
	                anchors.margins: 20
	                spacing: 15
	                
	                Text {
	                    text: 'Chat Application Pattern'
	                    font.pointSize: 16
	                    font.bold: true
	                }
	                
	                Row {
	                    width: parent.width
	                    spacing: 10
	                    
	                    Text {
	                        text: 'Username:'
	                        font.pointSize: 12
	                        anchors.verticalCenter: parent.verticalCenter
	                    }
	                    
	                    TextField {
	                        id: nameInput
	                        width: 150
	                        font.pointSize: 12
	                        text: 'Guest'
	                        onTextChanged: {
	                            Ring.callFunc("UpdateUserName", [text])
	                        }
	                    }
	                }
	                
	                Rectangle {
	                    width: parent.width
	                    height: 200
	                    color: 'white'
	                    radius: 5
	                    border.color: '#bdc3c7'
	
	                    ScrollView {
	                        anchors.fill: parent
	                        anchors.margins: 10
	                        
	                        Column {
	                            id: messageList
	                            spacing: 5
	                            width: parent.width
	                        }
	                    }
	                }
	                
	                Row {
	                    width: parent.width
	                    spacing: 10
	                    
	                    TextField {
	                        id: messageInput
	                        width: parent.width - sendBtn.width - 10
	                        font.pointSize: 12
	                        placeholderText: 'Type a message...'
	                    }
	                    
	                    Button {
	                        id: sendBtn
	                        text: 'Send'
	                        font.pointSize: 12
	                        onClicked: {
	                            var messages = Ring.callFunc("SendMessage", [messageInput.text])
	                            updateMessageList(messages)
	                            messageInput.text = ''
	                        }
	                    }
	                }
	            }
	            
	            function updateMessageList(messages) {
	                // Clear existing messages
	                for (var i = messageList.children.length - 1; i >= 0; i--) {
	                    messageList.children[i].destroy()
	                }
	                
	                // Add all messages with proper formatting
	                for (var j = 0; j < messages.length; j++) {
	                    // Escape quotes and newlines for safe QML string creation
	                    var safeText = JSON.stringify(messages[j]);
	                    var msg = Qt.createQmlObject(
	                        'import QtQuick 2.15; Text { ' +
	                        'text: ' + safeText + '; ' +
	                        'width: parent.width; ' +
	                        'wrapMode: Text.WordWrap; ' +
	                        'font.pointSize: 12 ' +
	                        '}',
	                        messageList,
	                        "dynamicMessage"
	                    )
	                }
	            }
	        }
	    `
	
	#--> Demonstrates complete Ring-QML application pattern
	#--> Ring manages data (username, messages)
	#--> QML handles UI and user interaction
	#--> Functions bridge the two worlds seamlessly


#==========================================#
#   SECTION 8: DATA BINDING & REACTIVITY   #
#==========================================#

pf()

# Narrative
# --------
# Sample 11.1: ComboBox (Dropdown Selection)
#
# Extracted from stzringqmltest.ring, block #30.

load "../../stzBase.ring"

# Use case: Selection from predefined options

	new qApp {
	    oQML = new RingQML(NULL) {
	        loadContent(QML_11_2())
	    }
	    exec()
	}
	
	func QML_11_2
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 450
	            height: 350
	            title: 'ComboBox & Selection Controls'
	            
	            Column {
	                anchors.centerIn: parent
	                spacing: 25
	                
	                Text {
	                    text: 'Select Your Preferences'
	                    font.pointSize: 16
	                    font.bold: true
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	                
	                Row {
	                    spacing: 15
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    
	                    Text {
	                        text: 'Theme:'
	                        font.pointSize: 12
	                        anchors.verticalCenter: parent.verticalCenter
	                    }
	                    
	                    ComboBox {
	                        id: themeCombo
	                        width: 200
	                        model: ['Light', 'Dark', 'Auto', 'High Contrast']
	                        font.pointSize: 11
	                        
	                        onCurrentTextChanged: {
	                            selectionText.text = 'Selected: ' + themeCombo.currentText + 
	                                               ' theme at index ' + themeCombo.currentIndex
	                        }
	                    }
	                }
	                
	                Row {
	                    spacing: 15
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    
	                    Text {
	                        text: 'Language:'
	                        font.pointSize: 12
	                        anchors.verticalCenter: parent.verticalCenter
	                    }
	                    
	                    ComboBox {
	                        id: langCombo
	                        width: 200
	                        model: ListModel {
	                            ListElement { text: 'English'; code: 'en' }
	                            ListElement { text: 'العربية'; code: 'ar' }
	                            ListElement { text: 'Français'; code: 'fr' }
	                            ListElement { text: 'Español'; code: 'es' }
	                        }
	                        textRole: 'text'
	                        font.pointSize: 11
	                    }
	                }
	                
	                Rectangle {
	                    width: 350
	                    height: 80
	                    color: '#ecf0f1'
	                    radius: 8
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    
	                    Text {
	                        id: selectionText
	                        text: 'Make a selection...'
	                        font.pointSize: 12
	                        anchors.centerIn: parent
	                        wrapMode: Text.WordWrap
	                        width: parent.width - 20
	                        horizontalAlignment: Text.AlignHCenter
	                    }
	                }
	            }
	        }
	    "
	
	#--> ComboBox for dropdown selections
	#--> Can use simple string arrays or ListModel with roles
	#--> Essential for forms and settings

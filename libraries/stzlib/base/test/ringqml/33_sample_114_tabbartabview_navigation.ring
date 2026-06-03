# Narrative
# --------
# Sample 11.4: TabBar/TabView Navigation
#
# Extracted from stzringqmltest.ring, block #33.

load "../../stzBase.ring"

# Use case: Organizing content in tabs

	new qApp {
	    oQML = new RingQML(NULL) {
	        loadContent(QML_11_5())
	    }
	    exec()
	}
	
	func QML_11_5
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        import QtQuick.Layouts 1.15
	        
	        Window {
	            visible: true
	            width: 500
	            height: 400
	            title: 'TabBar Navigation'
	            
	            ColumnLayout {
	                anchors.fill: parent
	                spacing: 0
	                
	                TabBar {
	                    id: tabBar
	                    Layout.fillWidth: true
	                    
	                    TabButton {
	                        text: '🏠 Home'
	                        font.pointSize: 12
	                    }
	                    TabButton {
	                        text: '📊 Dashboard'
	                        font.pointSize: 12
	                    }
	                    TabButton {
	                        text: '⚙ Settings'
	                        font.pointSize: 12
	                    }
	                    TabButton {
	                        text: '👤 Profile'
	                        font.pointSize: 12
	                    }
	                }
	                
	                StackLayout {
	                    Layout.fillWidth: true
	                    Layout.fillHeight: true
	                    currentIndex: tabBar.currentIndex
		                    
		                    Rectangle {
		                        color: '#ecf0f1'
		                        Text {
		                            text: 'Home Screen\n\nWelcome back!'
		                            font.pointSize: 18
		                            anchors.centerIn: parent
		                            horizontalAlignment: Text.AlignHCenter
		                        }
		                    }
		                    
		                    Rectangle {
		                        color: '#e8f8f5'
		                        Column {
		                            anchors.centerIn: parent
		                            spacing: 15
		                            
		                            Text {
		                                text: '📈 Dashboard'
		                                font.pointSize: 20
		                                font.bold: true
		                                anchors.horizontalCenter: parent.horizontalCenter
		                            }
		                            
		                            Row {
		                                spacing: 20
		                                anchors.horizontalCenter: parent.horizontalCenter
		                                
		                                Rectangle {
		                                    width: 100
		                                    height: 100
		                                    color: '#3498db'
		                                    radius: 10
		                                    
		                                    Column {
		                                        anchors.centerIn: parent
		                                        Text {
		                                            text: '1,234'
		                                            color: 'white'
		                                            font.pointSize: 20
		                                            font.bold: true
		                                            anchors.horizontalCenter: parent.horizontalCenter
		                                        }
		                                        Text {
		                                            text: 'Users'
		                                            color: 'white'
		                                            font.pointSize: 10
		                                            anchors.horizontalCenter: parent.horizontalCenter
		                                        }
		                                    }
		                                }
		                                
		                                Rectangle {
		                                    width: 100
		                                    height: 100
		                                    color: '#27ae60'
		                                    radius: 10
		                                    
		                                    Column {
		                                        anchors.centerIn: parent
		                                        Text {
		                                            text: '567'
		                                            color: 'white'
		                                            font.pointSize: 20
		                                            font.bold: true
		                                            anchors.horizontalCenter: parent.horizontalCenter
		                                        }
		                                        Text {
		                                            text: 'Sales'
		                                            color: 'white'
		                                            font.pointSize: 10
		                                            anchors.horizontalCenter: parent.horizontalCenter
		                                        }
		                                    }
		                                }
		                            }
		                        }
		                    }
		                    
		                    Rectangle {
		                        color: '#fef5e7'
		                        Column {
		                            anchors.centerIn: parent
		                            spacing: 20
		                            
		                            Text {
		                                text: '⚙ Settings'
		                                font.pointSize: 20
		                                font.bold: true
		                            }
		                            
		                            Switch {
		                                text: 'Enable notifications'
		                                font.pointSize: 12
		                            }
		                            
		                            Switch {
		                                text: 'Dark mode'
		                                font.pointSize: 12
		                            }
		                            
		                            Switch {
		                                text: 'Auto-save'
		                                font.pointSize: 12
		                                checked: true
		                            }
		                        }
		                    }
		                    
		                    Rectangle {
		                        color: '#fdeef3'
		                        Column {
		                            anchors.centerIn: parent
		                            spacing: 15
		                            
		                            Rectangle {
		                                width: 100
		                                height: 100
		                                color: '#9b59b6'
		                                radius: 50
		                                anchors.horizontalCenter: parent.horizontalCenter
		                                
		                                Text {
		                                    text: '👤'
		                                    font.pointSize: 40
		                                    anchors.centerIn: parent
		                                }
		                            }
		                            
		                            Text {
		                                text: 'John Doe'
		                                font.pointSize: 18
		                                font.bold: true
		                                anchors.horizontalCenter: parent.horizontalCenter
		                            }
		                            
		                            Text {
		                                text: 'john.doe@example.com'
		                                font.pointSize: 11
		                                color: '#7f8c8d'
		                                anchors.horizontalCenter: parent.horizontalCenter
		                            }
		                        }
		                    }
		                }
		            }
		        }
		    "
		
		#--> TabBar provides tab navigation
		#--> StackLayout switches views based on currentIndex
		#--> Perfect for multi-section applications


#======================================#
#   SECTION 12: DATA DISPLAY PATTERNS  #
#======================================#

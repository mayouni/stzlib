# Narrative
# --------
# Sample 15.1: Pull-to-Refresh Pattern
#
# Extracted from stzringqmltest.ring, block #44.

load "../../../stzBase.ring"

# Use case: Content refresh gesture
#TODO Adjust position of 'Pull down to refresh'


	new qApp {
	    oQML = new RingQML(NULL) {
	        loadContent(QML_15_1())
	    }
	    exec()
	}
	
	func QML_15_1
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 600
	            title: 'Pull to Refresh'
	            
	            Rectangle {
	                anchors.fill: parent
	                color: '#f5f5f5'
	                
	                Column {
	                    anchors.fill: parent
	                    
	                    Rectangle {
	                        width: parent.width
	                        height: 60
	                        color: '#3498db'
	                        
	                        Text {
	                            text: '📱 News Feed'
	                            color: 'white'
	                            font.pointSize: 16
	                            font.bold: true
	                            anchors.centerIn: parent
	                        }
	                    }
	                    
	                    Item {
	                        width: parent.width
	                        height: parent.height - 60
	                        
	                        Rectangle {
	                            id: refreshIndicator
	                            width: parent.width
	                            height: 60
	                            color: 'transparent'
	                            anchors.top: parent.top
	                            anchors.topMargin: -60 + Math.min(flickable.contentY * -1, 60)
	                            
	                            BusyIndicator {
	                                running: refreshIndicator.anchors.topMargin > -10
	                                anchors.centerIn: parent
	                                width: 40
	                                height: 40
	                            }
	                            
	                            Text {
	                                text: refreshIndicator.anchors.topMargin > -10 ? 
	                                      'Release to refresh...' : 'Pull down to refresh'
	                                font.pointSize: 11
	                                color: '#1b4f72'
	                                anchors.centerIn: parent
	                                anchors.verticalCenterOffset: 25
	                            }
	                        }
	                        
	                        Flickable {
	                            id: flickable
	                            anchors.fill: parent
	                            contentHeight: newsColumn.height
	                            clip: true
	                            boundsBehavior: Flickable.DragOverBounds
	                            
	                            onContentYChanged: {
	                                if (contentY < -80 && !dragging) {
	                                    refreshTimer.start()
	                                }
	                            }
	                            
	                            Column {
	                                id: newsColumn
	                                width: parent.width
	                                spacing: 0
	                                
	                                Repeater {
	                                    id: newsRepeater
	                                    model: ListModel {
	                                        ListElement { title: 'Breaking News'; time: '2 min ago'; emoji: '📰' }
	                                        ListElement { title: 'Tech Updates'; time: '15 min ago'; emoji: '💻' }
	                                        ListElement { title: 'Sports Results'; time: '1 hour ago'; emoji: '⚽' }
	                                        ListElement { title: 'Weather Alert'; time: '2 hours ago'; emoji: '🌤' }
	                                        ListElement { title: 'Market News'; time: '3 hours ago'; emoji: '📈' }
	                                    }
	                                    
	                                    Rectangle {
	                                        width: parent.width
	                                        height: 80
	                                        color: 'white'
	                                        
	                                        Row {
	                                            anchors.fill: parent
	                                            anchors.margins: 15
	                                            spacing: 15
	                                            
	                                            Text {
	                                                text: emoji
	                                                font.pointSize: 30
	                                                anchors.verticalCenter: parent.verticalCenter
	                                            }
	                                            
	                                            Column {
	                                                anchors.verticalCenter: parent.verticalCenter
	                                                spacing: 5
	                                                
	                                                Text {
	                                                    text: title
	                                                    font.pointSize: 13
	                                                    font.bold: true
	                                                }
	                                                
	                                                Text {
	                                                    text: time
	                                                    font.pointSize: 10
	                                                    color: '#95a5a6'
	                                                }
	                                            }
	                                        }
	                                        
	                                        Rectangle {
	                                            width: parent.width
	                                            height: 1
	                                            color: '#ecf0f1'
	                                            anchors.bottom: parent.bottom
	                                        }
	                                    }
	                                }
	                            }
	                        }
	                        
	                        Timer {
	                            id: refreshTimer
	                            interval: 1000
	                            onTriggered: {
	                                flickable.contentY = 0
	                            }
	                        }
	                    }
	                }
	            }
	        }
	    "
	
	#--> Pull-to-refresh gesture
	#--> Flickable with bounds behavior
	#--> Loading indicator

# Narrative
# --------
# Sample 8.3: ListModel and Repeater
#
# Extracted from stzringqmltest.ring, block #25.

load "../../stzBase.ring"

# Use case: Dynamic data-driven UIs



	new qApp {
	        oQML = new RingQML(NULL) {
	            loadContent(QML_8_3())
	        }
	        exec()
	}
	
	func QML_8_3
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 500
	            title: 'List-Driven UI'
	            
	            Rectangle {
	                anchors.fill: parent
	                color: '#ecf0f1'
	                
	                ListModel {
	                    id: taskModel
	                    
	                    ListElement { task: 'Learn QML basics'; completed: true }
	                    ListElement { task: 'Understand Ring integration'; completed: true }
	                    ListElement { task: 'Build real application'; completed: false }
	                    ListElement { task: 'Deploy to mobile'; completed: false }
	                }
	                
	                Column {
	                    anchors.fill: parent
	                    anchors.margins: 20
	                    spacing: 15
	                    
	                    Text {
	                        text: 'Task List'
	                        font.pointSize: 18
	                        font.bold: true
	                    }
	                    
	                    ListView {
	                        width: parent.width
	                        height: parent.height - 100
	                        model: taskModel
	                        spacing: 10
	                        
	                        delegate: Rectangle {
	                            width: parent.width
	                            height: 60
	                            color: 'white'
	                            radius: 8
	                            border.color: completed ? '#27ae60' : '#bdc3c7'
	                            border.width: 2
	                            
	                            Row {
	                                anchors.fill: parent
	                                anchors.margins: 10
	                                spacing: 10
	                                
	                                Rectangle {
	                                    width: 30
	                                    height: 30
	                                    color: completed ? '#27ae60' : 'white'
	                                    radius: 15
	                                    border.color: '#27ae60'
	                                    border.width: 2
	                                    anchors.verticalCenter: parent.verticalCenter
	                                    
	                                    Text {
	                                        text: completed ? '✓' : ''
	                                        color: 'white'
	                                        font.pointSize: 14
	                                        anchors.centerIn: parent
	                                    }
	                                    
	                                    MouseArea {
	                                        anchors.fill: parent
	                                        onClicked: {
	                                            taskModel.setProperty(index, 'completed', !completed)
	                                        }
	                                    }
	                                }
	                                
	                                Text {
	                                    text: task
	                                    font.pointSize: 12
	                                    font.strikeout: completed
	                                    color: completed ? '#7f8c8d' : '#2c3e50'
	                                    anchors.verticalCenter: parent.verticalCenter
	                                }
	                            }
	                        }
	                    }
	                }
	            }
	        }
	    "

	#--> ListModel stores structured data
	#--> ListView creates scrollable list from model
	#--> Delegate defines how each item looks
	#--> Perfect pattern for dynamic content

	#NOTE
	# Click on the green ✓ cercle to activate/deactivate a task


#==================================#
#   SECTION 9: ADVANCED PATTERNS   #
#==================================#

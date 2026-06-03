# Narrative
# --------
# Sample 10.1: Task Manager Application
#
# Extracted from stzringqmltest.ring, block #29.

load "../../stzBase.ring"

pr()

# Use case: Bringing everything together


	# Application state
	aTasks = []
	nTaskIdCounter = 0
	
	new qApp {
	    win = new QQuickView() {
	        setWidth(500)
	        setHeight(700)
	        
	        oQML = new RingQML(win) {
	            loadContent(QML_10_1())
	        }
	        show()
	    }
	    exec()
	}
	
	func AddTask(cTaskText)
	    if len(cTaskText) > 0
	        nTaskIdCounter++
	        aTask = [:id = nTaskIdCounter, :text = cTaskText, :completed = false]
	        aTasks + aTask
	        see "Task added: " + cTaskText + nl
	    ok
	    return aTasks
	
	func ToggleTask(nId)
	    for i = 1 to len(aTasks)
	        if aTasks[i][:id] = nId
	            aTasks[i][:completed] = !aTasks[i][:completed]
	            see "Task " + nId + " toggled to: " + aTasks[i][:completed] + nl
	            exit
	        ok
	    next
	    return aTasks
	
	func DeleteTask(nId)
	    for i = 1 to len(aTasks)
	        if aTasks[i][:id] = nId
	            del(aTasks, i)
	            see "Task " + nId + " deleted" + nl
	            exit
	        ok
	    next
	    return aTasks
	
	func GetTaskStats
	    nTotal = len(aTasks)
	    nCompleted = 0
	    for task in aTasks
	        if task[:completed]
	            nCompleted++
	        ok
	    next
	    return [nTotal, nCompleted, nTotal - nCompleted]
	
	func QML_10_1()
	    return `
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Layouts 1.15
	        
	        Rectangle {
	            width: 500
	            height: 700
	            color: '#f5f5f5'
	            
	            Component {
	                id: taskDelegate
	                Rectangle {
	                    width: taskList.width - 20
	                    height: 70
	                    color: "white"
	                    radius: 10
	                    property int taskId: 0
	                    property bool taskCompleted: false
	                    property string taskText: ""
	                    
	                    border.color: "#e0e0e0"
	                    border.width: 1
	                    
	                    Row {
	                        anchors.fill: parent
	                        anchors.margins: 15
	                        spacing: 15
	                        
	                        Rectangle {
	                            width: 28
	                            height: 28
	                            color: taskCompleted ? "#27ae60" : "white"
	                            radius: 14
	                            border.color: "#27ae60"
	                            border.width: 2
	                            anchors.verticalCenter: parent.verticalCenter
	                            
	                            Text {
	                                text: taskCompleted ? "✓" : ""
	                                color: "white"
	                                font.pointSize: 14
	                                font.bold: true
	                                anchors.centerIn: parent
	                            }
	                            
	                            MouseArea {
	                                anchors.fill: parent
	                                cursorShape: Qt.PointingHandCursor
	                                onClicked: {
	                                    var tasks = Ring.callFunc("ToggleTask", [taskId])
	                                    updateTaskList(tasks)
	                                    updateStats()
	                                }
	                            }
	                        }
	                        
	                        Text {
	                            text: taskText
	                            font.pointSize: 12
	                            font.strikeout: taskCompleted
	                            color: taskCompleted ? "#999" : "#333"
	                            anchors.verticalCenter: parent.verticalCenter
	                            width: 300
	                            wrapMode: Text.WordWrap
	                        }
	                        
	                        Item { width: 10 }
	                        
	                        Rectangle {
	                            width: 36
	                            height: 36
	                            color: deleteArea.containsMouse ? "#fee" : "transparent"
	                            radius: 18
	                            anchors.verticalCenter: parent.verticalCenter
	                            
	                            Text {
	                                text: "🗑"
	                                font.pointSize: 16
	                                anchors.centerIn: parent
	                            }
	                            
	                            MouseArea {
	                                id: deleteArea
	                                anchors.fill: parent
	                                hoverEnabled: true
	                                cursorShape: Qt.PointingHandCursor
	                                onClicked: {
	                                    var tasks = Ring.callFunc("DeleteTask", [taskId])
	                                    updateTaskList(tasks)
	                                    updateStats()
	                                }
	                            }
	                        }
	                    }
	                }
	            }
	            
	            Column {
	                anchors.fill: parent
	                spacing: 0
	                
	                Rectangle {
	                    width: parent.width
	                    height: 80
	                    gradient: Gradient {
	                        GradientStop { position: 0.0; color: '#667eea' }
	                        GradientStop { position: 1.0; color: '#764ba2' }
	                    }
	                    
	                    Text {
	                        text: '✓ Task Manager'
	                        color: 'white'
	                        font.pointSize: 24
	                        font.bold: true
	                        anchors.centerIn: parent
	                    }
	                }
	                
	                Rectangle {
	                    width: parent.width
	                    height: 100
	                    color: 'white'
	                    border.color: '#e0e0e0'
	                    border.width: 1
	                    
	                    Row {
	                        anchors.centerIn: parent
	                        spacing: 40
	                        
	                        Column {
	                            spacing: 5
	                            Text {
	                                id: totalStat
	                                text: '0'
	                                font.pointSize: 20
	                                font.bold: true
	                                color: '#667eea'
	                                anchors.horizontalCenter: parent.horizontalCenter
	                            }
	                            Text {
	                                text: 'Total'
	                                font.pointSize: 10
	                                color: '#666'
	                                anchors.horizontalCenter: parent.horizontalCenter
	                            }
	                        }
	                        
	                        Column {
	                            spacing: 5
	                            Text {
	                                id: completedStat
	                                text: '0'
	                                font.pointSize: 20
	                                font.bold: true
	                                color: '#27ae60'
	                                anchors.horizontalCenter: parent.horizontalCenter
	                            }
	                            Text {
	                                text: 'Completed'
	                                font.pointSize: 10
	                                color: '#666'
	                                anchors.horizontalCenter: parent.horizontalCenter
	                            }
	                        }
	                        
	                        Column {
	                            spacing: 5
	                            Text {
	                                id: pendingStat
	                                text: '0'
	                                font.pointSize: 20
	                                font.bold: true
	                                color: '#e74c3c'
	                                anchors.horizontalCenter: parent.horizontalCenter
	                            }
	                            Text {
	                                text: 'Pending'
	                                font.pointSize: 10
	                                color: '#666'
	                                anchors.horizontalCenter: parent.horizontalCenter
	                            }
	                        }
	                    }
	                }
	                
	                Rectangle {
	                    width: parent.width
	                    height: 70
	                    color: 'white'
	                    
	                    Row {
	                        anchors.centerIn: parent
	                        spacing: 10
	                        
	                        TextField {
	                            id: taskInput
	                            width: 350
	                            height: 50
	                            placeholderText: 'What needs to be done?'
	                            font.pointSize: 12
	                            background: Rectangle {
	                                color: '#f8f8f8'
	                                radius: 25
	                                border.color: taskInput.activeFocus ? '#667eea' : '#e0e0e0'
	                                border.width: 2
	                            }
	                            leftPadding: 20
	                            
	                            Keys.onReturnPressed: addButton.clicked()
	                        }
	                        
	                        Button {
	                            id: addButton
	                            width: 100
	                            height: 50
	                            text: '+ Add'
	                            
	                            background: Rectangle {
	                                color: addButton.pressed ? '#5568d3' : '#667eea'
	                                radius: 25
	                            }
	                            
	                            contentItem: Text {
	                                text: addButton.text
	                                color: 'white'
	                                font.pointSize: 12
	                                font.bold: true
	                                horizontalAlignment: Text.AlignHCenter
	                                verticalAlignment: Text.AlignVCenter
	                            }
	                            
	                            onClicked: {
	                                if (taskInput.text.trim().length > 0) {
	                                    var tasks = Ring.callFunc("AddTask", [taskInput.text.trim()])
	                                    updateTaskList(tasks)
	                                    updateStats()
	                                    taskInput.text = ''
	                                }
	                            }
	                        }
	                    }
	                }
	                
	                Rectangle {
	                    width: parent.width
	                    height: 400
	                    color: 'transparent'
	                    
	                    ScrollView {
	                        anchors.fill: parent
	                        anchors.margins: 15
	                        clip: true
	                        
	                        Column {
	                            id: taskList
	                            width: parent.width
	                            spacing: 10
	                            
	                            Text {
	                                id: placeholderText
	                                text: 'No tasks yet. Add one above!'
	                                color: '#999'
	                                font.pointSize: 12
	                                anchors.horizontalCenter: parent.horizontalCenter
	                                visible: true
	                            }
	                        }
	                    }
	                }
	                
	                Item { height: 20 }
	            }
	            
	            function updateTaskList(tasks) {
	                for (var i = taskList.children.length - 1; i >= 0; i--) {
	                    var child = taskList.children[i]
	                    if (child === placeholderText) continue
	                    child.destroy()
	                }
	                
	                placeholderText.visible = (tasks.length === 0)
	                
	                for (var i = 0; i < tasks.length; i++) {
	                    var task = tasks[i]
	                    taskDelegate.createObject(taskList, {
	                        taskId: task.id,
	                        taskCompleted: task.completed,
	                        taskText: task.text
	                    })
	                }
	            }
	            
	            function updateStats() {
	                var stats = Ring.callFunc("GetTaskStats", [])
	                totalStat.text = stats[0].toString()
	                completedStat.text = stats[1].toString()
	                pendingStat.text = stats[2].toString()
	            }
	            
	            Component.onCompleted: {
	                Ring.callFunc("AddTask", ["Learn RingQML basics"])
	                Ring.callFunc("AddTask", ["Build a real application"])
	                Ring.callFunc("AddTask", ["Deploy to production"])
	                var tasks = Ring.callFunc("ToggleTask", [1])
	                
	                updateTaskList(tasks)
	                updateStats()
	            }
	        }
	    `
	
	#--> Complete application combining all concepts
	#--> Ring manages data and business logic
	#--> QML handles beautiful, reactive UI
	#--> Clean separation of concerns
	#--> Production-ready patterns


#================================================#
#   SECTION 11: ADVANCED CONTROLS & COMPONENTS   #
#================================================#

pf()

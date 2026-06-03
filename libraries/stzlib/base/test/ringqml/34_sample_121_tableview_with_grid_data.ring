# Narrative
# --------
# Sample 12.1: TableView with Grid Data
#
# Extracted from stzringqmltest.ring, block #34.

load "../../stzBase.ring"

pr()

# Use case: Displaying tabular data

	new qApp {
	    oQML = new RingQML(NULL) {
	        loadContent(QML_12_1())
	    }
	    exec()
	}
	
	func QML_12_1
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 600
	            height: 400
	            title: 'Data Table Display'
	            
	            Column {
	                anchors.fill: parent
	                anchors.margins: 20
	                spacing: 15
	                
	                Text {
	                    text: 'Employee Database'
	                    font.pointSize: 16
	                    font.bold: true
	                }
	                
	                Rectangle {
	                    width: parent.width
	                    height: parent.height - 50
	                    border.color: '#bdc3c7'
	                    border.width: 1
	                    
	                    ListView {
	                        id: tableView
	                        anchors.fill: parent
	                        anchors.margins: 1
	                        clip: true
	                        
	                        header: Rectangle {
	                            width: tableView.width
	                            height: 40
	                            color: '#34495e'
	                            
	                            Row {
	                                anchors.fill: parent
	                                
	                                Text {
	                                    text: 'ID'
	                                    color: 'white'
	                                    font.pointSize: 11
	                                    font.bold: true
	                                    width: 60
	                                    anchors.verticalCenter: parent.verticalCenter
	                                    leftPadding: 10
	                                }
	                                
	                                Text {
	                                    text: 'Name'
	                                    color: 'white'
	                                    font.pointSize: 11
	                                    font.bold: true
	                                    width: 150
	                                    anchors.verticalCenter: parent.verticalCenter
	                                }
	                                
	                                Text {
	                                    text: 'Department'
	                                    color: 'white'
	                                    font.pointSize: 11
	                                    font.bold: true
	                                    width: 150
	                                    anchors.verticalCenter: parent.verticalCenter
	                                }
	                                
	                                Text {
	                                    text: 'Salary'
	                                    color: 'white'
	                                    font.pointSize: 11
	                                    font.bold: true
	                                    width: 100
	                                    anchors.verticalCenter: parent.verticalCenter
	                                }
	                                
	                                Text {
	                                    text: 'Status'
	                                    color: 'white'
	                                    font.pointSize: 11
	                                    font.bold: true
	                                    anchors.verticalCenter: parent.verticalCenter
	                                }
	                            }
	                        }
	                        
	                        model: ListModel {
	                            ListElement { empId: '001'; name: 'Alice Johnson'; dept: 'Engineering'; salary: 95000; active: true }
	                            ListElement { empId: '002'; name: 'Bob Smith'; dept: 'Marketing'; salary: 75000; active: true }
	                            ListElement { empId: '003'; name: 'Carol White'; dept: 'Sales'; salary: 68000; active: false }
	                            ListElement { empId: '004'; name: 'David Brown'; dept: 'Engineering'; salary: 92000; active: true }
	                            ListElement { empId: '005'; name: 'Emma Davis'; dept: 'HR'; salary: 71000; active: true }
	                            ListElement { empId: '006'; name: 'Frank Miller'; dept: 'Finance'; salary: 85000; active: true }
	                            ListElement { empId: '007'; name: 'Grace Lee'; dept: 'Engineering'; salary: 98000; active: true }
	                            ListElement { empId: '008'; name: 'Henry Wilson'; dept: 'Sales'; salary: 72000; active: false }
	                        }
	                        
	                        delegate: Rectangle {
	                            width: tableView.width
	                            height: 45
	                            color: index % 2 === 0 ? 'white' : '#f8f9fa'
	                            
	                            Row {
	                                anchors.fill: parent
	                                anchors.leftMargin: 10
	                                
	                                Text {
	                                    text: empId
	                                    font.pointSize: 10
	                                    width: 60
	                                    anchors.verticalCenter: parent.verticalCenter
	                                }
	                                
	                                Text {
	                                    text: name
	                                    font.pointSize: 10
	                                    width: 150
	                                    anchors.verticalCenter: parent.verticalCenter
	                                }
	                                
	                                Text {
	                                    text: dept
	                                    font.pointSize: 10
	                                    width: 150
	                                    anchors.verticalCenter: parent.verticalCenter
	                                }
	                                
	                                Text {
	                                    text: salary.toLocaleString()
	                                    font.pointSize: 10
	                                    width: 100
	                                    anchors.verticalCenter: parent.verticalCenter
	                                }
	                                
	                                Rectangle {
	                                    width: 70
	                                    height: 25
	                                    color: active ? '#27ae60' : '#e74c3c'
	                                    radius: 12
	                                    anchors.verticalCenter: parent.verticalCenter
	                                    
	                                    Text {
	                                        text: active ? 'Active' : 'Inactive'
	                                        color: 'white'
	                                        font.pointSize: 9
	                                        anchors.centerIn: parent
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
	        }
	    "
	
	#--> ListView with custom header creates table effect
	#--> Alternating row colors improve readability
	#--> Status badges show data visually

pf()

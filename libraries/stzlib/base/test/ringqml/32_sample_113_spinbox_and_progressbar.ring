# Narrative
# --------
# Sample 11.3: SpinBox and ProgressBar
#
# Extracted from stzringqmltest.ring, block #32.

load "../../stzBase.ring"

# Use case: Numeric input and progress display

	new qApp {
	    oQML = new RingQML(NULL) {
	        loadContent(QML_11_4())
	    }
	    exec()
	}
	
	func QML_11_4
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 400
	            title: 'SpinBox & Progress Indicators'
	            
	            Column {
	                anchors.centerIn: parent
	                spacing: 30
	                
	                Text {
	                    text: 'Download Manager'
	                    font.pointSize: 16
	                    font.bold: true
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	                
	                Row {
	                    spacing: 15
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    
	                    Text {
	                        text: 'Speed (MB/s):'
	                        font.pointSize: 12
	                        anchors.verticalCenter: parent.verticalCenter
	                    }
	                    
	                    SpinBox {
	                        id: speedSpin
	                        from: 1
	                        to: 100
	                        value: 50
	                        font.pointSize: 11
	                    }
	                }
	                
	                Column {
	                    spacing: 10
	                    width: 350
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    
	                    Row {
	                        width: parent.width
	                        spacing: 10
	                        
	                        Text {
	                            text: 'Progress:'
	                            font.pointSize: 12
	                            width: 80
	                        }
	                        
	                        ProgressBar {
	                            id: progressBar
	                            from: 0
	                            to: 100
	                            value: 0
	                            width: 260
	                        }
	                    }
	                    
	                    Text {
	                        text: Math.round(progressBar.value) + '% Complete'
	                        font.pointSize: 11
	                        color: '#7f8c8d'
	                    }
	                }
	                
	                Row {
	                    spacing: 10
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    
	                    Button {
	                        text: downloadTimer.running ? 'Pause' : 'Start Download'
	                        font.pointSize: 12
	                        onClicked: {
	                            if (downloadTimer.running) {
	                                downloadTimer.stop()
	                            } else {
	                                if (progressBar.value >= 100) {
	                                    progressBar.value = 0
	                                }
	                                downloadTimer.start()
	                            }
	                        }
	                    }
	                    
	                    Button {
	                        text: 'Reset'
	                        font.pointSize: 12
	                        onClicked: {
	                            downloadTimer.stop()
	                            progressBar.value = 0
	                        }
	                    }
	                }
	                
	                Row {
	                    spacing: 10
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    visible: downloadTimer.running
	                    
	                    BusyIndicator {
	                        running: true
	                        width: 30
	                        height: 30
	                    }
	                    
	                    Text {
	                        text: 'Downloading at ' + speedSpin.value + ' MB/s...'
	                        font.pointSize: 11
	                        color: '#3498db'
	                        anchors.verticalCenter: parent.verticalCenter
	                    }
	                }
	            }
	            
	            Timer {
	                id: downloadTimer
	                interval: 100
	                repeat: true
	                running: false
	                onTriggered: {
	                    progressBar.value += (speedSpin.value / 10)
	                    if (progressBar.value >= 100) {
	                        progressBar.value = 100
	                        stop()
	                    }
	                }
	            }
	        }
	    "
	
	#--> SpinBox for numeric input with increment/decrement
	#--> ProgressBar shows task completion
	#--> BusyIndicator for indeterminate progress

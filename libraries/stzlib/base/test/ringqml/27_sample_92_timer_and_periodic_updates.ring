# Narrative
# --------
# Sample 9.2: Timer and Periodic Updates
#
# Extracted from stzringqmltest.ring, block #27.

load "../../stzBase.ring"

# Use case: Time-based UI updates


	new qApp {
	    // Create proper QQuickView container
	    win = new QQuickView() {
	        setWidth(400)
	        setHeight(300)
	        setTitle('Timer Example')
	        
	        oQML = new RingQML(win) {
	            loadContent(QML_9_2())
	        }
	        show()
	    }
	    exec()
	}
	
	func QML_9_2
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        
	        Rectangle {
	            width: 400
	            height: 300
	            color: '#2c3e50'
	            
	            // Dynamic time property
	            property var currentTime: new Date()
	            
	            Column {
	                anchors.centerIn: parent
	                spacing: 20
	                
	                Text {
	                    text: Qt.formatTime(currentTime, 'hh:mm:ss')
	                    color: '#3498db'
	                    font.pointSize: 48
	                    font.bold: true
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	                
	                Text {
	                    text: Qt.formatDate(currentTime, 'dddd, MMMM d, yyyy')
	                    color: '#ecf0f1'
	                    font.pointSize: 14
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	            }
	            
	            Timer {
	                interval: 1000
	                running: true
	                repeat: true
	                onTriggered: {
	                    currentTime = new Date();
	                }
	            }
	        }
	    "

	#--> Timer triggers actions periodically
	#--> Perfect for clocks, countdowns, auto-refresh
	#--> interval is in milliseconds

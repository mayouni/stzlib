# Narrative
# --------
# Sample 12.3: SwipeView with Pages
#
# Extracted from stzringqmltest.ring, block #36.

load "../../stzBase.ring"

pr()

# Use case: Swipeable content (onboarding, image viewer)


	new qApp {
	    oQML = new RingQML(NULL) {
	        loadContent(QML_12_3())
	    }
	    exec()
	}
	
	func QML_12_3
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 440
	            height: 500
	            title: 'App Onboarding'
	            
	            SwipeView {
	                id: swipeView
	                anchors.fill: parent
	                currentIndex: 0
	                
	                Rectangle {
	                    color: '#e8f8f5'
	                    
	                    Column {
	                        anchors.centerIn: parent
	                        spacing: 30
	                        
	                        Text {
	                            text: '👋'
	                            font.pointSize: 80
	                            anchors.horizontalCenter: parent.horizontalCenter
	                        }
	                        
	                        Text {
	                            text: 'Welcome!'
	                            font.pointSize: 28
	                            font.bold: true
	                            anchors.horizontalCenter: parent.horizontalCenter
	                        }
	                        
	                        Text {
	                            text: 'Discover amazing features\nin our application'
	                            font.pointSize: 14
	                            color: '#7f8c8d'
	                            horizontalAlignment: Text.AlignHCenter
	                            anchors.horizontalCenter: parent.horizontalCenter
	                        }
	                    }
	                }
	                
	                Rectangle {
	                    color: '#fef5e7'
	                    
	                    Column {
	                        anchors.centerIn: parent
	                        spacing: 30
	                        
	                        Text {
	                            text: '🚀'
	                            font.pointSize: 80
	                            anchors.horizontalCenter: parent.horizontalCenter
	                        }
	                        
	                        Text {
	                            text: 'Fast & Efficient'
	                            font.pointSize: 28
	                            font.bold: true
	                            anchors.horizontalCenter: parent.horizontalCenter
	                        }
	                        
	                        Text {
	                            text: 'Lightning fast performance\nfor all your tasks'
	                            font.pointSize: 14
	                            color: '#7f8c8d'
	                            horizontalAlignment: Text.AlignHCenter
	                            anchors.horizontalCenter: parent.horizontalCenter
	                        }
	                    }
	                }
	                
	                Rectangle {
	                    color: '#fdeef3'
	                    
	                    Column {
	                        anchors.centerIn: parent
	                        spacing: 30
	                        
	                        Text {
	                            text: '🔒'
	                            font.pointSize: 80
	                            anchors.horizontalCenter: parent.horizontalCenter
	                        }
	                        
	                        Text {
	                            text: 'Secure & Private'
	                            font.pointSize: 28
	                            font.bold: true
	                            anchors.horizontalCenter: parent.horizontalCenter
	                        }
	                        
	                        Text {
	                            text: 'Your data is protected\nwith encryption'
	                            font.pointSize: 14
	                            color: '#7f8c8d'
	                            horizontalAlignment: Text.AlignHCenter
	                            anchors.horizontalCenter: parent.horizontalCenter
	                        }
	                        
	                        Button {
	                            text: 'Get Started'
	                            font.pointSize: 14
	                            anchors.horizontalCenter: parent.horizontalCenter
	                            onClicked: {
	                                console.log('Onboarding complete!')
	                            }
	                        }
	                    }
	                }
	            }
	            
	            PageIndicator {
	                count: swipeView.count
	                currentIndex: swipeView.currentIndex
	                anchors.bottom: parent.bottom
	                anchors.horizontalCenter: parent.horizontalCenter
	                anchors.bottomMargin: 20
	            }
	        }
	    "
	
	#--> SwipeView allows swipeable pages
	#--> PageIndicator shows current page
	#--> Great for onboarding, galleries, tutorials

pf()

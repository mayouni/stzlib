# Narrative
# --------
# Sample 8.1: Property Bindings
#
# Extracted from stzringqmltest.ring, block #23.

load "../../../stzBase.ring"

# Use case: Automatic UI updates through bindings


	new qApp {
	        oQML = new RingQML(NULL) {
	            loadContent(QML_8_1())
	        }
	        exec()
	}

	func QML_8_1
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 300
	            title: 'Property Bindings'
	            
	            Column {
	                anchors.centerIn: parent
	                spacing: 20
	                
	                Text {
	                    text: 'The Power of Binding'
	                    font.pointSize: 16
	                    font.bold: true
	                }
	                
	                Slider {
	                    id: opacitySlider
	                    from: 0
	                    to: 1
	                    value: 0.5
	                    width: 300
	                }
	                
	                Rectangle {
	                    width: 200
	                    height: 100
	                    color: '#e74c3c'
	                    radius: 10
	                    opacity: opacitySlider.value
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    
	                    Text {
	                        text: 'Opacity: ' + Math.round(opacitySlider.value * 100) + '%'
	                        color: 'white'
	                        font.pointSize: 14
	                        anchors.centerIn: parent
	                    }
	                }
	                
	                Text {
	                    text: 'No code needed - binding does it all!'
	                    font.pointSize: 10
	                    color: '#7f8c8d'
	                }
	            }
	        }
	    "
	
	#--> Property bindings create automatic relationships
	#--> When source changes, target updates instantly
	#--> No explicit update code required - it's reactive!

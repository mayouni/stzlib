# Narrative
# --------
# Sample 14.2: Pie Chart Visualization
#
# Extracted from stzringqmltest.ring, block #41.

load "../../stzBase.ring"

pr()

# Use case: Proportional data display

	new qApp {
	    oQML = new RingQML(NULL) {
	        loadContent(QML_14_2())
	    }
	    exec()
	}
	
	func QML_14_2
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 550
	            height: 550
	            title: 'Pie Chart - Budget Distribution'
	            
	            Column {
	                anchors.fill: parent
	                anchors.margins: 20
	                spacing: 20
	                
	                Text {
	                    text: 'Annual Budget Distribution'
	                    font.pointSize: 18
	                    font.bold: true
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	                
	                Canvas {
	                    id: pieChart
	                    width: 300
	                    height: 300
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    
	                    property var data: [
	                        { label: 'Salaries', value: 45, color: '#3498db' },
	                        { label: 'Marketing', value: 20, color: '#e74c3c' },
	                        { label: 'R&D', value: 25, color: '#27ae60' },
	                        { label: 'Operations', value: 10, color: '#f39c12' }
	                    ]
	                    
	                    onPaint: {
	                        var ctx = getContext('2d')
	                        ctx.clearRect(0, 0, width, height)
	                        
	                        var centerX = width / 2
	                        var centerY = height / 2
	                        var radius = Math.min(width, height) / 2 - 10
	                        
	                        var total = 0
	                        for (var i = 0; i < data.length; i++) {
	                            total += data[i].value
	                        }
	                        
	                        var startAngle = -Math.PI / 2
	                        
	                        for (var i = 0; i < data.length; i++) {
	                            var sliceAngle = (data[i].value / total) * 2 * Math.PI
	                            var endAngle = startAngle + sliceAngle
	                            
	                            ctx.beginPath()
	                            ctx.moveTo(centerX, centerY)
	                            ctx.arc(centerX, centerY, radius, startAngle, endAngle)
	                            ctx.closePath()
	                            
	                            ctx.fillStyle = data[i].color
	                            ctx.fill()
	                            
	                            ctx.strokeStyle = 'white'
	                            ctx.lineWidth = 2
	                            ctx.stroke()
	                            
	                            startAngle = endAngle
	                        }
	                        
	                        ctx.beginPath()
	                        ctx.arc(centerX, centerY, radius * 0.6, 0, 2 * Math.PI)
	                        ctx.fillStyle = 'white'
	                        ctx.fill()
	                    }
	                }
	                
	                Column {
	                    spacing: 10
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    
	                    Repeater {
	                        model: pieChart.data
	                        
	                        Row {
	                            spacing: 15
	                            
	                            Rectangle {
	                                width: 20
	                                height: 20
	                                color: modelData.color
	                                radius: 3
	                                anchors.verticalCenter: parent.verticalCenter
	                            }
	                            
	                            Text {
	                                text: modelData.label + ': ' + modelData.value + '%'
	                                font.pointSize: 12
	                                width: 200
	                                anchors.verticalCenter: parent.verticalCenter
	                            }
	                        }
	                    }
	                }
	            }
	        }
	    "
	
	#--> Canvas for custom drawing
	#--> Pie chart using arc drawing
	#--> Legend shows data breakdown

pf()

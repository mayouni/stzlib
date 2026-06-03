# Narrative
# --------
# Sample 14.4: Line Chart with Animation
#
# Extracted from stzringqmltest.ring, block #43.

load "../../stzBase.ring"

pr()

# Use case: Trend visualization
#TODO: See why animation is not running


	new qApp {
	    oQML = new RingQML(NULL) {
	        loadContent(QML_14_4())
	    }
	    exec()
	}
	
	func QML_14_4
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 700
	            height: 500
	            title: 'Line Chart - Temperature Trend'
	            
	            Column {
	                anchors.fill: parent
	                anchors.margins: 20
	                spacing: 15
	                
	                Text {
	                    text: 'Weekly Temperature Chart'
	                    font.pointSize: 18
	                    font.bold: true
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	                
	                Canvas {
	                    id: lineChart
	                    width: parent.width
	                    height: 350
	                    
	                    property var dataPoints: [20, 22, 25, 23, 27, 29, 26]
	                    property var labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
	                    
	                    onPaint: {
	                        var ctx = getContext('2d')
	                        ctx.clearRect(0, 0, width, height)
	                        
	                        var margin = 40
	                        var chartWidth = width - 2 * margin
	                        var chartHeight = height - 2 * margin
	                        var maxValue = 35
	                        
	                        ctx.strokeStyle = '#ecf0f1'
	                        ctx.lineWidth = 1
	                        for (var i = 0; i <= 5; i++) {
	                            var y = margin + (chartHeight / 5) * i
	                            ctx.beginPath()
	                            ctx.moveTo(margin, y)
	                            ctx.lineTo(width - margin, y)
	                            ctx.stroke()
	                        }
	                        
	                        var pointSpacing = chartWidth / (dataPoints.length - 1)
	                        
	                        ctx.beginPath()
	                        for (var i = 0; i < dataPoints.length; i++) {
	                            var x = margin + i * pointSpacing
	                            var y = margin + chartHeight - (dataPoints[i] / maxValue) * chartHeight
	                            
	                            if (i === 0) {
	                                ctx.moveTo(x, y)
	                            } else {
	                                ctx.lineTo(x, y)
	                            }
	                        }
	                        ctx.strokeStyle = '#3498db'
	                        ctx.lineWidth = 3
	                        ctx.stroke()
	                        
	                        for (var i = 0; i < dataPoints.length; i++) {
	                            var x = margin + i * pointSpacing
	                            var y = margin + chartHeight - (dataPoints[i] / maxValue) * chartHeight
	                            
	                            ctx.beginPath()
	                            ctx.arc(x, y, 5, 0, 2 * Math.PI)
	                            ctx.fillStyle = '#3498db'
	                            ctx.fill()
	                            ctx.strokeStyle = 'white'
	                            ctx.lineWidth = 2
	                            ctx.stroke()
	                        }
	                    }
	                }
	                
	                Row {
	                    spacing: parent.width / 8
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    
	                    Repeater {
	                        model: lineChart.labels
	                        Text {
	                            text: modelData
	                            font.pointSize: 10
	                        }
	                    }
	                }
	            }
	        }
	    "
	
	#--> Line chart using Canvas
	#--> Grid lines for reference
	#--> Data points visualization


#============================================#
#   SECTION 15: MOBILE UI PATTERNS           #
#============================================#

pf()

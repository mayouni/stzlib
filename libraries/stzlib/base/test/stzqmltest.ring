#   RingQML EXTENDED SAMPLES FILE
#   A Progressive Guide to Modern GUI Development with Ring and QML
#
#   RingQML is created by Mohannad Aldulaimi (2025)
#   This test file is written by Mansour Ayouni and ClaudeAI (2025)
#
#   Purpose: Educational samples demonstrating QML-Ring integration


load 'guilib.ring'
load 'ringQML.ring'
load 'stdlibcore.ring'

#=========================================#
#   SECTION 1: FOUNDATION & FIRST STEPS   #
#=========================================#

/*--- Sample 1.1: The Absolute Minimum - Hello RingQML
# Use case: Basic structure, Window creation, Text display


	new qApp {
		oQML = new RingQML(NULL)
		oQML.LoadContent(QML_1_1())
	
	        exec()
	}
	
	func QML_1_1
	    return "
	        import QtQuick 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 450
	            height: 300
	            title: 'Hello RingQML'
	            
	            Text {
	                text: 'Welcome to RingQML!'
	                font.pointSize: 24
	                anchors.centerIn: parent
	            }
	        }
	    "
	
	#--> A window appears with centered text
	#--> This is the minimal template for any RingQML application


/*--- Sample 1.2: Understanding the Rectangle - The Building Block
# Use case: Rectangle properties, color, dimensions


	new qApp {
	        oQML = new RingQML(NULL) {
	            loadContent(QML_1_2())
	        }
	        exec()
	}
	
	func QML_1_2
	    return "
	        import QtQuick 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 300
	            title: 'The Rectangle - QML Building Block'
	            
	            Rectangle {
	                width: 280
	                height: 150
	                color: '#21618c'
	                anchors.centerIn: parent
	                
	                Text {
	                    text: 'I am inside a Rectangle'
	                    color: 'white'
	                    font.pointSize: 14
	                    anchors.centerIn: parent
	                }
	            }
	        }
	    "
	
	#--> Rectangles are QML's most versatile visual element
	#--> They can contain other elements and serve as containers


/*--- Sample 1.3: Anchoring System - Relative Positioning
# Use case: How QML handles layout without hardcoded positions


	new qApp {
		oQML = new RingQML(NULL)
		oQML.LoadContent(QML_1_3())
	
	        exec()
	}
	
	func QML_1_3
	    return "
	        import QtQuick 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 480
	            height: 300
	            title: 'Anchoring System'
	            color: '#ecf0f1'
	
	            Rectangle {
	                id: topBar
	                width: parent.width
	                height: 60
	                color: '#2c3e50'
	                anchors.top: parent.top
	                
	                Text {
	                    text: 'Top Bar'
	                    color: 'white'
			    font.pointSize: 16
	                    anchors.centerIn: parent
	                }
	            }
	            
	            Rectangle {
	                id: content
	                anchors {
	                    top: topBar.bottom
	                    left: parent.left
	                    right: parent.right
	                    bottom: parent.bottom
	                }
	                color: 'white'
	                
	                Text {
	                    text: 'Content Area - Fills Remaining Space'
			    font.pointSize: 16
	                    anchors.centerIn: parent
	                }
	            }
	        }
	    "
	
	#--> Anchoring creates responsive layouts that adapt to window size
	#--> Elements position themselves relative to parents and siblings
	#--> Resize the window to see how the elements adjust!


#===============================#
#   SECTION 2: LAYOUT MASTERY   #
#===============================#

/*--- Sample 2.1: Column Layout - Vertical Organization
# Use case: Automatic vertical stacking with spacing


	new qApp {
		oQML = new RingQML(NULL)
		oQML.LoadContent(QML_2_1())
	
	        exec()
	}
	
	func QML_2_1
	    return "
	        import QtQuick 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 400
	            title: 'Column Layout'
	            
	            Column {
	                anchors.centerIn: parent
	                spacing: 15
	                
	                Rectangle {
	                    width: 200
	                    height: 60
	                    color: '#e74c3c'
	                    radius: 5
	                    
	                    Text {
	                        text: 'First Item'
	                        color: 'white'
				font.pointSize: 16
	                        anchors.centerIn: parent
	                    }
	                }
	                
	                Rectangle {
	                    width: 200
	                    height: 60
	                    color: '#f39c12'
	                    radius: 5
	                    
	                    Text {
	                        text: 'Second Item'
	                        color: 'white'
				font.pointSize: 16
	                        anchors.centerIn: parent
	                    }
	                }
	                
	                Rectangle {
	                    width: 200
	                    height: 60
	                    color: '#27ae60'
	                    radius: 5
	                    
	                    Text {
	                        text: 'Third Item'
	                        color: 'white'
				font.pointSize: 16
	                        anchors.centerIn: parent
	                    }
	                }
	            }
	        }
	    "
	
	#--> Column automatically arranges children vertically
	#--> Spacing property controls the gap between elements


/*--- Sample 2.2: Row Layout - Horizontal Organization
# Use case: Horizontal arrangement of elements


	new qApp {
		oQML = new RingQML(NULL)
		oQML.LoadContent(QML_2_2())
	
	        exec()
	}
	
	func QML_2_2
	    return "
	        import QtQuick 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 500
	            height: 300
	            title: 'Row Layout'
	            
	            Row {
	                anchors.centerIn: parent
	                spacing: 10
	                
	                Rectangle {
	                    width: 80
	                    height: 80
	                    color: '#9b59b6'
	                    radius: 40
	                }
	                
	                Rectangle {
	                    width: 80
	                    height: 80
	                    color: '#3498db'
	                    radius: 40
	                }
	                
	                Rectangle {
	                    width: 80
	                    height: 80
	                    color: '#1abc9c'
	                    radius: 40
	                }
	            }
	        }
	    "
	
	#--> Row arranges children horizontally
	#--> Perfect for toolbars, button groups, navigation


/*--- Sample 2.3: Grid Layout - Two-Dimensional Organization
# Use case: Grid for structured 2D layouts


	new qApp {
		oQML = new RingQML(NULL)
		oQML.LoadContent(QML_2_3())
	
	        exec()
	}
	
	func QML_2_3
	    return "
	        import QtQuick 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 400
	            title: 'Grid Layout'
	            
	            Grid {
	                anchors.centerIn: parent
	                columns: 3
	                spacing: 10
	                
	                Repeater {
	                    model: 9
	                    
	                    Rectangle {
	                        width: 80
	                        height: 80
	                        color: Qt.hsla((index * 40) / 360, 0.7, 0.6, 1.0)
	                        radius: 5
	                        
	                        Text {
	                            text: (index + 1).toString()
	                            color: 'white'
	                            font.pointSize: 20
	                            anchors.centerIn: parent
	                        }
	                    }
	                }
	            }
	        }
	    "
	
	#--> Grid with columns property creates structured layouts
	#--> Repeater generates multiple elements from a model
	#--> Ideal for dashboards, calculators, image galleries
	

/*--- Sample 2.4: Adaptive Layout - Mobile & Desktop Ready
# Use case: Responsive design based on window dimensions


	new qApp {
	        oQML = new RingQML(NULL) {
	            loadContent(QML_2_4())
	        }
	        exec()
	}

	func QML_2_4
	    return "
	        import QtQuick 2.15
	        import QtQuick.Window 2.15

	        Window {
	            visible: true
	            width: 600
	            height: 400
	            title: 'Adaptive Layout - Resize Window to See Magic!'

	            Rectangle {
	                anchors.fill: parent
	                color: '#ecf0f1'

	                // Dynamic layout based on width
	                Item {
	                    anchors.fill: parent
	                    
	                    Column {
	                        anchors.centerIn: parent
	                        spacing: 15
	                        visible: parent.width < 400
	                        
	                        Rectangle {
	                            width: 250
	                            height: 80
	                            color: '#e74c3c'
	                            radius: 5
	                            Text {
	                                text: 'Mobile Layout'
	                                color: 'white'
	                                font.pointSize: 16
	                                anchors.centerIn: parent
	                            }
	                        }
	                        
	                        Text {
	                            text: 'Vertical Stack\nfor Narrow Screens'
	                            font.pointSize: 14
	                            horizontalAlignment: Text.AlignHCenter
	                            anchors.horizontalCenter: parent.horizontalCenter
	                        }
	                    }
	                    
	                    Row {
	                        anchors.centerIn: parent
	                        spacing: 20
	                        visible: parent.width >= 400
	                        
	                        Rectangle {
	                            width: 150
	                            height: 100
	                            color: '#3498db'
	                            radius: 5
	                            Text {
	                                text: 'Desktop'
	                                color: 'white'
	                                font.pointSize: 16
	                                anchors.centerIn: parent
	                            }
	                        }

	                        Rectangle {
	                            width: 170
	                            height: 100
	                            color: '#27ae60'
	                            radius: 5
	                            Text {
	                                text: 'Wide Screen'
	                                color: 'white'
	                                font.pointSize: 16
	                                anchors.centerIn: parent
	                            }
	                        }
	                        
	                        Text {
	                            text: 'Horizontal Layout\nfor Wide Screens'
	                            font.pointSize: 14
	                            anchors.verticalCenter: parent.verticalCenter
	                        }
	                    }
	                }
	                
	                // Width indicator
	                Text {
	                    text: 'Width: ' + Math.round(parent.width) + 'px'
	                    anchors.bottom: parent.bottom
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    anchors.bottomMargin: 20
	                    font.pointSize: 12
	                    color: '#7f8c8d'
	                }
	            }
	        }
	    "
	
	#--> Visibility binding enables dynamic layout switching
	#--> Layout adapts based on window width
	#--> Essential pattern for mobile/desktop cross-platform apps
	#--> Resize the window to see the layout change!


#====================================#
#   SECTION 3: INTERACTIVE ELEMENTS  #
#====================================#

/*--- Sample 3.1: Button with Hover Effect
# Use case: Interactive visual feedback

	new qApp {
	    oQML = new RingQML(NULL)
	    oQML.LoadContent(QML_3_1())
	
	    exec()
	}
	
	func QML_3_1
	    return "
	        import QtQuick 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 300
	            title: 'Interactive Button'
	            
	            Rectangle {
	                id: button
	                width: 200
	                height: 60
	                color: mouseArea.containsMouse ? '#0b3c5d' : '#3498db'
	                radius: 8
	                anchors.centerIn: parent
	                
	                // Smooth color transition
	                Behavior on color {
	                    ColorAnimation { duration: 200 }
	                }
	                
	                Text {
	                    text: 'Hover Over Me'
	                    color: 'white'
	                    font.pointSize: 14
	                    anchors.centerIn: parent
	                }
	                
	                MouseArea {
	                    id: mouseArea
	                    anchors.fill: parent
	                    hoverEnabled: true
	                    cursorShape: Qt.PointingHandCursor
	                }
	            }
	        }
	    "
	
	#--> MouseArea detects user interaction
	#--> hoverEnabled allows hover state detection
	#--> Behavior on color creates smooth transitions


/*--- Sample 3.2: Text Input Field
# Use case: User text input and real-time updates


	new qApp {
	        oQML = new RingQML(NULL)
	        oQML.LoadContent(QML_3_2())

	        exec()
	}

	func QML_3_2
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 300
	            title: 'Text Input'
	            
	            Column {
	                anchors.centerIn: parent
	                spacing: 20
	                
	                TextField {
	                    id: inputField
	                    width: 300
	                    placeholderText: 'Type something...'
	                    font.pointSize: 12
	                }
	                
	                Text {
	                    text: 'You typed: ' + inputField.text
	                    font.pointSize: 14
	                    width: 300
	                    wrapMode: Text.WordWrap
	                }
	                
	                Text {
	                    text: 'Character count: ' + inputField.text.length
	                    color: '#7f8c8d'
	                    font.pointSize: 10
	                }
	            }
	        }
	    "
	
	#--> TextField provides user text input
	#--> Text binding (inputField.text) creates live updates
	#--> This is QML's reactivity in action!


/*--- Sample 3.3: Slider Control
# Use case: Range input and value binding


	new qApp {
		oQML = new RingQML(NULL)
		oQML.LoadContent(QML_3_3())
	
	        exec()
	}

	func QML_3_3
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 400
	            title: 'Slider Control'
	            
	            Column {
	                anchors.centerIn: parent
	                spacing: 30
	                
	                Text {
	                    text: 'Adjust Rectangle Size'
	                    font.pointSize: 14
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	                
	                Slider {
	                    id: sizeSlider
	                    from: 50
	                    to: 200
	                    value: 100
	                    width: 300
	                }
	                
	                Rectangle {
	                    width: sizeSlider.value
	                    height: sizeSlider.value
	                    color: '#e74c3c'
	                    radius: 10
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    
	                    // Smooth size transition
	                    Behavior on width {
	                        NumberAnimation { duration: 100 }
	                    }
	                    Behavior on height {
	                        NumberAnimation { duration: 100 }
	                    }
	                    
	                    Text {
	                        text: Math.round(sizeSlider.value) + 'px'
	                        color: 'white'
	                        font.pointSize: 12
	                        anchors.centerIn: parent
	                    }
	                }
	            }
	        }
	    "
	
	#--> Slider provides range input
	#--> Direct binding (sizeSlider.value) updates rectangle size
	#--> Behavior adds smooth animation to changes


#==============================#
#   SECTION 4: VISUAL DESIGN   #
#==============================#

/*--- Sample 4.1: Gradients - Beautiful Color Transitions
# Use case: Linear and radial gradients

	new qApp {
		oQML = new RingQML(NULL)
		oQML.LoadContent(QML_4_1())
	
	        exec()
	}
	
	func QML_4_1
	    return "
	        import QtQuick 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 500
	            height: 400
	            title: 'Gradients'
	            
	            Row {
	                anchors.centerIn: parent
	                spacing: 20
	                
	                // Linear Gradient
	                Rectangle {
	                    width: 200
	                    height: 300
	                    radius: 10
	                    
	                    gradient: Gradient {
	                        GradientStop { position: 0.0; color: '#e74c3c' }
	                        GradientStop { position: 1.0; color: '#7b241c' }
	                    }
	                    
	                    Text {
	                        text: 'Linear\nGradient'
	                        color: 'white'
	                        font.pointSize: 16
	                        anchors.centerIn: parent
	                        horizontalAlignment: Text.AlignHCenter
	                    }
	                }
	                
	                // Radial Gradient Effect
	                Rectangle {
	                    width: 200
	                    height: 300
	                    radius: 10
	                    color: '#1b4f72'
	                    
	                    Rectangle {
	                        width: parent.width * 0.8
	                        height: parent.height * 0.8
	                        anchors.centerIn: parent
	                        radius: parent.radius
	                        gradient: Gradient {
	                            GradientStop { position: 0.0; color: '#ffffff' }
	                            GradientStop { position: 1.0; color: 'transparent' }
	                        }
	                        opacity: 0.3
	                    }
	                    
	                    Text {
	                        text: 'Radial\nEffect'
	                        color: 'white'
	                        font.pointSize: 16
	                        anchors.centerIn: parent
	                        horizontalAlignment: Text.AlignHCenter
	                    }
	                }
	            }
	        }
	    "
	
	#--> Gradients add depth and visual interest
	#--> GradientStops define color at specific positions
	#--> Modern UIs often use subtle gradients


/*--- Sample 4.2: Borders and Shadows
# Use case: Visual depth and emphasis

	new qApp {
		oQML = new RingQML(NULL)
		oQML.loadContent(QML_4_2())
	
	        exec()
	}
	
	func QML_4_2
	    return "
	        import QtQuick 2.15
	        import QtQuick.Window 2.15
	        import QtGraphicalEffects 1.15
	        
	        Window {
	            visible: true
	            width: 500
	            height: 300
	            title: 'Borders and Shadows'
	            color: '#ecf0f1'
	            
	            Row {
	                anchors.centerIn: parent
	                spacing: 30
	                
	                // Card with Border
	                Rectangle {
	                    width: 180
	                    height: 200
	                    color: 'white'
	                    radius: 10
	                    border.color: '#3498db'
	                    border.width: 2
	                    
	                    Text {
	                        text: 'Border\nCard'
	                        anchors.centerIn: parent
	                        horizontalAlignment: Text.AlignHCenter
	                        font.pointSize: 14
	                    }
	                }
	                
	                // Card with Shadow
	                Rectangle {
	                    id: shadowCard
	                    width: 180
	                    height: 200
	                    color: 'white'
	                    radius: 10
	                    
	                    layer.enabled: true
	                    layer.effect: DropShadow {
	                        transparentBorder: true
	                        radius: 8.0
	                        samples: 17
	                        color: '#80000000'
	                        verticalOffset: 3
	                    }
	                    
	                    Text {
	                        text: 'Shadow\nCard'
	                        anchors.centerIn: parent
	                        horizontalAlignment: Text.AlignHCenter
	                        font.pointSize: 14
	                    }
	                }
	            }
	        }
	    "
	
	#--> Borders add clear visual boundaries
	#--> DropShadow creates depth perception
	#--> Essential for card-based and modern material design


/*--- Sample 4.3: Icons and Images
# Use case: Visual elements beyond basic shapes


	new qApp {
		oQML = new RingQML(NULL)
		oQML.LoadContent(QML_4_3())

		exec()
	}

	func QML_4_3
	    return "
	        import QtQuick 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 520
	            height: 300
	            title: 'Visual Elements'
	            
	            Column {
	                anchors.centerIn: parent
	                spacing: 20
	                
	                // Icon using Unicode
	                Text {
	                    text: '★ ♥ ⚙ ✓ ⚠'
	                    font.pointSize: 40
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	                
	                // Emoji support
	                Text {
	                    text: '🎨 🚀 💡 🎯 ✨'
	                    font.pointSize: 30
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	                
	                Text {
	                    text: 'QML supports Unicode symbols and emoji!'
	                    font.pointSize: 14
	                    color: '#5f6a6a'
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	            }
	        }
	    "
	
	#--> QML has excellent Unicode and emoji support
	#--> Great for icons without external image files
	#--> For complex icons, use SVG or icon fonts


#====================================#
#   SECTION 5: ANIMATIONS & MOTION   #
#====================================#

/*--- Sample 5.1: Simple Property Animation
# Use case: Animating position changes


	new qApp {
		oQML = new RingQML(NULL)
		oQML.LoadContent(QML_5_1())
	        exec()
	}

	func QML_5_1
	    return "
	        import QtQuick 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 500
	            height: 140
	            title: 'Property Animation'
	            
	            Rectangle {
	                id: box
	                width: 80
	                height: 80
	                color: '#e74c3c'
	                radius: 10
	                y: parent.height / 2 - height / 2
	                
	                Text {
	                    text: '→'
	                    color: 'white'
	                    font.pointSize: 24
	                    anchors.centerIn: parent
	                }
	                
	                // Continuous back-and-forth animation
	                SequentialAnimation on x {
	                    loops: Animation.Infinite
	                    running: true
	                    
	                    NumberAnimation {
	                        from: 50
	                        to: 370
	                        duration: 2000
	                        easing.type: Easing.InOutQuad
	                    }
	                    
	                    NumberAnimation {
	                        from: 370
	                        to: 50
	                        duration: 2000
	                        easing.type: Easing.InOutQuad
	                    }
	                }
	            }
	        }
	    "
	
	#--> SequentialAnimation creates back-and-forth motion
	#--> Easing functions control animation feel
	#--> Animations make UIs feel alive and responsive


/*--- Sample 5.2: Sequential Animation
# Use case: Choreographing multiple animations


	new qApp {
	        oQML = new RingQML(NULL) {
	            loadContent(QML_5_2())
	        }
	        exec()
	}

	func QML_5_2
	    return "
	        import QtQuick 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 400
	            title: 'Sequential Animation'
	            
	            Rectangle {
	                id: animBox
	                width: 60
	                height: 60
	                color: '#9b59b6'
	                radius: 30
	                x: 50
	                y: 50
	                
	                SequentialAnimation on color {
	                    loops: Animation.Infinite
	                    running: true
	                    
	                    ColorAnimation { to: '#e74c3c'; duration: 1000 }
	                    ColorAnimation { to: '#f39c12'; duration: 1000 }
	                    ColorAnimation { to: '#27ae60'; duration: 1000 }
	                    ColorAnimation { to: '#3498db'; duration: 1000 }
	                    ColorAnimation { to: '#9b59b6'; duration: 1000 }
	                }
	                
	                SequentialAnimation on scale {
	                    loops: Animation.Infinite
	                    running: true
	                    
	                    NumberAnimation { to: 1.5; duration: 1000; easing.type: Easing.InOutQuad }
	                    NumberAnimation { to: 1.0; duration: 1000; easing.type: Easing.InOutQuad }
	                }
	            }
	            
	            Text {
	                text: 'Breathing Circle'
	                anchors {
	                    horizontalCenter: parent.horizontalCenter
	                    bottom: parent.bottom
	                    bottomMargin: 40
	                }
	                font.pointSize: 14
	            }
	        }
	    "
	
	#--> SequentialAnimation chains animations
	#--> Multiple properties can animate simultaneously
	#--> Creates engaging, dynamic UIs


/*--- Sample 5.3: Rotation Animation
# Use case: Rotating elements smoothly


	new qApp {
	        oQML = new RingQML(NULL) {
	            loadContent(QML_5_3())
	        }
	        exec()
	}

	func QML_5_3
	    return "
	        import QtQuick 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 300
	            title: 'Rotation Animation'
	            
	            Rectangle {
	                width: 120
	                height: 120
	                color: 'transparent'
	                anchors.centerIn: parent
	                
	                Rectangle {
	                    width: 100
	                    height: 100
	                    color: '#3498db'
	                    radius: 10
	                    anchors.centerIn: parent
	                    
	                    RotationAnimation on rotation {
	                        from: 0
	                        to: 360
	                        duration: 2000
	                        loops: Animation.Infinite
	                        running: true
	                    }
	                    
	                    Text {
	                        text: '⚙'
	                        color: 'white'
	                        font.pointSize: 40
	                        anchors.centerIn: parent
	                    }
	                }
	            }
	        }
	    "
	
	#--> RotationAnimation rotates around element center
	#--> Perfect for loading indicators, spinners
	#--> Continuous rotation with loops: Animation.Infinite


#=====================================#
#   SECTION 6: STATES & TRANSITIONS   #
#=====================================#

/*--- Sample 6.1: Basic States
# Use case: Managing different UI configurations


	new qApp {
	        oQML = new RingQML(NULL) {
	            loadContent(QML_6_1())
	        }
	        exec()
	    }
	
	func QML_6_1
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 300
	            title: 'States'
	            
	            Rectangle {
	                id: statusCard
	                width: 350
	                height: 150
	                color: 'white'
	                radius: 10
	                border.width: 2
	                anchors.centerIn: parent
	                
	                state: 'normal'
	                
	                states: [
	                    State {
	                        name: 'normal'
	                        PropertyChanges {
	                            target: statusCard
	                            border.color: '#3498db'
	                        }
	                        PropertyChanges {
	                            target: statusText
	                            text: 'Normal Status'
	                            color: '#3498db'
	                        }
	                    },
	                    State {
	                        name: 'warning'
	                        PropertyChanges {
	                            target: statusCard
	                            border.color: '#27ae60'
	                        }
	                        PropertyChanges {
	                            target: statusText
	                            text: 'Warning Status'
	                            color: '#27ae60'
	                        }
	                    },
	                    State {
	                        name: 'error'
	                        PropertyChanges {
	                            target: statusCard
	                            border.color: '#e74c3c'
	                        }
	                        PropertyChanges {
	                            target: statusText
	                            text: 'Error Status'
	                            color: '#e74c3c'
	                        }
	                    }
	                ]
	                
	                transitions: [
	                    Transition {
	                        ColorAnimation { duration: 300 }
	                    }
	                ]
	                
	                Column {
	                    anchors.centerIn: parent
	                    spacing: 20
	                    
	                    Text {
	                        id: statusText
	                        font.pointSize: 16
	                        font.bold: true
	                        anchors.horizontalCenter: parent.horizontalCenter
	                    }
	                    
	                    Row {
	                        spacing: 10
	                        anchors.horizontalCenter: parent.horizontalCenter
	                        
	                        Button {
	                            text: 'Normal'
				    font.pointSize: 12
	                            onClicked: statusCard.state = 'normal'
	                        }
	                        Button {
	                            text: 'Warning'
				    font.pointSize: 12
	                            onClicked: statusCard.state = 'warning'
	                        }
	                        Button {
	                            text: 'Error'
				    font.pointSize: 12
	                            onClicked: statusCard.state = 'error'
	                        }
	                    }
	                }
	            }
	        }
	    "
	
	#--> States define different UI configurations
	#--> Transitions animate between states automatically
	#--> Clean way to manage complex UI variations


/*--- Sample 6.2: Expanded/Collapsed State
# Use case: Toggling UI sections


	new qApp {
	        oQML = new RingQML(NULL) {
	            loadContent(QML_6_2())
	        }
	        exec()
	}
	
	func QML_6_2
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 400
	            title: 'Expand/Collapse'
	            
	            Rectangle {
	                id: panel
	                width: 300
	                height: collapsed ? 60 : 250
	                color: '#ecf0f1'
	                radius: 8
	                border.color: '#bdc3c7'
	                border.width: 1
	                anchors.centerIn: parent
	                
	                property bool collapsed: true
	                
	                Behavior on height {
	                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
	                }
	                
	                Column {
	                    anchors.fill: parent
	                    anchors.margins: 10
	                    spacing: 10
	                    
	                    Rectangle {
	                        width: parent.width
	                        height: 40
	                        color: 'transparent'
	                        
	                        Text {
	                            text: 'Panel Title'
	                            font.pointSize: 14
	                            font.bold: true
	                            anchors.left: parent.left
	                            anchors.verticalCenter: parent.verticalCenter
	                        }
	                        
	                        Button {
	                            text: panel.collapsed ? '▼' : '▲'
	                            anchors.right: parent.right
	                            anchors.verticalCenter: parent.verticalCenter
	                            onClicked: panel.collapsed = !panel.collapsed
	                        }
	                    }
	                    
	                    Rectangle {
	                        width: parent.width
	                        height: 170
	                        color: 'white'
	                        radius: 5
	                        visible: !panel.collapsed
	                        
	                        Text {
	                            text: 'Panel Content\n\nThis content is hidden\nwhen collapsed.'
				    font.pointSize: 14
	                            anchors.centerIn: parent
	                            horizontalAlignment: Text.AlignHCenter
	                        }
	                    }
	                }
	            }
	        }
	    "
	
	#--> Property binding controls visibility and size
	#--> Behavior animates property changes automatically
	#--> Common pattern for accordion UIs, collapsible panels


#=========================================#
#   SECTION 7: RING ↔ QML COMMUNICATION   #
#=========================================#

/*--- Sample 7.1: Calling Ring from QML Button
# Use case: QML triggers Ring logic


	new qApp {
	        win = new QQuickView() {
	            setWidth(400)
	            oQML = new RingQML(win) {
	                loadContent(QML_7_1())
	            }
	            show()
	        }
	        exec()
	    }
	
	func HandleButtonClick
	    ? "Button was clicked from QML"
	    ? "Ring code executed successfully"
	    ? "---------------------------------"
	
	func QML_7_1
	    return `
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        
	        Rectangle {
	            width: 400
	            height: 300
	            color: '#ecf0f1'
	            
	            Column {
	                anchors.centerIn: parent
	                spacing: 20
	                
	                Text {
	                    text: 'QML → Ring Communication'
	                    font.pointSize: 16
	                    font.bold: true
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	                
	                Button {
	                    text: 'Click to Call Ring Function'
			    font.pointSize: 12
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    onClicked: {
	                        Ring.callFunc("HandleButtonClick", [])
	                    }
	                }
	                
	                Text {
	                    text: 'Check console for output'
	                    font.pointSize: 12
	                    color: '#7f8c8d'
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	            }
	        }
	    `

	#--> Ring.callFunc() executes Ring functions from QML
	#--> First parameter is function name as string
	#--> Second parameter is array of arguments
	#--> Output: Console shows Ring execution confirmation


/*--- Sample 7.2: Ring Function with Return Value
# Use case: Getting data back from Ring


	new qApp {
	        win = new QQuickView() {
	            setWidth(450)
		    setHeight(340)
	            oQML = new RingQML(win) {
	                loadContent(QML_7_2())
	            }
	            show()
	        }
	        exec()
	}
	
	func CalculateSum(n1, n2)
	    nSum = n1 + n2
	    ? "Ring calculated: " + n1 + " + " + n2 + " = " + nSum
	    return nSum
	
	func QML_7_2
	    return `
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        
	        Rectangle {
	            color: '#ecf0f1'
	            
	            Column {
	                anchors.centerIn: parent
	                spacing: 15
	                
	                Text {
	                    text: 'Ring Function with Return Value'
	                    font.pointSize: 14
	                    font.bold: true
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	                
	                Row {
	                    spacing: 10
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    
	                    TextField {
	                        id: input1
	                        width: 80
				font.pointSize: 16
	                        text: '5'
	                        validator: IntValidator {}
	                    }
	                    
	                    Text {
	                        text: '+'
	                        font.pointSize: 20
	                        anchors.verticalCenter: parent.verticalCenter
	                    }
	                    
	                    TextField {
	                        id: input2
	                        width: 80
				font.pointSize: 16
	                        text: '3'
	                        validator: IntValidator {}
	                    }
	                }
	                
	                Button {
	                    text: 'Calculate in Ring'
			    font.pointSize: 16
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    onClicked: {
	                        var result = Ring.callFunc("CalculateSum", 
	                            [parseInt(input1.text), parseInt(input2.text)])
	                        resultText.text = 'Result: ' + result
	                    }
	                }
	                
	                Text {
	                    id: resultText
	                    text: 'Result: -'
	                    font.pointSize: 16
	                    color: '#922b21'
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	            }
	        }
	    `
	
	#--> Ring functions can return values to QML
	#--> Return value captured in JavaScript variable
	#--> Enables powerful Ring computation from QML


/*--- Sample 7.3: Ring Setting QML Properties
# Use case: Ring controls QML elements

	nCounter = 0

	new qApp {
	        win = new QQuickView() {
	            setWidth(400)
		    setHeight(400)

	            oQML = new RingQML(win) {
	                loadContent(QML_7_3())
	            }

	            show()
	        }

	        exec()
	}

	func IncrementCounter
	    nCounter++
	    see "Counter incremented: " + nCounter + nl
	
	func QML_7_3
	    return `
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        
	        Rectangle {
	            width: 400
	            height: 300
	            color: '#ecf0f1'
	            
	            Column {
	                anchors.centerIn: parent
	                spacing: 20
	                
	                Text {
	                    text: 'Ring Variable Bridge'
	                    font.pointSize: 14
	                    font.bold: true
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	                
	                Rectangle {
	                    width: 200
	                    height: 100
	                    color: '#3498db'
	                    radius: 10
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    
	                    Text {
	                        id: counterDisplay
	                        text: '0'
	                        font.pointSize: 40
	                        color: 'white'
	                        anchors.centerIn: parent
	                    }
	                }
	                
	                Button {
	                    text: 'Increment via Ring'
			    font.pointSize: 12
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    onClicked: {
	                        Ring.callFunc("IncrementCounter", [])
	                        counterDisplay.text = Ring.getVar("nCounter")
	                    }
	                }
	            }
	        }
	    `
	
	#--> Ring.getVar() retrieves Ring variable values
	#--> Ring.setVar() can set Ring variables from QML
	#--> Creates a data bridge between Ring and QML


/*--- Sample 7.4: Complete Ring-QML Interaction
# Use case: Bidirectional communication pattern


	$cUserName = "Guest"
	$aMessages = []
	
	new qApp {
	    win = new QQuickView() {
	        setWidth(500)
	        setHeight(400)
	        oQML = new RingQML(win) {
	            loadContent(QML_7_4())
	        }
	        show()
	    }
	    exec()
	}
	
	
	func UpdateUserName(cNewName)
	    $cUserName = cNewName
	    ? "$Username updated to: " + cNewName
	
	func SendMessage(cMessage)
	    if len(cMessage) > 0
	        $aMessages + ($cUserName + ": " +cMessage)
	        ? "Message added: " + cMessage
	    ok
	    return $aMessages
	
	func QML_7_4
	    return `
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        
	        Rectangle {
	            width: 500
	            height: 400
	            color: '#ecf0f1'
	            
	            Column {
	                anchors.fill: parent
	                anchors.margins: 20
	                spacing: 15
	                
	                Text {
	                    text: 'Chat Application Pattern'
	                    font.pointSize: 16
	                    font.bold: true
	                }
	                
	                Row {
	                    width: parent.width
	                    spacing: 10
	                    
	                    Text {
	                        text: 'Username:'
	                        font.pointSize: 12
	                        anchors.verticalCenter: parent.verticalCenter
	                    }
	                    
	                    TextField {
	                        id: nameInput
	                        width: 150
	                        font.pointSize: 12
	                        text: 'Guest'
	                        onTextChanged: {
	                            Ring.callFunc("UpdateUserName", [text])
	                        }
	                    }
	                }
	                
	                Rectangle {
	                    width: parent.width
	                    height: 200
	                    color: 'white'
	                    radius: 5
	                    border.color: '#bdc3c7'
	
	                    ScrollView {
	                        anchors.fill: parent
	                        anchors.margins: 10
	                        
	                        Column {
	                            id: messageList
	                            spacing: 5
	                            width: parent.width
	                        }
	                    }
	                }
	                
	                Row {
	                    width: parent.width
	                    spacing: 10
	                    
	                    TextField {
	                        id: messageInput
	                        width: parent.width - sendBtn.width - 10
	                        font.pointSize: 12
	                        placeholderText: 'Type a message...'
	                    }
	                    
	                    Button {
	                        id: sendBtn
	                        text: 'Send'
	                        font.pointSize: 12
	                        onClicked: {
	                            var messages = Ring.callFunc("SendMessage", [messageInput.text])
	                            updateMessageList(messages)
	                            messageInput.text = ''
	                        }
	                    }
	                }
	            }
	            
	            function updateMessageList(messages) {
	                // Clear existing messages
	                for (var i = messageList.children.length - 1; i >= 0; i--) {
	                    messageList.children[i].destroy()
	                }
	                
	                // Add all messages with proper formatting
	                for (var j = 0; j < messages.length; j++) {
	                    // Escape quotes and newlines for safe QML string creation
	                    var safeText = JSON.stringify(messages[j]);
	                    var msg = Qt.createQmlObject(
	                        'import QtQuick 2.15; Text { ' +
	                        'text: ' + safeText + '; ' +
	                        'width: parent.width; ' +
	                        'wrapMode: Text.WordWrap; ' +
	                        'font.pointSize: 12 ' +
	                        '}',
	                        messageList,
	                        "dynamicMessage"
	                    )
	                }
	            }
	        }
	    `
	
	#--> Demonstrates complete Ring-QML application pattern
	#--> Ring manages data (username, messages)
	#--> QML handles UI and user interaction
	#--> Functions bridge the two worlds seamlessly


#==========================================#
#   SECTION 8: DATA BINDING & REACTIVITY   #
#==========================================#

/*--- Sample 8.1: Property Bindings
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


/*--- Sample 8.2: Computed Properties
# Use case: Deriving values from other properties


	new qApp {
	        oQML = new RingQML(NULL) {
	            loadContent(QML_8_2())
	        }
	        exec()
	}
	
	func QML_8_2
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 350
	            title: 'Computed Properties'
	            
	            Rectangle {
	                anchors.fill: parent
	                color: '#ecf0f1'
	                
	                Column {
	                    anchors.centerIn: parent
	                    spacing: 20
	                    
	                    Text {
	                        text: 'BMI Calculator'
	                        font.pointSize: 16
	                        font.bold: true
	                        anchors.horizontalCenter: parent.horizontalCenter
	                    }
	                    
	                    Row {
	                        spacing: 10
	                        anchors.horizontalCenter: parent.horizontalCenter
	                        
	                        Text {
	                            text: 'Weight (kg):'
				    font.pointSize: 12
	                            anchors.verticalCenter: parent.verticalCenter
	                        }
	                        TextField {
	                            id: weightInput
	                            width: 100
				    font.pointSize: 12
	                            text: '70'
	                            validator: DoubleValidator { bottom: 0; top: 500 }
	                        }
	                    }
	                    
	                    Row {
	                        spacing: 10
	                        anchors.horizontalCenter: parent.horizontalCenter
	                        
	                        Text {
	                            text: 'Height (cm):'
				    font.pointSize: 12
	                            anchors.verticalCenter: parent.verticalCenter
	                        }
	                        TextField {
	                            id: heightInput
	                            width: 100
				    font.pointSize: 12
	                            text: '175'
	                            validator: DoubleValidator { bottom: 0; top: 300 }
	                        }
	                    }
	                    
	                    Rectangle {
	                        width: 250
	                        height: 80
	                        color: bmiValue < 18.5 ? '#3498db' : 
	                               bmiValue < 25 ? '#27ae60' :
	                               bmiValue < 30 ? '#f39c12' : '#e74c3c'
	                        radius: 10
	                        anchors.horizontalCenter: parent.horizontalCenter
	                        
	                        property real bmiValue: {
	                            var w = parseFloat(weightInput.text)
	                            var h = parseFloat(heightInput.text) / 100
	                            if (w > 0 && h > 0) {
	                                return w / (h * h)
	                            }
	                            return 0
	                        }
	                        
	                        Behavior on color {
	                            ColorAnimation { duration: 300 }
	                        }
	                        
	                        Column {
	                            anchors.centerIn: parent
	                            spacing: 5
	                            
	                            Text {
	                                text: 'BMI: ' + parent.parent.bmiValue.toFixed(1)
	                                font.pointSize: 20
	                                font.bold: true
	                                color: 'white'
	                                anchors.horizontalCenter: parent.horizontalCenter
	                            }
	                            
	                            Text {
	                                text: parent.parent.bmiValue < 18.5 ? 'Underweight' :
	                                      parent.parent.bmiValue < 25 ? 'Normal' :
	                                      parent.parent.bmiValue < 30 ? 'Overweight' : 'Obese'
	                                color: 'white'
	                                anchors.horizontalCenter: parent.horizontalCenter
	                            }
	                        }
	                    }
	                }
	            }
	        }
	    "
	
	#--> Computed properties derive values from inputs
	#--> Ternary operators enable conditional logic
	#--> All updates happen automatically through bindings


/*--- Sample 8.3: ListModel and Repeater
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

/*--- Sample 9.1: Custom Reusable Component
# Use case: Component definition and reuse


	new qApp {
	        win = new QQuickView() {
	            setWidth(500)
		    setHeight(350)
	            oQML = new RingQML(win) {
	                NewComponent("ColorCard", GetColorCardComponent())
	                loadContent(QML_9_1())
	            }
	            show()
	        }
	        exec()
	}
	
	func GetColorCardComponent
	    return `
	        import QtQuick 2.15
	        
	        Rectangle {
	            id: card
	            width: 140
	            height: 100
	            radius: 10
	            
	            property string cardColor: '#3498db'
	            property string cardTitle: 'Card'
	            
	            color: cardColor
	            
	            Text {
	                text: cardTitle
	                color: 'white'
	                font.pointSize: 14
	                font.bold: true
	                anchors.centerIn: parent
	            }
	            
	            MouseArea {
	                anchors.fill: parent
	                hoverEnabled: true
	                onEntered: card.scale = 1.05
	                onExited: card.scale = 1.0
	            }
	            
	            Behavior on scale {
	                NumberAnimation { duration: 150 }
	            }
	        }
	    `
	
	func QML_9_1
	    return `
	        import QtQuick 2.15
	        
	        Rectangle {
	            width: 500
	            height: 400
	            color: '#ecf0f1'
	            
	            Column {
	                anchors.centerIn: parent
	                spacing: 20
	                
	                Text {
	                    text: 'Reusable Components'
	                    font.pointSize: 16
	                    font.bold: true
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	                
	                Grid {
	                    columns: 3
	                    spacing: 15
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    
	                    ColorCard {
	                        cardColor: '#e74c3c'
	                        cardTitle: 'Red'
	                    }
	                    
	                    ColorCard {
	                        cardColor: '#f39c12'
	                        cardTitle: 'Orange'
	                    }
	                    
	                    ColorCard {
	                        cardColor: '#f1c40f'
	                        cardTitle: 'Yellow'
	                    }
	                    
	                    ColorCard {
	                        cardColor: '#27ae60'
	                        cardTitle: 'Green'
	                    }
	                    
	                    ColorCard {
	                        cardColor: '#3498db'
	                        cardTitle: 'Blue'
	                    }
	                    
	                    ColorCard {
	                        cardColor: '#9b59b6'
	                        cardTitle: 'Purple'
	                    }
	                }
	            }
	        }
	    `
	
	#--> NewComponent() registers reusable QML components
	#--> Components have properties for customization
	#--> Promotes DRY principle and maintainability


/*--- Sample 9.2: Timer and Periodic Updates
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


/*--- Sample 9.3: Drawer Navigation Pattern
# Use case: Modern mobile navigation


	new qApp {
	        oQML = new RingQML(NULL) {
	            loadContent(QML_9_3())
	        }
	        exec()
	}
	
	func QML_9_3
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 600
	            title: 'Drawer Navigation'
	            
	            Rectangle {
	                id: mainContainer
	                anchors.fill: parent
	                
	                // App Bar
	                Rectangle {
	                    id: appBar
	                    width: parent.width
	                    height: 60
	                    color: '#2c3e50'
	                    z: 2
	                    
	                    Row {
	                        anchors.fill: parent
	                        anchors.margins: 10
	                        spacing: 15
	                        
	                        Rectangle {
	                            width: 40
	                            height: 40
	                            color: 'transparent'
	                            anchors.verticalCenter: parent.verticalCenter
	                            
	                            Text {
	                                text: '☰'
	                                color: 'white'
	                                font.pointSize: 24
	                                anchors.centerIn: parent
	                            }
	                            
	                            MouseArea {
	                                anchors.fill: parent
	                                onClicked: drawer.visible = !drawer.visible
	                            }
	                        }
	                        
	                        Text {
	                            text: 'My Application'
	                            color: 'white'
	                            font.pointSize: 16
	                            font.bold: true
	                            anchors.verticalCenter: parent.verticalCenter
	                        }
	                    }
	                }
	                
	                // Content Area
	                Rectangle {
	                    anchors {
	                        top: appBar.bottom
	                        left: parent.left
	                        right: parent.right
	                        bottom: parent.bottom
	                    }
	                    color: '#ecf0f1'
	                    
	                    Text {
	                        id: contentText
	                        text: 'Home Screen\n\nTap menu icon to open drawer'
	                        anchors.centerIn: parent
	                        horizontalAlignment: Text.AlignHCenter
	                        font.pointSize: 14
	                    }
	                }
	                
	                // Drawer
	                Rectangle {
	                    id: drawer
	                    width: parent.width * 0.7
	                    height: parent.height
	                    color: 'white'
	                    visible: false
	                    z: 3
	                    
	                    Behavior on x {
	                        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
	                    }
	                    
	                    Column {
	                        anchors.fill: parent
	                        
	                        Rectangle {
	                            width: parent.width
	                            height: 150
	                            color: '#3498db'
	                            
	                            Text {
	                                text: 'Menu'
	                                color: 'white'
	                                font.pointSize: 24
	                                font.bold: true
	                                anchors.centerIn: parent
	                            }
	                        }
	                        
	                        Repeater {
	                            model: ['Home', 'Profile', 'Settings', 'About']
	                            
	                            Rectangle {
	                                width: parent.width
	                                height: 60
	                                color: itemMouse.containsMouse ? '#ecf0f1' : 'white'
	                                
	                                Text {
	                                    text: modelData
	                                    anchors.left: parent.left
	                                    anchors.leftMargin: 20
	                                    anchors.verticalCenter: parent.verticalCenter
	                                    font.pointSize: 14
	                                }
	                                
	                                MouseArea {
	                                    id: itemMouse
	                                    anchors.fill: parent
	                                    hoverEnabled: true
	                                    onClicked: {
	                                        contentText.text = modelData + ' Screen'
	                                        drawer.visible = false
	                                    }
	                                }
	                            }
	                        }
	                    }
	                }
	                
	                // Overlay when drawer is open
	                Rectangle {
	                    anchors.fill: parent
	                    color: '#000000'
	                    opacity: drawer.visible ? 0.5 : 0
	                    visible: opacity > 0
	                    z: 2
	                    
	                    Behavior on opacity {
	                        NumberAnimation { duration: 250 }
	                    }
	                    
	                    MouseArea {
	                        anchors.fill: parent
	                        onClicked: drawer.visible = false
	                    }
	                }
	            }
	        }
	    "
	
	#--> Drawer pattern is essential for mobile apps
	#--> Overlay dims background when drawer is open
	#--> Smooth animations create polished feel
	

#===============================================#
#   SECTION 10: COMPLETE APPLICATION EXAMPLE    #
#===============================================#

/*--- Sample 10.1: Task Manager Application
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

/*--- Sample 11.1: ComboBox (Dropdown Selection)
# Use case: Selection from predefined options

	new qApp {
	    oQML = new RingQML(NULL) {
	        loadContent(QML_11_2())
	    }
	    exec()
	}
	
	func QML_11_2
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 450
	            height: 350
	            title: 'ComboBox & Selection Controls'
	            
	            Column {
	                anchors.centerIn: parent
	                spacing: 25
	                
	                Text {
	                    text: 'Select Your Preferences'
	                    font.pointSize: 16
	                    font.bold: true
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	                
	                Row {
	                    spacing: 15
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    
	                    Text {
	                        text: 'Theme:'
	                        font.pointSize: 12
	                        anchors.verticalCenter: parent.verticalCenter
	                    }
	                    
	                    ComboBox {
	                        id: themeCombo
	                        width: 200
	                        model: ['Light', 'Dark', 'Auto', 'High Contrast']
	                        font.pointSize: 11
	                        
	                        onCurrentTextChanged: {
	                            selectionText.text = 'Selected: ' + themeCombo.currentText + 
	                                               ' theme at index ' + themeCombo.currentIndex
	                        }
	                    }
	                }
	                
	                Row {
	                    spacing: 15
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    
	                    Text {
	                        text: 'Language:'
	                        font.pointSize: 12
	                        anchors.verticalCenter: parent.verticalCenter
	                    }
	                    
	                    ComboBox {
	                        id: langCombo
	                        width: 200
	                        model: ListModel {
	                            ListElement { text: 'English'; code: 'en' }
	                            ListElement { text: 'العربية'; code: 'ar' }
	                            ListElement { text: 'Français'; code: 'fr' }
	                            ListElement { text: 'Español'; code: 'es' }
	                        }
	                        textRole: 'text'
	                        font.pointSize: 11
	                    }
	                }
	                
	                Rectangle {
	                    width: 350
	                    height: 80
	                    color: '#ecf0f1'
	                    radius: 8
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    
	                    Text {
	                        id: selectionText
	                        text: 'Make a selection...'
	                        font.pointSize: 12
	                        anchors.centerIn: parent
	                        wrapMode: Text.WordWrap
	                        width: parent.width - 20
	                        horizontalAlignment: Text.AlignHCenter
	                    }
	                }
	            }
	        }
	    "
	
	#--> ComboBox for dropdown selections
	#--> Can use simple string arrays or ListModel with roles
	#--> Essential for forms and settings


/*--- Sample 11.2: CheckBox and RadioButton
# Use case: Boolean and exclusive selections

	new qApp {
	    oQML = new RingQML(NULL) {
	        loadContent(QML_11_3())
	    }
	    exec()
	}
	
	func QML_11_3
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 680
	            title: 'CheckBox & RadioButton'
	            
	            Column {
	                anchors.fill: parent
	                anchors.margins: 30
	                spacing: 25
	                
	                Text {
	                    text: 'Order Configuration'
	                    font.pointSize: 16
	                    font.bold: true
	                }
	                
	                Rectangle {
	                    width: parent.width
	                    height: 1
	                    color: '#bdc3c7'
	                }
	                
	                Text {
	                    text: 'Select extras (multiple):'
	                    font.pointSize: 13
	                    font.bold: true
	                }
	                
	                Column {
	                    spacing: 10
	                    
	                    CheckBox {
	                        id: extraCheese
	                        text: 'Extra Cheese (+$2)'
	                        font.pointSize: 11
	                        checked: false
	                    }
	                    
	                    CheckBox {
	                        id: extraSauce
	                        text: 'Extra Sauce (+$1)'
	                        font.pointSize: 11
	                    }
	                    
	                    CheckBox {
	                        id: gluten
	                        text: 'Gluten Free (+$3)'
	                        font.pointSize: 11
	                    }
	                }
	                
	                Rectangle {
	                    width: parent.width
	                    height: 1
	                    color: '#bdc3c7'
	                }
	                
	                Text {
	                    text: 'Select size (one only):'
	                    font.pointSize: 13
	                    font.bold: true
	                }
	                
	                Column {
	                    spacing: 10
	                    
	                    RadioButton {
	                        id: sizeSmall
	                        text: 'Small ($10)'
	                        font.pointSize: 11
	                        checked: true
	                    }
	                    
	                    RadioButton {
	                        id: sizeMedium
	                        text: 'Medium ($15)'
	                        font.pointSize: 11
	                    }
	                    
	                    RadioButton {
	                        id: sizeLarge
	                        text: 'Large ($20)'
	                        font.pointSize: 11
	                    }
	                }
	                
	                Rectangle {
	                    width: parent.width
	                    height: 80
	                    color: '#3498db'
	                    radius: 10
	                    
	                    Column {
	                        anchors.centerIn: parent
	                        spacing: 5
	                        
	                        Text {
	                            text: 'Total: ' + calculateTotal()
	                            color: 'white'
	                            font.pointSize: 20
	                            font.bold: true
	                            anchors.horizontalCenter: parent.horizontalCenter
	                        }
	                        
	                        Text {
	                            text: getOrderSummary()
	                            color: 'white'
	                            font.pointSize: 10
	                            anchors.horizontalCenter: parent.horizontalCenter
	                        }
	                    }
	                }
	            }
	            
	            function calculateTotal() {
	                var total = 0
	                if (sizeSmall.checked) total = 10
	                if (sizeMedium.checked) total = 15
	                if (sizeLarge.checked) total = 20
	                
	                if (extraCheese.checked) total += 2
	                if (extraSauce.checked) total += 1
	                if (gluten.checked) total += 3
	                
	                return total
	            }
	            
	            function getOrderSummary() {
	                var extras = []
	                if (extraCheese.checked) extras.push('Cheese')
	                if (extraSauce.checked) extras.push('Sauce')
	                if (gluten.checked) extras.push('GF')
	                
	                return extras.length > 0 ? 'With: ' + extras.join(', ') : 'No extras'
	            }
	        }
	    "
	
	#--> CheckBox for multiple selections
	#--> RadioButton for exclusive choices
	#--> Calculated properties update automatically


/*--- Sample 11.3: SpinBox and ProgressBar
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


/*--- Sample 11.4: TabBar/TabView Navigation
# Use case: Organizing content in tabs

	new qApp {
	    oQML = new RingQML(NULL) {
	        loadContent(QML_11_5())
	    }
	    exec()
	}
	
	func QML_11_5
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        import QtQuick.Layouts 1.15
	        
	        Window {
	            visible: true
	            width: 500
	            height: 400
	            title: 'TabBar Navigation'
	            
	            ColumnLayout {
	                anchors.fill: parent
	                spacing: 0
	                
	                TabBar {
	                    id: tabBar
	                    Layout.fillWidth: true
	                    
	                    TabButton {
	                        text: '🏠 Home'
	                        font.pointSize: 12
	                    }
	                    TabButton {
	                        text: '📊 Dashboard'
	                        font.pointSize: 12
	                    }
	                    TabButton {
	                        text: '⚙ Settings'
	                        font.pointSize: 12
	                    }
	                    TabButton {
	                        text: '👤 Profile'
	                        font.pointSize: 12
	                    }
	                }
	                
	                StackLayout {
	                    Layout.fillWidth: true
	                    Layout.fillHeight: true
	                    currentIndex: tabBar.currentIndex
		                    
		                    Rectangle {
		                        color: '#ecf0f1'
		                        Text {
		                            text: 'Home Screen\n\nWelcome back!'
		                            font.pointSize: 18
		                            anchors.centerIn: parent
		                            horizontalAlignment: Text.AlignHCenter
		                        }
		                    }
		                    
		                    Rectangle {
		                        color: '#e8f8f5'
		                        Column {
		                            anchors.centerIn: parent
		                            spacing: 15
		                            
		                            Text {
		                                text: '📈 Dashboard'
		                                font.pointSize: 20
		                                font.bold: true
		                                anchors.horizontalCenter: parent.horizontalCenter
		                            }
		                            
		                            Row {
		                                spacing: 20
		                                anchors.horizontalCenter: parent.horizontalCenter
		                                
		                                Rectangle {
		                                    width: 100
		                                    height: 100
		                                    color: '#3498db'
		                                    radius: 10
		                                    
		                                    Column {
		                                        anchors.centerIn: parent
		                                        Text {
		                                            text: '1,234'
		                                            color: 'white'
		                                            font.pointSize: 20
		                                            font.bold: true
		                                            anchors.horizontalCenter: parent.horizontalCenter
		                                        }
		                                        Text {
		                                            text: 'Users'
		                                            color: 'white'
		                                            font.pointSize: 10
		                                            anchors.horizontalCenter: parent.horizontalCenter
		                                        }
		                                    }
		                                }
		                                
		                                Rectangle {
		                                    width: 100
		                                    height: 100
		                                    color: '#27ae60'
		                                    radius: 10
		                                    
		                                    Column {
		                                        anchors.centerIn: parent
		                                        Text {
		                                            text: '567'
		                                            color: 'white'
		                                            font.pointSize: 20
		                                            font.bold: true
		                                            anchors.horizontalCenter: parent.horizontalCenter
		                                        }
		                                        Text {
		                                            text: 'Sales'
		                                            color: 'white'
		                                            font.pointSize: 10
		                                            anchors.horizontalCenter: parent.horizontalCenter
		                                        }
		                                    }
		                                }
		                            }
		                        }
		                    }
		                    
		                    Rectangle {
		                        color: '#fef5e7'
		                        Column {
		                            anchors.centerIn: parent
		                            spacing: 20
		                            
		                            Text {
		                                text: '⚙ Settings'
		                                font.pointSize: 20
		                                font.bold: true
		                            }
		                            
		                            Switch {
		                                text: 'Enable notifications'
		                                font.pointSize: 12
		                            }
		                            
		                            Switch {
		                                text: 'Dark mode'
		                                font.pointSize: 12
		                            }
		                            
		                            Switch {
		                                text: 'Auto-save'
		                                font.pointSize: 12
		                                checked: true
		                            }
		                        }
		                    }
		                    
		                    Rectangle {
		                        color: '#fdeef3'
		                        Column {
		                            anchors.centerIn: parent
		                            spacing: 15
		                            
		                            Rectangle {
		                                width: 100
		                                height: 100
		                                color: '#9b59b6'
		                                radius: 50
		                                anchors.horizontalCenter: parent.horizontalCenter
		                                
		                                Text {
		                                    text: '👤'
		                                    font.pointSize: 40
		                                    anchors.centerIn: parent
		                                }
		                            }
		                            
		                            Text {
		                                text: 'John Doe'
		                                font.pointSize: 18
		                                font.bold: true
		                                anchors.horizontalCenter: parent.horizontalCenter
		                            }
		                            
		                            Text {
		                                text: 'john.doe@example.com'
		                                font.pointSize: 11
		                                color: '#7f8c8d'
		                                anchors.horizontalCenter: parent.horizontalCenter
		                            }
		                        }
		                    }
		                }
		            }
		        }
		    "
		
		#--> TabBar provides tab navigation
		#--> StackLayout switches views based on currentIndex
		#--> Perfect for multi-section applications


#======================================#
#   SECTION 12: DATA DISPLAY PATTERNS  #
#======================================#

/*--- Sample 12.1: TableView with Grid Data
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
	

/*--- Sample 12.2: GridView with Cards
# Use case: Grid layout of items (photo gallery, products)
#TODO Adjust the offset after the bar title


	new qApp {
	    oQML = new RingQML(NULL) {
	        loadContent(QML_12_2())
	    }
	    exec()
	}
	
	func QML_12_2
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 550
	            height: 600
	            title: 'Product Grid'
	            
	            Column {
	                anchors.fill: parent
	                
	                Rectangle {
	                    width: parent.width
	                    height: 60
	                    color: '#2c3e50'
	                    
	                    Text {
	                        text: 'Product Catalog'
	                        color: 'white'
	                        font.pointSize: 18
	                        font.bold: true
	                        anchors.centerIn: parent
	                    }
	                }
	                
	                GridView {
	                    id: productGrid
	                    width: parent.width
	                    height: parent.height - 60
	                    cellWidth: 180
	                    cellHeight: 220
	                    clip: true
	                    
	                    model: ListModel {
	                        ListElement { name: 'Laptop Pro'; price: 1299; emoji: '💻'; rating: 5 }
	                        ListElement { name: 'Wireless Mouse'; price: 49; emoji: '🖱'; rating: 4 }
	                        ListElement { name: 'Keyboard RGB'; price: 129; emoji: '⌨'; rating: 5 }
	                        ListElement { name: 'Monitor 4K'; price: 599; emoji: '🖥'; rating: 4 }
	                        ListElement { name: 'Headphones'; price: 199; emoji: '🎧'; rating: 5 }
	                        ListElement { name: 'Webcam HD'; price: 89; emoji: '📷'; rating: 3 }
	                        ListElement { name: 'USB Hub'; price: 35; emoji: '🔌'; rating: 4 }
	                        ListElement { name: 'Desk Lamp'; price: 45; emoji: '💡'; rating: 4 }
	                        ListElement { name: 'Phone Stand'; price: 25; emoji: '📱'; rating: 5 }
	                    }
	                    
	                    delegate: Rectangle {
	                        width: productGrid.cellWidth - 10
	                        height: productGrid.cellHeight - 10
	                        color: 'white'
	                        radius: 10
	                        border.color: cardMouse.containsMouse ? '#3498db' : '#ecf0f1'
	                        border.width: 2
	                        
	                        Behavior on border.color {
	                            ColorAnimation { duration: 200 }
	                        }
	                        
	                        Column {
	                            anchors.centerIn: parent
	                            spacing: 10
	                            
	                            Text {
	                                text: emoji
	                                font.pointSize: 48
	                                anchors.horizontalCenter: parent.horizontalCenter
	                            }
	                            
	                            Text {
	                                text: name
	                                font.pointSize: 12
	                                font.bold: true
	                                anchors.horizontalCenter: parent.horizontalCenter
	                            }
	                            
	                            Text {
	                                text: price
	                                font.pointSize: 16
	                                color: '#27ae60'
	                                font.bold: true
	                                anchors.horizontalCenter: parent.horizontalCenter
	                            }
	                            
	                            Row {
	                                spacing: 3
	                                anchors.horizontalCenter: parent.horizontalCenter
	                                
	                                Repeater {
	                                    model: 5
	                                    Text {
	                                        text: index < rating ? '★' : '☆'
	                                        color: index < rating ? '#f39c12' : '#bdc3c7'
	                                        font.pointSize: 10
	                                    }
	                                }
	                            }
	                        }
	                        
	                        MouseArea {
	                            id: cardMouse
	                            anchors.fill: parent
	                            hoverEnabled: true
	                            cursorShape: Qt.PointingHandCursor
	                        }
	                    }
	                }
	            }
	        }
	    "
	
	#--> GridView arranges items in grid layout
	#--> cellWidth and cellHeight control grid spacing
	#--> Perfect for catalogs, galleries, dashboards


/*--- Sample 12.3: SwipeView with Pages
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


/*--- Sample 12.4: Hierarchical Data with Expandable Lists
# Use case: Tree-like data structures


	new qApp {
	    oQML = new RingQML(NULL) {
	        loadContent(QML_12_4())
	    }
	    exec()
	}
	
	func QML_12_4
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 500
	            title: 'File Explorer'
	            
	            component FolderItem: Column {
	                id: folderItem
	                width: parent.width
	                
	                property string folderName: 'Folder'
	                property string folderIcon: '📁'
	                property int itemCount: 0
	                property bool isExpanded: false
	                
	                Rectangle {
	                    width: parent.width
	                    height: 50
	                    color: folderMouse.containsMouse ? '#ecf0f1' : 'white'
	                    
	                    Row {
	                        anchors.fill: parent
	                        anchors.leftMargin: 15
	                        spacing: 10
	                        
	                        Text {
	                            text: folderItem.isExpanded ? '▼' : '▶'
	                            font.pointSize: 10
	                            anchors.verticalCenter: parent.verticalCenter
	                            color: '#7f8c8d'
	                        }
	                        
	                        Text {
	                            text: folderItem.folderIcon
	                            font.pointSize: 20
	                            anchors.verticalCenter: parent.verticalCenter
	                        }
	                        
	                        Column {
	                            anchors.verticalCenter: parent.verticalCenter
	                            spacing: 2
	                            
	                            Text {
	                                text: folderItem.folderName
	                                font.pointSize: 12
	                                font.bold: true
	                            }
	                            
	                            Text {
	                                text: folderItem.itemCount + ' items'
	                                font.pointSize: 9
	                                color: '#95a5a6'
	                            }
	                        }
	                    }
	                    
	                    MouseArea {
	                        id: folderMouse
	                        anchors.fill: parent
	                        hoverEnabled: true
	                        cursorShape: Qt.PointingHandCursor
	                        onClicked: {
	                            folderItem.isExpanded = !folderItem.isExpanded
	                        }
	                    }
	                }
	                
	                Column {
	                    width: parent.width
	                    visible: folderItem.isExpanded
	                    
	                    Repeater {
	                        model: Math.min(folderItem.itemCount, 5)
	                        
	                        Rectangle {
	                            width: folderItem.width
	                            height: 40
	                            color: index % 2 === 0 ? '#fafafa' : 'white'
	                            
	                            Row {
	                                anchors.fill: parent
	                                anchors.leftMargin: 60
	                                spacing: 10
	                                
	                                Text {
	                                    text: '📄'
	                                    font.pointSize: 14
	                                    anchors.verticalCenter: parent.verticalCenter
	                                }
	                                
	                                Text {
	                                    text: 'File_' + (index + 1) + '.txt'
	                                    font.pointSize: 10
	                                    anchors.verticalCenter: parent.verticalCenter
	                                }
	                            }
	                        }
	                    }
	                    
	                    Rectangle {
	                        width: parent.width
	                        height: 30
	                        color: '#ecf0f1'
	                        visible: folderItem.itemCount > 5
	                        
	                        Text {
	                            text: '... and ' + (folderItem.itemCount - 5) + ' more'
	                            font.pointSize: 9
	                            color: '#7f8c8d'
	                            anchors.centerIn: parent
	                        }
	                    }
	                }
	                
	                Rectangle {
	                    width: parent.width
	                    height: 1
	                    color: '#ecf0f1'
	                }
	            }
	            
	            Column {
	                anchors.fill: parent
	                
	                Rectangle {
	                    width: parent.width
	                    height: 50
	                    color: '#34495e'
	                    
	                    Text {
	                        text: '📁 File Explorer'
	                        color: 'white'
	                        font.pointSize: 14
	                        font.bold: true
	                        anchors.centerIn: parent
	                    }
	                }
	                
	                ScrollView {
	                    width: parent.width
	                    height: parent.height - 50
	                    clip: true
	                    
	                    Column {
	                        width: parent.width
	                        
	                        FolderItem {
	                            folderName: 'Documents'
	                            folderIcon: '📄'
	                            itemCount: 12
	                        }
	                        
	                        FolderItem {
	                            folderName: 'Pictures'
	                            folderIcon: '🖼'
	                            itemCount: 256
	                        }
	                        
	                        FolderItem {
	                            folderName: 'Videos'
	                            folderIcon: '🎬'
	                            itemCount: 43
	                        }
	                        
	                        FolderItem {
	                            folderName: 'Music'
	                            folderIcon: '🎵'
	                            itemCount: 1024
	                        }
	                        
	                        FolderItem {
	                            folderName: 'Downloads'
	                            folderIcon: '⬇'
	                            itemCount: 87
	                        }
	                    }
	                }
	            }
	        }
	    "
	
	#--> Expandable/collapsible list sections
	#--> Hierarchical data display
	#--> State management with isExpanded property


#===========================================#
#   SECTION 13: DIALOGS & POPUP PATTERNS    #
#===========================================#

/*--- Sample 13.1: Dialog Windows
# Use case: Modal dialogs for user decisions

	new qApp {
	    oQML = new RingQML(NULL) {
	        loadContent(QML_13_1())
	    }
	    exec()
	}
	
	func QML_13_1
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 300
	            title: 'Dialog Examples'
	            
	            Column {
	                anchors.centerIn: parent
	                spacing: 15
	                
	                Text {
	                    text: 'Dialog Patterns'
	                    font.pointSize: 16
	                    font.bold: true
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	                
	                Button {
	                    text: 'Show Confirmation Dialog'
	                    font.pointSize: 12
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    onClicked: confirmDialog.open()
	                }
	                
	                Button {
	                    text: 'Show Information Dialog'
	                    font.pointSize: 12
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    onClicked: infoDialog.open()
	                }
	                
	                Button {
	                    text: 'Show Custom Dialog'
	                    font.pointSize: 12
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    onClicked: customDialog.open()
	                }
	                
	                Text {
	                    id: resultText
	                    text: 'Action result will appear here'
	                    font.pointSize: 11
	                    color: '#7f8c8d'
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	            }
	            
	            Dialog {
	                id: confirmDialog
	                title: 'Confirm Action'
	                anchors.centerIn: parent
	                modal: true
	                
	                Column {
	                    spacing: 20
	                    
	                    Text {
	                        text: 'Are you sure you want to delete this item?'
	                        font.pointSize: 12
	                        wrapMode: Text.WordWrap
	                        width: 300
	                    }
	                }
	                
	                standardButtons: Dialog.Yes | Dialog.No
	                
	                onAccepted: {
	                    resultText.text = 'User clicked: Yes'
	                    resultText.color = '#27ae60'
	                }
	                
	                onRejected: {
	                    resultText.text = 'User clicked: No'
	                    resultText.color = '#e74c3c'
	                }
	            }
	            
	            Dialog {
	                id: infoDialog
	                title: 'Information'
	                anchors.centerIn: parent
	                modal: true
	                
	                Column {
	                    spacing: 15
	                    
	                    Text {
	                        text: 'ℹ️'
	                        font.pointSize: 40
	                        anchors.horizontalCenter: parent.horizontalCenter
	                    }
	                    
	                    Text {
	                        text: 'Operation completed successfully!'
	                        font.pointSize: 12
	                        wrapMode: Text.WordWrap
	                        width: 300
	                        horizontalAlignment: Text.AlignHCenter
	                    }
	                }
	                
	                standardButtons: Dialog.Ok
	                
	                onAccepted: {
	                    resultText.text = 'Info dialog closed'
	                    resultText.color = '#3498db'
	                }
	            }
	            
	            Dialog {
	                id: customDialog
	                title: 'Enter Your Name'
	                anchors.centerIn: parent
	                modal: true
	                
	                Column {
	                    spacing: 15
	                    
	                    TextField {
	                        id: nameInput
	                        placeholderText: 'Your name...'
	                        font.pointSize: 12
	                        width: 300
	                    }
	                }
	                
	                standardButtons: Dialog.Ok | Dialog.Cancel
	                
	                onAccepted: {
	                    if (nameInput.text.length > 0) {
	                        resultText.text = 'Hello, ' + nameInput.text + '!'
	                        resultText.color = '#9b59b6'
	                    }
	                    nameInput.text = ''
	                }
	                
	                onRejected: {
	                    nameInput.text = ''
	                }
	            }
	        }
	    "
	
	#--> Dialog provides modal popup windows
	#--> standardButtons adds common button sets
	#--> onAccepted/onRejected handle user choices


/*--- Sample 13.2: Popup and ToolTip
# Use case: Contextual information and actions

	new qApp {
	    oQML = new RingQML(NULL) {
	        loadContent(QML_13_2())
	    }
	    exec()
	}
	
	func QML_13_2
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 500
	            height: 480
	            title: 'Popup & ToolTip'
	            
	            Column {
	                anchors.centerIn: parent
	                spacing: 30
	                
	                Text {
	                    text: 'Popup Examples'
	                    font.pointSize: 16
	                    font.bold: true
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	                
	                Row {
	                    spacing: 15
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    
	                    Button {
	                        text: 'Show Menu Popup'
	                        font.pointSize: 12
	                        onClicked: menuPopup.open()
	                        
	                        ToolTip.visible: hovered
	                        ToolTip.text: 'Click to open menu'
	                        ToolTip.delay: 500
	                    }
	                    
	                    Button {
	                        text: 'Show Notification'
	                        font.pointSize: 12
	                        onClicked: notificationPopup.open()
	                        
	                        ToolTip.visible: hovered
	                        ToolTip.text: 'Show a notification popup'
	                        ToolTip.delay: 500
	                    }
	                }
	                
	                Row {
	                    spacing: 10
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    
	                    Rectangle {
	                        width: 40
	                        height: 40
	                        color: '#3498db'
	                        radius: 20
	                        
	                        Text {
	                            text: '?'
	                            color: 'white'
	                            font.pointSize: 20
	                            anchors.centerIn: parent
	                        }
	                        
	                        ToolTip {
	                            visible: helpMouse.containsMouse
	                            text: 'This is a help icon\nHover to see this tooltip'
	                            delay: 200
	                        }
	                        
	                        MouseArea {
	                            id: helpMouse
	                            anchors.fill: parent
	                            hoverEnabled: true
	                        }
	                    }
	                    
	                    Rectangle {
	                        width: 40
	                        height: 40
	                        color: '#e74c3c'
	                        radius: 20
	                        
	                        Text {
	                            text: '!'
	                            color: 'white'
	                            font.pointSize: 20
	                            anchors.centerIn: parent
	                        }
	                        
	                        ToolTip {
	                            visible: warnMouse.containsMouse
	                            text: 'Warning: Be careful!'
	                            delay: 200
	                        }
	                        
	                        MouseArea {
	                            id: warnMouse
	                            anchors.fill: parent
	                            hoverEnabled: true
	                        }
	                    }
	                    
	                    Rectangle {
	                        width: 40
	                        height: 40
	                        color: '#27ae60'
	                        radius: 20
	                        
	                        Text {
	                            text: 'i'
	                            color: 'white'
	                            font.pointSize: 20
	                            anchors.centerIn: parent
	                        }
	                        
	                        ToolTip {
	                            visible: infoMouse.containsMouse
	                            text: 'Information available here'
	                            delay: 200
	                        }
	                        
	                        MouseArea {
	                            id: infoMouse
	                            anchors.fill: parent
	                            hoverEnabled: true
	                        }
	                    }
	                }
	            }
	            
	            Popup {
	                id: menuPopup
	                x: (parent.width - width) / 2
	                y: (parent.height - height) / 2
	                width: 200
	                height: 210
	                modal: true
	                focus: true
	                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
	                
	                Column {
	                    anchors.fill: parent
	                    spacing: 0
	                    
	                    Rectangle {
	                        width: parent.width
	                        height: 40
	                        color: '#34495e'
	                        
	                        Text {
	                            text: 'Menu Options'
	                            color: 'white'
	                            font.pointSize: 12
	                            font.bold: true
	                            anchors.centerIn: parent
	                        }
	                    }
	                    
	                    Repeater {
	                        model: ['Profile', 'Settings', 'Logout']
	                        
	                        Rectangle {
	                            width: parent.width
	                            height: 50
	                            color: itemMouse.containsMouse ? '#ecf0f1' : 'white'
	                            
	                            Text {
	                                text: modelData
	                                font.pointSize: 11
	                                anchors.centerIn: parent
	                            }
	                            
	                            MouseArea {
	                                id: itemMouse
	                                anchors.fill: parent
	                                hoverEnabled: true
	                                onClicked: {
	                                    console.log('Clicked:', modelData)
	                                    menuPopup.close()
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
	            
	            Popup {
	                id: notificationPopup
	                x: parent.width - width - 20
	                y: 20
	                width: 280
	                height: 100
	                modal: false
	                closePolicy: Popup.CloseOnEscape
	                
	                Rectangle {
	                    anchors.fill: parent
	                    color: '#27ae60'
	                    radius: 10
	                    
	                    Row {
	                        anchors.fill: parent
	                        anchors.margins: 15
	                        spacing: 15
	                        
	                        Text {
	                            text: '✓'
	                            color: 'white'
	                            font.pointSize: 30
	                            anchors.verticalCenter: parent.verticalCenter
	                        }
	                        
	                        Column {
	                            anchors.verticalCenter: parent.verticalCenter
	                            spacing: 5
	                            
	                            Text {
	                                text: 'Success!'
	                                color: 'white'
	                                font.pointSize: 14
	                                font.bold: true
	                            }
	                            
	                            Text {
	                                text: 'Operation completed'
	                                color: 'white'
	                                font.pointSize: 10
	                            }
	                        }
	                    }
	                }
	                
	                Timer {
	                    interval: 3000
	                    running: notificationPopup.visible
	                    onTriggered: notificationPopup.close()
	                }
	            }
	        }
	    "
	
	#--> Popup for custom overlays
	#--> ToolTip shows contextual help on hover
	#--> Non-modal popups for notifications


#========================================#
#   SECTION 14: DATA VISUALIZATION       #
#========================================#

/*--- Sample 14.1: Custom Bar Chart with Canvas
# Use case: Simple data visualization

	new qApp {
	    oQML = new RingQML(NULL) {
	        loadContent(QML_14_1())
	    }
	    exec()
	}
	
	func QML_14_1
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 800
	            height: 450
	            title: 'Bar Chart Visualization'
	            
	            Column {
	                anchors.fill: parent
	                anchors.margins: 20
	                spacing: 15
	                
	                Text {
	                    text: 'Monthly Sales Report'
	                    font.pointSize: 18
	                    font.bold: true
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	                
	                ListModel {
	                    id: salesData
	                    ListElement { month: 'Jan'; value: 45 }
	                    ListElement { month: 'Feb'; value: 62 }
	                    ListElement { month: 'Mar'; value: 55 }
	                    ListElement { month: 'Apr'; value: 78 }
	                    ListElement { month: 'May'; value: 85 }
	                    ListElement { month: 'Jun'; value: 92 }
	                }
	                
	                Rectangle {
	                    width: parent.width
	                    height: 300
	                    color: 'white'
	                    border.color: '#ecf0f1'
	                    border.width: 2
	                    radius: 10
	                    
	                    Row {
	                        anchors.fill: parent
	                        anchors.margins: 30
	                        anchors.bottomMargin: 40
	                        spacing: (parent.width - 60) / (salesData.count + 1)
	                        
	                        Repeater {
	                            model: salesData
	                            
	                            Column {
	                                width: 60
	                                height: parent.height
	                                spacing: 10
	                                
	                                Item {
	                                    width: parent.width
	                                    height: parent.height - 40
	                                    
	                                    Rectangle {
	                                        id: bar
	                                        width: 50
	                                        height: (value / 100) * parent.height
	                                        anchors.bottom: parent.bottom
	                                        anchors.horizontalCenter: parent.horizontalCenter
	                                        
	                                        gradient: Gradient {
	                                            GradientStop { position: 0.0; color: '#667eea' }
	                                            GradientStop { position: 1.0; color: '#764ba2' }
	                                        }
	                                        
	                                        radius: 5
	                                        
	                                        Text {
	                                            text: value + '%'
	                                            color: 'white'
	                                            font.pointSize: 10
	                                            font.bold: true
	                                            anchors.centerIn: parent
	                                        }
	                                        
	                                        Behavior on height {
	                                            NumberAnimation { duration: 500; easing.type: Easing.OutBounce }
	                                        }
	                                    }
	                                }
	                                
	                                Text {
	                                    text: month
	                                    font.pointSize: 11
	                                    anchors.horizontalCenter: parent.horizontalCenter
	                                }
	                            }
	                        }
	                    }
	                }
	                
	                Row {
	                    spacing: 15
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    
	                    Button {
	                        text: 'Randomize Data'
	                        font.pointSize: 11
	                        onClicked: {
	                            for (var i = 0; i < salesData.count; i++) {
	                                salesData.setProperty(i, 'value', Math.random() * 100 )
	                            }
	                        }
	                    }
	                    
	                    Button {
	                        text: 'Reset Data'
	                        font.pointSize: 11
	                        onClicked: {
	                            salesData.setProperty(0, 'value', 45)
	                            salesData.setProperty(1, 'value', 62)
	                            salesData.setProperty(2, 'value', 55)
	                            salesData.setProperty(3, 'value', 78)
	                            salesData.setProperty(4, 'value', 85)
	                            salesData.setProperty(5, 'value', 92)
	                        }
	                    }
	                }
	            }
	        }
	    "
	
	#--> Custom bar chart using Rectangles
	#--> Animated data updates
	#--> Data-driven visualization


/*--- Sample 14.2: Pie Chart Visualization
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


/*--- Sample 14.3: Progress Visualizations
# Use case: Multiple progress display styles


	new qApp {
	    oQML = new RingQML(NULL) {
	        loadContent(QML_14_3())
	    }
	    exec()
	}
	
	func QML_14_3
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 500
	            height: 600
	            title: 'Progress Visualizations'
	            
	            Column {
	                anchors.fill: parent
	                anchors.margins: 30
	                spacing: 35
	                
	                Text {
	                    text: 'Project Completion Status'
	                    font.pointSize: 18
	                    font.bold: true
	                    anchors.horizontalCenter: parent.horizontalCenter
	                }
	                
	                Column {
	                    width: parent.width
	                    spacing: 20
	                    
	                    Text {
	                        text: 'Frontend Development'
	                        font.pointSize: 12
	                        font.bold: true
	                    }
	                    
	                    Rectangle {
	                        width: parent.width
	                        height: 30
	                        color: '#ecf0f1'
	                        radius: 15
	                        
	                        Rectangle {
	                            width: parent.width * 0.75
	                            height: parent.height
	                            color: '#27ae60'
	                            radius: 15
	                            
	                            Behavior on width {
	                                NumberAnimation { duration: 800; easing.type: Easing.OutCubic }
	                            }
	                            
	                            Text {
	                                text: '75%'
	                                color: 'white'
	                                font.pointSize: 11
	                                font.bold: true
	                                anchors.centerIn: parent
	                            }
	                        }
	                    }
	                }
	                
	                Column {
	                    width: parent.width
	                    spacing: 20
	                    
	                    Text {
	                        text: 'Backend API'
	                        font.pointSize: 12
	                        font.bold: true
	                    }
	                    
	                    Rectangle {
	                        width: parent.width
	                        height: 30
	                        color: '#ecf0f1'
	                        radius: 15
	                        
	                        Rectangle {
	                            width: parent.width * 0.60
	                            height: parent.height
	                            gradient: Gradient {
	                                GradientStop { position: 0.0; color: '#667eea' }
	                                GradientStop { position: 1.0; color: '#764ba2' }
	                            }
	                            radius: 15
	                            
	                            Behavior on width {
	                                NumberAnimation { duration: 800; easing.type: Easing.OutCubic }
	                            }
	                            
	                            Text {
	                                text: '60%'
	                                color: 'white'
	                                font.pointSize: 11
	                                font.bold: true
	                                anchors.centerIn: parent
	                            }
	                        }
	                    }
	                }
	                
	                Column {
	                    width: parent.width
	                    spacing: 20
	                    
	                    Text {
	                        text: 'Database Design'
	                        font.pointSize: 12
	                        font.bold: true
	                    }
	                    
	                    Rectangle {
	                        width: parent.width
	                        height: 30
	                        color: '#ecf0f1'
	                        radius: 15
	                        
	                        Rectangle {
	                            width: parent.width * 0.45
	                            height: parent.height
	                            color: '#f39c12'
	                            radius: 15
	                            
	                            Behavior on width {
	                                NumberAnimation { duration: 800; easing.type: Easing.OutCubic }
	                            }
	                            
	                            Text {
	                                text: '45%'
	                                color: 'white'
	                                font.pointSize: 11
	                                font.bold: true
	                                anchors.centerIn: parent
	                            }
	                        }
	                    }
	                }
	                
	                Row {
	                    spacing: 30
	                    anchors.horizontalCenter: parent.horizontalCenter
	                    
	                    Column {
	                        spacing: 10
	                        
	                        Text {
	                            text: 'Overall Progress'
	                            font.pointSize: 11
	                            anchors.horizontalCenter: parent.horizontalCenter
	                        }
	                        
	                        Canvas {
	                            id: circularProgress
	                            width: 100
	                            height: 100
	                            
	                            property real progress: 0.60
	                            
	                            onPaint: {
	                                var ctx = getContext('2d')
	                                ctx.clearRect(0, 0, width, height)
	                                
	                                var centerX = width / 2
	                                var centerY = height / 2
	                                var radius = 40
	                                var lineWidth = 8
	                                
	                                ctx.beginPath()
	                                ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
	                                ctx.strokeStyle = '#ecf0f1'
	                                ctx.lineWidth = lineWidth
	                                ctx.stroke()
	                                
	                                ctx.beginPath()
	                                ctx.arc(centerX, centerY, radius, -Math.PI / 2, 
	                                       -Math.PI / 2 + (progress * 2 * Math.PI))
	                                ctx.strokeStyle = '#3498db'
	                                ctx.lineWidth = lineWidth
	                                ctx.lineCap = 'round'
	                                ctx.stroke()
	                            }
	                            
	                            Text {
	                                text: Math.round(circularProgress.progress * 100) + '%'
	                                font.pointSize: 16
	                                font.bold: true
	                                anchors.centerIn: parent
	                            }
	                        }
	                    }
	                }
	            }
	        }
	    "
	
	#--> Multiple progress bar styles
	#--> Circular progress with Canvas
	#--> Smooth animations : Resize the window to see


/*--- Sample 14.4: Line Chart with Animation
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

/*--- Sample 15.1: Pull-to-Refresh Pattern
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


/*--- Sample 15.2: Bottom Sheet
# Use case: Modal content from bottom


	new qApp {
	    oQML = new RingQML(NULL) {
	        loadContent(QML_15_2())
	    }
	    exec()
	}
	
	func QML_15_2
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 700
	            title: 'Bottom Sheet'
	            
	            Rectangle {
	                anchors.fill: parent
	                color: '#ecf0f1'
	                
	                Column {
	                    anchors.centerIn: parent
	                    spacing: 20
	                    
	                    Text {
	                        text: 'Bottom Sheet Demo'
	                        font.pointSize: 18
	                        font.bold: true
	                        anchors.horizontalCenter: parent.horizontalCenter
	                    }
	                    
	                    Button {
	                        text: 'Show Options'
	                        font.pointSize: 13
	                        anchors.horizontalCenter: parent.horizontalCenter
	                        onClicked: bottomSheet.open()
	                    }
	                    
	                    Button {
	                        text: 'Show Share Sheet'
	                        font.pointSize: 13
	                        anchors.horizontalCenter: parent.horizontalCenter
	                        onClicked: shareSheet.open()
	                    }
	                }
	                
	                Rectangle {
	                    id: overlay
	                    anchors.fill: parent
	                    color: '#000000'
	                    opacity: bottomSheet.visible ? 0.5 : 0
	                    visible: opacity > 0
	                    
	                    Behavior on opacity {
	                        NumberAnimation { duration: 300 }
	                    }
	                    
	                    MouseArea {
	                        anchors.fill: parent
	                        onClicked: {
	                            bottomSheet.close()
	                            shareSheet.close()
	                        }
	                    }
	                }
	                
	                Rectangle {
	                    id: bottomSheet
	                    width: parent.width
	                    height: 300
	                    anchors.bottom: parent.bottom
	                    anchors.bottomMargin: visible ? 0 : -height
	                    color: 'white'
	                    radius: 20
	                    visible: false
	                    
	                    function open() {
	                        visible = true
	                    }
	                    
	                    function close() {
	                        visible = false
	                    }
	                    
	                    Behavior on anchors.bottomMargin {
	                        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
	                    }
	                    
	                    Column {
	                        anchors.fill: parent
	                        
	                        Rectangle {
	                            width: 40
	                            height: 5
	                            color: '#bdc3c7'
	                            radius: 2.5
	                            anchors.horizontalCenter: parent.horizontalCenter
	                            anchors.topMargin: 10
	                            y: 10
	                        }
	                        
	                        Text {
	                            text: 'Options'
	                            font.pointSize: 16
	                            font.bold: true
	                            anchors.horizontalCenter: parent.horizontalCenter
	                            topPadding: 30
	                        }
	                        
	                        Column {
	                            width: parent.width
	                            topPadding: 20
	                            
	                            Repeater {
	                                model: ['Edit', 'Share', 'Delete', 'Archive', 'Cancel']
	                                
	                                Rectangle {
	                                    width: parent.width
	                                    height: 50
	                                    color: optionMouse.containsMouse ? '#f8f9fa' : 'white'
	                                    
	                                    Text {
	                                        text: modelData
	                                        font.pointSize: 13
	                                        anchors.centerIn: parent
	                                        color: modelData === 'Delete' ? '#e74c3c' : '#2c3e50'
	                                    }
	                                    
	                                    MouseArea {
	                                        id: optionMouse
	                                        anchors.fill: parent
	                                        hoverEnabled: true
	                                        onClicked: {
	                                            console.log('Selected:', modelData)
	                                            bottomSheet.close()
	                                        }
	                                    }
	                                }
	                            }
	                        }
	                    }
	                }
	                
	                Rectangle {
	                    id: shareSheet
	                    width: parent.width
	                    height: 250
	                    anchors.bottom: parent.bottom
	                    anchors.bottomMargin: visible ? 0 : -height
	                    color: 'white'
	                    radius: 20
	                    visible: false
	                    
	                    function open() {
	                        visible = true
	                    }
	                    
	                    function close() {
	                        visible = false
	                    }
	                    
	                    Behavior on anchors.bottomMargin {
	                        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
	                    }
	                    
	                    Column {
	                        anchors.fill: parent
	                        anchors.margins: 20
	                        spacing: 20
	                        
	                        Text {
	                            text: 'Share via'
	                            font.pointSize: 16
	                            font.bold: true
	                        }
	                        
	                        GridView {
	                            width: parent.width
	                            height: 150
	                            cellWidth: 80
	                            cellHeight: 80
	                            
	                            model: ListModel {
	                                ListElement { name: 'Messages'; emoji: '💬' }
	                                ListElement { name: 'Email'; emoji: '📧' }
	                                ListElement { name: 'Copy'; emoji: '📋' }
	                                ListElement { name: 'More'; emoji: '⋯' }
	                            }
	                            
	                            delegate: Column {
	                                spacing: 5
	                                
	                                Rectangle {
	                                    width: 50
	                                    height: 50
	                                    color: '#ecf0f1'
	                                    radius: 25
	                                    anchors.horizontalCenter: parent.horizontalCenter
	                                    
	                                    Text {
	                                        text: emoji
	                                        font.pointSize: 24
	                                        anchors.centerIn: parent
	                                    }
	                                    
	                                    MouseArea {
	                                        anchors.fill: parent
	                                        onClicked: {
	                                            console.log('Share via:', name)
	                                            shareSheet.close()
	                                        }
	                                    }
	                                }
	                                
	                                Text {
	                                    text: name
	                                    font.pointSize: 10
	                                    anchors.horizontalCenter: parent.horizontalCenter
	                                }
	                            }
	                        }
	                    }
	                }
	            }
	        }
	    "
	
	#--> Bottom sheet modal pattern
	#--> Slide-up animation
	#--> Overlay dimming


/*--- Sample 15.3: Floating Action Button with Speed Dial
# Use case: Quick actions menu


	new qApp {
	    oQML = new RingQML(NULL) {
	        loadContent(QML_15_3())
	    }
	    exec()
	}
	
	func QML_15_3
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
		import QtGraphicalEffects 1.15
	
	        Window {
	            visible: true
	            width: 450
	            height: 600
	            title: 'Floating Action Button'
	            
	            Rectangle {
	                anchors.fill: parent
	                color: '#ecf0f1'
	                
	                Text {
	                    text: '📱 FAB Speed Dial Example'
	                    font.pointSize: 18
	                    font.bold: true
	                    anchors.centerIn: parent
	                }
	                
	                Rectangle {
	                    id: fabOverlay
	                    anchors.fill: parent
	                    color: '#000000'
	                    opacity: fabExpanded ? 0.5 : 0
	                    visible: opacity > 0
	                    
	                    property bool fabExpanded: false
	                    
	                    Behavior on opacity {
	                        NumberAnimation { duration: 200 }
	                    }
	                    
	                    MouseArea {
	                        anchors.fill: parent
	                        onClicked: fabOverlay.fabExpanded = false
	                    }
	                }
	                
	                Column {
	                    id: speedDial
	                    anchors.right: parent.right
	                    anchors.bottom: fab.top
	                    anchors.rightMargin: 20
	                    anchors.bottomMargin: 15
	                    spacing: 15
	                    
	                    opacity: fabOverlay.fabExpanded ? 1 : 0
	                    visible: opacity > 0
	                    
	                    Behavior on opacity {
	                        NumberAnimation { duration: 200 }
	                    }
	                    
	                    Repeater {
	                        model: [
	                            { icon: '✏️', label: 'Edit', color: '#3498db' },
	                            { icon: '📷', label: 'Camera', color: '#9b59b6' },
	                            { icon: '📁', label: 'Files', color: '#27ae60' }
	                        ]
	                        
	                        Row {
	                            spacing: 15
	                            layoutDirection: Qt.RightToLeft
	                            
	                            Rectangle {
	                                width: 56
	                                height: 56
	                                color: modelData.color
	                                radius: 28
	                                
	                                scale: fabOverlay.fabExpanded ? 1 : 0
	                                
	                                Behavior on scale {
	                                    NumberAnimation { 
	                                        duration: 200 
	                                        easing.type: Easing.OutBack
	                                    }
	                                }
	                                
	                                Text {
	                                    text: modelData.icon
	                                    font.pointSize: 24
	                                    anchors.centerIn: parent
	                                }
	                                
	                                MouseArea {
	                                    anchors.fill: parent
	                                    onClicked: {
	                                        console.log('Action:', modelData.label)
	                                        fabOverlay.fabExpanded = false
	                                    }
	                                }
	                            }
	                            
	                            Rectangle {
	                                width: labelText.width + 20
	                                height: 35
	                                color: 'white'
	                                radius: 4
	                                anchors.verticalCenter: parent.verticalCenter
	                                
	                                scale: fabOverlay.fabExpanded ? 1 : 0
	                                
	                                Behavior on scale {
	                                    NumberAnimation { 
	                                        duration: 200 
	                                        easing.type: Easing.OutBack
	                                    }
	                                }
	                                
	                                Text {
	                                    id: labelText
	                                    text: modelData.label
	                                    font.pointSize: 12
	                                    anchors.centerIn: parent
	                                }
	                            }
	                        }
	                    }
	                }
	                
	                Rectangle {
	                    id: fab
	                    width: 64
	                    height: 64
	                    color: '#e74c3c'
	                    radius: 32
	                    anchors.right: parent.right
	                    anchors.bottom: parent.bottom
	                    anchors.margins: 20
	                    
	                    scale: fabMouse.pressed ? 0.9 : 1
	                    
	                    Behavior on scale {
	                        NumberAnimation { duration: 100 }
	                    }
	                    
	                    Text {
	                        text: fabOverlay.fabExpanded ? '✕' : '+'
	                        color: 'white'
	                        font.pointSize: 28
	                        anchors.centerIn: parent
	                        
	                        rotation: fabOverlay.fabExpanded ? 45 : 0
	                        
	                        Behavior on rotation {
	                            NumberAnimation { duration: 200 }
	                        }
	                    }
	                    
	                    MouseArea {
	                        id: fabMouse
	                        anchors.fill: parent
	                        onClicked: fabOverlay.fabExpanded = !fabOverlay.fabExpanded
	                    }
	                    
	                    layer.enabled: true
	                    layer.effect: DropShadow {
	                        horizontalOffset: 0
	                        verticalOffset: 2
	                        radius: 8
	                        samples: 16
	                        color: '#80000000'
	                    }
	                }
	            }
	        }
	    "
	
	#--> Floating action button
	#--> Speed dial expansion
	#--> Label hints for actions
	#--> Smooth animations


#===================================#
#   CONCLUSION AND BEST PRACTICES   #
#===================================#

`
CONGRATULATIONS! You've completed the RingQML journey!

KEY TAKEAWAYS:
==============

1. QML-FIRST THINKING
   - Start with QML's declarative structure
   - Design the UI visually and expressively
   - Let QML handle layout, binding, and reactivity

2. RING FOR ORCHESTRATION
   - Use Ring for business logic and data management
   - Ring.callFunc() connects QML events to Ring functions
   - Ring.getVar() and Ring.setVar() bridge data

3. SEPARATION OF CONCERNS
   - Keep QML in dedicated strings or .qml files
   - Keep Ring logic separate
   - Clear boundaries = maintainable code

4. MODERN UI PRINCIPLES
   - Use animations for polish
   - Provide immediate feedback
   - Think mobile-first, scale to desktop
   - Leverage binding for reactivity

5. ARCHITECTURAL PATTERNS
   - Component-based design
   - Data-driven UIs with models
   - State management for complex UIs
   - Clean API between Ring and QML

NEXT STEPS:
===========

1. Experiment with these samples
2. Combine patterns to build your own applications
3. Move QML to .qml files for larger projects
4. Explore Qt documentation for more QML features
5. Share your RingQML creations with the community!

RESOURCES:
=========

- RingQML Library: https://github.com/mohannad-aldulaimi/ringqml
- Ring Language: https://ring-lang.net/
- Qt QML Documentation: https://doc.qt.io/qt-5/qmlapplications.html
- Ring Community: https://groups.google.com/g/ring-lang

Happy coding with RingQML! 🎨🚀

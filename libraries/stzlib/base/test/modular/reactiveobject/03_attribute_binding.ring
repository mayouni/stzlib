# Narrative
# --------
# Attribute Binding
#
# Extracted from stzreactiveobjecttest.ring, block #3.

load "../../../stzBase.ring"


pr()
	
	# Create reactive system
	Rs = new stzReactiveSystem()
	
	# Create source object
	oXSource = Rs.ReactiveObject()
	oXSource {
		SetAttribute(:@Temperature, 20)
		SetAttribute(:@Status, "normal")
	}

	# Create target objects
	oXDisplay1 = Rs.ReactiveObject()
	oXDisplay1 {
		SetAttribute(:@Temp, 0)
		SetAttribute(:@DisplayName, "Display1")
	}
	
	oXDisplay2 = Rs.ReactiveObject()
	oXDisplay2 {
		SetAttribute(:@Temp, 0)
		SetAttribute(:@DisplayName, "Display2")
	}

	# Watch target objects to see binding updates

	oXDisplay1.Watch(:@Temp, func(oSelf, attr, oldval, newval) {
		cDisplayName = oXDisplay1.GetAttribute(:@DisplayName)
		? cDisplayName + " received temperature: " + newval + "°C"
	})
	
	oXDisplay2.Watch(:@Temp, func(oSelf, attr, oldval, newval) {
		cDisplayName = oXDisplay2.GetAttribute(:@DisplayName)
		? cDisplayName + " received temperature: " + newval + "°C"
	})
	
	# Create bindings

	Rs.BindObjects(oXSource, :@Temperature, oXDisplay1, :@Temp, DEFAULT_BINDING_MODE)
	Rs.BindObjects(oXSource, :@Temperature, oXDisplay2, :@Temp, DEFAULT_BINDING_MODE)
	
	# Test binding updates

	Rs.RunAfter(100, func {
		? "Setting source temperature to 25°C..."
		oXSource.SetAttribute(:@Temperature, 25)
		
		Rs.RunAfter(500, func {
			? "Setting source temperature to 30°C..."
			oXSource.SetAttribute(:@Temperature, 30)
			
			Rs.RunAfter(500, func {
				? "Setting source temperature to 35°C..."
				oXSource.SetAttribute(:@Temperature, 35)
			})
		})
	})
	
	Rs.Start()
	? NL + "✔ Sample completed."

#--> Should return
# Setting source temperature to 25°C...
# Setting source temperature to 30°C...
# Setting source temperature to 35°C...

pf()
# Executed in 2.08 second(s) in Ring 1.23

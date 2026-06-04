# Narrative
# --------
# Attribute Streams
#
# Extracted from stzreactiveobjecttest.ring, block #5.
#ERR Error (R54) : Object attribute redefinition, attribute is already defined!

load "../../stzBase.ring"


pr()
	
	# Create reactive system
	Rs = new stzReactiveSystem()
	
	# Create reactive object
	oXSensor = Rs.ReactiveObject()
	oXSensor.SetAttribute(:@Value, 0)
	
	# Create stream from Attribute changes
	St = oXSensor.StreamAttribute(:@Value)
	
	# Transform the stream with map and filter
	St {
		Map(func(data) {
			# Extract new value from data array
			newValue = 0
			_nDataLen_2 = ring_len(data)
			for i = 1 to _nDataLen_2 step 2
				if data[i] = "newValue" //todo why "newValue"?
					newValue = data[i+1]
					exit
				ok
			next
			return "Sensor reading: " + string(newValue)
		})

		Filter(func(message) {
			# Only pass through readings > 50
			return substr(message, "reading: ") > 0 and 
			       number(substrXT([ message, substr(message, ": ") + 2 ])) > 50
		})

		OnPassed(func(message) {
			? "🌡️ High reading alert: " + message
		})

		# Also create a simple subscriber for all changes
		OnPassed(func(data) {
			newValue = 0
			_nDataLen_ = ring_len(data)
			for i = 1 to _nDataLen_ step 2
				if data[i] = "newValue"
					newValue = data[i+1]
					exit
				ok
			next
			? "📊 Raw sensor data: " + string(newValue)
		})
	}

	# Generate sensor readings
	anReadings = [10, 25, 60, 75, 30, 85, 45, 95]
	nCurrentReading = 1
	
	Rs.RunAfter(100, func {
		NextReading()
	})
	
	Rs.Start()
	? NL + "✔ Sample completed."

pf()

func NextReading()
	if nCurrentReading <= len(anReadings)
		value = anReadings[nCurrentReading]
		? "Setting sensor value to: " + string(value)
		oXSensor.SetAttribute(:@value, value)
		nCurrentReading++

		if nCurrentReading <= len(anReadings)
			Rs.RunAfter(300, func { NextReading() })
		ok
	ok

#-->
# Setting sensor value to: 10
# Setting sensor value to: 25
# Setting sensor value to: 60
# Setting sensor value to: 75
# Setting sensor value to: 30
# Setting sensor value to: 85
# Setting sensor value to: 45
# Setting sensor value to: 95

# ✔ Sample completed.

# Executed in 3.42 second(s) in Ring 1.23

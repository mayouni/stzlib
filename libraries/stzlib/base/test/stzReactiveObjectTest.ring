load "../stzbase.ring"

# Softanza Reactive Programming System - Reactive Objects Samples

/*--- Basic Property Watching

pr()

	# Create reactive system
	Rs = new stzReactive()

	# Create reactive object
	oUser = Rs.CreateReactiveObject('')
	oUser.SetAttribute(:name, "")
	oUser.SetAttribute(:age, 0)

	# Watch name changes
	oUser.Watch(:name, func(prop, old, new_val) {
		? "Name changed from (" + old + ") to (" + new_val + ")"
	})

	# Watch age changes
	oUser.Watch("age", func(prop, old, new_val) {
		? "Age changed from " + string(old) + " to " + string(new_val)
	})

	# Test property changes
	Rs.SetTimeout(func {
		? "Setting name to 'John'..."
		oUser.SetAttribute("name", "John")
		
		Rs.SetTimeout(func {
			? "Setting age to 25..."
			oUser.SetAttribute("age", 25)
			
			Rs.SetTimeout(func {
				? "Changing name to 'John Doe'..."
				oUser.SetAttribute("name", "John Doe")
			}, 500)
		}, 500)
	}, 100)
	
	Rs.Start()
	? NL + "✅ Sample completed."

#-->
# Setting name to 'John'...
# Name changed from () to (John)
# Setting age to 25...
# Age changed from  to 25
# Changing name to 'John Doe'...
# Name changed from () to (John Doe)

# ✅ Sample completed.

pf()
# Executed in 2.00 second(s) in Ring 1.23

/*--- Computed Properties

pr()
	
	# Create reactive system
	Rs = new stzReactive()
	
	# Create reactive object
	oUser = Rs.CreateReactiveObject('')
	oUser.SetAttribute(:firstName, "")
	oUser.SetAttribute(:lastName, "")
	oUser.SetAttribute(:fullName, "")
	oUser.SetAttribute(:email, "")
	oUser.SetAttribute(:age, 0)
	oUser.SetAttribute(:isAdult, false)
	
	# Computed property: fullName depends on firstName and lastName

	oUser.Computed(:fullName,

		func {
			return  oUser.GetAttribute(:firstName) +
				oUser.GetAttribute(:lastName)

		},

		[ :firstName, :lastName ]
	)
	
	# Computed property: isAdult depends on age

	oUser.Computed(:isAdult,

		func {
			return oUser.getattribute(:age) >= 18
		},

		[:age]
	)
	
	# Watch computed properties to see auto-updates

	oUser.Watch(:fullName,
		func(prop, old, new_val) {
			? "Full name computed: (" + new_val + ")"
		}
	)

	oUser.Watch(:isAdult,
		func(prop, old, new_val) {
			? "Adult status: " + string(new_val)
		}
	)
	
	# Test computed properties

	Rs.SetTimeout(
		func {
		? "Setting firstName to 'Jane'..."
		oUser.SetAttribute(:firstName, "Jane")
			Rs.SetTimeout(func {
				? "Setting lastName to 'Smith'..."
				oUser.SetAttribute(:lastName, "Smith")
	
				Rs.SetTimeout(func {
					? "Setting age to 17..."
					oUser.SetAttribute(:age, 17)
				
					Rs.SetTimeout(func {
						? "Setting age to 21..."
						oUser.SetAttribute(:age, 21)
					}, 500)
				}, 500)
			}, 500)
		}, 100)
	
	Rs.Start()
	? NL + "✅ Sample completed."

#-->
# Setting firstName to 'Jane'...
# Setting lastName to 'Smith'...
# Setting age to 17...
# Setting age to 21...

# ✅ Sample completed.

pf()
# Executed in 2.60 second(s) in Ring 1.23

/*--- Property Binding

pr()
	
	# Create reactive system
	Rs = new stzReactive()
	
	# Create source object
	oSource = Rs.CreateReactiveObject(NULL)
	oSource.SetAttribute(:temperature, 20)
	oSource.SetAttribute(:status, "normal")
	
	# Create target objects
	oDisplay1 = Rs.CreateReactiveObject(NULL)
	oDisplay1.SetAttribute(:temp, 0)
	oDisplay1.SetAttribute(:displayName, "Display1")
	
	oDisplay2 = Rs.CreateReactiveObject(NULL)
	oDisplay2.SetAttribute(:temp, 0)
	oDisplay2.SetAttribute(:displayName, "Display2")
	
	# Watch target objects to see binding updates

	oDisplay1.Watch(:temp, func(prop, old, new_val) {
		displayName = oDisplay1.GetAttribute(:displayName)
		? displayName + " received temperature: " + string(new_val) + "°C"
	})
	
	oDisplay2.Watch(:temp, func(prop, old, new_val) {
		displayName = oDisplay2.GetAttribute(:displayName)
		? displayName + " received temperature: " + string(new_val) + "°C"
	})
	
	# Create bindings

	Rs.BindObjects(oSource, :temperature, oDisplay1, :temp)
	Rs.BindObjects(oSource, :temperature, oDisplay2, :temp)
	
	# Test binding updates

	Rs.SetTimeout(func {
		? "Setting source temperature to 25°C..."
		oSource.SetAttribute("temperature", 25)
		
		Rs.SetTimeout(func {
			? "Setting source temperature to 30°C..."
			oSource.SetAttribute("temperature", 30)
			
			Rs.SetTimeout(func {
				? "Setting source temperature to 35°C..."
				oSource.SetAttribute("temperature", 35)
			}, 500)
		}, 500)
	}, 100)
	
	Rs.Start()
	? NL + "✅ Sample completed."

#-->
# Setting source temperature to 25°C...
# Setting source temperature to 30°C...
# Setting source temperature to 35°C...

pf()
# Executed in 2.06 second(s) in Ring 1.23

/*--- Batch Updates
*/
pr()

	# Create reactive system
	Rs = new stzReactive()
	
	# Create reactive object
	oProduct = Rs.CreateReactiveObject(NULL)
	oProduct.SetAttribute(:@Name, "")
	oProduct.SetAttribute(:@Price, 0)
	oProduct.SetAttribute(:@Category, "")
	oProduct.SetAttribute(:@InStock, false)
	
	# Watch all properties to see update order

	oProduct.Watch(:@Name, func(attr, oldval, newval) {
		? "  Name updated: " + newval
	})
	
	oProduct.Watch(:@Price, func(attr, oldval, newval) {
		? "  Price updated: $" + string(newval)
	})
	
	oProduct.Watch(:@Category, func(attr, oldval, newval) {
		? "  Category updated: " + newval
	})
	
	oProduct.Watch(:@InStock, func(attr, oldval, newval) {
		? "  Stock status: " + string(newval)
	})
	
	Rs.SetTimeout(func {
		? "Individual updates (watch each change):"

		oProduct.SetAttribute(:@Name, "Laptop")
		sleep(0.1)

		oProduct.SetAttribute(:@Price, 999.99)
		sleep(0.1)

		oProduct.SetAttribute(:@Category, "Electronics")
		sleep(0.1)

		oProduct.SetAttribute(:@InStock, true)
		
		Rs.SetTimeout(func {
			? ""
			? "Batch updates (all changes processed together):"

			oProduct.Batch(func {
				oProduct.SetAttribute(:@Name, "Gaming Laptop")
				oProduct.SetAttribute(:@Price, 1299.99)
				oProduct.SetAttribute(:@Category, "Gaming")
				oProduct.SetAttribute(:@InStock, false)
			})
		}, 1000)
	}, 100)
	
	Rs.Start()
	? NL + "✅ Sample completed."

pf()

/*--- Property Streams

func sample_PropertyStreams

	? "=== Property Streams Sample ==="
	
	# Create reactive system
	Rs = new stzReactive()
	Rs.Init()
	
	# Create reactive object
	oSensor = Rs.CreateReactiveObject(NULL)
	oSensor.SetAttribute("value", 0)
	
	# Create stream from property changes
	valueStream = oSensor.StreamProperty("value")
	
	# Transform the stream with map and filter
	valueStream
		.Map(func(data) {
			# Extract new value from data array
			newValue = 0
			for i = 1 to len(data) step 2
				if data[i] = "newValue"
					newValue = data[i+1]
					exit
				ok
			next
			return "Sensor reading: " + string(newValue)
		})
		.Filter(func(message) {
			# Only pass through readings > 50
			return find(message, "reading: ") > 0 and 
			       number(substr(message, find(message, ": ") + 2)) > 50
		})
		.Subscribe(func(message) {
			? "🌡️ High reading alert: " + message
		})
	
	# Also create a simple subscriber for all changes
	valueStream.Subscribe(func(data) {
		newValue = 0
		for i = 1 to len(data) step 2
			if data[i] = "newValue"
				newValue = data[i+1]
				exit
			ok
		next
		? "📊 Raw sensor data: " + string(newValue)
	})
	
	# Generate sensor readings
	readings = [10, 25, 60, 75, 30, 85, 45, 95]
	currentReading = 1
	
	def nextReading()
		if currentReading <= len(readings)
			value = readings[currentReading]
			? "Setting sensor value to: " + string(value)
			oSensor.SetAttribute("value", value)
			currentReading++
			
			if currentReading <= len(readings)
				Rs.SetTimeout(func { nextReading() }, 300)
			else
				Rs.SetTimeout(func { Rs.StopSafe() }, 500)
			ok
		ok
	
	Rs.SetTimeout(func {
		nextReading()
	}, 100)
	
	Rs.Start()
	? "Sample completed."
	? ""

/*--- Debounced Properties

func sample_DebouncedProperties

	? "=== Debounced Properties Sample ==="
	
	# Create reactive system
	Rs = new stzReactive()
	Rs.Init()
	
	# Create reactive object
	oSearch = Rs.CreateReactiveObject(NULL)
	oSearch.SetAttribute("query", "")
	
	# Watch immediate changes
	oSearch.Watch("query", func(prop, old, new_val) {
		? "🔍 Search query changed: '" + new_val + "'"
	})
	
	# Set up debounced handler (waits 800ms before firing)
	oSearch.DebounceProperty("query", 800, func(prop, old, new_val) {
		? "🎯 Debounced search executed for: '" + new_val + "'"
		? "    (This simulates an API call)"
	})
	
	# Simulate rapid typing
	queries = ["h", "he", "hel", "hell", "hello", "hello w", "hello wo", "hello wor", "hello world"]
	currentQuery = 1
	
	def typeNext()
		if currentQuery <= len(queries)
			query = queries[currentQuery]
			? "⌨️ Typing: '" + query + "'"
			oSearch.SetAttribute("query", query)
			currentQuery++
			
			if currentQuery <= len(queries)
				# Fast typing simulation
				Rs.SetTimeout(func { typeNext() }, 150)
			else
				# Wait for debounce to finish, then stop
				Rs.SetTimeout(func { Rs.StopSafe() }, 1500)
			ok
		ok
	
	Rs.SetTimeout(func {
		? "Simulating rapid typing (debounced search will fire only after typing stops):"
		typeNext()
	}, 100)
	
	Rs.Start()
	? "Sample completed."
	? ""

/*--- Async Property Updates

func sample_AsyncPropertyUpdates

	? "=== Async Property Updates Sample ==="
	
	# Create reactive system
	Rs = new stzReactive()
	Rs.Init()
	
	# Create reactive object
	oUser = Rs.CreateReactiveObject(NULL)
	oUser.SetAttribute("email", "")
	oUser.SetAttribute("profilePicture", "")
	
	# Watch property changes
	oUser.Watch("email", func(prop, old, new_val) {
		? "✉️ Email updated to: " + new_val
	})
	
	oUser.Watch("profilePicture", func(prop, old, new_val) {
		? "🖼️ Profile picture updated to: " + new_val
	})
	
	Rs.SetTimeout(func {
		# Test successful async update
		? "Testing successful async email update..."
		oUser.SetAsync("email", "john@example.com", 
			func(result) { 
				? "✅ Success callback: Email set to " + result 
			},
			func(error) { 
				? "❌ Error callback: " + error 
			}
		)
		
		Rs.SetTimeout(func {
			# Test another successful update
			? ""
			? "Testing async profile picture update..."
			oUser.SetAsync("profilePicture", "avatar_123.jpg",
				func(result) {
					? "✅ Success callback: Profile picture set to " + result
				},
				func(error) {
					? "❌ Error callback: " + error
				}
			)
			
			Rs.SetTimeout(func {
				Rs.StopSafe()
			}, 1000)
		}, 1000)
	}, 100)
	
	Rs.Start()
	? "Sample completed."
	? ""

/*--- Complex Example: User Management System

func sample_ComplexUserSystem

	? "=== Complex Example: User Management System ==="
	
	# Create reactive system
	Rs = new stzReactive()
	Rs.Init()
	
	# Create user object
	oUser = Rs.CreateReactiveObject(NULL)
	oUser.SetAttribute("firstName", "")
	oUser.SetAttribute("lastName", "")
	oUser.SetAttribute("email", "")
	oUser.SetAttribute("age", 0)
	oUser.SetAttribute("fullName", "")
	oUser.SetAttribute("isValid", false)
	
	# Create dashboard object
	oDashboard = Rs.CreateReactiveObject(NULL)
	oDashboard.SetAttribute("currentUser", "")
	oDashboard.SetAttribute("userCount", 0)
	oDashboard.SetAttribute("lastActivity", "")
	
	# Set up computed properties
	oUser.Computed("fullName", func {
		firstName = oUser.getattribute("firstName")
		lastName = oUser.getattribute("lastName")
		return firstName + " " + lastName
	}, ["firstName", "lastName"])
	
	oUser.Computed("isValid", func {
		firstName = oUser.getattribute("firstName")
		lastName = oUser.getattribute("lastName")
		email = oUser.getattribute("email")
		age = oUser.getattribute("age")
		return len(firstName) > 0 and len(lastName) > 0 and 
		       find(email, "@") > 0 and age >= 18
	}, ["firstName", "lastName", "email", "age"])
	
	# Set up property bindings
	Rs.BindObjects(oUser, "fullName", oDashboard, "currentUser")
	
	# Set up watchers
	oUser.Watch("isValid", func(prop, old, new_val) {
		if new_val
			? "✅ User validation passed"
		else
			? "❌ User validation failed"
		ok
	})
	
	oDashboard.Watch("currentUser", func(prop, old, new_val) {
		? "📊 Dashboard updated - Current user: " + new_val
		oDashboard.SetAttribute("lastActivity", "User updated: " + new_val)
	})
	
	# Set up debounced email validation
	oUser.DebounceProperty("email", 500, func(prop, old, new_val) {
		if find(new_val, "@") > 0
			? "📧 Email validation passed: " + new_val
		else
			? "⚠️ Email validation failed: " + new_val
		ok
	})
	
	# Create activity stream
	activityStream = oUser.StreamProperty("isValid")
	activityStream.Subscribe(func(data) {
		isValidNow = false
		for i = 1 to len(data) step 2
			if data[i] = "newValue"
				isValidNow = data[i+1]
				exit
			ok
		next
		
		if isValidNow
			? "🎉 User is now valid and can access the system!"
		ok
	})
	
	# Run the demo
	Rs.SetTimeout(func {
		? "Step 1: Setting basic info..."
		oUser.Batch(func {
			oUser.SetAttribute("firstName", "Alice")
			oUser.SetAttribute("lastName", "Johnson")
			oUser.SetAttribute("age", 25)
		})
		
		Rs.SetTimeout(func {
			? ""
			? "Step 2: Setting email (with debounce)..."
			oUser.SetAttribute("email", "alice")  # Invalid
			sleep(0.1)
			oUser.SetAttribute("email", "alice@")  # Still invalid
			sleep(0.1)
			oUser.SetAttribute("email", "alice@company.com")  # Valid
			
			Rs.SetTimeout(func {
				? ""
				? "Step 3: Checking final state..."
				? "Full Name: " + oUser.getattribute("fullName")
				? "Is Valid: " + string(oUser.getattribute("isValid"))
				? "Dashboard User: " + oDashboard.getattribute("currentUser")
				? "Last Activity: " + oDashboard.getattribute("lastActivity")
				
				Rs.SetTimeout(func {
					Rs.StopSafe()
				}, 1000)
			}, 1000)
		}, 1000)
	}, 100)
	
	Rs.Start()
	? "Sample completed."
	

load "../stzbase.ring"

# Softanza Reactive Programming System - Reactive Objects Samples

/*--- Basic Property Watching

pr()

	# Create reactive system
	Rs = new stzReactive()

	# Create reactive object
	oUser = Rs.CreateReactiveObject('')
	oUser.SetAttribute(:@Name, "")
	oUser.SetAttribute(:@Age, 0)

	# Watch name changes
	oUser.Watch(:@Name, func(attr, oldval, newval) {
		? "Name changed from (" + @@(oldval) + ") to (" + @@(newval) + ")"
	})

	# Watch age changes
	oUser.Watch(:@Age, func(attr, oldval, newval) {
		? "Age changed from " + @@(oldval) + " to " + @@(newval)
	})

	# Test property changes
	Rs.SetTimeout(func {
		? "Setting name to 'John'..."
		oUser.SetAttribute(:@Name, "John")
		
		Rs.SetTimeout(func {
			? "Setting age to 25..."
			oUser.SetAttribute(:@Age, 25)
			
			Rs.SetTimeout(func {
				? "Changing name to 'John Doe'..."
				oUser.SetAttribute(:@Name, "John Doe")
			}, 500)
		}, 500)
	}, 100)
	
	Rs.Start()
	? NL + "✅ Sample completed."

#-->
# Setting name to 'John'...
# Name changed from ('') to ("John")
# Setting age to 25...
# Age changed from '' to 25	#TODO why "" and not 0!
# Changing name to 'John Doe'...
# Name changed from () to (John Doe)

# ✅ Sample completed.

pf()
# Executed in 2.22 second(s) in Ring 1.23

/*--- Computed Properties

pr()
	
	# Create reactive system
	Rs = new stzReactive()
	
	# Create reactive object
	oUser = Rs.CreateReactiveObject('')
	oUser.SetAttribute(:@FirstName, "")
	oUser.SetAttribute(:@LastName, "")
	oUser.SetAttribute(:@FullName, "")
	oUser.SetAttribute(:@Email, "")
	oUser.SetAttribute(:@Age, 0)
	oUser.SetAttribute(:@IsAdult, false)
	
	# Computed property: fullName depends on firstName and lastName

	oUser.Computed(:@FullName,

		func {
			return  oUser.GetAttribute(:@FirstName) +
				oUser.GetAttribute(:@LastName)

		},

		[ :@FirstName, :@LastName ]
	)
	
	# Computed property: isAdult depends on age

	oUser.Computed(:@IsAdult,

		func {
			return oUser.getattribute(:@Age) >= 18
		},

		[:@Age]
	)
	
	# Watch computed properties to see auto-updates

	oUser.Watch(:@FullName,
		func(attr, oldval, newval) {
			? "Full name computed: (" + newval + ")"
		}
	)

	oUser.Watch(:@IsAdult,
		func(attr, oldval, newval) {
			? "Adult status: " + string(newval)
		}
	)
	
	# Test computed properties

	Rs.SetTimeout(
		func {
		? "Setting firstName to 'Jane'..."
		oUser.SetAttribute(:@FirstName, "Jane")
			Rs.SetTimeout(func {
				? "Setting lastName to 'Smith'..."
				oUser.SetAttribute(:@LastName, "Smith")
	
				Rs.SetTimeout(func {
					? "Setting age to 17..."
					oUser.SetAttribute(:@Age, 17)
				
					Rs.SetTimeout(func {
						? "Setting age to 21..."
						oUser.SetAttribute(:@Age, 21)
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
	oSource.SetAttribute(:@Temperature, 20)
	oSource.SetAttribute(:@Status, "normal")
	
	# Create target objects
	oDisplay1 = Rs.CreateReactiveObject(NULL)
	oDisplay1.SetAttribute(:@Temp, 0)
	oDisplay1.SetAttribute(:@DisplayName, "Display1")
	
	oDisplay2 = Rs.CreateReactiveObject(NULL)
	oDisplay2.SetAttribute(:@Temp, 0)
	oDisplay2.SetAttribute(:@DisplayName, "Display2")
	
	# Watch target objects to see binding updates

	oDisplay1.Watch(:@Temp, func(attr, oldval, newval) {
		displayName = oDisplay1.GetAttribute(:@DisplayName)
		? displayName + " received temperature: " + string(newval) + "°C"
	})
	
	oDisplay2.Watch(:@Temp, func(attr, oldval, newval) {
		displayName = oDisplay2.GetAttribute(:@DisplayName)
		? displayName + " received temperature: " + string(newval) + "°C"
	})
	
	# Create bindings

	Rs.BindObjects(oSource, :@Temperature, oDisplay1, :@Temp)
	Rs.BindObjects(oSource, :@Temperature, oDisplay2, :@Temp)
	
	# Test binding updates

	Rs.SetTimeout(func {
		? "Setting source temperature to 25°C..."
		oSource.SetAttribute(:@Temperature, 25)
		
		Rs.SetTimeout(func {
			? "Setting source temperature to 30°C..."
			oSource.SetAttribute(:@Temperature, 30)
			
			Rs.SetTimeout(func {
				? "Setting source temperature to 35°C..."
				oSource.SetAttribute(:@Temperature, 35)
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

	oProduct.Watch(:@Name, func(attr, oldvalval, newval) {
		? "  Name updated: " + newval
	})
	
	oProduct.Watch(:@Price, func(attr, oldvalval, newval) {
		? "  Price updated: $" + string(newval)
	})
	
	oProduct.Watch(:@Category, func(attr, oldvalval, newval) {
		? "  Category updated: " + newval
	})
	
	oProduct.Watch(:@InStock, func(attr, oldvalval, newval) {
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

#-->
# Individual updates (watch each change):
#   Name updated: Laptop
#   Price updated: $999.99
#   Category updated: Electronics
#   Stock status: 1
#
# Batch updates (all changes processed together):
#   Name updated: Gaming Laptop
#   Price updated: $1299.99
#   Category updated: Gaming
#   Stock status: 0

# ✅ Sample completed.

pf()
# Executed in 2.32 second(s) in Ring 1.23

/*--- Property Streams

pr()
	
	# Create reactive system
	Rs = new stzReactive()
	
	# Create reactive object
	oSensor = Rs.CreateReactiveObject(NULL)
	oSensor.SetAttribute(:@Value, 0)
	
	# Create stream from property changes
	St = oSensor.StreamProperty(:@Value)
	
	# Transform the stream with map and filter
	St {
		Map(func(data) {
			# Extract new value from data array
			newValue = 0
			for i = 1 to len(data) step 2
				if data[i] = "newValue" #todo why "newValue"?
					newValue = data[i+1]
					exit
				ok
			next
			return "Sensor reading: " + string(newValue)
		})

		Filter(func(message) {
			# Only pass through readings > 50
			return find(message, "reading: ") > 0 and 
			       number(substr(message, find(message, ": ") + 2)) > 50
		})

		OnData(func(message) {
			? "🌡️ High reading alert: " + message
		})

		# Also create a simple subscriber for all changes
		OnData(func(data) {
			newValue = 0
			for i = 1 to len(data) step 2
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
	
	Rs.SetTimeout(func {
		NextReading()
	}, 100)
	
	Rs.Start()
	? NL + "✅ Sample completed."

pf()

func NextReading()
	if nCurrentReading <= len(anReadings)
		value = anReadings[nCurrentReading]
		? "Setting sensor value to: " + string(value)
		oSensor.SetAttribute(:@value, value)
		nCurrentReading++

		if nCurrentReading <= len(anReadings)
			Rs.SetTimeout(func { NextReading() }, 300)
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

# ✅ Sample completed.

# Executed in 3.61 second(s) in Ring 1.23

/*--- Debounced Properties

pr()
	
	# Create reactive system
	Rs = new stzReactive()
	
	# Create reactive object
	oSearch = Rs.CreateReactiveObject(NULL)
	oSearch.SetAttribute(:@Query, "")
	
	# Watch immediate changes
	oSearch.Watch(:@Query, func(attr, oldval, newval) {
		? "🔍 Search query changed: " + @@(newval)
	})
	
	# Set up debounced handler (waits 800ms before firing)
	oSearch.DebounceProperty(:@Query, 800, func(attr, oldval, newval) {
		? "🎯 Debounced search executed for: (" + newval + ")"
		? "    (This simulates an API call)"
	})
	
	# Simulate rapid typing
	queries = ["h", "he", "hel", "hell", "hello", "hello w", "hello wo", "hello wor", "hello world"]
	currentQuery = 1
	
	Rs.SetTimeout(func {
		? "Simulating rapid typing (debounced search will fire only after typing stops):"
		TypeNext()
	}, 100)
	
	Rs.Start()
	? NL + "✅ Sample completed."

pf()

func TypeNext()
	if currentQuery <= len(queries)
		query = queries[currentQuery]
		? "⌨️ Typing: " + @@(query)
		oSearch.SetAttribute(:@Query, query)
		currentQuery++
		
		if currentQuery <= len(queries)
			# Fast typing simulation
			Rs.SetTimeout(func { TypeNext() }, 150)
		else
			# Wait for debounce to finish, then stop
			// Rs.SetTimeout(func { Rs.StopSafe() }, 1500)
		ok
	ok

#-->
# Simulating rapid typing (debounced search will fire only after typing stops):
# ⌨️ Typing: 'h'
# 🔍 Search query changed: 'h'
# ⌨️ Typing: 'he'
# 🔍 Search query changed: 'he'
# ⌨️ Typing: 'hel'
# 🔍 Search query changed: 'hel'
# ⌨️ Typing: 'hell'
# 🔍 Search query changed: 'hell'
# ⌨️ Typing: 'hello'
# 🔍 Search query changed: 'hello'
# ⌨️ Typing: 'hello w'
# 🔍 Search query changed: 'hello w'
# ⌨️ Typing: 'hello wo'
# 🔍 Search query changed: 'hello wo'
# ⌨️ Typing: 'hello wor'
# 🔍 Search query changed: 'hello wor'
# ⌨️ Typing: 'hello world'
# 🔍 Search query changed: 'hello world'

# ✅ Sample completed.

# Executed in 4.20 second(s) in Ring 1.23

/*--- Async Property Updates #todo error

pr()
	
	# Create reactive system
	Rs = new stzReactive()
	
	# Create reactive object
	oUser = Rs.CreateReactiveObject(NULL)
	oUser.SetAttribute(:@Email, "")
	oUser.SetAttribute(:@ProfilePicture, "")
	
	# Watch property changes
	oUser.Watch(:@Email, func(attr, oldval, newval) {
		? "✉️ Email updated to: " + newval
	})
	
	oUser.Watch(:@ProfilePicture, func(attr, oldval, newval) {
		? "🖼️ Profile picture updated to: " + newval
	})
	
	Rs.SetTimeout(func {
		# Test successful async update
		? "Testing successful async email update..."
		oUser.SetAsync(:@Email, "john@example.com", 
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

		}, 1000)
	}, 100)
	
	Rs.Start()
	? NL + "✅ Sample completed."

pf()

/*--- Complex Example: User Management System
*/
pr()
	
	# Create reactive system
	Rs = new stzReactive()
	

	# Create user object
	oUser = Rs.CreateReactiveObject(NULL)
	oUser.SetAttribute(:@FirstName, "")
	oUser.SetAttribute(:@LastName, "")
	oUser.SetAttribute(:@Email, "")
	oUser.SetAttribute(:@Age, 0)
	oUser.SetAttribute(:@FullName, "")
	oUser.SetAttribute(:@IsValid, false)
	
	# Create dashboard object
	oDashboard = Rs.CreateReactiveObject(NULL)
	oDashboard.SetAttribute(:@CurrentUser, "")
	oDashboard.SetAttribute(:@UserCount, 0)
	oDashboard.SetAttribute(:@LastActivity, "")
	
	# Set up computed properties

	oUser.Computed(
		:@FullName,

		func {
			return	oUser.GetAttribute(:@FirstName) + " " +
				oUser.GetAttribute(:@LastName)
		},

		[ :@FirstName, :@LastName ]
	)
	
	oUser.Computed(
		:@IsValid,

		func {
			cFirstName = oUser.GetAttribute(:@FirstName)
			cLastName = oUser.GetAttribute(:@LastName)
			cEmail = oUser.GetAttribute(:@Email)
			cAge = oUser.GetAttribute(:@Age)

			return  len(cFirstName) > 0 and len(cLastName) > 0 and 
		       		substr(cEmail, "@") > 0 and age >= 18
		},

		[ :@FirstName, :@LastName, :@Email, :@Age ]
	)
	
	# Set up property bindings
	Rs.BindObjects(oUser, :@FullName, oDashboard, :@CurrentUser)
	
	# Set up watchers
	oUser.Watch(:@IsValid, func(attr, oldval, newval) {
		if newval
			? "✅ User validation passed"
		else
			? "❌ User validation failed"
		ok
	})
	
	oDashboard.Watch(:@CurrentUser, func(attr, oldval, newval) {
		? "📊 Dashboard updated - Current user: " + @@(newval)
		oDashboard.SetAttribute(:@LastActivity, "User updated: " + @@(newval))
	})
	
	# Set up debounced email validation
	oUser.DebounceProperty(:@Email, 500, func(attr, oldval, newval) {
		if substr(newval, "@") > 0
			? "📧 Email validation passed: " + newval
		else
			? "⚠️ Email validation failed: " + newval
		ok
	})
	
	# Create activity stream
	oActivityStream = oUser.StreamProperty(:@IsValid)
	oActivityStream.Subscribe(func(data) {
		bIsValidNow = false
		for i = 1 to len(data) step 2
			if data[i] = "newval"
				bIsValidNow = data[i+1]
				exit
			ok
		next
		
		if bIsValidNow
			? "🎉 User is now valid and can access the system!"
		ok
	})

	# Run the demo
	Rs.SetTimeout(func {
		? "Step 1: Setting basic info..."
		oUser.Batch(func {
			oUser.SetAttribute(:@FirstName, "Alice")
			oUser.SetAttribute(:@LastName, "Johnson")
			oUser.SetAttribute(:@Age, 25)
		})
		
		Rs.SetTimeout(func {
			? ""
			? "Step 2: Setting email (with debounce)..."
			oUser.SetAttribute(:@Email, "alice")  # Invalid
			sleep(0.1)

			oUser.SetAttribute(:@Email, "alice@")  # Still invalid
			sleep(0.1)

			oUser.SetAttribute(:@Email, "alice@company.com")  # Valid
			
			Rs.SetTimeout(func {
				? ""
				? "Step 3: Checking final state..."
				? "Full Name: " + oUser.Getattribute(:@FullName)
				? "Is Valid: " + oUser.GetAttribute(:@isValid)
				? "Dashboard User: " + oDashboard.GetAttribute(:@CurrentUser)
				? "Last Activity: " + oDashboard.GetAttribute(:@LastActivity)
				
			}, 1000)
		}, 1000)
	}, 100)
	
	Rs.Start()
	? NL + "✅ Sample completed."

pf()
	

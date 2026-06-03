load "../stzbase.ring"

# Softanza Reactive Programming System - Reactive Objects Samples

#========================================================================#
#  REACTIVE OBJECTS CREATED IN RUNTIME -- Not based on existing classes  #
#========================================================================#

/*--- Basic Attribute Watching

pr()

	# Create reactive system
	Rs = new stzReactiveSystem()

	# Create reactive object
	oXUser = Rs.ReactiveObject()
	oXUser.SetAttribute(:@Name, "")
	oXUser.SetAttribute(:@Age, 0)

	# Watch name changes
	oXUser.Watch(:@Name, func(oSelf, attr, oldval, newval) {
		? "╰─> Name changed from (" + @@(oldval) + ") to (" + @@(newval) + ")"
	})

	# Watch age changes
	oXUser.Watch(:@Age, func(oSelf, attr, oldval, newval) {
		? "╰─> Age changed from " + @@(oldval) + " to " + @@(newval)
	})

	# Test Attribute changes
	Rs.RunAfter(100, func {
		? "Setting name to 'John'..."
		oXUser.SetAttribute(:@Name, "John")
		? ""

		Rs.RunAfter(500, func {
			? "Setting age to 25..."
			oXUser.SetAttribute(:@Age, 25)
			? ""

			Rs.RunAfter(500, func {
				? "Changing name to 'John Doe'..."
				oXUser.SetAttribute(:@Name, "John Doe")
			})
		})
	})
	
	Rs.Start()
	? NL + "✔ Sample completed."

#-->
# Setting name to 'John'...
# ╰─> Name changed from ("") to ("John")
#
# Setting age to 25...
# ╰─> Age changed from 0 to 25
#
# Changing name to 'John Doe'...
# ╰─> Name changed from ("John") to ("John Doe")

# ✔ Sample completed.

pf()
# Executed in 1.98 second(s) in Ring 1.23

/*--- Computed Attributes

pr()
	
	# Create a reactive system
	Rs = new stzReactiveSystem()
	
	# From inside the reactive system, we create a reactive object

	oXUser = Rs.ReactiveObject()
	oXUser { # Here we craft the object's attributes

		@(:@FirstName = "")	# Or SetAttribute(name, val)
		@(:@LastName = "")
		@(:@FullName = "")
		@(:@Email = "")
		@(:@Age = 0)
		@(:@IsAdult = false)
	}
	
	# Computed Attribute: @fullName depends on @firstName and lastName

	oXUser.Computed(:@FullName,

		func oSelf {
		        cResult = trim(oSelf.GetAttribute(:@FirstName) + " " + oSelf.GetAttribute(:@LastName))
		        return cResult
		},

		[ :@FirstName, :@LastName ]
	)

	
	# Computed Attribute: isAdult depends on age

	oXUser.Computed(:@IsAdult,

		func oSelf {
			return oContext.GetAttribute(:@Age) >= 18
		},

		[ :@Age ]
	)
	
	# Watch computed attributes to see auto-updates

	oXUser.Watch(:@FullName,
		func(oSelf, attr, oldval, newval) {
			? "Full name computed: (" + newval + ")"
		}
	)

	oXUser.Watch(:@IsAdult,
		func(oSelf, attr, oldval, newval) {
			? "Adult status: " + newval
		}
	)
	
	# Test computed attributes
	# SetTimeout is used to givethe reactive loop time to
	# start and perfom subsequent tasks

	Rs.RunAfter(100, func {
		? "Setting firstName to 'Jane'..."
		oXUser.SetAttribute(:@FirstName, "Jane")
		? ""

			Rs.SetTimeout(500, func {
				? "Setting lastName to 'Smith'..."
				oXUser.SetAttribute(:@LastName, "Smith")
				? ""

				Rs.SetTimeout(500, func {
					? "Setting age to 17..."
					oXUser.SetAttribute(:@Age, 17)
					? ""

					Rs.SetTimeout(500, func {
						? "Setting age to 21..."
						oXUser.SetAttribute(:@Age, 21)
					})
				})
			})
		})
	
	Rs.Start()
	? NL + "✔ Sample completed."

#-->
# Setting firstName to 'Jane'...
# Full name computed: (Jane)
#
# Setting lastName to 'Smith'...
# Full name computed: (Jane Smith)
#
# Setting age to 17...
#
# Setting age to 21...
#
# Adult status: 1

# ✔ Sample completed.

pf()
# Executed in 2.52 second(s) in Ring 1.23

/*--- Attribute Binding

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

/*--- Batch Updates

pr()

	# Create reactive system
	Rs = new stzReactiveSystem()
	
	# Create reactive object
	oXProduct = Rs.ReactiveObject()
	oXProduct.SetAttribute(:@Name, "")
	oXProduct.SetAttribute(:@Price, 0)
	oXProduct.SetAttribute(:@Category, "")
	oXProduct.SetAttribute(:@InStock, false)
	
	# Watch all attributes to see update order

	oXProduct.Watch(:@Name, func(oSelf, attr, oldval, newval) {
	    ? "  Name updated: " + newval
	})
	
	oXProduct.Watch(:@Price, func(oSelf, attr, oldval, newval) {
	    ? "  Price updated: $" + string(newval)
	})
	
	oXProduct.Watch(:@Category, func(oSelf, attr, oldval, newval) {
	    ? "  Category updated: " + newval
	})
	
	oXProduct.Watch(:@InStock, func(oSelf, attr, oldval, newval) {
	    ? "  Stock status: " + string(newval)
	})
	
	# The three attributes are now under the magic eyies of
	# our reactive system: each change could be captured!

	# Let's change them and check how the change is captured,
	# both when the changes are made indivisually or in bacth!

	Rs.RunAfter(100, func {
		? "Individual updates (watch each change):"

		oXProduct.SetAttribute(:@Name, "Laptop")
		sleep(0.1)

		oXProduct.SetAttribute(:@Price, 999.99)
		sleep(0.1)

		oXProduct.SetAttribute(:@Category, "Electronics")
		sleep(0.1)

		oXProduct.SetAttribute(:@InStock, true)
		
		Rs.RunAfter(1000, func {
			? ""
			? "Batch updates (all changes processed together):"

			oXProduct.Batch(func {
				oXProduct.SetAttribute(:@Name, "Gaming Laptop")
				oXProduct.SetAttribute(:@Price, 1299.99)
				oXProduct.SetAttribute(:@Category, "Gaming")
				oXProduct.SetAttribute(:@InStock, false)
			})
		})
	})
	
	Rs.Start()
	? NL + "✔ Sample completed."

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

# ✔ Sample completed.

pf()
# Executed in 2.32 second(s) in Ring 1.23

/*--- Attribute Streams

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
			for i = 1 to len(data) step 2
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

/*--- Reactive Search with Attribute Settling
    Demonstrates how WaitForAttributeToSettle() provides natural debouncing
    without confusing electronics metaphors

pr()
	
	# Create the reactive container system
	Rs = new stzReactiveSystem()
	
	# Create a reactive object to track search state
	oXSearch = Rs.ReactiveObject()
	oXSearch.SetAttribute(:@Query, "")  # Initialize search query attribute
	
	# Watch for immediate feedback on every keystroke
	# This fires instantly on each attribute change
	oXSearch.Watch(:@Query, func(oSelf, attr, oldval, newval) {
		? "🔍 Search query changed: " + @@(newval)
	})
	
	# Wait for the query to "settle" (stop changing) before executing search
	# This replaces traditional "debounce" with clearer semantics
	# 800ms = settling period (time to wait after last change)
	oXSearch.WaitForAttributeToSettle(:@Query, 800, func(attr, oldval, newval) {
		? "🎯 Query settled at: (" + newval + ") - Executing search API call"
		? "    (This simulates expensive operations like network requests)"
	})
	
	# Simulate realistic rapid typing behavior
	queries = ["h", "he", "hel", "hell", "hello", "hello w", "hello wo", "hello wor", "hello world"]
	currentQuery = 1
	
	# Start the typing simulation after a brief delay
	Rs.RunAfter(100, func {
		? "Simulating rapid typing - search will execute only after typing settles:"
		? ""
		TypeNext()
	})
	
	# Activate the reactive system
	Rs.Start()
	? NL + "✔ Reactive search demo completed."

pf()

func TypeNext()
	# Continue typing simulation until all queries are processed
	if currentQuery <= len(queries)
		query = queries[currentQuery]
		? "⌨️ User types: " + @@(query)
		
		# This triggers both immediate Watch() and starts settling timer
		oXSearch.SetAttribute(:@Query, query)
		currentQuery++
		
		if currentQuery <= len(queries)
			# Simulate fast typing (150ms between keystrokes)
			Rs.RunAfter(150, func { TypeNext() })
		else
			# Allow enough time for final settling (800ms + buffer)
			Rs.RunAfter(1500, func { Rs.Stop() })
		ok
	ok

#--> Expected Output:
# Simulating rapid typing - search will execute only after typing settles:
# 
# ⌨️ User types: 'h'
# 🔍 Search query changed: 'h'
# ⌨️ User types: 'he'
# 🔍 Search query changed: 'he'
# ⌨️ User types: 'hel'
# 🔍 Search query changed: 'hel'
# ⌨️ User types: 'hell'
# 🔍 Search query changed: 'hell'
# ⌨️ User types: 'hello'
# 🔍 Search query changed: 'hello'
# ⌨️ User types: 'hello w'
# 🔍 Search query changed: 'hello w'
# ⌨️ User types: 'hello wo'
# 🔍 Search query changed: 'hello wo'
# ⌨️ User types: 'hello wor'
# 🔍 Search query changed: 'hello wor'
# ⌨️ User types: 'hello world'
# 🔍 Search query changed: 'hello world'
# 🎯 Query settled at: (hello world) - Executing search API call
#     (This simulates expensive operations like network requests)
# 
# ✔ Reactive search demo completed.

#===========================================================#
#  EXAMPLES OF REACTIVE OBJECTS BASEDD ON EXISTING CLASSES  #
#===========================================================#

/*---

pr()

# Create a regular object instance
oPerson = new Person("John", 25)

# Initialize reactive system
Rs = new stzReactiveSystem()

# Make the existing object reactive
oXPerson = Rs.Reactivate(oPerson)
oXPerson {

	# Add watchers
	Watch(:name, func(oSelf, attr, oldval, newval) {
		? CheckMark() + " Name changed: " + oldval + " → " + newval
	})

	Watch(:age, func(oSelf, attr, oldval, newval) {
		? CheckMark() + " Age chnaged: " + oldval + " → " + newval
	})

	Watch(:email, func(oSelf, attr, oldval, newval) {
		? CheckMark() + " Email set: " + newval
	})

	? "Starting property changes..."

	@(:name = "Karim")
	@(:age = 30)
	@(:email = "karim@example.com")

}

Rs.Start()
? NL + "✔ Attribute changes completed."

pf()

# Define a regular class
class Person
	name = ""
	age = 0
	email = ""
	
	def Init(cName, nAge)
		name = cName
		age = nAge

#-->
# Starting property changes...
# ✓ Name changed: John → Karim
# ✓ Age chnaged: 25 → 30
# ✓ Email set: karim@example.com
# 
# ✔ Attribute changes completed.

# Executed in 0.96 second(s) in Ring 1.23

/*--- Making a Person Class Reactive

pr()

# The class used by this example (Person) is defined at the
# end of the code after the pf() function

	# Creating an instance of the Person class

	oPerson = new Person("Youssef", 28)

	# Initialize a Softanza reactive system (Rs)
	Rs = new stzReactiveSystem()

	# Making the Person object reactive
	oXPerson = Rs.ReactivateObject(oPerson)

	# Defining the attributes we want to watch and what
	# would happen when they are changed

	oXPerson.Watch(:name, func(oSelf, attr, oldval, newval) {
		? "✓ Name updated: " + oldval + " → " + newval
	})

	oXPerson.Watch(:age, func(oSelf, attr, oldval, newval) {
		? "✓ Age updated: " + oldval + " → " + newval
	})

	oXPerson.Watch(:email, func(oSelf, attr, oldval, newval) {
		? "✓ Email set: " + newval
	})

	# Changing the attributes and expecting the reactive system
	# to watch the change and fire the functions we definded above

	Rs.RunAfter(100, func {

		oXPerson {
			@(:name = "John Doe")
			@(:age = 26)
			@(:email = "john@test.com")
		}
		
		Rs.RunAfter(500, func {
			? ""
			? "Current person info:"
			oXPerson {
				? "  Name: " + name
				? "  Age: " + age
				? "  Email: " + email
			}
		})
	})

	Rs.Start()
	? NL + "✔ Sample completed."

pf()

class Person
	name = ""
	age = 0
	email = ""
	
	def init(pcName, pnAge)
		name = pcName
		age = pnAge

#-->
# ✓ Name updated: Youssef → John Doe
# ✓ Age updated: 28 → 26
# ✓ Email set: john@test.com
#
# Current person info:
#   Name: John Doe
#   Age: 26
#   Email: john@test.com

# ✔ Sample completed.

# Executed in 1.48 second(s) in Ring 1.23

/*--- Reactive Bank Account Class

pr()

	# Create reactive system
	Rs = new stzReactiveSystem()

	# Make bank account reactive

	oXAccount = Rs.Reactivate(new BankAccount("ACC-001", 1000))

	# Watch balance changes with business logic
	oXAccount.Watch(:balance, func(oSelf, attr, oldval, newval) {
		? "💰 Balance: $" + oldval + " → $" + newval
		
		if newval < 100
			? "(!)  Low balance warning!"
		ok
		
		if newval > oldval
			? "✔ Deposit detected: +" + (newval - oldval)
		else
			? "📉 Withdrawal: -" + (oldval - newval)
		ok
	})

	# Watch status changes
	oXAccount.Watch(:status, func(oSelf, attr, oldval, newval) {
		? "🔄 Account status: " + oldval + " → " + newval
	})

	# 
	Rs.RunAfter(100, func {
		? "Processing deposit..."
		oXAccount.SetAttribute("balance", 1500)

		Rs.RunAfter(500, func {
			? ""
			? "Processing withdrawal..."
			oXAccount.SetAttribute("balance", 50)

			Rs.RunAfter(500, func {
				? ""
				? "Freezing account..."
				oXAccount.SetAttribute("status", "frozen")
			})
		})
	})

	Rs.Start()
	? NL + "✔ Sample completed."

pf()

class BankAccount
	balance = 0
	accountNumber = ""
	status = "active"
	
	def init(cNumber, nBalance)
		accountNumber = cNumber
		balance = nBalance

#-->
# Processing deposit...
# 💰 Balance: $1000 → $1500
# ✔ Deposit detected: +500
#
# Processing withdrawal...
# 💰 Balance: $1500 → $50
# (!)  Low balance warning!
# 📉 Withdrawal: -1450
#
# Freezing account...
# 🔄 Account status: active → frozen

# ✔ Sample completed.

# Executed in 1.99 second(s) in Ring 1.23

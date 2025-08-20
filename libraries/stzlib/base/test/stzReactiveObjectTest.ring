load "../stzbase.ring"

# Softanza Reactive Programming System - Reactive Objects Samples

#=======================================================================#
#  REACTIVE OBJECTS CREATED IN RUNTIME -- Not base on existing classes  #
#=======================================================================#

/*--- Basic Attribute Watching

pr()

	# Create reactive system
	Rs = new stzReactive()

	# Create reactive object
	oUser = Rs.CreateReactiveObject()
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

	# Test Attribute changes
	Rs.SetTimeout(func {
		? "Setting name to 'John'..."
		oUser.SetAttribute(:@Name, "John")
		? ""

		Rs.SetTimeout(func {
			? "Setting age to 25..."
			oUser.SetAttribute(:@Age, 25)
			? ""

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
# Name changed from ("") to ("John")
#
# Setting age to 25...
# Age changed from 0 to 25
#
# Changing name to 'John Doe'...
# Name changed from ("John") to ("John Doe")

# ✅ Sample completed.

pf()
# Executed in 2.02 second(s) in Ring 1.23

/*--- Computed Attributes

pr()
	
	# Create reactive system
	Rs = new stzReactive()
	
	# Create reactive object
	oUser = Rs.CreateReactiveObject()
	oUser.SetAttribute(:@FirstName, "")
	oUser.SetAttribute(:@LastName, "")
	oUser.SetAttribute(:@FullName, "")
	oUser.SetAttribute(:@Email, "")
	oUser.SetAttribute(:@Age, 0)
	oUser.SetAttribute(:@IsAdult, false)
	
	# Computed Attribute: fullName depends on firstName and lastName

	oUser.Computed(:@FullName,

		func(oContext) {
		        cResult = trim(oContext.GetAttribute(:@FirstName) + " " + oContext.GetAttribute(:@LastName))
		        return cResult
		},

		[ :@FirstName, :@LastName ]
	)

	
	# Computed Attribute: isAdult depends on age

	oUser.Computed(:@IsAdult,

		func(oContext) {
			return oContext.GetAttribute(:@Age) >= 18
		},

		[:@Age]
	)
	
	# Watch computed attributes to see auto-updates

	oUser.Watch(:@FullName,
		func(oContext, attr, oldval, newval) {
			? "Full name computed: (" + newval + ")"
		}
	)

	oUser.Watch(:@IsAdult,
		func(oContext, attr, oldval, newval) {
			? "Adult status: " + string(newval)
		}
	)
	
	# Test computed attributes

	Rs.SetTimeout(
		func {
		? "Setting firstName to 'Jane'..."
		oUser.SetAttribute(:@FirstName, "Jane")
		? ""

			Rs.SetTimeout(func {
				? "Setting lastName to 'Smith'..."
				oUser.SetAttribute(:@LastName, "Smith")
				? ""

				Rs.SetTimeout(func {
					? "Setting age to 17..."
					oUser.SetAttribute(:@Age, 17)
					? ""

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

# ✅ Sample completed.

pf()
# Executed in 2.52 second(s) in Ring 1.23

/*--- Attribute Binding

pr()
	
	# Create reactive system
	Rs = new stzReactive()
	
	# Create source object
	oSource = Rs.CreateReactiveObject()
	oSource.SetAttribute(:@Temperature, 20)
	oSource.SetAttribute(:@Status, "normal")
	
	# Create target objects
	oDisplay1 = Rs.CreateReactiveObject()
	oDisplay1.SetAttribute(:@Temp, 0)
	oDisplay1.SetAttribute(:@DisplayName, "Display1")
	
	oDisplay2 = Rs.CreateReactiveObject()
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

#--> Should return
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
	oProduct = Rs.CreateReactiveObject()
	oProduct.SetAttribute(:@Name, "")
	oProduct.SetAttribute(:@Price, 0)
	oProduct.SetAttribute(:@Category, "")
	oProduct.SetAttribute(:@InStock, false)
	
	# Watch all attributes to see update order

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

/*--- Attribute Streams

pr()
	
	# Create reactive system
	Rs = new stzReactive()
	
	# Create reactive object
	oSensor = Rs.CreateReactiveObject()
	oSensor.SetAttribute(:@Value, 0)
	
	# Create stream from Attribute changes
	St = oSensor.StreamAttribute(:@Value)
	
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
			return substr(message, "reading: ") > 0 and 
			       number(substrXT([ message, substr(message, ": ") + 2 ])) > 50
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

/*--- Debounced Attributes

pr()
	
	# Create reactive system
	Rs = new stzReactive()
	
	# Create reactive object
	oSearch = Rs.CreateReactiveObject()
	oSearch.SetAttribute(:@Query, "")
	
	# Watch immediate changes
	oSearch.Watch(:@Query, func(attr, oldval, newval) {
		? "🔍 Search query changed: " + @@(newval)
	})
	
	# Set up debounced handler (waits 800ms before firing)
	oSearch.DebounceAttribute(:@Query, 800, func(attr, oldval, newval) {
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
			Rs.SetTimeout(func { Rs.Stop() }, 1500)
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

# Executed in 15.08 second(s) in Ring 1.23

#===========================================================#
#  EXAMPLES OF REACTIVE OBJECTS BASEDD ON EXISTING CLASSES  #
#===========================================================#

/*---
*/
pr()

# Create a regular object instance
oPerson = new Person("John", 25)

# Initialize reactive system
Rs = new stzReactive()

# Make the existing object reactive
oRPerson = Rs.Reactivate(oPerson)
oRPerson {

	# Add watchers
	Watch(:name, func(attr, oldval, newval) {
		? "👤 Person name changed: " + oldval + " → " + newval
	})

	Watch(:age, func(attr, oldval, newval) {
		? "🎂 Age updated: " + oldval + " → " + newval
	})

	Watch(:email, func(attr, oldval, newval) {
		? "📧 Email set: " + newval
	})

	? "Starting property changes..."

	@(:name = "Karim")
	@(:age = 30)
	@(:email = "karim@example.com")

}

Rs.Start()
? "✅ Attribute changes completed."

pf()

# Define a regular class
class Person
	name = ""
	age = 0
	email = ""
	
	def Init(cName, nAge)
		name = cName
		age = nAge


/*--- Making a Person Class Reactive

pr()

# The class used by this example (Person) is defined at the
# end of the code after the pf() function

	oPerson = new Person("Youssef", 28)
	# Create reactive system
	Rs = new stzReactive()

	# Make existing Person class reactive
	oRPerson = Rs.MakeObjectReactive(:oPerson)

	# Watch attribute changes using Ring's natural syntax
	oRPerson.Watch(:name, func(attr, oldval, newval) {
		? "👤 Person name changed: " + oldval + " → " + newval
	})

	oRPerson.Watch(:age, func(attr, oldval, newval) {
		? "🎂 Age updated: " + oldval + " → " + newval
	})

	oRPerson.Watch(:email, func(attr, oldval, newval) {
		? "📧 Email set: " + newval
	})

	# Use Ring's natural brace syntax - triggers reactive system
	Rs.SetTimeout(func {
		? "Using Ring's natural brace syntax..."
		oRPerson {
			name = "John Doe"      # Triggers setName() + reactive watch
			age = 26               # Triggers setAge() + reactive watch
			email = "john@test.com" # Triggers setEmail() + reactive watch
		}
		
		Rs.SetTimeout(func {
			? ""
			? "Current person info:"
			oRPerson {
				? "Name: " + name    	# Triggers getName()
				? "Age: " + string(age)	# Triggers getAge()
				? "Email: " + email	# Triggers getEmail()
			}
		}, 500)
	}, 100)

	Rs.Start()
	? NL + "✅ Sample completed."

#-->
# Using Ring's natural brace syntax...
# 👤 Person name changed: John → John Doe
# 🎂 Age updated: 25 → 26
# 📧 Email set: john@test.com
#
# Current person info:
# Name: John Doe
# Age: 26
# Email: john@test.com

# ✅ Sample completed.

pf()

class Person
	name = ""
	age = 0
	email = ""
	
	def init(pcName, pnAge)
		name = pcName
		age = pnAge
	
	# Ring's automatic attribute access hooks
	def setName(cName)
		name = cName
	
	def getName()
		return name
		
	def setAge(nAge)
		age = nAge
		
	def getAge()
		return age
		
	def setEmail(cEmail)
		email = cEmail
		
	def getEmail()
		return email

/*--- Reactive Bank Account Class

pr()

	class BankAccount
		balance = 0
		accountNumber = ""
		status = "active"
		
		def init(cNumber, nBalance)
			accountNumber = cNumber
			balance = nBalance
		
		def setBalance(nAmount)
			balance = nAmount
			
		def getBalance()
			return balance
			
		def setStatus(cStatus)
			status = cStatus
			
		def getStatus()
			return status

	# Create reactive system
	Rs = new stzReactive()

	# Make bank account reactive
	oAccount = Rs.MakeReactive(new BankAccount("ACC-001", 1000))

	# Watch balance changes with business logic
	oAccount.Watch(:balance, func(attr, oldval, newval) {
		? "💰 Balance: $" + string(oldval) + " → $" + string(newval)
		
		if newval < 100
			? "⚠️  Low balance warning!"
		ok
		
		if newval > oldval
			? "✅ Deposit detected: +" + string(newval - oldval)
		else
			? "📉 Withdrawal: -" + string(oldval - newval)
		ok
	})

	# Watch status changes
	oAccount.Watch(:status, func(attr, oldval, newval) {
		? "🔄 Account status: " + oldval + " → " + newval
	})

	# Simulate transactions using Ring's brace syntax
	Rs.SetTimeout(func {
		? "Processing deposit..."
		oAccount {
			balance = 1500    # Triggers setBalance() + reactive logic
		}
		
		Rs.SetTimeout(func {
			? ""
			? "Processing withdrawal..."
			oAccount {
				balance = 50   # Triggers low balance warning
			}
			
			Rs.SetTimeout(func {
				? ""
				? "Freezing account..."
				oAccount {
					status = "frozen"
				}
			}, 500)
		}, 500)
	}, 100)

	Rs.Start()
	? NL + "✅ Sample completed."

#-->
# Processing deposit...
# 💰 Balance: $1000 → $1500
# ✅ Deposit detected: +500
#
# Processing withdrawal...
# 💰 Balance: $1500 → $50
# ⚠️  Low balance warning!
# 📉 Withdrawal: -1450
#
# Freezing account...
# 🔄 Account status: active → frozen

# ✅ Sample completed.

pf()

/*--- Reactive Product with Computed Properties

pr()

	class Product
		name = ""
		price = 0
		taxRate = 0.1
		quantity = 0
		totalCost = 0
		
		def setName(cName)
			name = cName
			
		def getName()
			return name
			
		def setPrice(nPrice)
			price = nPrice
			
		def getPrice()
			return price
			
		def setQuantity(nQty)
			quantity = nQty
			
		def getQuantity()
			return quantity
			
		def setTotalCost(nCost)
			totalCost = nCost
			
		def getTotalCost()
			return totalCost

	# Create reactive system
	Rs = new stzReactive()

	# Make product reactive
	oProduct = Rs.MakeReactive(new Product())

	# Set up computed property for totalCost
	oProduct.Computed(:totalCost, 
		func(oContext) {
			basePrice = oContext.getPrice() * oContext.getQuantity()
			tax = basePrice * oContext.taxRate
			return basePrice + tax
		},
		[:price, :quantity]
	)

	# Watch all changes
	oProduct.Watch(:name, func(attr, oldval, newval) {
		? "📦 Product: " + newval
	})

	oProduct.Watch(:price, func(attr, oldval, newval) {
		? "💵 Price: $" + string(newval)
	})

	oProduct.Watch(:quantity, func(attr, oldval, newval) {
		? "📊 Quantity: " + string(newval)
	})

	oProduct.Watch(:totalCost, func(attr, oldval, newval) {
		? "🧮 Total cost (with tax): $" + string(newval)
	})

	# Update product using Ring's natural syntax
	Rs.SetTimeout(func {
		? "Setting up product..."
		oProduct {
			name = "Laptop"
			price = 999.99
			quantity = 2        # This will trigger totalCost computation
		}
		
		Rs.SetTimeout(func {
			? ""
			? "Updating quantity..."
			oProduct {
				quantity = 3    # Recomputes totalCost automatically
			}
		}, 500)
	}, 100)

	Rs.Start()
	? NL + "✅ Sample completed."

#-->
# Setting up product...
# 📦 Product: Laptop
# 💵 Price: $999.99
# 📊 Quantity: 2
# 🧮 Total cost (with tax): $2199.98
#
# Updating quantity...
# 📊 Quantity: 3
# 🧮 Total cost (with tax): $3299.97

# ✅ Sample completed.

pf()

/*--- Reactive Form with Validation

pr()

	class UserForm
		username = ""
		email = ""
		password = ""
		isValid = false
		errors = []
		
		def setUsername(cUser)
			username = cUser
			
		def getUsername()
			return username
			
		def setEmail(cMail)
			email = cMail
			
		def getEmail()
			return email
			
		def setPassword(cPass)
			password = cPass
			
		def getPassword()
			return password
			
		def setIsValid(bValid)
			isValid = bValid
			
		def getIsValid()
			return isValid
			
		def setErrors(aErrs)
			errors = aErrs
			
		def getErrors()
			return errors

	# Create reactive system
	Rs = new stzReactive()

	# Make form reactive
	oForm = Rs.MakeReactive(new UserForm())

	# Set up validation as computed property
	oForm.Computed(:isValid,
		func(oContext) {
			aErrors = []
			
			# Validate username
			if len(oContext.getUsername()) < 3
				aErrors + "Username must be at least 3 characters"
			ok
			
			# Validate email
			cEmail = oContext.getEmail()
			if not (find(cEmail, "@") > 0 and find(cEmail, ".") > 0)
				aErrors + "Invalid email format"
			ok
			
			# Validate password
			if len(oContext.getPassword()) < 6
				aErrors + "Password must be at least 6 characters"
			ok
			
			# Update errors
			oContext.setErrors(aErrors)
			
			return len(aErrors) = 0
		},
		[:username, :email, :password]
	)

	# Watch validation results
	oForm.Watch(:isValid, func(attr, oldval, newval) {
		if newval
			? "✅ Form is valid!"
		else
			? "❌ Form validation failed"
		ok
	})

	oForm.Watch(:errors, func(attr, oldval, newval) {
		if len(newval) > 0
			? "🚨 Validation errors:"
			for error in newval
				? "   • " + error
			next
		ok
	})

	# Test form validation using Ring's brace syntax
	Rs.SetTimeout(func {
		? "Testing form validation..."
		oForm {
			username = "jo"              # Too short
			email = "invalid-email"      # No @ or .
			password = "123"             # Too short
		}
		
		Rs.SetTimeout(func {
			? ""
			? "Fixing form data..."
			oForm {
				username = "john_doe"
				email = "john@example.com"
				password = "secure123"
			}
		}, 1000)
	}, 100)

	Rs.Start()
	? NL + "✅ Sample completed."

#-->
# Testing form validation...
# ❌ Form validation failed
# 🚨 Validation errors:
#    • Username must be at least 3 characters
#    • Invalid email format
#    • Password must be at least 6 characters
#
# Fixing form data...
# ✅ Form is valid!

# ✅ Sample completed.

pf()

/*--- Reactive Shopping Cart with Item Binding

pr()

	class CartItem
		name = ""
		price = 0
		quantity = 1
		subtotal = 0
		
		def init(cName, nPrice)
			name = cName
			price = nPrice
		
		def setQuantity(nQty)
			quantity = nQty
			
		def getQuantity()
			return quantity
			
		def setSubtotal(nSub)
			subtotal = nSub
			
		def getSubtotal()
			return subtotal

	class ShoppingCart
		items = []
		total = 0
		itemCount = 0
		
		def setTotal(nTotal)
			total = nTotal
			
		def getTotal()
			return total
			
		def setItemCount(nCount)
			itemCount = nCount
			
		def getItemCount()
			return itemCount

	# Create reactive system
	Rs = new stzReactive()

	# Create reactive cart
	oCart = Rs.MakeReactive(new ShoppingCart())

	# Create reactive items
	oItem1 = Rs.MakeReactive(new CartItem("Laptop", 999.99))
	oItem2 = Rs.MakeReactive(new CartItem("Mouse", 25.50))

	# Set up computed subtotals for items
	oItem1.Computed(:subtotal,
		func(oContext) {
			return oContext.price * oContext.getQuantity()
		},
		[:quantity]
	)

	oItem2.Computed(:subtotal,
		func(oContext) {
			return oContext.price * oContext.getQuantity()
		},
		[:quantity]
	)

	# Bind item subtotals to cart total calculation
	oCart.Computed(:total,
		func(oContext) {
			return oItem1.getSubtotal() + oItem2.getSubtotal()
		},
		[]  # Will be updated manually when items change
	)

	oCart.Computed(:itemCount,
		func(oContext) {
			return oItem1.getQuantity() + oItem2.getQuantity()
		},
		[]
	)

	# Watch changes
	oItem1.Watch(:quantity, func(attr, oldval, newval) {
		? "🖥️  Laptop quantity: " + string(newval)
		oCart.ComputeAttribute(:total)     # Trigger cart recalculation
		oCart.ComputeAttribute(:itemCount)
	})

	oItem1.Watch(:subtotal, func(attr, oldval, newval) {
		? "💰 Laptop subtotal: $" + string(newval)
	})

	oItem2.Watch(:quantity, func(attr, oldval, newval) {
		? "🖱️  Mouse quantity: " + string(newval)
		oCart.ComputeAttribute(:total)     # Trigger cart recalculation
		oCart.ComputeAttribute(:itemCount)
	})

	oItem2.Watch(:subtotal, func(attr, oldval, newval) {
		? "💰 Mouse subtotal: $" + string(newval)
	})

	oCart.Watch(:total, func(attr, oldval, newval) {
		? "🛒 Cart total: $" + string(newval)
	})

	oCart.Watch(:itemCount, func(attr, oldval, newval) {
		? "📦 Total items: " + string(newval)
	})

	# Test cart updates using Ring's brace syntax
	Rs.SetTimeout(func {
		? "Adding items to cart..."
		oItem1 { quantity = 1 }
		oItem2 { quantity = 2 }
		
		Rs.SetTimeout(func {
			? ""
			? "Customer increases laptop quantity..."
			oItem1 { quantity = 2 }
			
			Rs.SetTimeout(func {
				? ""
				? "Customer adds more mice..."
				oItem2 { quantity = 5 }
			}, 500)
		}, 500)
	}, 100)

	Rs.Start()
	? NL + "✅ Sample completed."

#-->
# Adding items to cart...
# 🖥️  Laptop quantity: 1
# 💰 Laptop subtotal: $999.99
# 🛒 Cart total: $999.99
# 📦 Total items: 1
# 🖱️  Mouse quantity: 2
# 💰 Mouse subtotal: $51
# 🛒 Cart total: $1050.99
# 📦 Total items: 3
#
# Customer increases laptop quantity...
# 🖥️  Laptop quantity: 2
# 💰 Laptop subtotal: $1999.98
# 🛒 Cart total: $2050.98
# 📦 Total items: 4
#
# Customer adds more mice...
# 🖱️  Mouse quantity: 5
# 💰 Mouse subtotal: $127.5
# 🛒 Cart total: $2127.48
# 📦 Total items: 7

# ✅ Sample completed.

pf()

/*--- Error Handling in Reactive Classes

pr()

	class Temperature
		celsius = 0
		fahrenheit = 32
		kelvin = 273.15
		
		def setCelsius(nTemp)
			if nTemp < -273.15
				raise("Temperature cannot be below absolute zero!")
			ok
			celsius = nTemp
			
		def getCelsius()
			return celsius
			
		def setFahrenheit(nTemp)
			fahrenheit = nTemp
			
		def getFahrenheit()
			return fahrenheit
			
		def setKelvin(nTemp)
			kelvin = nTemp
			
		def getKelvin()
			return kelvin
		
		# Ring's error handling hook
		def BraceError()
			? "🚨 Error in Temperature object: " + cCatchError
			# Reset to safe values
			celsius = 0
			fahrenheit = 32
			kelvin = 273.15

	# Create reactive system
	Rs = new stzReactive()

	# Make temperature reactive
	oTemp = Rs.MakeReactive(new Temperature())

	# Set up unit conversions as computed properties
	oTemp.Computed(:fahrenheit,
		func(oContext) {
			return (oContext.getCelsius() * 9/5) + 32
		},
		[:celsius]
	)

	oTemp.Computed(:kelvin,
		func(oContext) {
			return oContext.getCelsius() + 273.15
		},
		[:celsius]
	)

	# Watch temperature changes
	oTemp.Watch(:celsius, func(attr, oldval, newval) {
		? "🌡️  Celsius: " + string(newval) + "°C"
	})

	oTemp.Watch(:fahrenheit, func(attr, oldval, newval) {
		? "🌡️  Fahrenheit: " + string(newval) + "°F"
	})

	oTemp.Watch(:kelvin, func(attr, oldval, newval) {
		? "🌡️  Kelvin: " + string(newval) + "K"
	})

	# Test with valid and invalid values
	Rs.SetTimeout(func {
		? "Setting normal temperature..."
		oTemp {
			celsius = 25    # Valid temperature
		}
		
		Rs.SetTimeout(func {
			? ""
			? "Attempting invalid temperature..."
			oTemp {
				celsius = -300  # Below absolute zero - will trigger error
				# This line won't execute due to error above
				celsius = 100   
			}
			
			Rs.SetTimeout(func {
				? ""
				? "Setting another valid temperature..."
				oTemp {
					celsius = 0  # Freezing point
				}
			}, 500)
		}, 500)
	}, 100)

	Rs.Start()
	? NL + "✅ Sample completed."

#-->
# Setting normal temperature...
# 🌡️  Celsius: 25°C
# 🌡️  Fahrenheit: 77°F
# 🌡️  Kelvin: 298.15K
#
# Attempting invalid temperature...
# 🚨 Error in Temperature object: Temperature cannot be below absolute zero!
#
# Setting another valid temperature...
# 🌡️  Celsius: 0°C
# 🌡️  Fahrenheit: 32°F
# 🌡️  Kelvin: 273.15K

# ✅ Sample completed.

pf()

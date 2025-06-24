load "../max/stzmax.ring"
load "reactive.ring"


/*----
*/
profon()

oMachine = new CoffeeMachine

oMachine {

	processTask([
		:object = ATrueObject(),
		:name = "press_button",
		:label = "espresso",
		:msg = "Waiting for your espresso...",

		:action = "..."
	])

/*	processTask([
		:name = "temperature",
		:value = 95,

		:priority = 1,

		:action = '{
			if @[:value] > 90
				result = "Temperature too high!"
			else
				result = "OK"
			ok
		}',

		# You can pu any success condition you could imagine
		:successW = '{
			isString(result) and
			Q(result).IsEither("Temperature too high!", :Or = "OK")
		}'

	])


	processTask([
		:name = "temperature",
		:value = 82,
		:action = "..."
	])

	RunTasks()
*/
	? @@NL( history )
}

#-->
# Making espresso...
# Temperature too high!

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*----

profon()

oHome = new SmartHome

oHome.processTask([ :name = "motion", :location = "living_room" ])

? oHome.result  # "Turning on lights"
#--> Turning on lights


proff()
# Executed in almost 0 second(s) in Ring 1.22

/*----

profon()


oOrders = new OrderSystem

oOrders {

	processTask([
	    :name = "new_order",
	    :id = "123",
	    :payment = "verified"
	])

	? result
	#--> Processing order #123

	processTask([
		:name = "cancelled_order",
		:id = "77",
		:payment = "cancelled",

		:action = "
			if @[:payment] = 'cancelled'
				result = 'Paiement of order #' + @[:id] + ' cancelled!'
			ok
		"
	])

	? result
	#--> Paiement of order #77 cancelled!

	processTask([
		:name = "cancelled_order",
		:id = "33",
		:payment = "cancelled"
	])

	? result + NL
	#--> Paiement of order #33 cancelled!

	? @@NL(history)

}

proff()
# Executed in almost 0 second(s) in Ring 1.22

load "../max/stzmax.ring"

#TODO Add tests for creating a stzRingState object

/*--- #ring-states Softanza functions
*/
pr()

	#WARNING// This code works as expected and even executes
	# the final proff() function correctly, but it returns
	# an internal error I cant't understand:
	# 
	# ~> Error (E3) : Deleting scope while no scope! 
	# 
	#TODO # ~> Ask Mahmoud for it

# Some useful Softanza functions for checking Ring states

pState1 = ring_state_init()
pState2 = ring_state_init()
pNotAState = _NULL_

? isPointer(pstate1)
#--> _TRUE_

? isPointer(pState2)
#--> _TRUE_

? isPointer(pNotAState)
#--> _FALSE_

? type(pState1)
#--> RINGSTATE

? type(pState2)
#--> RINGSTATE

? type(pNotAState)
#--> STRING


? IsRingState(pState1)
#--> _TRUE_

? IsRingState(pState2) # A Softanza function
#--> _TRUE_

? IsRingState(pNotAState)
#--> _FALSE_

? AreRingStates([ pState1, pState2 ]) # A Softanza function
#--> _TRUE_

? AreRingStates([ pState1, pState2, pNotAState ])
#--> _FALSE_

proff()
# Executed in 0.01 second(s)

/*=========== #ring Testing the use of Ring states

pr()
# Creating VM states (Ring Instances in Softanza terms)

	pState1 = ring_state_init()
	#--> Create a state. Returns a pointer of the form:
	#--> [ "000002BFD29F4200", "RINGSTATE", 0 ]

	pState2 = ring_state_init()

# Executing A hello code in each instance

	ring_state_runcode(pState1, ' ? "Hello from Instance 1" ')

	ring_state_runcode(pState2, ' ? "Hello from Instance 2" ')

# Executing a code setting a variable x with a different value in each instance

	ring_state_runcode(pState1, ' x = 10 ')
	ring_state_runcode(pState2, ' x = 20 ')

# Executing a code displaying the value of x in each instance

	ring_state_runcode(pState1, ' ? x ') #--> 10
	ring_state_runcode(pState2, ' ? x ') #--> 20

# Executing a code adding a variable y in function of x value

	ring_state_runcode(pState2, ' y = x * 100 ')

# Getting the current value of x var in each state

	? NL + "---" + NL
	
	? ring_state_findvar(pState1, 'x')[3]
	#--> 10

	? ring_state_findvar(pState2, 'x')[3]
	#--> 20

# Getting the value of y in state 2
	? NL + "---" + NL

	? ring_state_findvar(pState2, 'y')[3]
	#--> 2000

# Altering the value of x and y and get the value y in state 2

	ring_state_runcode(pState2, 'x = 22')
	ring_state_runcode(pState2, 'y = x * 100')

	? ring_state_findvar(pState2, 'y')[3]
	#--> 2200

# Deleting the states

	ring_state_delete(pState1)
	ring_state_delete(pState2)

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.07 second(s) in Ring 1.20

/*-----	#ring #ring-state fault-tolerance
*/
# Desing a fault-tolerant progam in Ring is easy, due to the feature
# of embedding Ring in Ring as explained here:
# https://ring-lang.github.io/doc1.20/ringemb.html

# Let's make a program and istruct it to run four codes, each in a
# disticn instance of the Ring VM.

# And let's make some erros in some of these codes, and see how
# the program will resist and continue its path until ruling them all!

pr()

	? "PROGRAM STARTED >>>"

	# We define a list of operations to be executed,
	# including some that will cause errors

	acOperations = [
		'? 10 + 2',
		'? 10 / 0 ',  # This will cause an error, but program continues
		'? 5 * 3',
		'? ImaginaryFunction()',  # This function doesn't exist
		'? 8 - 3'
	]
 
	# Creating a new Ring state for each operation

	n = 0
	for i = 1 to 4
		n++
		? NL + "~~> Processing operation " + n + " ~~~~~~~~"

		oState = ring_state_init()
		ring_state_runcode( oState, acOperations[i] )

		# State is deleted immediately after execution,
		# because we don't need it anymore

		ring_state_delete(oState)

		#NOTE
		# if the states created are needed in future code
		# then we should leave them alive, and delete them
		# only when required.
		#WARNING
		# In any case we should not leave an instance we
		# don't need to avoid memory leakage.

	next
    
	? NL + "<<< PROGRAM COMPLETED"

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.09 second(s) in Ring 1.20

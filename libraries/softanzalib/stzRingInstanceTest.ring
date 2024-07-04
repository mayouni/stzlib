load "stzlib.ring"

/*--- #ring Testing the use of Ring states
*
pron()
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
# Executed in 0.07 second(s)

/*--- #ring-states Softanza functions
*/
pron()

# Some useful Softanza functions for checking Ring states

pState1 = ring_state_init()
pState2 = ring_state_init()
pNotAState = NULL

? isPointer(pState1) # A standard Ring function
#--> TRUE

? IsRingState(pState2) # A Softanza function
#--> TRUE

? IsRingState(pNotAState)
#--> FALSE

? ArePointers([ pState1, pState2 ]) # A Softanza function
#--> TRUE

? AreRingStates([ pState1, pState2 ]) # A Softanza function
#--> TRUE

? AreRingStates([ pState1, pState2, pNotAState ])
#--> FALSE

proff()
# Executed in 0.04 second(s)

/*-----	#ring #ring-state fault-tolerance

# Desing a fault-tolerant progam in Ring is easy, dut to the feature
# of embedding Ring in Ring as explained here:
# https://ring-lang.github.io/doc1.20/ringemb.html

# Let's make a program and istruct it to run for codes, each in a
# disticn instance of the Ring VM.

# And let's make some erros in some of these codes, and see how
# the program will resist and continue its path until ruling them all!

pron()

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
		ring_state_runcode( ring_state_init(), acOperations[i] )
	next
    
	? NL + "<<< PROGRAM COMPLETED"

proff()
# Executed in 0.08 second(s)

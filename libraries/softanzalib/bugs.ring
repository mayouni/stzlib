load "stzlib.ring"



/*--- #ring Testing the use of Ring states

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

/*-----	#ring-state failt-tolerance

load "stdlib.ring"

func main() {

	? "Starting fault-tolerant program"

	# We define a list of operations to be executed,
	# including some that will cause errors

	aOperations = [
		'divide(10, 2)',
		'divide(10, 0)',  # This will cause an error
		'multiply(5, 3)',
		'badFunction()',  # This function doesn't exist
		'subtract(8, 3)'
	]
 
	# Creating a new Ring state for each operation

	for cOperation in aOperations
		executeOperation(cOperation)
	next
    
	? "Program completed"

}


load "../max/stzmax.ring"

/*---

rx('\[ \d+(?:\.\d+)?, \d+(?:\.\d+)?, "[^"]*" \]') {
	? Match('[ 1, 2, "hello" ]')
}
#--> TRUE

/*---
*/
pr()

# Create patterns to match different list structures

Lx = new stzListex('[ @N, @N, @S, "World", 3 ]') # Lx for Listex
Lx {

	? Match([1, 2, "hello", "World", 3 ])
	#--> TRUE

	# A list in wrong order

	? Match([1, "hello", 2])
	#--> FALSE
}

proff()

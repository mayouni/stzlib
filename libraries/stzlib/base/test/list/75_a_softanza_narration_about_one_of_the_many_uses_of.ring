# Narrative
# --------
# One of the many uses of @ : calling a GLOBAL function from inside an
# object scope.
#
# Many Softanza helpers exist both as a global function AND as a 0-arg
# method on a class. Inside a Q(){} block Ring binds the bare name to the
# METHOD, so calling the global *with arguments* there fails (extra
# params). The @ wildcard (@BothAreNumbers) reaches the global without
# leaving your train of thought -- no need to spin up another object.
#
# Extracted from stzlisttest.ring, block #75.

load "../../stzBase.ring"

pr()

# A global helper -- usable from anywhere:

? BothAreNumbers(5, -12)
#--> TRUE

# When it makes sense, the same check is also a method (call it with Q()):

? Q([ 5, -12 ]).BothAreNumbers() # Q() elevates the list to a stzList object
#--> TRUE

# ~> Same name, different signature: the global takes the two values; the
# method takes none and inspects the object it's called on.

# Inside a stzList block, the bare name binds to the METHOD:

Q([ 5, -12 ]) {
	? BothAreNumbers()	# the 0-arg method -- works
	#--> TRUE

	# ? BothAreNumbers(9, -9)   # <-- would ERROR: "extra number of
	#                           # parameters" (the method takes none).
}

# Workaround 1 -- make another object for the pair:

Q([ 5, -12 ]) {
	? Q([ 9, -9 ]).BothAreNumbers()
	#--> TRUE
}

# Workaround 2 (the Softanza way) -- the @ wildcard calls the GLOBAL:

Q([ 5, -12 ]) {
	? @BothAreNumbers(9, -9)
	#--> TRUE
}

# GENERAL RULE: to call a global from inside an object that also exposes a
# method of the same name, prefix it with @.

pf()
# Executed in almost 0 second(s)

# Narrative
# --------
# StartProfiler()
#
# Extracted from stzGlobalTest.ring, block #35.
#ERR TIMEOUT (>15s)

load "../../stzBase.ring"

pr()

# The following is an exploration of the comprative performance
# of for loops and for/in loops.

# If we iterate over a list of 200 thousand numbers using for/in,
# and without doing anything inside the loop:

	StartTimer()
	
	aList = 1 : 200_000
	for n in aList
		// do nothing
	next
	
	? ElapsedTime()
	#--> 0.07 second(s)

# Let's compare it with a for loop:

	StartTimer()
	
	aList = 1 : 200_000

	_nListLen_ = ring_len(aList)
	for i = 1 to _nListLen_
		// do nothing
	next
	
	? ElapsedTime()
	#--> 0.04 second(s)

# It's done in say X2 better performance!

# Now, what if we omit the call of the function len() from the loop declaration
# and put in a variable, like this:

	StartTimer()
	
	aList = 1 : 200_000
	nLen = len(aList)
	for i = 1 to nLen
		// do nothing
	next
	
	? ElapsedTime()
	#--> 0.03 second(s)

# The X2 factor is maintained in favor of the normal for looo!

# But wait, in the for/in snippet above, we used the variable aList = 1 : 200_000
# and then called it in the loop declaration like this : for n in aList, right?

# So, what if we omit that and use the data 1:200_000 directly like this:

//	StartTimer()
	
//	for n in 1 : 200_000
		// do nothing
//	next
	
//	? ElapsedTime()

# Wow! It's sooo slow!! I aborted the process after more then 10 minutes...

# So, this is the first thing we should learn:
# NEVER USE A FUNCTION CALL IN THE LOOP DECLARATION.

# Now, let's take a step towards reality, and do something
# inside the loop:

	StartTimer()

	aList = 1 : 200_000
	nLen = len(aList)
	nSum = 0

	for i = 1 to nLen 
		nSum += aList[i]
	next

	? ElapsedTime()
	#--> 0.06 second(s)

# For loop made it so quickly in 0.06 seconds! What about for/in loops?

	StartTimer()

	aList = 1 : 200_000
	nSum = 0

	for n in aList 
		nSum += n
	next

	? ElapsedTime()
	#--> 0.09 second(s)

# It's about 0.9 seconds, 30% slower then for loops.

# Now, what if we challenge for/in loop with what it is normally made for:
# the possibility of changing the items values while looping over them...

# To do so, we want to update the item n by the value (n + 2 * n):

	StartTimer()

	aList = 1 : 200_000

	for n in aList 
		n = n + 2 * n
	next

	? ElapsedTime()
	#--> 0.11 second(s)

# Done in 0.11 seconds (less then a second), which is nice!
# Will for loop win the battle as usual? Let's see...

	StartTimer()

	aList = 1 : 200_000
	nLen = len(aList)

	for i = 1 to nLen
		aList[i] = aList[i] + 2 * aList[i]
	next

	? ElapsedTime()
	#--> 0.09 second(s)

# Oh! For loop made it in 0.09 seconds, 30% faster!

# Let's try it for a list as large as 1 million items, first with for/in:

	StartTimer()

	aList = 1 : 1_000_000

	for n in aList 
		n = n + 2 * n
	next

	? ElapsedTime()
	#--> 0.52 second(s)

# And then with a normal for loop:

	StartTimer()

	aList = 1 : 1_000_000
	nLen = len(aList)

	for i = 1 to nLen
		aList[i] = aList[i] + 2 * aList[i]
	next

	? ElapsedTime()
	#--> 0.47 second(s)

# The difference is not huge, but still for is more performant then for/in!

# Then, this is the second thing we should learn, when performance is
# a critical requirement to your algorithm:

# ALWAYS USE THE FOR LOOP INSTEAD OF THE FOR/IN LOOP

StopProfiler()

pf()
# Executed in 0.47 second(s).

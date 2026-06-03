# Narrative
# --------
# Reactive Search with Attribute Settling
#
# Extracted from stzreactiveobjecttest.ring, block #6.

load "../../../stzBase.ring"

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

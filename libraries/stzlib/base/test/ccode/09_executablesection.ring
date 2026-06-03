# Narrative
# --------
# #narration
#
# Extracted from stzccodetest.ring, block #9.

load "../../stzBase.ring"

pr()

StartProfiler()

# When you use keywords other then This[@i] and alike in your
# conditional code, then you must use ExecutableSectionXT()
# and not ExecutableSection(). Otherwise results are not
# guaranteed to be correct. Here is an example:

	o1 = new stzCCode('{ @item = @NextItem + 5 }')
	? o1.ExecutableSection()
	#--> [ 1, :Last ] Which is wrong!

# To be accurate, and because we used @item and @NextItem in
# our conditional code above, we can get the correct executable
# section by using the ...XT() form like this:


	? o1.ExecutableSectionXT() #TODO // Check this!
	#--> [ 1, -1 ]

# We can check this visually by seeing the transpiled code
# made by ExecutableSectionXT() in the background:

	? o1.Transpiled()
	#--> This[@i] = This[@i + 1] + 5

# In fact, when we check it directly:
	? StzCCodeQ('This[@i] = This[@i + 1] + 5').ExecutableSection()
	#--> [ 1, -1 ]

StopProfiler()

pf()
# Executed in 0.10 second(s) in Ring 1.23
# Executed in 0.17 second(s) in ring 1.21
# Executed in 0.43 second(s) in Ring 1.17

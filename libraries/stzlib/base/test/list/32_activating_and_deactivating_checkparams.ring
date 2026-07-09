# Narrative
# --------
# Trading safety for speed: CheckParamsOff() skips Softanza's param
# validation.
#
# By default Softanza validates method arguments (types, named-param shapes,
# ranges) -- safe but not free. CheckParamsOff() turns that off so hot loops
# run faster (the docs note ~half the time on the author's machine); the
# result is identical. The same ReplaceTheseItemsAtPositions call is shown
# with checking ON (named :By) and OFF (positional) -- both yield the same
# list. (ElapsedTime is machine-dependent, so it is illustrative, not
# asserted.)
#
# Extracted from stzlisttest.ring, block #32.

load "../../stzBase.ring"

pr()

# With params-checking ON (the default):

	o1 = new stzList([ "ring", "ruby", "softanza", "ring", "php", "softanza" ])
	o1.ReplaceTheseItemsAtPositions([ 1, 3, 4, 5 ], [ "ring", "softanza" ], :By = "♥♥♥")

	? o1.Content()
	#--> [ "♥♥♥", "ruby", "♥♥♥", "♥♥♥", "php", "softanza" ]

	? ElapsedTime() # illustrative -- varies by machine
	#--> 0.01 second(s)

# Now disable checking and repeat the same job:

	CheckParamsOff()

	o1 = new stzList([ "ring", "ruby", "softanza", "ring", "php", "softanza" ])
	o1.ReplaceTheseItemsAtPositions([ 1, 3, 4, 5 ], [ "ring", "softanza" ], "♥♥♥")

	? o1.Content()
	#--> [ "♥♥♥", "ruby", "♥♥♥", "♥♥♥", "php", "softanza" ]

	# Same result, roughly half the time.

pf()
# Executed in almost 0 second(s)

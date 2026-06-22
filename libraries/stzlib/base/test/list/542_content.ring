# Narrative
# --------
# ReplaceW(:Where, :By): replace every item matching a condition with one value.
#
# The :Where block '{ isNumber(@item) }' selects every number in
# [ "a", 1, "b", 2, "c", 3 ]; :By = "*" is the replacement, giving
# [ "a", "*", "b", "*", "c", "*" ]. ReplaceW is the value-replacing twin of
# ReplaceItemsW. W is the single performant + expressive conditional form.
#
# Extracted from stzlisttest.ring, block #542.

load "../../stzBase.ring"

pr()

StzListQ([ "a", 1, "b", 2, "c", 3 ]) {

	ReplaceW( :Where = '{ isNumber(@item) }', :By = "*" )
	? @@( Content() )
	#--> [ "a", "*", "b", "*", "c", "*" ]
}

pf()
# Executed in 0.13 second(s).

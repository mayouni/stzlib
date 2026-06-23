# Narrative
# --------
# Conditional replacement: ReplaceItemsW(:Where, :By) swaps every matching item.
#
# ReplaceItemsW replaces, with one given value, every item selected by a W
# condition. The :Where block '{ isString(@item) and IsLowercase(@item) }'
# matches each lowercase string; :By = "*" is the replacement. So
# [ 1, "a", 2, "b", 3, "c" ] becomes [ 1, "*", 2, "*", 3, "*" ] -- the
# numbers are left untouched. W is the single performant + expressive
# conditional form (the old WXT is retired).
#
# Extracted from stzlisttest.ring, block #536.

load "../../stzBase.ring"

pr()

StzListQ( [ 1, "a", 2, "b", 3, "c" ] ) {
	ReplaceItemsW(
		:Where = '{ isString(@item) and IsLowercase(@item) }',
		:By = "*"
	)

	? Content()
	#--> [ 1, "*", 2, "*", 3, "*" ]
}

pf()
# Executed in 0.14 second(s).

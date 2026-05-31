# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #536.

load "../../../stzBase.ring"


# Conditional replacement of items can happen for all the items defined by a
# given condition, and by replacing themn with the same given value like this:

StzListQ( [ 1, "a", 2, "b", 3, "c" ] ) {
	ReplaceItemsWXT(
		:Where = '{ isString(@item) and Q(@item).isLowercase() }',
		:By = "*"
	)

	? Content()
	#--> [ 1, "*", 2, "*", 3, "*" ]
}

StopProfiler()
# Executed in 0.14 second(s) in Ring 1.21
# Executed in 0.28 second(s) in Ring 1.19

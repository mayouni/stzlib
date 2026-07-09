# Narrative
# --------
# Validating a "raise descriptor" hashlist with stzList.
#
# aList is a hashlist whose keys are the parts of a StzRaise message
# (:Where / :What / :Why / :Todo). The block shows how stzList checks such a
# descriptor today: it is a hashlist of at most 4 items, its KEYS are drawn
# from the allowed set, and its VALUES are all non-null strings. The value
# check uses AllItemsVerifyW (Ring's NULL is the empty string, so '@item !=
# NULL' is honoured).
#
# The SECOND block sketches how the same rules could one day be declared as
# reusable constraints on the list object. That constraint system is not built
# yet, so those lines are inert illustrations (they parse as no-ops) kept to
# document the intended direction.
#
# Extracted from stzStringTest.ring, block #980.

load "../../stzBase.ring"

pr()

aList = [
	:Where = "file.ring",
	:What  = "Describes what happened",
	:Why   = "Describes why it happened",
	:Todo  = "Posposes an action to do"
]

# How stzList validates the descriptor today
StzListQ(aList) {
	? NumberOfItems() <= 4
	#--> TRUE

	? IsHashList()
	#--> TRUE

	? ToStzHashList().KeysQ().IsMadeOfSomeOfThese([ :Where, :What, :Why, :Todo ])
	#--> TRUE

	? ToStzHashList().ValuesQ().AllItemsVerifyW("isString(@item) and @item != NULL")
	#--> TRUE
}

# FUTURE (not implemented): in a better world those same conditions could be
# declared once, globally, then reused as constraints on any stzList -- e.g.
#
#	StzListQ(aList) {
#		:MustHave@4@Items
#		:MustBeAHashList
#		:AKeyMustBeOneOfThese = [ :Where, :What, :Why, :Todo ]
#		:ValuesMustBeNonNullStrings
#	}

pf()
# Executed in almost 0 second(s) in Ring 1.27

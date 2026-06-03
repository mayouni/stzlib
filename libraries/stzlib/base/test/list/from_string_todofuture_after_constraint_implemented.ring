# Narrative
# --------
# TODO/FUTURE : AFTER CONSTRAINT IMPLEMENTED
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

IsRaiseNamedParamList(aList) #--> TRUE

# Internally, StzList checks for a number of conditions

StzListQ(aList) {
	? NumberOfItems() <= 4 #--> TRUE
	? IsHashList() #--> TRUE
	? ToStzHashList().KeysQ().IsMadeOfSomeOfThese([ :Where, :What, :Why, :Todo ]) #--> TRUE
	? ToStzHashList().ValuesQ().AllItemsVerifyW("isString(@item) and @item != NULL") #--> TRUE
}

# In a better world, those conditions could be expressed as
# constraints on the list object like this:

StzListQ(aList) {
	:MustHave@4@Items
	:MustBeAHashList
	:AKeyMustBeOneOfThese = [ :Where, :What, :Why, :Todo ]
	:ValuesMustBeNonNullStrings
}

# To make it happen, those constraints should be defined once at
# the global level, and then reused every where inside a stzList

pf()

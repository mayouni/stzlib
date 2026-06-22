# Narrative
# --------
# Checks that a list "is made of these" items: IsMadeOfThese([...])
# returns TRUE when the list contains all of the given values.
#
# IsMadeOfThese is a readable alias in the IsMadeOf family; it simply
# delegates to ContainsMany. Here the list [ "by", "except", "stopwords" ]
# is tested against the same three items expressed as symbols, and since
# every requested item is present the predicate answers TRUE. The family
# reads as plain English (IsMadeOf / IsMadeOfThese), letting set-membership
# checks express the "the list consists of these" idiom directly.
#
# Extracted from stzlisttest.ring, block #429.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "by", "except", "stopwords" ])
? o1.IsMadeOfThese([ :by, :except, :stopwords ])
#--> TRUE

pf()
# Executed in 0.01 second(s).

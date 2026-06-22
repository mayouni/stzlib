# Narrative
# --------
# Shows two type-uniformity predicates on a stzList of lists.
#
# Given [ [1],[1],[1],[1] ] -- a list whose every item is itself a
# one-element list -- ItemsHaveSameType() answers TRUE because all
# four items share the same Ring type (list). ItemsAreEmptyLists()
# answers FALSE because, although every item is a list, none of them
# is empty (each holds the value 1). The pair illustrates the
# Softanza idiom of separating "are the items the same type?" from
# the stricter "are the items all empty lists?" question.
#
# Extracted from stzlisttest.ring, block #470.

load "../../stzBase.ring"

pr()

oList = new stzList([ [1],[1],[1],[1] ])
? oList.ItemsHaveSameType()
#--> TRUE

? oList.ItemsAreEmptyLists()
#--> FALSE

pf()
# Executed in almost 0 second(s).

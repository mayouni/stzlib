# Narrative
# --------
# Counting matches: CountW and its NumberOfOccurrenceW alias.
#
# '{ IsLowercase(@item) }' selects every all-lowercase string in
# [ "c", "c++", "C#", "RING", "python", "ruby" ] -- that is "c", "c++",
# "python", "ruby", four of them. CountW returns that tally (4), and
# NumberOfOccurrenceW is a readable alias for the same count. W is the
# single performant + expressive conditional form (the old WXT is retired).
#
# Extracted from stzlisttest.ring, block #553.

load "../../stzBase.ring"

pr()

o1 = new stzList(["c", "c++", "C#", "RING", "python", "ruby"])

? o1.CountW('{ IsLowercase(@item) }')
#--> 4

? o1.NumberOfOccurrenceW('{ IsLowercase(@item) }')
#--> 4

pf()
# Executed in 0.25 second(s).

# Narrative
# --------
# FindAllW / ItemsW over a type/case predicate.
#
# '{ IsUppercase(@item) }' selects every all-uppercase string. FindAllW
# returns their POSITIONS -- [ 3, 4, 6 ] -- and ItemsW returns the VALUES at
# them -- [ "C#", "RING", "RUBY" ]. ("c", "c++" and "Python" are not all
# uppercase.) W is the single performant + expressive conditional form;
# FindAllW is an alias of FindW.
#
# Extracted from stzlisttest.ring, block #550.

load "../../stzBase.ring"

pr()

o1 = new stzList(["c", "c++", "C#", "RING", "Python", "RUBY"])

? o1.FindAllW('{ IsUppercase(@item) }')
#--> [ 3, 4, 6 ]

? o1.ItemsW('{ IsUppercase(@item) }')
#--> [ "C#", "RING", "RUBY" ]

pf()
# Executed in 0.25 second(s).

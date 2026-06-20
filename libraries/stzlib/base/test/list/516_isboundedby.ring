# Narrative
# --------
# IsBoundedBy + RemoveTheseBounds: detect and strip a matching opening /
# closing pair around a list.
#
# IsBoundedBy([ open, close ]) is TRUE when the FIRST item equals open and
# the LAST equals close -- here "{" ... "}" wrapping the payload. Once
# confirmed, RemoveTheseBounds("{", "}") peels both ends off in place,
# leaving just the inner items. Think of it as bracket-stripping for
# list-shaped data.
#
# Extracted from stzlisttest.ring, block #516.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "{", "A", "B", "C", "}" ])

? o1.IsBoundedBy([ "{", "}" ]) + NL
#--> TRUE

o1.RemoveTheseBounds("{", "}")
? o1.Content()
#--> [ "A", "B", "C" ]

pf()
# Executed in almost 0 second(s)

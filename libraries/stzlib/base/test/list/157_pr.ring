# Narrative
# --------
# Extends a stzList with the items of another list via the explicit
# ExtendXT( :List, :With = [...] ) named-argument form.
#
# ExtendXT is the eXtended (XT) variant of Extend: the first argument
# selects the extension mode (:List here, meaning "append the items of
# the given list one by one"), and :With supplies the source list. So
# [ "A", "B", "C" ] extended with [ "D", "E" ] grows in place to the
# flat five-item list [ "A", "B", "C", "D", "E" ] rather than nesting
# the second list as a single element. The named arguments make the
# intent self-documenting at the call site.
#
# Extracted from stzlisttest.ring, block #157.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "C" ])
o1.ExtendXT( :List, :With = ["D", "E"])
o1.Show()
#--> [ "A", "B", "C", "D", "E" ]

pf()
# Executed in 0.04 second(s)

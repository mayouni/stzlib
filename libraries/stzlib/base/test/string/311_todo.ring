# Narrative
# --------
# TODO
#
# Extracted from stzStringTest.ring, block #311.
#
# NOTE (audit, 2026-07-01): DEFERRED. The archive marks this block TODO and
# the call passes NO substring to insert -- InsertAfterEachNCharsXT(3,
# :StartingFrom = :End) is expected to produce "123_456_789" but nothing in
# the API says where "_" comes from. The from-the-END grouping form needs an
# upstream API decision (e.g. InsertAfterEachNCharsXT(n, str, :StartingFrom))
# before it can be implemented and asserted. The forward form is covered by
# InsertXT(str, :EachNChars = n) -- see test 308.

load "../../stzBase.ring"


pr()

o1 = new stzString("123456789")

o1.InsertAfterEachNCharsXT(3, :StartingFrom = :End)
? o1.Content()
#--> 123_456_789

pf()
# Executed in 0.03 second(s)

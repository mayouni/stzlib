# Narrative
# --------
# Inserting an item past the end of a stzList auto-grows the list,
# back-filling the skipped positions.
#
# Here a list seeded with the range "A":"E" (five items) receives
# "X" at position 8 via AddItemAt(). Positions 6 and 7 did not
# exist, so Softanza extends the list to fit and fills the gap with
# empty-string placeholders rather than rejecting the out-of-range
# index. Content() then returns the full eight-item list, and @@()
# renders the gap fillers as "" (empty strings), not NULL.
#
# Extracted from stzlisttest.ring, block #472.

load "../../stzBase.ring"

pr()

o1 = new stzList("A":"E")
o1.AddItemAt(8, "X")
? @@( o1.Content() )
#--> [ "A", "B", "C", "D", "E", "", "", "X" ]

pf()
# Executed in almost 0 second(s).

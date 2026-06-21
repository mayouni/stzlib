# Narrative
# --------
# Detecting a list whose every item is itself an empty list, and
# what Association() does when all of its lists are empty.
#
# AllItemsAreEmptyLists() (an alias of IsListOfEmptyLists, also spelled
# ContainsOnlyEmptyLists) returns TRUE for [ [], [] ] because both items
# are empty lists. The second line probes the Association() global: it
# pads every input list up to the longest one then zips them column by
# column. When all lists are empty the common max length is 0, the zip
# loop never runs, and the result is simply an empty list [ ] -- there is
# no "can't associate empty lists" error; the operation degrades cleanly.
#
# Extracted from stzlisttest.ring, block #88.

load "../../stzBase.ring"

pr()

? Q([ [], [] ]).AllItemsAreEmptyLists()
#--> TRUE

? @@( Association([ [], [] ]) )
#--> [ ]

pf()

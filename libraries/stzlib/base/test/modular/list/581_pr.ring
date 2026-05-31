# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #581.

load "../../../stzBase.ring"


o1 = new stzList(["file1", "file2", "file3" ])

# The operators (*, +, /) when used with basic Ring types
# (strings, numbers) return a new value without altering
# the object itself (o1 in our case).

# Hence, if we say:

? o1 * ".ring"
#--> [ "file1.ring", "file2.ring", "file3.ring" ]

? o1.Content()
#--> ["file1", "file2", "file3" ]

? o1 + "file4"
#--> [ "file1", "file2", "file3", "file4" ]

pf()
# Executed in almost 0 second(s).

# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #485.

load "../../stzBase.ring"


# Softanza have a Repeat() function you can use like thois:

? Repeat("A", 3)
#--> [ "A", "A", "A" ]

# Which is the same as:

? RepeatInList("A", 3)

# And when you want the repetinion putpt to be a sitring:

? RepeatInString("A", 3) # Equaivalent of Ring copy() function
#--> "AAA"

# But this is just a part of the story. Say hello the extented RepeatXT() function!
# ~> See next narration.
pf()
# Executed in almost 0 second(s) in Ring 1.22

# Narrative
# --------
# pr()
#
# Extracted from stzccodetest.ring, block #1.

load "../../stzBase.ring"

pr()

rx = new stzRegex("@i[+-]\d+|@i")
? rx.Match("@i-2 @i+1 @i")
? @@( rx.Matches() ) + NL
#--> [ "@i-2", "@i+1", "@i" ]

rx = new stzRegex("(?<=@i)([+-]\d+)")
? rx.Match("@i-2 @i+1 @i")
? @@( rx.Matches() ) + NL
#--> [ "-2", "+1" ]

pf()
# Executed in almost 0 second(s) in Ring 1.26 (Backed by StzEngine)
# Executed in 0.02 second(s) in Ring 1.22

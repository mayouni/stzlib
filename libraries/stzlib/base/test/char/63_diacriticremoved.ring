# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #63.

load "../../stzBase.ring"

pr()

? StzCharQ("é").DiacriticRemoved() #--> "e"
? StzCharQ("æ").DiacriticRemoved() #--> "a"
? StzCharQ("Ķ").DiacriticRemoved() #--> "k"
? StzCharQ("œ").DiacriticRemoved() #--> "o"

? StzCharQ("ſ").RemoveDiacriticQ().Content() #--> "s"

pf()
# Executed in 0.05 second(s) in Ring 1.23

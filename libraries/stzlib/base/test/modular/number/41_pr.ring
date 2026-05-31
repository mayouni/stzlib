# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #41.

load "../../../stzBase.ring"


? @@( CircledNumbers() )
#--> [ "①", "②", "③", "④", "⑤", "⑥", "⑦", "⑧", "⑨", "⓪" ]

? StzNumberQ("⓪").Number() #--> 0 
? StzNumberQ("①").Number() #--> 1 
? StzNumberQ("②").Number() #--> 2 
? StzNumberQ("③").Number() #--> 3 
? StzNumberQ("④").Number() #--> 4 
? StzNumberQ("⑤").Number() #--> 5 
? StzNumberQ("⑥").Number() #--> 6 
? StzNumberQ("⑦").Number() #--> 7 
? StzNumberQ("⑧").Number() #--> 8 
? StzNumberQ("⑨").Number() #--> 9
# You can also use .NumericValue() or just .Value() and it works!

pf()
# Executed in 0.07 second(s)

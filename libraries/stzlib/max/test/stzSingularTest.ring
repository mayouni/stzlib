load "../stzmax.ring"

/*--- Test regular plurals

pr()

? Singular("cats")       #--> cat
? Singular("dogs")       #--> dog

pf()
# Executed in 0.21 second(s) in Ring 1.22

/*--- Test morphological patterns

pr()

? Singular("buses")      #--> bus
? Singular("boxes")      #--> box
? Singular("churches")   #--> church
? Singular("cities")     #--> city
? Singular("babies")     #--> baby
? Singular("leaves")     #--> leaf
? Singular("knives")     #--> knife

pf()
# Executed in 0.54 second(s) in Ring 1.22

/*--- Test irregular plurals

pr()

? Singular("children")   #--> child
? Singular("men")        #--> man
? Singular("mice")       #--> mouse

pf()
# Executed in 0.17 second(s) in Ring 1.22

/*--- Test unchanged plurals

pr()

? Singular("sheep")      #--> sheep
? Singular("fish")       #--> fish

pf()
# Executed in 0.12 second(s) in Ring 1.22

/*--- Test uppercase and trimmed input

pr()

? Singular("CATS")       #--> cat
? Singular("  dogs  ")   #--> dog

pf()
# Executed in 0.20 second(s) in Ring 1.22

/*--- Test edge cases

pr()

? Singular("xyzs")       #--> xyz
? Singular("bs")         #--> b
? Singular("s")          #--> s

pf()
# Executed in 0.32 second(s) in Ring 1.22

/*--- Test dynamic rule addition

pr()

? Singular("cacti")      #--> cacti  (before rule addition)
AddSingularRule("^cacti$", "cactus", "exact", 1, "custom")
? Singular("cacti")      #--> cactus (after rule addition)
pf()

# Executed in 0.16 second(s) in Ring 1.22

/*--- Test category-based queries
*/
pr()

? len(GetSingularRulesByCategory("irregular"))  #--> 8
? len(GetSingularRulesByCategory("morphology")) #--> 8

pf()
# Executed in almost 0 second(s) in Ring 1.22

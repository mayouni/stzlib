load "../stzmax.ring"

/*--- Test regular plurals

pr()

? Plural("cat")         #--> cats
? Plural("dog")         #--> dogs

pf()
# Executed in 0.12 second(s) in Ring 1.22

/*--- Test morphological patterns

pr()

? Plural("bus")         #--> buses
? Plural("box")         #--> boxes
? Plural("church")      #--> churches
? Plural("city")        #--> cities
? Plural("baby")        #--> babies
? Plural("leaf")        #--> leaves
? Plural("knife")       #--> knives

pf()
# Executed in 0.29 second(s) in Ring 1.22

/*--- Test irregular plurals

pr()

? Plural("child")       #--> children
? Plural("man")         #--> men
? Plural("mouse")       #--> mice

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Test unchanged plurals


pr()

? Plural("sheep")       #--> sheep
? Plural("fish")        #--> fish

pf()
# Executed in 0.03 second(s) in Ring 1.22

/*---Test uppercase and trimmed input

pr()

? Plural("CAT")         #--> cats
? Plural("  dog  ")     #--> dogs

pf()
# Executed in 0.14 second(s) in Ring 1.22

/*--- Test edge cases

pr()

? Plural("xyz")         #--> xyzs
? Plural("b")           #--> bs
? Plural("")            #--> s

pf()
# Executed in 0.14 second(s) in Ring 1.22

/*---Test dynamic rule addition

pr()


AddPluralRule("^test$", "tests", "exact", 1, "custom")
? Plural("test")        #--> tests

#TODO The example does not show the importance of adding dynamic rules
# think of a case of a word that is not managed correctly with the
# existant system, but can be fixed with a dynamic rule!

#TODO Also show more examples of rules.

pf()
# Executed in 0.06 second(s) in Ring 1.22

/*---Test category-based queries
*/

pr()

? len(GetPluralRulesByCategory("irregular"))  #--> 8
? len(GetPluralRulesByCategory("morphology")) #--> 9

pf()
# Executed in almost 0 second(s) in Ring 1.22

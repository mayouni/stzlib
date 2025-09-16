# Test of the data-driven Adverb() function

load "../stzbase.ring"


/*--- Morphological patterns (priority 4)

pr()

? Adverb("quick")		#--> quickly
? Adverb("happy")		#--> happily  
? Adverb("gentle")		#--> gently
? Adverb("basic")		#--> basically
? Adverb("comfortable")		#--> comfortably

pf()
# Executed in 0.22 second(s) in Ring 1.23
# Executed in 0.51 second(s) in Ring 1.22

/*--- Irregular forms (priority 1)

pr()

? Adverb("good")	#--> well
? Adverb("fast")	#--> fast
? Adverb("hard")	#--> hard

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Domain-specific (priority 2)

pr()

? Adverb("finance")		#--> financially
? Adverb("science")		#--> scientifically
? Adverb("sales")		#--> sales-wise
? Adverb("accounting")		#--> from an accounting perspective

? ""

? Adverb("technology")		#--> technologically
? Adverb("administration")	#--> administratively
? Adverb("economy")		#--> economically

? Adverb("Marketing")		#--> from a marketing perspective
? Adverb("Support")		#--> supportly

pf()
# Executed in 0.20 second(s) in Ring 1.23
# Executed in 0.45 second(s) in Ring 1.22

/*--- Geographic/Cultural (priority 3)

pr()

? Adverb("france")		#--> french
? Adverb("english")		#--> english
? Adverb("arab")		#--> arabic

? Adverb("africa")		#--> african
? Adverb("asia")		#--> asian
? Adverb("australia")		#--> australian
? Adverb("north")		#--> northern
? Adverb("south")		#--> southern
? Adverb("east")		#--> eastern
? Adverb("west")		#--> western

pf()
# Executed in 0.35 second(s) in Ring 1.23
# Executed in 0.80 second(s) in Ring 1.22

/*--- Testing priority system

pr()

? Adverb("business")	#--> business-wise
? Adverb("Education")	#--> educationly

pf()
# Executed in 0.04 second(s) in Ring 1.23
# Executed in 0.06 second(s) in Ring 1.22

/*--- Dynamic rule management

pr()

AddAdverbRule("^legal$", "legally", "exact", 2, "domain")
? Adverb("legal") #--> legally

AddAdverbRule("ment$", "mentally", "suffix", 4, "morphology")
? Adverb("payment") #--> paymentally

pf()
# Executed in 0.07 second(s) in Ring 1.23
# Executed in 0.14 second(s) in Ring 1.22

/*--- Category-based queries

pr()

? len(GetAdverbRulesByCategory("domain"))	#--> 11
? len(GetAdverbRulesByCategory("morphology"))	#--> 12

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Edge cases

pr()

? Adverb("QUICK")		#--> quickly
? Adverb("  slow  ")		#--> slowly
? Adverb("xyzabc")		#--> xyzabcly

? ""

# Vowel+y test
? Adverb("play")	#--> playily

# Consonant+y test
? Adverb("dry")		#--> drily

pf()
# Executed in 0.26 second(s) in Ring 1.23
# Executed in 0.56 second(s) in Ring 1.22

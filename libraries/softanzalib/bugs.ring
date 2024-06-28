load "stzlib.ring"

/*--- #narration #semantic-precision
*/
pron()

# In Softanza ContainsLetters() is different from ContainsOnlyLetters()

o1 = new stzString("123 ABCDEF")
	? o1.ContainsLetters() # Coudd contains non letters
	#--> TRUE
	
	? o1.ContainsOnlyLetters() # same as IsAlphabetic()
	#--> FALSE

o2 = new stzString("ABCDEF")
	? o2.ContainsLetters()
	#--> TRUE
	
	? o2.ContainsOnlyLetters()
	#--> TRUE

#TODO add sample on ContainsNumbersAndLetters() vs ContainsNumbersOrLetters()

proff()
# Executed in 0.07 second(s)

/*-- # ring

pron()

? isAlpha("Ring")
#--> TRUE

? isAlnum("Ring120")
#--> TRUE

proff()

/*--- #ring #fix

pron()

# Ring standard functions

? isAlpha("محمود")
#!--> FALSE
#~> Should be TRUE
	
? isAlnum("محمود2024")
#!--> FALSE
#~> Should be TRUE

# Softanza function fixing the issue

? @IsAlpha("محمود") # or @IsAlphabetical()
#--> TRUE

? @IsAlnum("محمود2024") # or @IsAlphanum()
#--> TRUE

proff()
# Executed in 0.04 second(s)

/*----
*/
pron()

o1 = new stzString("The quick brown fox")

? @@(  o1.SubStringsWCSXTZZ('len(@SubString) = 5 and Q(@SubString).IsAlphabetic()', TRUE) )
#--> [ [ "quick", [ 5, 9 ] ], [ "brown", [ 11, 15 ] ] ]

proff()
# Executed in 2.26 second(s)

/*-----
*/


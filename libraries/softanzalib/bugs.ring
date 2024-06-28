load "stzlib.ring"

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

o1 = new stzString("The quick brown fox jumps over the lazy dog. The Fox is quick!")

? @@(  o1.SubStringsWCSXTZZ('len(@SubString) = 5 and Q(@SubString).IsAlphabetic()', TRUE) )

proff()

/*-----
*/


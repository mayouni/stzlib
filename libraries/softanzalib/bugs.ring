load "stzlib.ring"

/*-- # ring
*/

pron()

? isAlpha("Ring")
#--> TRUE

? isAlnum("Ring120")
#--> TRUE
#!--> FALSE
#~> Should be TRUE

? isAlpha("محمود")
#!--> FALSE
#~> Should be TRUE

? @IsAlpha("محمود") # From Softanza
#--> TRUE

proff()

/*----

o1 = new stzString("The quick brown fox jumps over the lazy dog. The Fox is quick!")

? @@(  o1.SubStringsWCSXTZZ('len(@string) = 5 and Q(@string).IsAlphabetic()', TRUE) )
/*-----
*/


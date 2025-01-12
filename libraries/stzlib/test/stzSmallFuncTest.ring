load "../max/stzmax.ring"

/*======== Some small functions #perf (Ring 1.19 quicker than 1.20)
*/
pr()

# Returning a number in the form of string using S() abbreviation

? S(12) #--> "12"

# Returning a list in the form of string using S() abbreviation

? S(["A","B","C"]) #--> '["A","B","C"]'

# Returning a list of strings from ♥1 to ♥2 using L() abbreviation

? L(' "♥1" : "♥5" ') #--> [ "♥1", "♥2", "♥3", "♥4", "♥5" ]

# Returning a contiguous list of strings in a non latin script using L() abbreviation

? L(' "كلمة1" : "كلمة3" ') #--> [ "كلمة3", "كلمة2", "كلمة1" ]

# Returning a list of 5 Empty items using L() abbreviation

? @@( L(5) ) #--> [ "", "", "", "", "" ]

# Returning a number hosted in string using N() abbreviation

? N("12") #--> 12

# Returning a number written in letters inside a string using N() abbreviation (TODO)

//? N("seven") #--> 7	TODO


# Return a number written in arabic letters inside a string using N() abbreviation (TODO)
//? N("سبعة") #--> 7	TODO

# Returning the number of items of a list using N() abbreviation

? N([ "A", "B", "C" ]) #--> 3

# Returning the number of items in a list hosted in a string using N() abbreviation

? N("[ 1, 2, 3 ]") #--> 3

# Returning the number of chars in a string using N() abbreviation

? N("SOFTANZA") #--> 8

# Returning the list of numbers contained in the list using LoN() abbreviation

? LoN([ "A", 12, "B", 14, "C", 20 ]) #--> [12, 14, 20]

# Returning the list of strings contained in the list using LoS() abbreviation

? LoS([ "A", 12, "B", 14, "C", 20 ]) #--> ["A", "B", "C"]

proff()
# Executed in 0.08 second(s) in Ring 1.21
# Executed in 0.14 second(s) in Ring 1.20
# Executed in 0.11 second(s) in Ring 1.19

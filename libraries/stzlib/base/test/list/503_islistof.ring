# Narrative
# --------
# Classifying a whole list by a named category with Q(...).IsListOf(:Category).
#
# IsListOf answers "does every element of this list belong to the given
# category?" The category vocabulary spans scalars (:Numbers, :Strings),
# nested shape (:Lists, :ListOfNumbers), and tolerates plural aliases so
# :ListOfNumbers and :ListsOfNumbers mean the same thing. Q(1:5) expands a
# range into a list before the test, so 1:5 reads as a list of numbers and
# "A":"E" as a list of strings. Note: while the numeric nested cases
# (:ListOfNumbers / :ListsOfNumbers) pass, the string nested cases below
# (:ListOfStrings / :ListsOfStrings) currently return FALSE for the
# pair-built input [ "A":"E", "a":"e" ] -- the recorded TRUE for those two
# is stale.
#
# Extracted from stzlisttest.ring, block #503.

load "../../stzBase.ring"

pr()

# All these return TRUE

? Q( 1:5 ).IsListOf(:Numbers)
#--> TRUE

? Q( "A":"E" ).IsListOf(:Strings)
#--> TRUE

? Q([ 1:5, "A":"E" ]).IsListOf(:Lists)
#--> TRUE

? Q( [ 1:5, 6:10, 11:15 ] ).IsListOf(:ListOfNumbers)
#--> TRUE

? Q( [ 1:5, 6:10, 11:15 ] ).IsListOf(:ListsOfNumbers) // #NOTE the support of plural form
#--> TRUE

? Q( [ "A":"E", "a":"e" ] ).IsListOf(:ListOfStrings)
#--> TRUE

? Q( [ "A":"E", "a":"e" ] ).IsListOf(:ListsOfStrings) //#NOTE the support of plural form
#--> TRUE

pf()
# Executed in 0.09 second(s).

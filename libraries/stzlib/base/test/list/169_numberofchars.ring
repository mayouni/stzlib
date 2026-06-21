# Narrative
# --------
# Counts and extracts the members of a heterogeneous stzList by their
# underlying value type.
#
# Given a single list mixing single characters, multi-char strings,
# numbers, and a nested list, Softanza classifies each member:
# a "char" is a one-codepoint string ("a", "♥", "b"), a "letter" is a
# one-codepoint string that is alphabetic (so "♥" is a char but not a
# letter), a "number" is a numeric value, a "string" is any string
# (chars included), a "list" is any sublist, and a "pair" is a two-item
# sublist. Each family exposes a NumberOf...() count, a plural getter
# returning the values, and a ...Z() variant pairing each value with its
# 1-based position in the host list. NumberOfObjects() is 0 here, so the
# Objects getters return the empty list.
#
# Extracted from stzlisttest.ring, block #169.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "bcd", "♥", 5, "b", "♥♥♥", [1, 2] ])

#--

? o1.NumberOfChars()
#--> 3

? @@( o1.Chars() )
#--> [ "a", "♥", "b" ]

? @@( o1.CharsZ() ) # Or CharsAndTheirPositions()
#--> [ [ "a", 1 ], [ "♥", 3 ], [ "b", 5 ] ]

#--

? o1.NumberOfLetters()
#--> 2

? @@( o1.Letters() )
#--> [ "a", "b" ]

? @@( o1.LettersZ() )
#--> [ [ "a", 1 ], [ "b", 5 ] ]

#--

? o1.NumberOfNumbers()
#--> 1

? @@( o1.Numbers() )
#--> [ 5 ]

? @@( o1.NumbersZ() )
#--> [ [ 5, 4 ] ]

#--

? o1.NumberOfStrings()
#--> 5

? @@( o1.Strings() )
#--> [ "a", "bcd", "♥", "b", "♥♥♥" ]

? @@( o1.StringsZ() )
#--> [ [ "a", 1 ], [ "bcd", 2 ], [ "♥", 3 ], [ "b", 5 ], [ "♥♥♥", 6 ] ]

#--

? o1.NumberOfLists()
#--> 1

? @@( o1.Lists() )
#--> [ [ 1, 2 ] ]

? @@( o1.ListsZ() )
#--> [ [ [ 1, 2 ], 7 ] ]

#--

? o1.NumberOfPairs()
#--> 1

? @@( o1.Pairs() )
#--> [ [ 1, 2 ] ]

? @@( o1.PairsZ() )
#--> [ [ [ 1, 2 ], [ 7 ] ] ]

#--

? o1.NumberOfObjects()
#--> 0

? @@( o1.Objects() )
#--> [ ]

? @@( o1.ObjectsZ() )
#--> [ ]

pf()
# Executed in 0.12 second(s) in Ring 1.20

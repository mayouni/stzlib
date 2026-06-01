# Narrative
# --------
# #narration IDENTIFYING LISTS INSIDE A STRING
#
# Extracted from stzStringTest.ring, block #527.

load "../../../stzBase.ring"


#NOTE // I made an article on the subject here:
# https://github.com/mayouni/stzlib/blob/main/libraries/stzlib/doc/narrations/stz-narration-list-in-strings.md

pr()

# In many situations (especially in advanced metaprogramming scenarios),
# you may need to host a list inside a string, do whatever operations
# on it as as string, and then evaluate it back, in runtime, to
# transform it to a vibrant Ring list again!

# Whatever syntax is used ( noramal [ _ , _ , _ ] or short _:_ ), Softanza
# can recognize any Ring list you would host inside a string:

? StzStringQ('[1,2,3]').IsListInString()		#--> TRUE

? StzStringQ('1:3').IsListInString()			#--> TRUE

? StzStringQ(' "A":"C" ').IsListInString()		#--> TRUE
? StzStringQ(' "ا":"ج" ').IsListInString() + NL		#--> TRUE

# Softanza can tell you if the syntax used is normal or short:

? StzStringQ('[1,2,3]').IsListInNormalForm()		#--> TRUE
? StzStringQ('1:3').IsListInShortForm()			#--> TRUE

? StzStringQ(' "A":"C" ').IsListInShortForm()		#--> TRUE
? StzStringQ(' "ا":"ج" ').IsListInShortForm() + NL	#--> TRUE

# And knows about the list beeing contiguous or not:

? StzStringQ('[1,3]').IsContiguousListInString()	#--> FALSE
? StzStringQ('1:3').IsContiguousListInString()		#--> TRUE

? StzStringQ(' "A":"C" ').IsContiguousListInString()	#--> TRUE
? StzStringQ(' "ا":"ج" ').IsContiguousListInString()	#--> TRUE

	# REMINDER: A contiguous list can be made of  numbers,
	# or contiguous chars (based on their unicode numbers).
	# And you can identify them using the stzList.IsContiguous():

	? IsContiguous(1:3)			#--> TRUE
	? IsContiguous("A":"E") + NL	#--> TRUE

# Back to list IN STRINGS!

# Not only Softanza can see if the list in string is contiguous
# or not, it can also see in what form they are:

? StzStringQ('[1,2,3]').IsContiguousListInNormalForm()	#--> TRUE
? StzStringQ('1:3').IsContiguousListInShortForm()	#--> TRUE

? StzStringQ(' "A":"C" ').IsContiguousListInShortForm()	#--> TRUE
? StzStringQ(' "ا":"ج" ').IsContiguousListInShortForm()	#--> TRUE
? NL

# Now, what about tranforming one form to another: possible in
# both directions, from normal to short, and from short to normal!

? @@( StzStringQ('[1,2,3]').ToListInShortForm() )	#--> "1 : 3"

? @@( StzStringQ('1:3').ToListInNormalForm() )		#--> "[1, 2, 3]"

? StzStringQ(' ["A","B","C","D"] ').ToListInShortForm()	#--> "A" : "D"
? StzStringQ(' "ا":"ج" ').ToListInShortForm() + NL	#--> "ا" : "ج"

# And by default, of course, the normal form is used:

? @@( StzStringQ('[1,2,3]').ToListInString() )	#--> "[1, 2, 3]"
? @@( StzStringQ('1:3').ToListInString() )	#--> "[1, 2, 3]"

? StzStringQ(' "A":"C" ').ToListInString()	#--> [ "A", "B", "C" ]
? StzStringQ(' "ا":"ج" ').ToListInString() + NL	#--> [ "ا", "ب", "ة", "ت", "ث", "ج" ]

# If you prefer (or need) the short form, there is an interesting
# abbreviation to the ToListInShortForm() alternative that uses
# the simple SF prefix (S for Short and F for Form), like this:

? @@( StzStringQ('[1,2, 3]').ToListInStringSF() ) 		#--> "1 : 3"

? @@( StzStringQ('1:3').ToListInStringSF() )			#--> "1 : 3"

? StzStringQ(' ["A","B","C","D"] ').ToListInStringSF()		#--> "A" : "D"
? StzStringQ(' [ "ا", "ب", "ة", "ت" ] ').ToListInStringSF()+ NL	#--> "ا" : "ت"

# Finally, as a cherry on the cake, you can evaluate
# the string in list in runtime like this:

? StzStringQ('1:3').ToList()	   	#--> [1, 2, 3]
? StzStringQ(' "A":"C" ').ToList() 	#--> ["A", "B", "C"]
? StzStringQ(' "ا":"ج" ').ToList() 	#--> [ "ا", "ب", "ة", "ت", "ث", "ج" ]

pf()
# Executed in 1.62 second(s) in Ring 1.22

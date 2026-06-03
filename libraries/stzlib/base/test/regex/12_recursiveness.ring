# Narrative
# --------
# #  Recursiveness  #
#
# Extracted from stzRegexTest.ring, block #12.

load "../../stzBase.ring"

#-----------------#

# Recursive patterns in REGEX are commonly used to match nested
# structures in text. They can be used to validate the correctness
# of nested HTML tags, return them or replace them and parse and
# manipulate complex deep data structures like JSON and XML.

#TODO Reflect on how to simplify it in stzRegexMaker
#DONE See the declarative design experience in stzRegexMakerTest.ring

pr()

# Matching a string containing any number of duplicated "abc"
# Note the use of (?R) inside the pattern to say it's Recursive!

rx("(abc(?R)?)") {

	? IsValid()
	#--> TRUE

	? MatchRecursive("abc")	# Or MatchNested()
	#--> TRUE

	? MatchRecursive("abcabcabc") + NL
	#--> TRUE
}


# Matching a string that contains balanced parentheses

rx("(\((?R)*\))") {

	? MatchManyRecursiveXT([ "()", "(())", "((()))" ])
	#--> [ TRUE, TRUE, TRUE ]

	# NOTE: The XT() here returns the match result of each string in the list.
	# When you omit it, then you all the matches must be TRUE otherwise FALSE is returned

	? MatchManyRecursive([ "()", "not matching", "((()))" ])
	#--> FALSE

	# That's because "not matching" is not matching ;)
	# Bring the XT() backt to see it:

	? MatchManyRecursiveXT([ "()", "not matching", "((()))" ])
	#--> [ TRUE, FALSE, TRUE ]
 }

pf()
# Executed in 0.05 second(s) in Ring 1.22

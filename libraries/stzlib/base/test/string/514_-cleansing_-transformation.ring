# Narrative
# --------
# #narration #data-cleansing #data-transformation
#
# Extracted from stzStringTest.ring, block #514.
#ERR Error (R13) : Object is required

load "../../stzBase.ring"


pr()

# Let's start with a string containing semi-structured data.
# The data is separated by semicolons and spread across multiple
# lines, including empty lines.

o1 = new stzString("

	.;1;.;.;.
	1;2;3;4;5


	.;3;.;.;.
	.;4;.;.;.

	.;5;.;.;.  ")

# The goal is to transform the string into a clean,
# structured list of lists, where each inner list
# represents a row of data, like this:

#--> [
#	[ ".", "1", ".", ".", "." ],
#	[ "1", "2", "3", "4", "5" ],
#	[ ".", "3", ".", ".", "." ],
#	[ ".", "4", ".", ".", "." ],
#	[ ".", "5", ".", ".", "." ]
# ]

# If you think about it, these are the necessary steps:
#	1. Remove empty lines
#	2. Convert the remaining lines into a list of strings
#	3. Trim each string to remove any extra whitespace
#	4. Split each string using the semicolon as a delimiter

# Here is the translation of this thought process in Softanza:

? @@SP(
	o1.RemoveEmptyLinesQ().
	LinesQRT(:stzListOfStrings).
	TrimQ().
	StringsSplitted(:Using = ";")
)
#--> [
#	[ ".", "1", ".", ".", "." ],
#	[ "1", "2", "3", "4", "5" ],
#	[ ".", "3", ".", ".", "." ],
#	[ ".", "4", ".", ".", "." ],
#	[ ".", "5", ".", ".", "." ]
# ]

# It's totally WYTIWYG: "What You Think Is What You Get"!

pf()
# Executed in 0.04 second(s).

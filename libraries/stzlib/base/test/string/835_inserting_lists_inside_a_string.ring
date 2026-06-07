# Narrative
# --------
# #narration INSERTING LISTS INSIDE A STRING
#
# Extracted from stzStringTest.ring, block #835.

load "../../stzBase.ring"


pr()

# In the following example, we'll demonstrate how to use
# InsertSubstringsXT to insert a list of software versions into
# a sentence, complete with proper formatting, separators, and
# surrounding characters.

# Create a new stzString object with the initial text

o1 = new stzString("All our software versions must be updated!")

# Find the position right after the word "versions" in the string
# This is where we'll insert our list of version numbers

nPosition = o1.PositionAfter("versions")

# Use InsertSubstringsXT method to insert a formatted list of versions
# The result showcases how InsertSubstringsXT can create a
# well-formatted list within our original string, complete with
# proper punctuation, separators, and surrounding characters.

o1.InsertSubstringsXT(
	nPosition,
	
	# The list of version numbers to be inserted

	[ "V1", "V2", "V3", "V4", "V5" ],
	
	[
		# Insert the list before the found position

		:InsertBeforeOrAfter = :Before,
		
		# Define the opening and closing characters for the list

		:OpeningChar = "{ ",
		:ClosingChar = " }",
		
		# Set the main separator between list items

		:MainSeparator = ",",

		# Add a space after each separator for readability

		:AddSpaceAfterSeparator = TRUE,
		
		# Use "and" as the separator before the last item

		:LastSeparator = "and",

		# Combine the last separator with the main one (", and")

		:AddLastToMainSeparator = TRUE,
		
		# Add spaces around the entire inserted list

		:SpaceOption = :AddLeadingSpace //+ :AddTrailingSpace
	]
)

# Print the final result to see the formatted string
? o1.Content()
#--> All our software versions { V1, V2, V3, V4, and V5 } must be updated!

pf()
# Executed in 0.02 second(s).

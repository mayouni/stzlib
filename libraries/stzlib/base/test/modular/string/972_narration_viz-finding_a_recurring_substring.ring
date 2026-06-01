# Narrative
# --------
# narration #visiality VIZ-FINDING A RECURRING SUBSTRING
#
# Extracted from stzStringTest.ring, block #972.

load "../../../stzBase.ring"


# This narration explores methods to locate and highlight recurring 
# sequences within strings, with both precision and visual assistance.

pr()

# Searching for "ring" within a jumble of letters:

o1 = new stzString("fjringljringdjringg")

# Let's start with a straightforward approach using Find(),
# which returns the list of positions where "ring" appears:

? @@( o1.Find("ring") ) + NL
#--> [ 3, 9, 15 ]

# We can go further and add a visual dimension by using
# the "viz" prefix with Find(), making the positions easy to spot:

? o1.vizFind("ring") + NL
#-->
# fjringljringdjringg
# --^-----^-----^----

# To gain even more insight, we can add the XT() suffix,
# providing a numeric guide for each matched position:

? o1.vizFindXT("ring", [ :Numbered = TRUE ]) + NL
#-->
# fjringljringdjringg
# --^-----^-----^----
#   3     9     15       

# Now, let's find the positions of "ring" as sections:

? @@( o1.FindAsSections("ring") ) + NL # Or simply FindZZ()
#--> [ [3, 6], [9, 12], [15, 18] ]

# The sections can also be visualized by using
# the :Sectioned option:

? o1.vizFindZZ("ring") + NL
#-->
# fjringljringdjringg
#   '--'  '--'  '--'

? o1.vizFindXT("ring", [ :Sectioned = TRUE, :Numbered = TRUE ]) + NL
#-->
# fjringljringdjringg
#   '--'  '--'  '--'
#   3  6  9 12  15 18

# For a more sophisticated display, we can box and section the output,
# the results become both visually structured and detailed:

? o1.vizFindXT("ring", [
	:Boxed = TRUE, :Rounded = TRUE, :Sectioned = TRUE, :Numbered = TRUE ])
#-->
# ╭───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───╮
# │ f │ j │ r │ i │ n │ g │ l │ j │ r │ i │ n │ g │ d │ j │ r │ i │ n │ g │ g │
# ╰───┴───┴─•─┴───┴───┴─•─┴───┴───┴─•─┴───┴───┴─•─┴───┴───┴─•─┴───┴───┴─•─┴───╯
#           '-----------'           '-----------'           '-----------'
#           3           6           9         12            15         18

pf()
# Code executed in 0.17 second(s) in Ring 1.21

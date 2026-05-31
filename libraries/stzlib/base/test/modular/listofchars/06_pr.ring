# Narrative
# --------
# pr()
#
# Extracted from stzlistofcharstest.ring, block #6.

load "../../../stzBase.ring"


SetHilightChar("♥")

? StzListOfCharsQ("TEXT").BoxedXT([
	:Line = :Solid,	# or :Dashed
		
	:AllCorners = :Round, # can also be :Rectangualr

	# Or you can specify evey corner like this:

	:Corners = [ :Round, :Rectangular, :Round, :Rectangular ],

	:Hilighted = [ 3 ] # The 3rd char is hilighted
		
])

#-->
# ╭───┬───┬───┬───┐
# │ T │ E │ X │ T │
# └───┴───┴─♥─┴───╯

pf()
# Executed in 0.09 second(s).

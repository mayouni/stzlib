# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #24.

load "../../stzBase.ring"


StzTableQ([
	[ :M, :FUNCTION 	, :OBJECT ],

	[ ' ', 'Q'		, 'stzList' ],
	[ ' ', 'AreBothQ' 	, 'stzListOfStrings' ],
	[ '•', 'HavingQ'	, 'stzListOfStrings' ],
	[ ' ', 'AllTheirQ'	, 'stzListOfStrings' ]

# When we specify just the intersection char, Softanza
# add the values by default for the separator ("|")
# and the underline char ("-")

]).ShowXT([ :IntersectionChar = "+" ])

#-->
#  M |  FUNCTION |           OBJECT
#  --+-----------+-----------------
#    |         Q |          stzList
#    |  AreBothQ | stzListOfStrings
#  • |   HavingQ | stzListOfStrings
#    | AllTheirQ | stzListOfStrings

pf()
# Executed in 0.10 second(s)

# Narrative
# --------
# #narration
#
# Extracted from stztabletest.ring, block #27.

load "../../stzBase.ring"


pr()

o1 = new stzTable([
	:COL1 = [ "I", 1 ],
	:COL2 = [ AHeart(), 2 ],
	:COL3 = [ "Ring", 3 ],
	:COL4 = [ "Language", 4 ]
])

# By default, the colnames are underline using "-",
# with a separator, cells are adjusted to the right,
# and the row numbers are not showen

? o1.Show()

#--> COL1   COL2   COL3       COL4
#    ----- ------ ------ ---------
#       I      ♥   Ring   Language
#       1      2      3          4

# If you need a more sophisticated presentation,
# than you can use the extended form the the
# function, without speciying any options.

# In this case, Softanza uses in the backgound,
# the default values the options like this:
# - the colanmes are underlined using "-"
# - the cells are adjusted to the right
# - the colnames and the cells are separated by "|"
# - and the rows numbers are showen

? o1.ShowXT([])

#--> # | COL1 | COL2 | COL3 |     COL4
#    --+------+------+------+---------
#    1 |    I |    ♥ | Ring | Language
#    2 |    1 |    2 |    3 |        4

# If you deactivate the underlining of the header,
# and you do not specify any other option, all
# those options are deactivated

? o1.ShowXT([ :UnderlineHeader = FALSE ])
#--> COL1   COL2   COL3       COL4
#       I      ♥   Ring   Language
#       1      2      3          4

# And when you activate the underlining of
# the header, and don't set any other option,
# only the header is underlined using the
# default char "-"

? o1.ShowXT([ :UnderLineHeader = TRUE ])
#--> COL1   COL2   COL3       COL4
#    -----------------------------
#       I      ♥   Ring   Language
#       1      2      3          4

# But when you specify an intersection char,
# without specifying any other option, all
# the default options are used

o1.ShowXT([ :IntersectionChar = "+" ])
#--> COL1 | COL2 | COL3 |     COL4
#    -----+------+------+---------
#       I |    ♥ | Ring | Language
#       1 |    2 |    3 |        4

pf()
# Executed in 0.24 second(s)

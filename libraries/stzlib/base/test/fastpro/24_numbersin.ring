# Narrative
# --------
# pr()
#
# Extracted from stzfastprotest.ring, block #24.

load "../../stzBase.ring"

pr()

#--- Multiply

str = '[ "muliply", [ [ "col", 1 ], [ "by", 2 ] ] ]'

? @@( NumbersIn(str) )

_aCommandsXT = [
	:set = [ :set, 1, 2 ],
	:add = [ :add, 2, 1 ],
	:subtract = [ :sub, 2, 1 ],
	:multiply = [ :mul, 1, 2 ],
	:divide = [ :div, 1, 2 ],
	:raise = [ :pow, 1, 2 ],
	:modulo = [ :rem, 1, 2 ],
	:copy = [ :copy, 1, 2 ],
	:merge = [ :merge, 1, 2 ]
]




pf()

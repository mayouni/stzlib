# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #214.

load "../../stzBase.ring"

pr()

#                   ..3...7..0...4..7...1..4...8..  
o1 = new stzString("..&^^^&..&^^^&..&---&..&---&..")

? @@NL( o1.BoundedByZ("&") ) + NL
#--> [
#	[ "^^^", 4 ],
#	[ "..", 8 ],
#	[ "^^^", 11 ],
#	[ "..", 15 ],
#	[ "---", 18 ],
#	[ "..", 22 ],
#	[ "---", 25 ]
# ]

? @@NL( o1.BoundedByZZ("&") )
#--> [
#	[ "^^^", [ 4, 6 ] ],
#	[ "..", [ 8, 9 ] ],
#	[ "^^^", [ 11, 13 ] ],
#	[ "..", [ 15, 16 ] ],
#	[ "---", [ 18, 20 ] ],
#	[ "..", [ 22, 23 ] ],
#	[ "---", [ 25, 27 ] ]
# ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.18 second(s) in Ring 1.18

# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #958.

load "../../stzBase.ring"


? @@NL( CardsXT() ) + NL
#--> [
#	[ "ace","🂡" ],
#	[ "two", "🂢" ],
#	[ "three", "🂣" ],
#	[ "four", "🂤" ],
#	[ "five", "🂥" ],
#	[ "six", "🂦" ],
#	[ "seven", "🂧" ],
#	[ "eight", "🂨" ],
#	[ "nine", "🂩" ],
#	[ "ten", "🂪" ],
#	[ "jack", "🂫" ],
#	[ "queen", "🂭" ],
#	[ "king", "🂮" ]
# ]

? @@( Cards() ) + NL
#--> [ "🂡", "🂢", "🂣", "🂤", "🂥", "🂦", "🂧", "🂨", "🂩", "🂪", "🂫", "🂭", "🂮" ]

? Card(:jack) + NL
#--> 🂫

? @@( TheseCards([ :four, :nine, :king ]) ) + NL
#--> [ "🂤", "🂩", "🂮" ]

? @@NL( TheseCardsXT([ :four, :nine, :king ]) )
#--> [
#	[ "four", "🂤" ],
#	[ "nine", "🂩" ],
#	[ "king", "🂮" ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

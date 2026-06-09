# Narrative
# --------
# VISUAL RULES (DATA-DRIVEN)
#
# Extracted from stzdiagramtest.ring, block #52.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("PricingTiers")
oDiag {
	# Add pricing nodes
	AddNodeXTT(:@free, "Free Tier", [ :Price = 0 ])
	AddNodeXTT(:@basic, "Basic Tier", [ :Price = 10 ])
	AddNodeXTT(:@pro, "Pro Tier", [ :Price = 50 ])
	AddNodeXTT(:@entreprise, "Enterprise Tier", [ :price = 200 ])

	ConnectSequence([ :@free, :@basic, :@pro, :@entreprise ])

	# Register visual rules as pure data
	RegisterVisualRule("CHEAP_GREEN", [
	    :ConditionType = "property_range",
	    :ConditionParams = [ :Price, 0, 30 ],
	    :Effects = [
	        :Color = "green-",
	        :PenWidth = 1
	    ]
	])

	RegisterVisualRule("MID_BLUE", [
	    :ConditionType = "property_range",
	    :ConditionParams = [ :Price, 31, 99 ],
	    :Effects = [
	        :Color = "blue+",
	        :PenWidth = 1
	    ]
	])

	RegisterVisualRule("EXPENSIVE_GOLD", [
	    :ConditionType = "property_range",
	    :ConditionParams = [ :Price, 100, 999999 ],
	    :Effects = [
	        :Color = "gold",
		:PenWidth = 3
	    ]
	])
	
	ApplyVisualRules()
	? @@NL( VisualRulesApplied() ) + NL
	#--> [ "@free", "@basic", "@pro", "@entreprise" ]

	? @@( NodesAffectedByVisualRules() )
	#--> [
	# 	[
	# 		[ "name", "CHEAP_GREEN" ],
	# 		[ "conditiontype", "property_range" ],
	# 		[ "effectscount", 2 ]
	# 	],
	# 	[
	# 		[ "name", "MID_BLUE" ],
	# 		[ "conditiontype", "property_range" ],
	# 		[ "effectscount", 2 ]
	# 	],
	# 	[
	# 		[ "name", "EXPENSIVE_GOLD" ],
	# 		[ "conditiontype", "property_range" ],
	# 		[ "effectscount", 2 ]
	# 	]
	# ]

	View()
? Dot()
}

pf()
# Executed in 0.52 second(s) in Ring 1.25
# Executed in 0.68 second(s) in Ring 1.24

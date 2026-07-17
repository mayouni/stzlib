# Narrative
# --------
# How to use .stzgraf file format?
#
# Extracted from stzgraphtest.ring, block #83.

load "../../stzBase.ring"


pr()

# Loading graph from file

oGraph = new stzGraph("supply_chain")
oGraph {
	LoadFromStzGraf("../_data/supply_chain.stzgraf")

	? NodeCount() #--> 5
	? EdgeCount() #--> 5

	# A property comes back as what it IS, not as the text it was written
	# as: a number stays a number, a quoted string loses its quotes.
	? @@(NodeProperty("warehouse_ny", "capacity")) #--> 50000
	? @@(NodeProperty("factory_cn", "cost_per_unit")) #--> 2.50
	? @@(NodeProperty("warehouse_ny", "location")) #--> "New York"

//	View() #--> See the generated SVG image...

//	Show()
	`
	     ╭────────────╮      
	     │ factory_cn │      
	     ╰────────────╯      
	            |            
	            v            
	    ╭──────────────╮     
	    │ warehouse_ny │     
	    ╰──────────────╯     
	            |            
	            v            
	   ╭────────────────╮    
	   │ distributor_eu │    
	   ╰────────────────╯    
	
	          ////
	
	     ╭────────────╮  ↑	#ERR: returns "â†‘" "â”€â”€â•¯"
	     │ factory_cn │──╯
	     ╰────────────╯      
	            |            
	            v            
	   ╭────────────────╮    
	   │ !warehouse_la! │    
	   ╰────────────────╯    
	            |            
	            v            
	   ╭────────────────╮    
	   │ distributor_eu │    
	   ╰────────────────╯    
	
	          ////
	
	     ╭────────────╮      
	     │ factory_mx │      
	     ╰────────────╯      
	            |            
	            v            
	   ╭────────────────╮    
	   │ !warehouse_la! │    
	   ╰────────────────╯    
	            |            
	            v            
	   ╭────────────────╮    
	   │ distributor_eu │    
	   ╰────────────────╯  
	`
}

pf()
# Executed in 0.04 second(s) in Ring 1.24

#-------------------------------------------#
#  2. compliance_rules.stzrulz              #
#     Rule properties (links to functions)  #
#===========================================#

# EXAMPLE OF .stzrulz file content
#---------------------------------
`
ruleset "Banking Compliance Rules"
    domain: banking
    version: 1.0

rules

    rule no_cycles
        type: constraint
        severity: error
        function: ConstraintFunc_NoCycles
        message
            "Workflows must be acyclic"

    rule separation_of_duties
        type: constraint
        severity: error
        function: ConstraintFunc_Separation
        params
            property: department
            values: ["finance", "audit"]
        message
            "Finance and Audit must be separated"

    rule max_span
        type: constraint
        severity: warning
        function: ConstraintFunc_MaxDegree
        params
            max: 7
        message
            "Maximum 7 direct reports per manager"

    rule all_connected
        type: validation
        severity: error
        function: ValidationFunc_IsConnected
        message
            "All positions must be connected"

    rule inherit_permissions
        type: derivation
        severity: info
        function: DerivationFunc_Transitivity
        message
            "Permissions inherited through hierarchy"
`

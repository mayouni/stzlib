# Narrative
# --------
# EXAMPLE 1: Query-Triggered Constraint Rules
#
# Extracted from stzgraphtest.ring, block #86.

load "../../../stzBase.ring"

# This example show how rules enforce business logic on specific graph subsets

pr()

# Step 1: Register the rule SEPARATION_FINANCE in a rules group called COMPLIANCE

	# Many rules can be registred to the same group using the same command:
	# RegisterRule(:COMPLIANCE, "AN_OTHER_RULE_NAME", [ ... ])
	
	RegisterRule(:COMPLIANCE, "SEPARATION_FINANCE", [
		:type = :Constraint,
		:function = ConstraintFunc_Separation(), # Built-in function in stzGraphRule.ring
		:params = [:property = "department", :values = ["finance", "finance"]],
		:message = "Separation of duties violation",
		:severity = :error
	])
	# The rule will be used inside the stzGraph object we will creat via UseRulesFrom()

# Step 2: Build the graph with domain data

StzGraphQ("compliance_system") {

	# Employees as nodes with properties
	AddNodeXTT("alice", "Alice Chen", [:department = "finance", :level = 5])
	AddNodeXTT("bob", "Bob Smith", [:department = "finance", :level = 3])
	AddNodeXTT("carol", "Carol Davis", [:department = "engineering", :level = 4])
	AddNodeXTT("dave", "Dave Wilson", [:department = "finance", :level = 2])
	
	# Approval relationships as edges
	Connect("alice", "bob")
	Connect("bob", "carol")
	
	# Step 3: Activate rules from COMPLIANCE group for this graph
	UseRulesFrom(:COMPLIANCE) # All the rules registred on this group will apply
	
	# Step 4: Make a query that triggers rule on matched subset only
	try
		QueryQ() { # A stzGraphQuery object is used internally
			Match([:nodes, :props = [:department = "finance"]])
			EnforceRule("SEPARATION_FINANCE")  # Applied only to finance nodes
			Select("*")
			Execute()
		}	
		? "✔ Finance connections validated"
		
	catch
		? "✗ Query-level validation failed: " + cCatchError
	done
	
	? NL + "Testing constraint at operation level..." + NL
	
	# Rules don't just work in queries - they guard ALL graph operations
	# Once loaded via UseRulesFrom(), every Connect(), AddNode(), etc. 
	# is automatically checked against constraint rules
	try
		Connect("alice", "dave")  # Both finance - should fail
		? "✔ Connection allowed"
	catch
		? "✗ Blocked: " + cCatchError
	done
}
#-->
` 
✔ Finance connections validated

Testing constraint at operation level...

✗ Blocked: Cannot add edge - constraint violation: Separation of duties violation
`

pf()
# Executed in 0.01 second(s) in Ring 1.25

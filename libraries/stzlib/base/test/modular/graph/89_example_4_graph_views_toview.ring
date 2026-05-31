# Narrative
# --------
# EXAMPLE 4: Graph Views (ToView)
#
# Extracted from stzgraphtest.ring, block #89.

load "../../../stzBase.ring"

# This example illustrates editable filtered view with commit/rollback
*/
pr()

StzGraphQ("organization") {

	AddNodeXTT("eng", "Engineering", [:budget = 500000])
	AddNodeXTT("sales", "Sales", [:budget = 300000])
	AddNodeXTT("hr", "HR", [:budget = 150000])

	? "Original budgets:"
	? "  Engineering: $" + NodeProperty("eng", "budget")
	? "  Sales: $" + NodeProperty("sales", "budget")

	# Create editable view of high-budget departments
	QueryQ() {
		Match([:nodes])
		Where(["budget", ">", 200000])
		oView = ToViewQ()  # Linked to parent, supports commit/rollback
	}

	? NL + "View has " + oView.NodesCount() + " departments"

	# Modify in view (parent unchanged)
	oView.SetNodeProperty("eng", "budget", 550000)
	oView.SetNodeProperty("sales", "budget", 330000)

	? "Modified nodes in view: " + len(oView.Changes()[:nodesModified])
	? "Original graph: Engineering still $" + NodeProperty("eng", "budget")

	# Commit changes to parent
	oView.Commit()

	? NL + "After commit:"
	? "  Engineering: $" + NodeProperty("eng", "budget")
	? "  Sales: $" + NodeProperty("sales", "budget")

	# Changes made by the commit
	? @@NL( oView.Changes() ) #ERR

	oView.Rollback()
	? NodesCount()
}
#-->
`
Original budgets:
  Engineering: $500000
  Sales: $300000

View has 2 departments
Modified nodes in view: 2
Original graph: Engineering still $500000

After commit:
  Engineering: $550000
  Sales: $330000
`

pf()
# Executed in 0.01 second(s) in Ring 1.25

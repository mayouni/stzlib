# Narrative
# --------
# Immediate Auto-Conclude (Default)
#
# Extracted from stzreactivestreamtest.ring, block #15.

load "../../stzBase.ring"

# Best for: Batch processing, complete datasets, sales reports

pr()

Rs = new stzReactiveSystem()
Rs {
    oSalesStream = CreateStream("batch-sales")
    oSalesStream {

        # Default: immediate auto-conclude after RecieveMany()
	# Those two setting can be removed
        SetAutoConclude(true)  # Default behavior
        SetAutoConcludeDelay(0)  # No delay - conclude immediately
        
        Accumulate(func(total, sale) {
            return total + sale["amount"]
        }, 0)
        
        OnPassed(func totalSales {
            ? "💰 Batch Total: $" + totalSales + " (concluded immediately)"
        })
        
        OnNoMore(func() {
            ? "✅ Batch processing completed instantly"
        })
        
        # Complete dataset arrives at once
        salesData = [
            [:amount = 150.00, :product = "Laptop"],
            [:amount = 89.99, :product = "Mouse"], 
            [:amount = 299.99, :product = "Monitor"]
        ]
        
        RecieveMany(salesData)  # Auto-concludes immediately after processing
        # No manual Conclude() needed!
    }
}
#-->
# 💰 Batch Total: $539.98 (concluded immediately)
# ✅ Batch processing completed instantly

pf()
# Executed in 0.01 second(s) in Ring 1.23

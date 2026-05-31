# Narrative
# --------
# Data Aggregation with Accumulate
#
# Extracted from stzreactivestreamtest.ring, block #4.

load "../../../stzBase.ring"


# Shows how streams manage accumulated data that must be explicitly concluded
# Essential for analytics, totals, and summary operations

pr()

Rs = new stzReactiveSystem()
Rs {

    # Sales data aggregation stream

    oSalesStream = CreateStream("sales-aggregation")
    oSalesStream {

        Accumulate( func(total, sale) {
            return total + sale["amount"]  # Running total kept internally
        }, 0)  # Starting value: $0.00


        OnRecieved( func totalSales {
            ? "💰 Total Sales: $" + totalSales
        })


        OnNoMore( func() {
            ? "✅ Sales calculation completed"
        })

        # Daily sales transactions
        salesData = [
            [ :amount = 150.00, :product = "Laptop" ],
            [ :amount = 89.99, :product = "Mouse" ], 
            [ :amount = 299.99, :product = "Monitor" ],
            [ :amount = 45.50, :product = "Keyboard" ]
        ]

        # Recieve all sales data into the accumulation pipeline
        # Each item gets added to the internal accumulator (150 + 89.99 + 299.99 + 45.50)
 
        RecieveMany(salesData)

    }

    RunLoop()
    #-->
    # 💰 Total Sales: $585.48
    # ✅ Sales calculation completed
}
# Executed in 0.95 second(s) in Ring 1.23


pf()
# Executed in 0.95 second(s) in Ring 1.23

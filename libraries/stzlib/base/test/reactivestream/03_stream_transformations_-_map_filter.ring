# Narrative
# --------
# Stream Transformations - Map, Filter
#
# Extracted from stzreactivestreamtest.ring, block #3.

load "../../stzBase.ring"


# Shows data transformation capabilities with chaining
# Key concepts: Map (transform), Filter (predicate)

pr()

Rs = new stzReactiveSystem()
Rs {
    
    # Create stream for data processing pipeline
    oTransformStream = CreateStream("transform-pipeline")
    oTransformStream {
        # Chain transformations
        Transform(func price { return price * 1.20 })	# Add 20% tax
        Filter(func price { return price >= 100 })	# Only expensive items

        OnPassed(func finalPrice {
            ? "💰 Final price after tax & filtering: $" + finalPrice
        })

        # Test data with duplicates and various price ranges
        testPrices = [ 80, 90, 100, 120, 150, 200 ]
        RecieveMany(testPrices)

    }

    RunLoop()
    #-->
    # 💰 Final price after tax & filtering: $108
    # 💰 Final price after tax & filtering: $120  
    # 💰 Final price after tax & filtering: $144
    # 💰 Final price after tax & filtering: $180
    # 💰 Final price after tax & filtering: $240
}

pf()
# Executed in 0.93 second(s) in Ring 1.23

#Note #SemanticPrecision
# OnPassed() and OnRecieve() are equivalent, but it's more expressive
# to use the first with Filter() and the second otherwise.

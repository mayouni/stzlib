# Narrative
# --------
# Processing multiple items efficiently with reactive functions
#
# Extracted from stzreactivefunctest.ring, block #5.

load "../../../stzBase.ring"


# When you have many items to process, reactive functions prevent blocking
# Each item processes independently, results arrive as ready

pr()

oRs = new stzReactiveSystem()
oRs {
    Init()

    # Function to process individual items
    processItem = func item {
        # Different processing times based on item value
        if item < 10
            sleep(0.05)  # Quick items
        else
            sleep(0.15)  # Slower items
        ok
        return "Processed: " + item + " -> " + (item * item)
    }

    RProcess = MakeReactive(processItem)
    
    # Batch of items to process
    items = [1, 15, 3, 22, 7, 18, 5]
    results = []
    processed = 0
    total = len(items)

    ? "Processing " + total + " items in parallel..."
    
    # Launch all items for processing simultaneously
    for item in items
        RProcess.CallAsync(
            [item],
            func result {
                processed++
                results + result
                ? result + " (" + processed + "/" + total + ")"
                
                # Check if all items are done
                if processed = total
                    ? "All items processed!"
                    ? "Results summary: " + len(results) + " items completed"
                ok
            },
            func error {
                ? "Item processing error: " + error
            }
        )
    next

    Start()
    #-->
    # Processing 7 items in parallel...
    # Processed: 1 -> 1 (1/7)
    # Processed: 3 -> 9 (2/7)
    # Processed: 7 -> 49 (3/7)
    # Processed: 5 -> 25 (4/7)
    # Processed: 15 -> 225 (5/7)
    # Processed: 22 -> 484 (6/7)
    # Processed: 18 -> 324 (7/7)
    # All items processed!
    # Results summary: 7 items completed
}

pf()
# Executed in 1.72 second(s) in Ring 1.23

#-----------------------------------#
#  EXAMPLE 6: ADVANCED PATTERNS     #
#-----------------------------------#

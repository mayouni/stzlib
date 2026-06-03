# Narrative
# --------
# Data Structure Transformation: Tree Processing
#
# Extracted from stzlistexutertest.ring, block #7.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

pr()

lxu() {
    # Define patterns for tree node types
    AddTrigger(:LeafNode = "[@S, @N]")         # Name, value
    AddTrigger(:InnerNode = "[@S, [@L+]]")     # Name, children
    AddTrigger(:RootNode = "[@S, [@L+], @N?]") # Name, children, optional total
    
    # Processing for different node types
    AddCode(:LeafNode, '{
        # Format leaf nodes consistently
        @list = {
            "type": "leaf",
            "name": @list[1],
            "value": @list[2]
        }
    }')
    
    AddCode(:InnerNode, '{
        # Calculate sum of child values
        nSum = 0
        
        for child in @list[2]
            if type(child) = "HASH" and child["type"] = "leaf"
                nSum += child["value"]
            ok
        next
        
        # Format inner node with calculated value
        @list = {
            "type": "inner",
            "name": @list[1],
            "children": @list[2],
            "childCount": len(@list[2]),
            "value": nSum
        }
    }')
    
    AddCode(:RootNode, '{
        # Calculate total value from children
        nSum = 0
        
        for child in @list[2]
            if type(child) = "HASH" and child["type"] = "inner"
                nSum += child["value"]
            ok
        next
        
        # Add provided total or calculated one
        nTotal = 0
        if len(@list) > 2
            nTotal = @list[3]
        else
            nTotal = nSum
        ok
        
        # Format root node
        @list = {
            "type": "root",
            "name": @list[1],
            "children": @list[2],
            "calculated": nSum,
            "total": nTotal,
            "accurate": (nSum = nTotal)
        }
    }')
    
    # Sample tree structure
    treeData = [
        "Expenses",
        [
            ["Food", [
                ["Groceries", 150],
                ["Dining", 120]
            ]],
            ["Housing", [
                ["Rent", 800],
                ["Utilities", 200]
            ]],
            ["Transportation", 300]
        ],
        1600  # Total (should equal calculated sum of 1570)
    ]
    
    # Process tree depth-first from bottom to top
    Process(treeData)
    
    # Display processed tree with calculated values
    ? "=== Processed Tree Structure ==="
    ? @@NL(Results()[1])
    
    # Verify tree transformation results
    ? NL + "=== Verification ==="
    isAccurate = Results()[1]["accurate"]
    
    if isAccurate
        ? "Tree totals match: " + Results()[1]["total"]
    else
        ? "Tree totals mismatch!"
        ? "Provided: " + Results()[1]["total"]
        ? "Calculated: " + Results()[1]["calculated"]
        ? "Difference: " + (Results()[1]["total"] - Results()[1]["calculated"])
    ok
}

proff()

pf()
# Executed in 0.05 second(s) in Ring 1.22

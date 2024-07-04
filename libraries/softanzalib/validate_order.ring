
	    ? "Validating order: " + order["id"]
	    if len(order["items"]) = 0
	        ? "Error: Order has no items"
	        continue_workflow = false
	    else
	        ? "Order validated successfully"
	        continue_workflow = true
	    ok
	
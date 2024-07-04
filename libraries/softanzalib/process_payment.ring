
	    ? "Processing payment for order: " + order["id"]
	    ? "Payment of $" + order["total"] + " processed"
	    order["payment_status"] = "Paid"
	    continue_workflow = true
	
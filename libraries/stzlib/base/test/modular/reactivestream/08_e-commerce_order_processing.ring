# Narrative
# --------
# E-commerce Order Processing
#
# Extracted from stzreactivestreamtest.ring, block #8.

load "../../../stzBase.ring"


# Complex business logic example with multiple transformations
# Shows stream composition for real business scenarios

pr()

Rs = new stzReactiveSystem()
Rs {
    
    # Order processing stream

    oOrderStream = CreateStream("order-processing")
    oOrderStream {

        # Validate orders

        Filter(func order {
            # Basic validation
            return order["amount"] > 0 and len(order["customer"]) > 0
        })
        
        # Calculate totals with tax and shipping

        Transform(func order {
            subtotal = order["amount"]
            tax = subtotal * 0.08  # 8% tax
            shipping = 15.00  # Flat rate shipping
            
            order["tax"] = tax
            order["shipping"] = shipping  
            order["total"] = subtotal + tax + shipping
            
            return order
        })
        
        # Filter high-value orders for special handling

        Filter(func order {
            return order["total"] >= 100  # VIP orders only
        })

	# Here we can also use OnRecieve() but OnPassed() is
	# more expressive when Filter() is used

        OnPassed(func processedOrder {
            ? "🛒 VIP Order processed:"
            ? "   Customer: " + processedOrder["customer"]
            ? "   Subtotal: $" + processedOrder["amount"]
            ? "   Tax: $" + processedOrder["tax"]  
            ? "   Shipping: $" + processedOrder["shipping"]
            ? "   Total: $" + processedOrder["total"]
            ? "   Status: Ready for priority shipping"
            ? ""
        })
        
        # Simulate incoming orders

        orders = [
            [ :customer = "John Doe", :amount = 89.99 ],      # Below threshold
            [ :customer = "Jane Smith", :amount = 150.00 ],   # VIP order
            [ :customer = "", :amount = 200.00 ],             # Invalid customer
            [ :customer = "Bob Wilson", :amount = 299.99 ],   # VIP order
            [ :customer = "Alice Brown", :amount = 0 ]        # Invalid amount
        ]
        
        RecieveMany(orders)

    }
    
    RunLoop()
    #-->
    '
	🛒 VIP Order processed:
	   Customer: John Doe
	   Subtotal: $89.99
	   Tax: $7.20
	   Shipping: $15
	   Total: $112.19
	   Status: Ready for priority shipping
	
	🛒 VIP Order processed:
	   Customer: Jane Smith
	   Subtotal: $150
	   Tax: $12
	   Shipping: $15
	   Total: $177
	   Status: Ready for priority shipping
	
	🛒 VIP Order processed:
	   Customer: Bob Wilson
	   Subtotal: $299.99
	   Tax: $24.00
	   Shipping: $15
	   Total: $338.99
	   Status: Ready for priority shipping
    '
}

pf()
# Executed in 0.93 second(s) in Ring 1.23

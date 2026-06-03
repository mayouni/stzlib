# Narrative
# --------
# Reactive Bank Account Class
#
# Extracted from stzreactiveobjecttest.ring, block #9.

load "../../stzBase.ring"


pr()

	# Create reactive system
	Rs = new stzReactiveSystem()

	# Make bank account reactive

	oXAccount = Rs.Reactivate(new BankAccount("ACC-001", 1000))

	# Watch balance changes with business logic
	oXAccount.Watch(:balance, func(oSelf, attr, oldval, newval) {
		? "💰 Balance: $" + oldval + " → $" + newval
		
		if newval < 100
			? "(!)  Low balance warning!"
		ok
		
		if newval > oldval
			? "✔ Deposit detected: +" + (newval - oldval)
		else
			? "📉 Withdrawal: -" + (oldval - newval)
		ok
	})

	# Watch status changes
	oXAccount.Watch(:status, func(oSelf, attr, oldval, newval) {
		? "🔄 Account status: " + oldval + " → " + newval
	})

	# 
	Rs.RunAfter(100, func {
		? "Processing deposit..."
		oXAccount.SetAttribute("balance", 1500)

		Rs.RunAfter(500, func {
			? ""
			? "Processing withdrawal..."
			oXAccount.SetAttribute("balance", 50)

			Rs.RunAfter(500, func {
				? ""
				? "Freezing account..."
				oXAccount.SetAttribute("status", "frozen")
			})
		})
	})

	Rs.Start()
	? NL + "✔ Sample completed."

pf()

class BankAccount
	balance = 0
	accountNumber = ""
	status = "active"
	
	def init(cNumber, nBalance)
		accountNumber = cNumber
		balance = nBalance

#-->
# Processing deposit...
# 💰 Balance: $1000 → $1500
# ✔ Deposit detected: +500
#
# Processing withdrawal...
# 💰 Balance: $1500 → $50
# (!)  Low balance warning!
# 📉 Withdrawal: -1450
#
# Freezing account...
# 🔄 Account status: active → frozen

# ✔ Sample completed.

# Executed in 1.99 second(s) in Ring 1.23

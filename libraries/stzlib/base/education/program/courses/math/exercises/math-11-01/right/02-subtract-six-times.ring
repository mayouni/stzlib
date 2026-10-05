# The same, subtracting the share six times from the whole.
oShare = StzMoneyQ("250.00")
oShare.Divide("7")
? oShare.Content()
oLast = StzMoneyQ("250.00")
for i = 1 to 6
	oLast.Subtract(oShare.Content())
next
? oLast.Content()

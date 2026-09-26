# The rounded share six times, and the seventh takes the remainder.
oShare = StzMoneyQ("250.00")
oShare.Divide("7")
? oShare.Content()
oSix = StzMoneyQ(oShare.Content())
oSix.MultiplyBy("6")
oLast = StzMoneyQ("250.00")
oLast.Subtract(oSix.Content())
? oLast.Content()

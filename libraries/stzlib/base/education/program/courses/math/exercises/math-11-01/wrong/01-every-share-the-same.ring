# Gives everyone the rounded share: seven of them make 249.97, and three centimes are lost.
oShare = StzMoneyQ("250.00")
oShare.Divide("7")
? oShare.Content()
? oShare.Content()

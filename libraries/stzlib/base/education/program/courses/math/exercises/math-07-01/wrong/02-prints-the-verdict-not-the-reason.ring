# Prints whether it is exact instead of why it is not.
oN = StzNumberQ("100.10")
oN.Divide("3")
? oN.Content()
? oN.IsExact()

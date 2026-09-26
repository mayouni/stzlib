# Seed, throw, count, and check the count against a half.
SeedRandom(11)
nCount = 0
for i = 1 to 500
	if StzRandom01() < 0.5  nCount++  ok
next
? nCount
? fabs(nCount - 250) <= 50

# The same, through a list of throws counted afterwards.
SeedRandom(11)
aThrows = []
for i = 1 to 500
	aThrows + StzRandom01()
next
nCount = 0
for i = 1 to len(aThrows)
	if aThrows[i] < 0.5  nCount++  ok
next
? nCount
? nCount >= 200 and nCount <= 300

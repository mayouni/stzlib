cRule = read($cProjectFolder + "/rule.txt")
acLines = StzSplit(read($cProjectFolder + "/data.txt"), char(10))
aNums = []
for i = 1 to len(acLines)
	if trim(acLines[i]) != ""
		aNums + (0 + trim(acLines[i]))
	ok
next
? "rule: " + cRule
? "count: " + StzListQ(aNums).CountW(cRule)

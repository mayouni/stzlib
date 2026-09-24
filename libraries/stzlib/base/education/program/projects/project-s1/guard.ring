# The court of this project. %PROJECT% is the learner's folder; it prints what it found.
cP = "%PROJECT%"
if fexists(cP + "/rule.txt") and fexists(cP + "/data.txt") and fexists(cP + "/tool.ring")
	cRule = read(cP + "/rule.txt")
	acLines = StzSplit(read(cP + "/data.txt"), char(10))
	aNums = []
	for i = 1 to len(acLines)
		if trim(acLines[i]) != ""
			aNums + (0 + trim(acLines[i]))
		ok
	next
	nExpected = StzListQ(aNums).CountW(cRule)
	aRun = StzEduRunSoftanza('$cProjectFolder = "' + cP + '"' + char(10) + read(cP + "/tool.ring"))
	? "rule read as data: " + yn(StzFindFirst("rule: " + cRule, aRun[1]) > 0)
	? "count correct: " + yn(StzFindFirst("count: " + nExpected, aRun[1]) > 0)
else
	? "files: missing"
ok
func yn(b)
	if b
		return "yes"
	ok
	return "no"


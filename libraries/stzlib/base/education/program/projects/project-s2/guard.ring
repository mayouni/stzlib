# The court of this project. %PROJECT% is the learner's folder; it prints what it found.
cP = "%PROJECT%"
if fexists(cP + "/data.csv") and fexists(cP + "/report.ring")
	aRun = StzEduRunSoftanza('$cProjectFolder = "' + cP + '"' + char(10) + read(cP + "/report.ring"))
	cOut = aRun[1]
	? "table drawn: " + yn(len(StzFind("│", cOut)) >= 6)
	? "bars drawn: " + yn(StzFindFirst("▇", cOut) > 0 or StzFindFirst("██", cOut) > 0)
	? "pattern reported: " + yn(StzFindFirst("pattern: ", cOut) > 0)
else
	? "files: missing"
ok
func yn(b)
	if b
		return "yes"
	ok
	return "no"


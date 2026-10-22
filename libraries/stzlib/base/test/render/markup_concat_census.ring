load "../../stzBase.ring"

# RX gate -- the census of the markup-concatenation rule over the library.
#
#   ring markup_concat_census.ring FILELIST
#
# FILELIST is a text file of paths, one per line, relative to base/ (the caller
# makes it with git ls-files, so the tool reads exactly the tracked tree). For
# every file the rule finds a line in, it prints the file, the line number and
# the line; then a total. It is a HEAVY JOB over the whole library: run it once,
# alone, never beside a build.
#
# WHAT THE COUNT IS. The rule is a text heuristic over one line: a tag literal
# joined to a dynamic operand with no escaping face on the line. A finding is a
# writer for a person to read, not a defect. The count says how many such lines
# there are today, so a new one can be seen.

cList = ""
if len(sysargv) > 0
	cList = sysargv[len(sysargv)]
ok
if cList = "" or NOT fexists(cList)
	? "ERR give the path of a file list"
	shutdown(2)
ok
CensusMain(cList)

func CensusMain(cList)
	acFiles = StzSplit(StzReplace(read(cList), char(13), ""), char(10))
	nFiles = len(acFiles)
	nTotal = 0
	nWith = 0
	nRead = 0
	for i = 1 to nFiles
		cF = ring_trim(acFiles[i])
		if cF = "" or NOT fexists("../../" + cF)
			loop
		ok
		nRead++
		cSrc = read("../../" + cF)
		aF = _StzCheckMarkupConcat(cSrc)
		nN = len(aF)
		if nN = 0
			loop
		ok
		nWith++
		nTotal += nN
		? "FILE " + cF + " " + nN
		acLines = StzSplit(StzReplace(cSrc, char(13), ""), char(10))
		for j = 1 to nN
			nL = aF[j][:line]
			cShow = ring_trim(acLines[nL])
			if len(cShow) > 110
				cShow = StzLeft(cShow, 110)
			ok
			? "  " + nL + ": " + cShow
		next
	next
	? "TOTAL " + nTotal + " lines in " + nWith + " files of " + nRead + " read"

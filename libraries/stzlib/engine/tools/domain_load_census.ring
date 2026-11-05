# W7 of SOFTANZA_ONE_HOUR.md, part 1 -- what each engine domain costs to load, and what it adds.
#
# Loads every stz_*/stk_* library of an engine folder ALONE, in a process that
# loads nothing else (no stzBase), and records for each: the milliseconds
# LoadLib took and the C functions it registered (the difference of
# cfunctions() before and after). Writes the function -> domain map that part 2
# (domain_reach.ring) reads.
#
#   run:     rnxc domain_load_census.ring <engineDir> <outMap>
#            engineDir holds zig-out/bin (Windows) or zig-out/lib
#   prints:  one line per domain -- name|ms|functions -- then the totals
#   note:    the first library loaded pays for what all of them share (the C
#            runtime); its number is printed, not hidden. A library whose load
#            fails is printed with ms -1 and adds nothing to the map.

aArgs = sysargv
nArgs = len(aArgs)
if nArgs < 4
	? "usage: rnxc domain_load_census.ring <engineDir> <outMap>"
	shutdown(2)
ok
cDir = aArgs[nArgs - 1]
cOut = aArgs[nArgs]

if isWindows()
	cBin = cDir + "/zig-out/bin"
	cExt = ".dll"
else
	cBin = cDir + "/zig-out/lib"
	cExt = ".so"
ok

aFiles = dir(cBin)
aLibs = []
for i = 1 to len(aFiles)
	cF = aFiles[i][1]
	if aFiles[i][2] = 0 and right(cF, len(cExt)) = cExt
		cL = lower(cF)
		if left(cL, 4) = "stz_" or left(cL, 4) = "stk_" or left(cL, 7) = "libstz_" or left(cL, 7) = "libstk_"
			aLibs + cF
		ok
	ok
next
aLibs = sort(aLibs)

# cfunctions() lists registrations in order, so what a library added is the
# tail past the previous count. The check that makes the tail an honest
# reading: the entry that was last before a load is still at its place after
aPrev = cfunctions()
nPrev = len(aPrev)
cLastPrev = lower(aPrev[nPrev])
nOrderBreaks = 0

cMap = "# function|domain -- written by domain_load_census.ring from " + cBin + char(10)
nTotalMs = 0
nTotalFn = 0
nLoaded = 0
for i = 1 to len(aLibs)
	cName = aLibs[i]
	cDom = left(cName, len(cName) - len(cExt))
	if left(cDom, 3) = "lib"  cDom = substr(cDom, 4)  ok
	nT0 = clock()
	bOk = 1
	try
		pH = LoadLib(cBin + "/" + cName)
	catch
		bOk = 0
	done
	nMs = clock() - nT0
	if bOk = 0
		? cDom + "|-1|0"
		loop
	ok
	aNow = cfunctions()
	nNow = len(aNow)
	nNew = nNow - nPrev
	for j = nPrev + 1 to nNow
		cMap += lower(aNow[j]) + "|" + cDom + char(10)
	next
	if nNew < 0 or lower(aNow[nPrev]) != cLastPrev  nOrderBreaks++  ok
	nPrev = nNow
	cLastPrev = lower(aNow[nNow])
	? cDom + "|" + nMs + "|" + nNew
	nTotalMs += nMs
	nTotalFn += nNew
	nLoaded++
next

write(cOut, cMap)
? "TOTAL|" + nTotalMs + "|" + nTotalFn + "|" + nLoaded + " of " + len(aLibs) + " libraries loaded|order breaks " + nOrderBreaks

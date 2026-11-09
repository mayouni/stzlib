/*
	stkRingStdFuncs -- the nineteen functions Softanza took from Ring's
	standard library, defined here so the library loads no part of Ring's
	distribution.

	Haro ships none of Ring's distribution (haro CHARTER D50, ruled by the
	author 2026-11-05: "no Ring has to be carried with us in Haro at all
	other than the surface we already have in Ring++ VM"). Until this file,
	core/common/stkRingLibs.ring loaded "stdlibcore.ring" and
	base/file/stzFile.ring loaded "ziplib.ring", and haro.exe stopped at
	both (the C27 that kept it from loading stzlib).

	Each function keeps the NAME and the BEHAVIOUR its callers relied on,
	read from Ring++'s copy of stdlibcore.ring and ziplib.ring -- so the
	252 library call sites (and the tests' calls to Split, MakeDir,
	SystemCmd and List2Code, the last four below) are unchanged. A program that loads Ring's stdlib beside
	stzlib still works: Ring++ lets the later definition stand, and the two
	agree. Where Ring's version raised an index error on an edge case the
	callers never reach (TrimRight of an all-blank text), this one answers
	instead; that is the only difference, and it is named at the function.

	Natives are spelled in lowercase (haro ruling of 2026-11-07).
*/

# 1 when cStr, trimmed, begins with cSub (Ring's Startswith trims first).
func StartsWith cStr, cSub
	cStr = trim(cStr)
	if left(cStr, len(cSub)) = cSub
		return 1
	ok
	return 0

# 1 when cStr, trimmed, ends with cSub.
func EndsWith cStr, cSub
	cStr = trim(cStr)
	if right(cStr, len(cSub)) = cSub
		return 1
	ok
	return 0

# 1 for an odd number, 2 for an even one.
func EvenOrOdd n
	if n % 2 = 1
		return 1
	ok
	return 2

# The divisors of n, from 1 to n.
func Factors n
	aDivisors = []
	for i = 1 to n
		if n % i = 0
			aDivisors + i
		ok
	next
	return aDivisors

# The items of aList for which the function fTest answers true.
func Filter aList, fTest
	aKept = []
	nCount = len(aList)
	for i = 1 to nCount
		if call fTest(aList[i])
			aKept + aList[i]
		ok
	next
	return aKept

# The size in bytes of an open file; the position is left at the start.
func FSize fHandle
	fseek(fHandle, 0, 2)
	nSize = ftell(fHandle)
	fseek(fHandle, 0, 0)
	return nSize

# The greatest common divisor (Euclid).
func GCD nA, nB
	while nB
		nC = nA
		nA = nB
		nB = nC % nB
	end
	return nA

# 1 when nNum is prime.
func IsPrime nNum
	if nNum <= 1
		return 0
	ok
	if nNum % 2 = 0 and nNum != 2
		return 0
	ok
	for i = 2 to sqrt(nNum)
		if nNum % i = 0
			return 0
		ok
	next
	return 1

# 1 when cLetter is one of A E I O U, in either case.
func IsVowel cLetter
	cUp = upper(cLetter)
	cVowels = "AEIOU"
	for i = 1 to 5
		if cUp = cVowels[i]
			return 1
		ok
	next
	return 0

# The least common multiple.
func LCM nM, nN
	return nM * nN / GCD(nM, nN)

# A copy of aList with fMap applied to every item.
func Map aList, fMap
	aMapped = aList
	nCount = len(aMapped)
	for i = 1 to nCount
		aMapped[i] = call fMap(aMapped[i])
	next
	return aMapped

# aList folded by fStep(accumulated, item) from pInitial; with pInitial
# empty (""), from the first item. Every item must have the type of the
# start value, as in Ring's Reduce.
func Reduce aList, fStep, pInitial
	if NOT islist(aList)
		raise("aList should be a list.  Instead, it's a " + type(aList))
	ok
	nLength = len(aList)
	if NOT isfunction(fStep)
		raise(fStep + " is not a function.")
	ok
	nStart = 1
	if isstring(pInitial) and pInitial = ""
		if nLength > 0
			pInitial = aList[1]
			nStart = 2
		else
			raise("if xInitial is NULL, then Reduce() requires a non-empty list aList")
		ok
	else
		if nLength < 1
			return pInitial
		ok
	ok
	cType = type(pInitial)
	pResult = pInitial
	for i = nStart to nLength
		if NOT type(aList[i]) = cType
			raise("At least one of the elements in aList is " + type(aList[i]) + ".  It should be " + cType)
		ok
		pResult = call fStep(pResult, aList[i])
	next
	return pResult

# -1, 0 or 1.
func Sign n
	if n < 0
		return -1
	ok
	if n = 0
		return 0
	ok
	return 1

# Waits nSeconds seconds (a number, or a text holding one).
#
# Ring's Sleep called SysSleep and then, unless it answered true, waited AGAIN
# in a clock loop. On rnxc and haro.exe syssleep answers nothing, so that form
# slept twice: Sleep(0.5) took 1.00 s on both (measured 2026-11-09). syssleep
# is native on both runtimes, so it is the whole wait here.
func Sleep nSeconds
	if isstring(nSeconds)
		nSeconds = number(nSeconds)
	ok
	if NOT isnumber(nSeconds)
		raise("Bad parameter type!")
	ok
	syssleep(nSeconds * 1000)

# cStr without its trailing spaces and tabs. An all-blank or empty text
# gives "" (Ring's version raised an index error there).
func TrimRight cStr
	nIndex = len(cStr)
	while nIndex > 0
		cLast = cStr[nIndex]
		if NOT (cLast = " " or cLast = char(9))
			exit
		ok
		nIndex--
	end
	if nIndex = 0
		return ""
	ok
	return left(cStr, nIndex)


# --- Four more, which the library itself never calls but its tests did,
# reaching Ring's stdlib through the library's load (found 2026-11-08 by the
# haroport gate: stzGraphQuery_defects and 54_fswatch_engine went red).

# Ring's Split(): a space or tab delimiter collapses runs of blanks, the text
# is trimmed, a line break always splits too. The library calls ring_split.
func Split cString, cDelimiter
	return ring_split(cString, cDelimiter)

# Creates the folder cFolder (and its parents off Windows), silently.
func MakeDir cFolder
	if iswindows()
		system("mkdir " + cFolder + " >nul 2>nul")
	else
		system("mkdir -p " + cFolder + " >/dev/null 2>&1")
	ok

# The output of the shell command cCmd, without its last line break.
func SystemCmd cCmd
	cTmpPath = tempname()
	system(cCmd + "> " + cTmpPath)
	cOut = read(cTmpPath)
	remove(cTmpPath)
	if right(cOut, 1) = char(10)
		cOut = left(cOut, len(cOut) - 1)
	ok
	return cOut

# Ring's List2Code(): the list as Ring source, one item per line, tab-indented.
func List2Code aList
	return List2CodeAt(aList, 0)

	func List2CodeAt aList, nDepth
		if NOT islist(aList)
			raise("Error (List2Code) : Expect a list")
		ok
		cCode = copy(char(9), nDepth) + "[" + windowsnl()
		cTabs = copy(char(9), nDepth + 1)
		nCount = len(aList)
		for i = 1 to nCount
			if i > 1
				cCode += "," + windowsnl()
			ok
			if isstring(aList[i])
				cCode += cTabs + '"' + substr(aList[i], '"', '"+char(34)+"') + '"'
			but isnumber(aList[i])
				cCode += cTabs + "" + aList[i]
			but islist(aList[i])
				cCode += List2CodeAt(aList[i], nDepth + 1)
			ok
		next
		cCode += windowsnl() + copy(char(9), nDepth) + "]"
		return cCode

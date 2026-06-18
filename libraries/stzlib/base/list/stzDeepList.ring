# stzDeepList -- deep (nested) list navigation and search.
#
# A dedicated subclass of stzList that adds the PATH-based deep-list API
# documented in stz-managing-deep-lists-narration.md, keeping stzList itself
# lean (modular design). A "path" is a list of 1-based indices locating an
# item; e.g. [2,3,2] is the 2nd item of the 3rd item of the 2nd item.
#
#   o = new stzDeepList([ "A", [ "x","B",[ "C","x" ],"x" ], "E" ])
#   ? @@( o.DeepFind("x") )      #--> [ [2,1], [2,3,2], [2,4] ]
#   ? o.ItemAtPath([2,3,1])      #--> "C"
#
# The path-relationship UTILITIES (IsSubPathOf, CommonPath, SortPaths, ...)
# live as globals in stzListPaths.ring; this class provides the LIST-BOUND
# operations (Paths, DeepFind, ItemAtPath, ...) that produce/consume them.
#
# IMPLEMENTATION NOTE: all list-building is done in GLOBAL helpers below, not
# in the class methods. Two Ring traps make this necessary inside a class:
#   - bare add(list,x) resolves to the inherited Add() method (1 param -> R20)
#   - bare len(x) resolves to a method (-> R20)
# Build a path with a copy + add: aP = aPrefix (copies), add(aP, i). Append a
# path as ONE element with add(aRes, aP). The `+` operator wraps unpredictably.

#-- Recursion + building helpers (global scope: add()/len() are the builtins)

func _DplPathsRec(aList, aPrefix)
	aResult = []
	nLen = len(aList)
	for i = 1 to nLen
		aPath = aPrefix
		add(aPath, i)
		add(aResult, aPath)
		if isList(aList[i])
			aSub = _DplPathsRec(aList[i], aPath)
			nS = len(aSub)
			for j = 1 to nS add(aResult, aSub[j]) next
		ok
	next
	return aResult

func _DplFindRec(aList, pItem, aPrefix)
	aResult = []
	nLen = len(aList)
	for i = 1 to nLen
		aPath = aPrefix
		add(aPath, i)
		if _DplItemsEqual(aList[i], pItem)
			add(aResult, aPath)
		but isList(aList[i])
			aSub = _DplFindRec(aList[i], pItem, aPath)
			nS = len(aSub)
			for j = 1 to nS add(aResult, aSub[j]) next
		ok
	next
	return aResult

func _DplItemAt(aContent, aPath)
	aCur = aContent
	nLen = len(aPath)
	for i = 1 to nLen
		if NOT isList(aCur)
			StzRaise("Invalid path! it goes deeper than the structure.")
		ok
		aCur = aCur[ aPath[i] ]
	next
	return aCur

func _DplItemsAt(aContent, aPaths)
	aResult = []
	nLen = len(aPaths)
	for i = 1 to nLen
		add(aResult, _DplItemAt(aContent, aPaths[i]))
	next
	return aResult

func _DplMaxPathLen(aPaths)
	nMax = 0
	nLen = len(aPaths)
	for i = 1 to nLen
		if len(aPaths[i]) > nMax nMax = len(aPaths[i]) ok
	next
	return nMax

func _DplPathsByLen(aPaths, nWanted)
	aResult = []
	nLen = len(aPaths)
	for i = 1 to nLen
		if len(aPaths[i]) = nWanted add(aResult, aPaths[i]) ok
	next
	return aResult

func _DplExpandPath(aContent, aPath)
	aResult = []
	add(aResult, aPath)
	item = _DplItemAt(aContent, aPath)
	if isList(item)
		aSub = _DplPathsRec(item, aPath)
		nS = len(aSub)
		for j = 1 to nS add(aResult, aSub[j]) next
	ok
	return aResult

func _DplListEq(aA, aB)
	if len(aA) != len(aB) return FALSE ok
	nLen = len(aA)
	for i = 1 to nLen
		if isList(aA[i]) and isList(aB[i])
			if NOT _DplListEq(aA[i], aB[i]) return FALSE ok
		but isList(aA[i]) or isList(aB[i])
			return FALSE
		else
			if aA[i] != aB[i] return FALSE ok
		ok
	next
	return TRUE

func _DplItemsEqual(pA, pB)
	if isList(pA) and isList(pB) return _DplListEq(pA, pB) ok
	if isList(pA) or isList(pB) return FALSE ok
	return pA = pB

#-- Factory

func DeepListQ(paList)
	return new stzDeepList(paList)

#=============#
#  THE CLASS  #
#=============#

class stzDeepList from stzList

	def Paths()
		return _DplPathsRec(This.Content(), [])

		def AllPaths()
			return This.Paths()

	def DeepFind(pItem)
		return _DplFindRec(This.Content(), pItem, [])

		def DeepFindAll(pItem)
			return This.DeepFind(pItem)

		def PathsContaining(pItem)
			return This.DeepFind(pItem)

	def DeepContains(pItem)
		return ring_len(This.DeepFind(pItem)) > 0

	def DeepFindAt(pItem, paPath)
		if _DplItemsEqual(This.ItemAtPath(paPath), pItem)
			return paPath
		ok
		return []

	def ItemAtPath(paPath)
		if NOT isList(paPath)
			StzRaise("Incorrect param! paPath must be a list of indices.")
		ok
		return _DplItemAt(This.Content(), paPath)

	def ItemsAtPaths(paPaths)
		return _DplItemsAt(This.Content(), paPaths)

	def LongestPaths()
		aPaths = This.Paths()
		return _DplPathsByLen(aPaths, _DplMaxPathLen(aPaths))

	def PathsAtDepth(nDepth)
		return _DplPathsByLen(This.Paths(), nDepth)

	def ExpandPath(paPath)
		return _DplExpandPath(This.Content(), paPath)

	def CollapsePath(paPath)
		if ring_len(paPath) = 0 return [] ok
		return [ paPath[1] ]

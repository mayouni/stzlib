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
# ENGINE-FIRST: the heavy work -- recursive path enumeration, deep search, and
# path navigation -- runs in the Zig engine (stz_list_deep_* in list.zig), NOT
# in Ring loops. Each method marshals its content/path/needle to engine list
# handles, calls the engine, and unmarshals the result. The path-relationship
# UTILITIES (IsSubPathOf, CommonPath, SortPaths, ...) live as globals in
# stzListPaths.ring; this class provides the LIST-BOUND operations.
#
# The only Ring-side logic kept here is trivial, non-looping glue (a single
# value comparison for DeepFindAt, head-of-path for CollapsePath).

#-- Value-equality helper (global scope; used only for the single comparison
#-- in DeepFindAt -- not a loop over the structure).

func _DplListEq(aA, aB)
	if len(aA) != len(aB) return FALSE ok
	_nLen_ = len(aA)
	for i = 1 to _nLen_
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
		pList = This._EngineListFromContent()
		pRes  = StzEngineListDeepPaths(pList)
		_aResult_ = StzEngineListContentToRingList(pRes)
		StzEngineListFree(pList)
		StzEngineListFree(pRes)
		return _aResult_

		def AllPaths()
			return This.Paths()

	def DeepFind(pItem)
		pList   = This._EngineListFromContent()
		pNeedle = StzEngineMarshalList([ pItem ])
		pRes    = StzEngineListDeepFind(pList, pNeedle, 1)
		_aResult_ = StzEngineListContentToRingList(pRes)
		StzEngineListFree(pList)
		StzEngineListFree(pNeedle)
		StzEngineListFree(pRes)
		return _aResult_

		def DeepFindAll(pItem)
			return This.DeepFind(pItem)

		def PathsContaining(pItem)
			return This.DeepFind(pItem)

	def DeepContains(pItem)
		return ring_len(This.DeepFind(pItem)) > 0

	def DeepFindAt(pItem, paPath)
		_aWrap_ = This._ItemWrapAtPath(paPath)
		if ring_len(_aWrap_) > 0 and _DplItemsEqual(_aWrap_[1], pItem)
			return paPath
		ok
		return []

	def ItemAtPath(paPath)
		if NOT isList(paPath)
			StzRaise("Incorrect param! paPath must be a list of indices.")
		ok
		_aWrap_ = This._ItemWrapAtPath(paPath)
		if ring_len(_aWrap_) = 0
			StzRaise("Invalid path! it goes deeper than the structure.")
		ok
		return _aWrap_[1]

		#-- Returns a 0- or 1-element list wrapping the item at paPath (empty if
		#-- the path is invalid). The engine wraps it so a nested-list item also
		#-- round-trips cleanly through StzEngineContentFromList.
		def _ItemWrapAtPath(paPath)
			pList = This._EngineListFromContent()
			pPath = StzEngineMarshalList(paPath)
			pRes  = StzEngineListItemAtPath(pList, pPath)
			_aWrap_ = StzEngineListContentToRingList(pRes)
			StzEngineListFree(pList)
			StzEngineListFree(pPath)
			StzEngineListFree(pRes)
			return _aWrap_

	def ItemsAtPaths(paPaths)
		pList  = This._EngineListFromContent()
		pPaths = StzEngineMarshalList(paPaths)
		pRes   = StzEngineListItemsAtPaths(pList, pPaths)
		_aResult_ = StzEngineListContentToRingList(pRes)
		StzEngineListFree(pList)
		StzEngineListFree(pPaths)
		StzEngineListFree(pRes)
		return _aResult_

	def LongestPaths()
		pList = This._EngineListFromContent()
		pRes  = StzEngineListLongestPaths(pList)
		_aResult_ = StzEngineListContentToRingList(pRes)
		StzEngineListFree(pList)
		StzEngineListFree(pRes)
		return _aResult_

	def PathsAtDepth(nDepth)
		pList = This._EngineListFromContent()
		pRes  = StzEngineListPathsAtDepth(pList, nDepth)
		_aResult_ = StzEngineListContentToRingList(pRes)
		StzEngineListFree(pList)
		StzEngineListFree(pRes)
		return _aResult_

	def ExpandPath(paPath)
		pList = This._EngineListFromContent()
		pPath = StzEngineMarshalList(paPath)
		pRes  = StzEngineListExpandPath(pList, pPath)
		_aResult_ = StzEngineListContentToRingList(pRes)
		StzEngineListFree(pList)
		StzEngineListFree(pPath)
		StzEngineListFree(pRes)
		return _aResult_

	def CollapsePath(paPath)
		if ring_len(paPath) = 0 return [] ok
		return [ paPath[1] ]

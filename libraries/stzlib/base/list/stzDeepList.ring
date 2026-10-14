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
	if len(aA) != len(aB) return 0 ok
	_nLen_ = len(aA)
	for i = 1 to _nLen_
		if isList(aA[i]) and isList(aB[i])
			if NOT _DplListEq(aA[i], aB[i]) return 0 ok
		but isList(aA[i]) or isList(aB[i])
			return 0
		else
			if aA[i] != aB[i] return 0 ok
		ok
	next
	return 1

func _DplItemsEqual(pA, pB)
	if isList(pA) and isList(pB) return _DplListEq(pA, pB) ok
	if isList(pA) or isList(pB) return 0 ok
	return pA = pB

#-- Factory

func DeepListQ(paList)
	return new stzDeepList(paList)

#=============#
#  THE CLASS  #
#=============#

# Navigates a nested list by paths: lists every location, finds an item wherever it hides, and reads the item at a path.
#
# A path is a list of 1-based positions that locates an item: [2,3,1] is the 1st item of the 3rd
# item of the 2nd item. stzDeepList is a stzList, so every list method is still there; this subclass
# adds the path vocabulary, and the recursive work runs in the Zig engine. Build one with new
# stzDeepList(aList) or DeepListQ(aList). The path utilities that do not need a list (IsSubPathOf,
# CommonPath, SortPaths) are globals in stzListPaths.ring.
#
#   receiver   o1 = new stzDeepList([ "A", [ "x", "B", [ "C", "x" ], "x" ], "E" ])
#   example    ? @@( o1.DeepFind("x") )
#              #--> [ [ 2, 1 ], [ 2, 3, 2 ], [ 2, 4 ] ]
#              ? o1.ItemAtPath([2,3,1])
#              #--> C
#              ? @@( o1.PathsAtDepth(3) )
#              #--> [ [ 2, 3, 1 ], [ 2, 3, 2 ] ]
#              ? o1.DeepContains("E")
#              #--> 1
#   see        stzList, stzListOfLists
class stzDeepList from stzList

	# Returns the path of every item in the nested list, parents before their children, as lists of 1-based positions.
	#
	#   returns    a list of paths; [ ] for an empty list
	#   note       a sublist is itself an item, so [2] and [2,1] are both listed
	#   see        AllPaths, PathsAtDepth, ItemAtPath
	def Paths()
		_pList_ = This._EngineListFromContent()
		pRes  = StzEngineListDeepPaths(_pList_)
		_aResult_ = StzEngineListContentToRingList(pRes)
		StzEngineListFree(_pList_)
		StzEngineListFree(pRes)
		return _aResult_

		def AllPaths()
			return This.Paths()

	# Returns the paths of every item equal to the given one, at any depth.
	#
	#   pItem      the item to look for, a text, a number or a list
	#   returns    a list of paths; [ ] when the item is absent
	#   note       the comparison is case-sensitive: "X" does not find "x"; a sublist is found as a
	#              whole, as an item of its parent
	#   see        DeepContains, DeepFindAt, ItemAtPath
	def DeepFind(pItem)
		_pList_   = This._EngineListFromContent()
		pNeedle = StzEngineMarshalList([ pItem ])
		pRes    = StzEngineListDeepFind(_pList_, pNeedle, 1)
		_aResult_ = StzEngineListContentToRingList(pRes)
		StzEngineListFree(_pList_)
		StzEngineListFree(pNeedle)
		StzEngineListFree(pRes)
		return _aResult_

		def DeepFindAll(pItem)
			return This.DeepFind(pItem)

		def PathsContaining(pItem)
			return This.DeepFind(pItem)

	# TRUE if the item occurs anywhere in the nested list, at any depth.
	#
	#   pItem      the item to look for
	#   returns    TRUE or FALSE
	#   see        DeepFind
	def DeepContains(pItem)
		return ring_len(This.DeepFind(pItem)) > 0

	# Returns the path back if the item at that path equals the given item, and [ ] when it does not or when the path does not exist.
	#
	#   pItem      the item expected at the path
	#   paPath     the path to test, as 1-based positions
	#   returns    the path when the item is there, else [ ]
	#   see        DeepFind, ItemAtPath
	def DeepFindAt(pItem, paPath)
		_aWrap_ = This._ItemWrapAtPath(paPath)
		if ring_len(_aWrap_) > 0 and _DplItemsEqual(_aWrap_[1], pItem)
			return paPath
		ok
		return []

	# Returns the item found by following a path of 1-based positions down the nested list.
	#
	#   paPath     the path, such as [2,3,1] for the 1st item of the 3rd item of the 2nd item
	#   returns    the item; a list when the path ends on a sublist
	#   warning    an unreachable path (a position past the end, 0, or a step below a plain item)
	#              raises "Invalid path! it goes deeper than the structure."; a path that is not a
	#              list raises "Incorrect param!"
	#   see        ItemsAtPaths, DeepFindAt, Paths
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
			_pList_ = This._EngineListFromContent()
			pPath = StzEngineMarshalList(paPath)
			pRes  = StzEngineListItemAtPath(_pList_, pPath)
			_aWrap_ = StzEngineListContentToRingList(pRes)
			StzEngineListFree(_pList_)
			StzEngineListFree(pPath)
			StzEngineListFree(pRes)
			return _aWrap_

	# Returns the items at several paths at once, in the order of the paths, leaving out the paths that lead nowhere.
	#
	#   paPaths    a list of paths, each a list of 1-based positions
	#   returns    a list of items
	#   note       unlike ItemAtPath it never raises: a bad path is skipped silently, so the answer
	#              can be shorter than the list of paths
	#   see        ItemAtPath
	def ItemsAtPaths(paPaths)
		_pList_  = This._EngineListFromContent()
		pPaths = StzEngineMarshalList(paPaths)
		pRes   = StzEngineListItemsAtPaths(_pList_, pPaths)
		_aResult_ = StzEngineListContentToRingList(pRes)
		StzEngineListFree(_pList_)
		StzEngineListFree(pPaths)
		StzEngineListFree(pRes)
		return _aResult_

	# Returns the paths that go deepest into the nested list, all of the same length.
	#
	#   returns    a list of paths; [ ] for an empty list
	#   see        PathsAtDepth, Paths
	def LongestPaths()
		_pList_ = This._EngineListFromContent()
		pRes  = StzEngineListLongestPaths(_pList_)
		_aResult_ = StzEngineListContentToRingList(pRes)
		StzEngineListFree(_pList_)
		StzEngineListFree(pRes)
		return _aResult_

	# Returns the paths of exactly the given depth, a path of one position being depth 1.
	#
	#   nDepth     the number of positions in the paths wanted
	#   returns    a list of paths; [ ] when the depth is 0 or deeper than the list
	#   see        Paths, LongestPaths
	def PathsAtDepth(nDepth)
		_pList_ = This._EngineListFromContent()
		pRes  = StzEngineListPathsAtDepth(_pList_, nDepth)
		_aResult_ = StzEngineListContentToRingList(pRes)
		StzEngineListFree(_pList_)
		StzEngineListFree(pRes)
		return _aResult_

	# Returns the given path followed by the paths of everything beneath it, as a list of paths.
	#
	#   paPath     the path of the item to open up
	#   returns    a list of paths; just the given path when it is a plain item
	#   note       a path that does not exist answers itself unchecked, as the only path of the list
	#   see        CollapsePath, Paths
	def ExpandPath(paPath)
		_pList_ = This._EngineListFromContent()
		pPath = StzEngineMarshalList(paPath)
		pRes  = StzEngineListExpandPath(_pList_, pPath)
		_aResult_ = StzEngineListContentToRingList(pRes)
		StzEngineListFree(_pList_)
		StzEngineListFree(pPath)
		StzEngineListFree(pRes)
		return _aResult_

	# Returns the one-position path of the top-level item that contains the given path.
	#
	#   paPath     a path of any depth
	#   returns    a list holding the first position; [ ] for an empty path
	#   see        ExpandPath
	def CollapsePath(paPath)
		if ring_len(paPath) = 0 return [] ok
		return [ paPath[1] ]

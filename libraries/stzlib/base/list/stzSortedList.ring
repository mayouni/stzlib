

func StzSortedListQ(paList)
	return new stzSortedList(paList)

class stzOrderedList from stzSortedList

# Holds a list that stays sorted: it sorts at creation and every item added goes to its place.
#
# Build one with new stzSortedList(aList) or StzSortedListQ(aList); it is a stzList, so every list
# method also works on the sorted content (Content, NumberOfItems, Contains ...). Numbers sort
# before texts; texts sort by character code, so "Apple" comes before "apple", which comes before
# "banana". Add, Append and the + operator insert one item at its place. The Q forms AddQ and
# AppendQ do not insert today.
#
#   receiver   o1 = new stzSortedList([ 5, 2, 9, 1 ])
#   example    ? @@( o1.Content() )
#              #--> [ 1, 2, 5, 9 ]
#              o1.Add(4)
#              ? @@( o1.Content() )
#              #--> [ 1, 2, 4, 5, 9 ]
#              o2 = new stzSortedList([ "pear", "Apple", "שלום" ])
#              ? @@( o2.Content() )
#              #--> [ "Apple", "pear", "שלום" ]
#   see        stzList, stzSet
class stzSortedList from stzList
	@aContent

	# Builds a sorted list from a list, sorting its items once at creation.
	#
	#   paList     the list to sort, of numbers, texts or both
	#   returns    nothing; the object is built
	#   warning    the list given is copied and the original keeps its order; numbers sort before
	#              texts, and texts sort by character code, so capitals come before lower case and
	#              Hebrew, Arabic and emoji come after Latin letters
	#   see        Add
	def init(paList)
		@aContent = paList
		_pSlInit = This._EngineListFromContent()
		if _pSlInit != ""
			StzEngineListSort(_pSlInit)
			@aContent = StzEngineListContentToRingList(_pSlInit)
			StzEngineListFree(_pSlInit)
		else
			@aContent = @SortList(paList)
		ok

	# Inserts one item at its place in the sorted order and keeps the list sorted.
	#
	#   pItem      the number or text to insert
	#   returns    nothing; AddQ is meant to chain and does not insert today
	#   note       a duplicate is kept next to its equal
	#   warning    The Q form AddQ does not insert: AddQ("c") on b d leaves b d, because its body
	#              only returns the object; use Add
	#   see        Append, Content
	def Add(pItem)
		_pSlAdd = This._EngineListFromContent()
		if _pSlAdd != ""
			# Type-specific sorted insert -- builds the value inside the list
			# DLL. (A StzValue handle minted by the value DLL does NOT resolve
			# in the list DLL's handle table, so the old handle-based
			# StzEngineListSortedInsert read garbage and was a silent no-op.)
			if isNumber(pItem)
				if floor(pItem) = pItem
					StzEngineListSortedInsertInt(_pSlAdd, pItem)
				else
					StzEngineListSortedInsertFloat(_pSlAdd, pItem)
				ok
			else
				StzEngineListSortedInsertString(_pSlAdd, "" + pItem)
			ok
			@aContent = StzEngineListContentToRingList(_pSlAdd)
			StzEngineListFree(_pSlAdd)
		else
			@aContent + pItem
			@aContent = @SortList(@aContent)
		ok

		def AddQ(pItem)
			return this

	# Inserts one item at its place in the sorted order, the same as Add, since a sorted list has no end to append to.
	#
	#   pItem      the number or text to insert
	#   returns    nothing; AppendQ is meant to chain and does not insert today
	#   warning    The Q form AppendQ does not insert: AppendQ("a") on b d leaves b d; use Append
	#   see        Add
	def Append(pItem)
		This.Add(pItem)

		def AppendQ(pItem)
			return This

	# Handles the + operator on the list: o + item inserts the item in sorted order, in place.
	#
	#   pcOp       the operator, only "+" is acted on, anything else is ignored
	#   item       the number or text to insert
	#   returns    nothing; the list is changed
	#   warning    the list changes in place, so o + 9 does not leave the original untouched
	#   see        Add
	def operator(pcOp, item)

		if pcOp = "+"
			This.Add(item)
		ok

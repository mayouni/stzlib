#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTPERFORMER           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List performer subclass -- higher-order    #
#                  perform and yield operations.               #
#                  For aliases, use stzListPerformerXT.         #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

# Applies an expression to the items of a list, to all of them or to some, either rewriting the list (Perform) or only reading the results (Yield).
#
# Build one with new stzListPerformer(aList) or over a stzList object; it keeps its own copy, so
# what you passed in is not changed, and Content gives the result of the Perform calls. An
# expression is text in which @item is the current item and @i its position, such as "2*@item" or
# "upper(@item)"; braces around it are accepted. The W forms (PerformW, YieldW) choose the items by
# a condition written the same way, and the On forms by positions. Inside an expression len() counts
# bytes, not letters. YieldPairs does not return pairs today.
#
#   receiver   o1 = new stzListPerformer([ 3, 1, 4, 1, 5 ])
#   example    ? @@( o1.Yield("2*@item") )
#              #--> [ 6, 2, 8, 2, 10 ]
#              ? @@( o1.YieldW("@item > 2", "10*@item") )
#              #--> [ 30, 40, 50 ]
#              o1.PerformOn([ 1, 5 ], "@item + 100")
#              ? @@( o1.Content() )
#              #--> [ 103, 1, 4, 1, 105 ]
#   see        stzList, stzListWalker
class stzListPerformer from stzObject

	@oList

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds a performer over a list or over a stzList object, working on its own copy, so the list passed in is never changed.
	#
	#   pListOrObj   a list, or a stzList object, whose items are transformed or read
	#   returns      nothing; the object is built
	#   warning      any other kind of value raises "Can't create stzListPerformer! Parameter must
	#                be a list or stzList object."
	#   see          Content
	def init(pListOrObj)
		if isList(pListOrObj)
			@oList = new stzList(pListOrObj)
		but isObject(pListOrObj)
			@oList = pListOrObj
		else
			StzRaise("Can't create stzListPerformer! Parameter must be a list or stzList object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	# Returns the items the performer holds, after any Perform made through it.
	#
	#   returns    a list
	#   see        Yield
	def Content()
		return @oList.Content()

	# Returns how many items the list holds.
	#
	#   returns    a number
	#   see        Content
	def NumberOfItems()
		return @oList.NumberOfItems()

	# TRUE if the list holds no item.
	#
	#   returns    TRUE or FALSE
	#   see        NumberOfItems
	def IsEmpty()
		return @oList.IsEmpty()

	  #===============================#
	 #     PERFORM / YIELD           #
	#===============================#

	# Replaces every item by the result of an expression applied to it, in place.
	#
	#   pcAction   the expression as text, where @item stands for the item and @i for its position,
	#              such as "2*@item"
	#   returns    nothing; use PerformQ to chain
	#   note       Yield gives the same results without changing the list; inside an expression
	#              len() counts bytes, so len(@item) of the Hebrew שלום is 8
	#   see        Yield, PerformOn
	def Perform(pcAction)
		_pPfList_ = @oList._EngineListFromContent()
		if _pPfList_ != ""
			_pPfResult_ = StzEngineListMapExpr(_pPfList_, pcAction)
			if _pPfResult_ != ""
				@oList.UpdateWith(@oList._ContentFromEngineList(_pPfResult_))
				StzEngineListFree(_pPfResult_)
			ok
			StzEngineListFree(_pPfList_)
			return
		ok
		_aPfContent_ = @oList.Map(pcAction)
		@oList.UpdateWith(_aPfContent_)

		def PerformQ(pcAction)
			This.Perform(pcAction)
			return This

	# Replaces by the result of an expression only the items at the given positions, in place.
	#
	#   panPos     the positions to transform, from 1
	#   pcAction   the expression as text, where @item stands for the item
	#   returns    nothing; use PerformOnQ to chain
	#   note       the expression is computed over the whole list and only the results at panPos are
	#              kept
	#   see        Perform, PerformW
	def PerformOn(panPos, pcAction)
		_aPoAll_ = @oList.Map(pcAction)
		_aPoContent_ = @oList.Content()
		_nPoLen_ = len(panPos)
		for _iPo_ = 1 to _nPoLen_
			_nPoPos_ = panPos[_iPo_]
			if _nPoPos_ >= 1 and _nPoPos_ <= len(_aPoContent_)
				_aPoContent_[_nPoPos_] = _aPoAll_[_nPoPos_]
			ok
		next
		@oList.UpdateWith(_aPoContent_)

		def PerformOnQ(panPos, pcAction)
			This.PerformOn(panPos, pcAction)
			return This

		# Replaces by the result of an expression only the items at the given positions, the same as PerformOn.
		#
		#   panPos     the positions to transform, from 1
		#   pcAction   the expression as text, where @item stands for the item
		#   returns    nothing
		#   see        PerformOn
		def PerformOnPositions(panPos, pcAction)
			This.PerformOn(panPos, pcAction)

	def PerformW(pcCondition, pcAction)
		_anPwPos_ = @oList.FindW(pcCondition)
		This.PerformOn(_anPwPos_, pcAction)

		def PerformWQ(pcCondition, pcAction)
			This.PerformW(pcCondition, pcAction)
			return This

	# Replaces by the result of an expression only the items that are both at one of the given positions and meet a W condition, in place.
	#
	#   panPos        the positions allowed
	#   pcCondition   the W condition as text, where @item stands for the item
	#   pcAction      the expression as text, where @item stands for the item
	#   returns       nothing; use PerformAtWQ to chain
	#   note          an item at a listed position that fails the condition stays as it was
	#   see           PerformW, PerformOn
	#@ aka  -- PerformAtW: transform only the items that are BOTH at one of panPos -- and satisfy the W condition (the position-restricted PerformW).
	def PerformAtW(panPos, pcCondition, pcAction)
		_anPawMatch_ = @oList.FindW(pcCondition)
		_anPawSel_ = []
		_nPawLen_ = len(panPos)
		for _iPaw_ = 1 to _nPawLen_
			if ring_find(_anPawMatch_, panPos[_iPaw_]) > 0
				_anPawSel_ + panPos[_iPaw_]
			ok
		next
		This.PerformOn(_anPawSel_, pcAction)

		def PerformAtWQ(panPos, pcCondition, pcAction)
			This.PerformAtW(panPos, pcCondition, pcAction)
			return This

	# Returns the results of an expression applied to every item, as a list, leaving the list unchanged.
	#
	#   pcYielder   the expression as text, where @item stands for the item and @i for its position,
	#               such as "2*@item"
	#   returns     a list with one result per item
	#   note        YieldQ answers a stzList to chain on; len() inside the expression counts bytes;
	#               an item the expression cannot compute, such as 10 / @item for 0, gives an empty
	#               text and no error
	#   see         Perform, YieldOn
	def Yield(pcYielder)
		_pYdList_ = @oList._EngineListFromContent()
		if _pYdList_ != ""
			_pYdResult_ = StzEngineListMapExpr(_pYdList_, pcYielder)
			if _pYdResult_ != ""
				_aYdContent_ = @oList._ContentFromEngineList(_pYdResult_)
				StzEngineListFree(_pYdResult_)
				StzEngineListFree(_pYdList_)
				return _aYdContent_
			ok
			StzEngineListFree(_pYdList_)
		ok
		return @oList.Map(pcYielder)

		def YieldQ(pcYielder)
			return new stzList(This.Yield(pcYielder))

	# Returns the results of an expression for the items at the given positions only, in the order of the positions.
	#
	#   panPos      the positions to read, from 1, in the order wanted
	#   pcYielder   the expression as text, where @item stands for the item
	#   returns     a list of results; positions outside the list are skipped
	#   note        the expression is computed over the whole list and only the results at panPos
	#               are kept
	#   see         Yield, YieldW
	#@ aka  Evaluate the yielder expression over the items and return the results AT the given positions.
	def YieldOn(panPos, pcYielder)
		_aYoAll_ = @oList.Map(pcYielder)
		_nYoLen_ = len(panPos)
		_aYoResult_ = []
		for _iYo_ = 1 to _nYoLen_
			_nYoPos_ = panPos[_iYo_]
			if _nYoPos_ >= 1 and _nYoPos_ <= len(_aYoAll_)
				@AddItem(_aYoResult_, _aYoAll_[_nYoPos_])
			ok
		next
		return _aYoResult_

	def YieldW(pcCondition, pcYielder)
		_anYwPos_ = @oList.FindW(pcCondition)
		return This.YieldOn(_anYwPos_, pcYielder)

	  #======================================================#
	 #   YIELD ON POSITIONS Q                               #
	#======================================================#

	def YieldOnQ(panPos, pcYielder)
		return new stzList(This.YieldOn(panPos, pcYielder))

	def YieldWQ(pcCondition, pcYielder)
		return new stzList(This.YieldW(pcCondition, pcYielder))

	  #======================================================#
	 #   PERFORM ON EACH WITH INDEX                         #
	#======================================================#

	# Replaces every item by the result of an expression that can use both the item and its position, in place.
	#
	#   pcAction   the expression as text, where @item stands for the item and @i for its position,
	#              such as "@item + @i"
	#   returns    nothing; use PerformOnEachItemAndItsPositionQ to chain
	#   note       it is Perform under a longer name: the position is available as @i in Perform too
	#   see        Perform
	def PerformOnEachItemAndItsPosition(pcAction)
		This.Perform(pcAction)

		def PerformOnEachItemAndItsPositionQ(pcAction)
			This.PerformOnEachItemAndItsPosition(pcAction)
			return This

	  #======================================================#
	 #   YIELD PAIRS [POSITION, ITEM]                       #
	#======================================================#

	# Returns the results of an expression applied to every item, exactly as Yield does.
	#
	#   pcYielder   the expression as text, where @item stands for the item
	#   returns     a list of results, not of pairs
	#   warning     Does not return [ position, item ] pairs today, as its section title says:
	#               YieldPairs("2*@item") on 10 20 30 answers 20 40 60, the same list as Yield
	#   see         Yield
	def YieldPairs(pcYielder)
		return @oList.Map(pcYielder)

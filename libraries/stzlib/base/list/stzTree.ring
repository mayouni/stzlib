# stzTree - Softanza Tree Class
# Extending stzList to provide tree-specific capabilities


func StzTreeQ(paTree)
	return new stzTree(paTree)

func IsValidNodePath(pcPath)
	# Checks that the branch has this format : '[:root][:node1][:node11]'

	return rx('^\[:[a-zA-Z0-9_]+\](?:\[:[a-zA-Z0-9_]+\])*$').Match(pcPath)

	func @IsValidNodePath(pcPath)
		return IsValidNodePath(pcPath)

func IsListOfValidNodesPaths(pacList)

	if CheckParams()
		if NOT ( isList(pacList) and IsListOfStrings(pacList) )
			stzraise("Incorrect param type! pacList must be a list of strings.")
		ok
	ok

	_bResult_ = 1

	_nLen_ = len(pacList)
	for i = 1 to _nLen_
		if NOT IsValidNodePath(pacList[i])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

	func IsValidListOfNodesPaths(pacList)
		return IsListOfValidNodesPaths(pacList)

	func @IsListOfValidNodesPaths(pacList)
		return IsListOfValidNodesPaths(pacList)

	func @IsValidListOfNodesPaths(pacList)
		return IsListOfValidNodesPaths(pacList)

func IsValidItemPath(pcPath)
	# Checks that the path has this format : [:root][:node1][:node11][3]'

	return rx('^\[:[a-zA-Z0-9_]+\](?:\[:[a-zA-Z0-9_]+\])*\[\d+\]$').Match(pcPath)

	#NOTE // Thank's to rx(), the one liner above replacede all this code:

	# oPath = new stzString(pcBranch)
	# 
	# n1 = oPath.FindLast("[")
	# n2 = oPath.NumberOfChars()
	# cPos = oPath.Section( n1+1, n2-1 )
	# 
	# if IsNumberInString(cPos)
	# 	return TRUE
	# else
	# 	return FALSE
	# ok

	func @IsValidItemPath(pcPath)
		return IsValidItemPath(pcPath)

func IsListOfValidItemsPaths(pacList)

	if CheckParams()
		if NOT ( isList(pacList) and IsListOfStrings(pacList) )
			stzraise("Incorrect param type! pacList must be a list of strings.")
		ok
	ok

	_bResult_ = 1

	_nLen_ = len(pacList)
	for i = 1 to _nLen_
		if NOT IsValidItemPath(pacList[i])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

	func IsValidListOfItemsPaths(pacList)
		return IsListOfValidItemsPaths(pacList)

	func @IsListOfValidItemsPaths(pacList)
		return IsListOfValidItemsPaths(pacList)

	func @IsValidListOfItemsPaths(pacList)
		return IsListOfValidItemsPaths(pacList)

class stzTree from stzList
	
	def init(paTree)

		if CheckParams()
			if NOT isList(paTree)
				stzraise("Can't create a stzTree object! paTree must be a list.")
			ok
		ok

		if NOT @IsTree(paTree)
			stzraise("Can't create a stzTree object! paTree must be a tree.")
		ok

		_aTemp_ = []
		_aTemp_ + paTree

		super.init(_aTemp_)

	def Root()
		return This.Content()[1]

	  #--------------------------------#
	 #  VISUALIZING THE TREE CONTENT  #
	#--------------------------------#

	def Show()
		? @@NL(This.Content()[1])

	  #---------------------#
	 #  MANAGING BRANCHES  #
	#---------------------#

	def Branches()
		_aResult_ = [ '[:root]' ]

		_aTree_ = super.Content()[1]

		_aRootContent_ = _aTree_[2]
		This._CollectBranches("[:root]", _aRootContent_, _aResult_)
    
		return _aResult_

		def AllBranches()
			return This.Branches()

	def _CollectBranches(cCurrentPath, paContent, _aResult_)
		_nLen_ = len(paContent)

		for i = 1 to _nLen_
			_item_ = paContent[i]
        
			# Skip if item is not a list

			if NOT isList(_item_)
				loop
			ok
        
			_nLenItem_ = len(_item_)

			# Process branch entries - they're lists
			# with string as first element

			if _nLenItem_ >= 2 and isString(_item_[1])

				_cBranchName_ = _item_[1]
				_cBranchPath_ = cCurrentPath + "[:" + _cBranchName_ + "]"
				_aResult_ + _cBranchPath_

				# Process subbranches if exists

				if _nLenItem_ >= 2 and isList(_item_[2])
					This._CollectBranches(_cBranchPath_, _item_[2], _aResult_)
				ok
			ok
		next

	  #------------------#
	 #  MANAGING NODES  #
	#------------------#

	def Nodes()
		_aResult_ = [ 'root' ]

		_aTree_ = super.Content()[1]
		_aRootContent_ = _aTree_[2]

		This._CollectNodes(_aRootContent_, _aResult_)

		return _aResult_

		def AllNodes()
			return This.Nodes()

	def TheseNodes(pacNodesNames)

		if CheckParams()
			if NOT (isList(pacNodesNames) and @IsListOfStrings(pacNodesNames))
				stzraise("Incorrect param type! pacNodesNames must be a list of strings.")
			ok
		ok

		_aResult_ = []
		_nLen_ = len(pacNodesNames)

		for i = 1 to _nLen_
			_aResult_ + This.Node(pacNodesNames[i])
		next

		return _aResult_

	def _CollectNodes(paContent, _aResult_)
		_nLenContent_ = len(paContent)

		for i = 1 to _nLenContent_
			_item_ = paContent[i]

			# Skip if item is not a list

			if NOT isList(_item_)
				loop
			ok

			_nLenItem_ = len(_item_)

			# Process branch entries - they're lists
			# with string as first element

			if _nLenItem_ >= 2 and isString(_item_[1])
				_cNodeName_ = _item_[1]
				_aResult_ + _cNodeName_

				# Process subnodes if exists

				if _nLenItem_ >= 2 and isList(_item_[2])
					This._CollectNodes(_item_[2], _aResult_)
				ok
			ok
		next

	def NodesZ()
		return @Association([ This.Nodes(), This.Branches() ])

		def NodesAndTheirBranches()
			return This.NodesZ()

	def FindNode(pcNodeName)
		if not isString(pcNodeName)
			stzraise("Incorrect param type! pcNodeName must be a string.")
		ok

		if pcNodeName = ""
			stzraise("Can't proceed! pcNode must not be empty string.")
		ok

		pcNodeName = StzLower(pcNodeName)
		_cResult_ = This.NodesZ()[pcNodeName]

		if _cResult_ = ""
			stzraise("Inexistant node!")
		ok

		return _cResult_

	def Node(pcNodeName)

		_cBranch_ = This.FindNode(pcNodeName)
		_aResult_ = This.NodeAt(_cBranch_)

		return _aResult_

	def NodeAt(pcBranch)

		if CheckParams()
			if NOT isString(pcBranch)
				stzraise("Incorrect param type! pcBranch must be a string.")
			ok
		ok

		if NOT @IsValidNodePath(pcBranch)
			stzraise("Can't proceed! pcBranch is not a valid node path.")
		ok

		_cCode_ = '_aResult_ = This.Content()' + pcBranch
		eval(_cCode_)

		return _aResult_

	def NodesAt(pacBranches)

		if CheckParams()
			if NOT (isList(pacBranches) and @IsListOfStrings(pacBranches) )
				stzraise("Incorrect param type! pacBranches must be a list of strings.")
			ok
		ok

		if NOT @IsValidListOfNodesPaths(pacBranches)
			stzraise("Can't proceed! pacBranches is not a list of valid nodes paths.")
		ok

		_nLen_ = len(pacBranches)
		_aResult_ = []

		for i = 1 to _nLen_
			_aResult_ + This.NodeAt(pacBranches[i])
		next

		return _aResult_

	def FindTheseNodes(pacNodesNames)
		if CheckParams()
			if NOT (isList(pacNodesNames) and @IsListOfStrings(pacNodesNames) )
				stzraise("Incorrect param type!")
			ok
		ok

		_acNodesNames_ = U(pacNodesNames)
		_nLen_ = len(_acNodesNames_)
		_acResult_ = [] // Branches

		for @i = 1 to _nLen_
			_acResult_ + This.FindNode(_acNodesNames_[@i])
		next

		return _acResult_

	def FindNodes() # Finding all nodes in the list
		return This.Branches()

		def FindAllNodes()
			return This.FindNodes()

	  #------------------#
	 #  MANAGING ITEMS  #
	#------------------#
	
	def ItemsCS(pCaseSensitive)
		_aResult_ = []
		_aTree_ = super.ContentCS(pCaseSensitive)[1]
		_aRootContent_ = _aTree_[2]
		
		This._CollectItems(_aRootContent_, _aResult_)
		
		return _aResult_

		def AllItemsCS(pCaseSensitive)
			return This.ItemsCS(pCaseSensitive)

	def Items()
		return This.ItemsCS(1)

		def AllItems()
			return This.Items()

	# An internal method used by Items()

	def _CollectItems(paContent, _aResult_)
		_nLenContent_ = len(paContent)
    
		for i = 1 to _nLenContent_
			_item_ = paContent[i]
        
			# If the item is not a list or it's
			# a simple value, it's an item in the tree semantic

			if NOT isList(_item_) OR (isList(_item_) AND len(_item_) = 0)
				_aResult_ + _item_
				loop
			ok

			# If it is a list but not a branch
			# (doesn't have a string as first element)

			if isList(_item_) AND (len(_item_) < 2 OR NOT isString(_item_[1]))
				_aResult_ + _item_
				loop
			ok
        
			# If it's a branch, check its contents

			if isList(_item_) AND len(_item_) >= 2 AND isString(_item_[1])
				# Only process the contents if it's a list
				if len(_item_) >= 2 AND isList(_item_[2])
					This._CollectItems(_item_[2], _aResult_)
				ok
			ok
		next

	def ItemsXTCS(pCaseSensitive) # ItemsAndTheirPathsCS()
		_aItems_ = This.Items()
		_aItemPaths_ = []
		
		_nItemsLen_3 = len(_aItems_)
		for i = 1 to _nItemsLen_3
			_aItemPaths_ + []
		next
		
		_aTree_ = super.Content()[1]
		_aRootContent_ = _aTree_[2]
		
		This._MapItemsToPathsCS(_aRootContent_, "[:root]", _aItems_, _aItemPaths_, pCaseSensitive)
		
		_aResult_ = []
		_nItemsLen_2 = len(_aItems_)
		for i = 1 to _nItemsLen_2
			_aResult_ + [ _aItems_[i], _aItemPaths_[i] ]
		next
		
		return _aResult_

		#< @FunctionAlternativeForms

		def ItemsAndTheirPathsCS(pCaseSensitive)
			return This.ItemsXTCS(pCaseSensitive)

		#>

	def ItemsZ()
		return This.ItemsXTCS(1)

		def ItemsAndTheirPaths()
			return This.ItemsZ()

	# An internal method used by ItemsZ()

	def _MapItemsToPathsCS(paContent, cCurrentPath, _aItems_, _aItemPaths_, pCaseSensitive)
		_nLenContent_ = len(paContent)
		
		for i = 1 to _nLenContent_
			_item_ = paContent[i]
			
			# If the item is not a list or it's a simple value, then take it
			if NOT isList(_item_) OR (isList(_item_) AND len(_item_) = 0)
				_nPos_ = StzListQ(_aItems_).FindFirstCS(_item_, pCaseSensitive)
				if _nPos_ > 0
					_aItemPaths_[_nPos_] + cCurrentPath
				ok
				loop
			ok
			
			# If it is a list but not a branch (doesn't have a string as first element)
			if isList(_item_) AND (len(_item_) < 2 OR NOT isString(_item_[1]))

				_nPos_ = StzListQ(_aItems_).FindFirstCS(_item_, pCaseSensitive)
				if _nPos_ > 0
					_aItemPaths_[_nPos_] + cCurrentPath
				ok
				loop
			ok
			
			# If it's a branch, check its contents
			if isList(_item_) AND len(_item_) >= 2 AND isString(_item_[1])
				_cBranchName_ = _item_[1]
				_cBranchPath_ = cCurrentPath + "[:"+_cBranchName_+"]"
				
				# Only process the contents if it's a list
				if len(_item_) >= 2 AND isList(_item_[2])
					This._MapItemsToPathsCS(_item_[2], _cBranchPath_, _aItems_, _aItemPaths_, pCaseSensitive)
				ok
			ok
		next

	def _MapItemsToPaths(paContent, cCurrentPath, _aItems_, _aItemPaths_)
		return This._MapItemsToPathsCS(paContent, cCurrentPath, _aItems_, _aItemPaths_, 1)

	  #-----------------#
	 #  FINDING ITEMS  #
	#-----------------#

	def FindItemCS(pItem, pCaseSensitive)
		_aResult_ = []
		_aItemsAndBranches_ = This.ItemsXTCS(pCaseSensitive)
		
		_nItemsAndBranchesLen_2 = len(_aItemsAndBranches_)
		for i = 1 to _nItemsAndBranchesLen_2
			if _aItemsAndBranches_[i][1] = pItem
				_aBranches_ = _aItemsAndBranches_[i][2]
				_aPositions_ = This._FindItemPositionsAt(pItem, _aBranches_, pCaseSensitive)
				
				_nBranchesLen_3 = len(_aBranches_)
				for j = 1 to _nBranchesLen_3
					# Concatenate branch path with position directly
					if _aPositions_[j] != ""
						_aResult_ + (_aBranches_[j] + _aPositions_[j])
					ok
				next
				
				exit
			ok
		next
		
		return _aResult_

		def FindThisItemCS(pItem, pCaseSensitive)
			return This.FindItemCS(pItem, pCaseSensitive)

	def FindItem(pItem)
		return This.FindItemCS(pItem, 1)

		def FindThisItem(pItem)
			This.FindItem(pItem)
	
	# Helper function to find positions of an item in multiple branches

	def _FindItemPositionsAt(pItem, paBranches, pCaseSensitive)
		_aPositions_ = []
		
		_nBranchesLen_2 = len(paBranches)
		for i = 1 to _nBranchesLen_2
			_aNodeContent_ = This.NodeAt(paBranches[i])
			_nPos_ = 0
			
			_nNodeContentLen_2 = len(_aNodeContent_)
			for j = 1 to _nNodeContentLen_2
				if pCaseSensitive = 1
					if _aNodeContent_[j] = pItem
						_nPos_ = j
						exit
					ok
				else
					if StzLower(_aNodeContent_[j]) = StzLower(pItem)
						_nPos_ = j
						exit
					ok
				ok
			next
			
			# Return the position as "[n]" instead of just "n"
			if _nPos_ > 0
				_aPositions_ + ("[" + _nPos_ + "]")
			else
				_aPositions_ + ""
			ok
		next
		
		return _aPositions_
	
	# Helper function to find position of an item in a specific branch

	def _FindItemPositionAt(pItem, pcBranch, pCaseSensitive)
		_aNodeContent_ = This.NodeAtBranch(pcBranch)
		_nPos_ = 0
		
		_nNodeContentLen_ = len(_aNodeContent_)
		for i = 1 to _nNodeContentLen_
			if pCaseSensitive = 1
				if _aNodeContent_[i] = pItem
					_nPos_ = i
					exit
				ok
			else
				if StzLower(_aNodeContent_[i]) = StzLower(pItem)
					_nPos_ = i
					exit
				ok
			ok
		next
		
		# Return the position as "[n]" instead of just "n"
		if _nPos_ > 0
			return "[" + _nPos_ + "]"
		else
			return ""
		ok

	#--

	def FindTheseItemsCS(paItems, pCaseSensitive)
		_aResult_ = []
		_nLen_ = len(paItems)

		_nItemsLen_ = len(paItems)
		for i = 1 to _nItemsLen_
			_aBranchesWithPos_ = This.FindItemCS(paItems[i], pCaseSensitive)
			_nLen2_ = len(_aBranchesWithPos_)
			for j = 1 to _nLen2_
				_aResult_ + _aBranchesWithPos_[_nLen2_]
			next
		next
		
		return _aResult_
	
	def FindTheseItems(paItems)
		return This.FindTheseItemsCS(paItems, 1)

	#--

	def FindItemsCS(pCaseSensitive) # FindAllItems()
		_aResult_ = []
		_aItemsAndBranches_ = This.ItemsXTCS(pCaseSensitive)

		_nItemsAndBranchesLen_ = len(_aItemsAndBranches_)
		for i = 1 to _nItemsAndBranchesLen_
			_cItem_ = _aItemsAndBranches_[i][1]
			_aBranches_ = _aItemsAndBranches_[i][2]
			_aPositions_ = This._FindItemPositionsAt(_cItem_, _aBranches_, pCaseSensitive)

			_nBranchesLen_ = len(_aBranches_)
			for j = 1 to _nBranchesLen_
				# Concatenate branch path with position directly
				if _aPositions_[j] != ""
					_aResult_ + (_aBranches_[j] + _aPositions_[j])
				ok
			next
		next

		return _aResult_

		def FindAllItemsCS(pCaseSensitive)
			return This.FindItemsCS(pCaseSensitive)

	def FindItems()
		return This.FindItemsCS(1)

	#--

	def ItemAt(pcPath) # Path = Branch that ends with a position
		if CheckParams()
			if NOT isString(pcPath)
				stzraise("Incorrect param type! pcPath must be a string.")
			ok
		ok

		if NOT @IsValidItemPath(pcPath)
			stzraise("Syntax error! pcPath is not a well formed branch string.")
		ok

		_cCode_ = "_result_ = This.Content()" + pcPath
		eval(_cCode_)
		return _result_

	def ItemsAt(pcNodePath)
		if NOT @IsValidNodePath(pcNodePath)
			stzraise("Incorrect param! pcNodePath is not a valid node path.")
		ok

		_cCode_ = '_aResult_ = This.Content()' + pcNodePath
		eval(_cCode_)
		return _aResult_

	def ItemsInNode(pcNode)
		return This.Node(pcNode)

	  #--------------------------#
	 #  ADDING NODES AND ITEMS  #
	#--------------------------#

	def AddNodeAt(paNode, pcBranch)
		if CheckParams()

			if NOT ( isList(paNode) and len(paNode) = 2 and
			         isString(paNode[1]) and isList(paNode[2]) )

				stzRaise("Incorrect param! paNode is not a valid node.")
			ok
			
			if NOT isString(pcBranch)
				stzRaise("Can't add node! pcBranch must be a string.")
			ok
		ok
		
		# Check if branch exists
		if NOT StzFindFirst(pcBranch, This.Branches()) > 0
			return
		ok

		_cNodeName_ = paNode[1]
		_aNodeContent_ = paNode[2]

		_cCode_ = 'This.Content()' + pcBranch + ' + [ _cNodeName_, _aNodeContent_ ]'
		eval(_cCode_)

	
	def AddItemAt(pItem, pcBranch)
		if CheckParams()
			if NOT isString(pcBranch)
				stzRaise("Can't add item! pcBranch must be a string.")
			ok
		ok
		
		# Check if branch exists
		if NOT StzFindFirst(pcBranch, This.Branches()) > 0
			return
		ok
		
		_cCode_ = 'This.Content()' + pcBranch + ' + pItem'
		eval(_cCode_)

	  #-------------------------------#
	 #  GEETING NODES FROM A BRANCH  #
	#-------------------------------#
	
	def NumberOfNodesInBranch(pcBranch)
		return len( @split(pcBranch, "]["))

		#< @FunctionAlternativeForms

		def CountNodesInBranch(pcBranch)
			return THis.NumberOfNodesInBranch(pcBranch)
	
		def HowManyNodesInBranch(pcBranch)
			return THis.NumberOfNodesInBranch(pcBranch)

		#--

		def NumberOfNodesInPath(pcBranch)
			return THis.NumberOfNodesInBranch(pcBranch)
	
		def CountNodesInPath(pcBranch)
			return THis.NumberOfNodesInBranch(pcBranch)
	
		def HowManyNodesInPath(pcBranch)
			return THis.NumberOfNodesInBranch(pcBranch)

		#>

	def NodesInBranch(pcBranch)
	
		_acSplits_ = @split(pcBranch, "][")
		_nLen_ = len(_acSplits_)
	
		if _nLen_ > 0
			_acSplits_[1] = StzReplace(_acSplits_[1], "[", "")
			_acSplits_[1] = StzReplace(_acSplits_[1], "]", "")
		ok
	
		if _nLen_ > 1
			_acSplits_[_nLen_] = StzReplace(_acSplits_[_nLen_], "]", "")
		ok
	
		return _acSplits_

		def NodesInPath(pcBranch)
			return This.NodesInBranch(pcBranch)

	def NthNodeInBranch(_n_, pcBranch)
		if isString(_n_) and isNumber(pcBranch)
			_temp_ = pcBranch
			pcPath = _n_
			_n_ = _temp_
		ok
	
		return This.NodesInBranch(pcBranch)[_n_]

		def NthNodeInPath(_n_, pcBranch)
			return This.NthNodeInBranch(_n_, pcBranch)

	def FirstNodeInBranch(pcBranch)
		return This.NthNodeInBranch(1, pcBranch)

		def FirstNodeInPath(pcBranch)
			return This.FirstNodeInBranch(pcBranch)

	def LastNodeInBranch(pcBranch)
		return This.NthNodeInBranch(This.NumberOfNodesInBranch(pcBranch), pcBranch)

		def LastNodeInPath(pcBranch)
			return This.LastNodeInBranch(pcBranch)


	  #----------------------------#
	 #  REMOVING ITEMS AND NODES  #
	#----------------------------#


	def RemoveItemCS(pItem, pCaseSensitive) #TODO
		stzraise("Not yet implemented!")

		def RemoveThisItemCS(pItem, pCaseSensitive)

	def RemoveItem(pItem) #TODO
    		This.RemoveItemCS(pItem, 1)

	#--

	def RemoveTheseItemsCS(paItems, pCaseSensitive) #TODO
		stzraise("Not yet implemented!")

	def RemoveTheseItems(paItems)
		This.RemoveTheseItemsCS(paItems, 1)

	#--

	def RemoveItems() #TODO
		stzraise("Not yet implemented!")

	def RemoveAllItems()
		This.RemoveItems()

	# Helper functions for extracting branch and position from path

	def _GetBranchFromPath(cPath)
		_oPath_ = new stzString(cPath)
		_n_ = _oPath_.FindLast("[")

		_cBranch_ = _oPath_.Section(1, _n_-1)
		return _cBranch_

	def _GetPositionFromPath(cPath)
		_oPath_ = new stzString(cPath)
		_n1_ = _oPath_.FindLast("[")
		_n2_ = _oPath_.NumberOfChars()

		_cPos_ = _oPath_.Section(_n1_+1, _n2_-1)
		return 0+ _cPos_

	#-----------------#
	#  TODO FEATURES  #
	#-----------------#

	# Updating/Replacing Content
	# Moving/Reorganizing Tree Sections
	# Tree Merging and Comparison
	# Advanced Filtering and Searching
	# Serialization/Deserialization

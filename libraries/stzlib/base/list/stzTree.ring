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

# Holds a named tree of nodes and leaf items, and finds, reads and adds nodes and items by name or by path.
#
# It extends stzList. A tree is one named root holding nodes, a node being a name paired with a list
# that may hold items and further nodes: :root = [ :node1 = [ "X", :node11 = [ "A" ] ], :node2 = [
# 1, 2 ] ]. A path names the nodes from the root, as in [:root][:node1], and an item path adds the
# item's position in its node, as in [:root][:node2][1]. Branches and Nodes list them in depth-first
# order, Find methods return paths, and NodeAt and ItemAt read what a path points to. Node names are
# matched without regard to case. Adding goes through AddNodeAt and AddItemAt at the end of a node;
# a path that does not exist changes nothing without any error. Removing goes through RemoveItem,
# RemoveTheseItems and RemoveAllItems: they take every occurrence of an item out of the whole tree,
# at any depth, and leave every node and the root in place (a node may end up empty); an item that is
# absent changes nothing without any error, and removing a node by its name is not written.
# FindTheseItems repeats the last path of an item that occurs several times, and FindThisItem
# answers an empty text.
#
#   receiver   o1 = StzTreeQ(:root = [ :node1 = [ "X", :node11 = [ "A", "B" ] ], :node2 = [ 1, 2, 3
#              ] ])
#   example    ? @@( o1.Branches() )
#              #--> [ "[:root]", "[:root][:node1]", "[:root][:node1][:node11]", "[:root][:node2]" ]
#              ? @@( o1.Node("node2") )
#              #--> [ 1, 2, 3 ]
#              ? @@( o1.FindItem("B") )
#              #--> [ "[:root][:node1][:node11][2]" ]
#              o2 = StzTreeQ(:root = [ :a = [ "שלום", "😀" ], :b = [ "😀" ] ])
#              ? @@( o2.FindItem("😀") )
#              #--> [ "[:root][:a][2]", "[:root][:b][1]" ]
#   see        stzList, stzHashList, stzTreeCanvas
class stzTree from stzList
	
	# Builds a tree from a named root holding nested named nodes and leaf items.
	#
	#   paTree     the tree as one named list, such as :root = [ :node1 = [ "X", 1 ], :node2 = [ 2 ]
	#              ]
	#   returns    nothing; the object is built
	#   note       a node is a name paired with a list; what is not a node inside it is an item; the
	#              tree is held as a one-item list, so Content answers [ tree ]
	#   see        Root, Nodes, Items
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

	# Returns the root entry, the name paired with the whole content below it.
	#
	#   returns    a list [ name, content ]
	#   note       for the sample tree the answer starts with root and holds node1, node2 and node3
	#   see        Branches, Show
	def Root()
		return This.Content()[1]

	  #--------------------------------#
	 #  VISUALIZING THE TREE CONTENT  #
	#--------------------------------#

	# Prints the whole tree as an indented outline, one entry per line.
	#
	#   returns    nothing; it prints
	#   see        Root, Branches
	def Show()
		? @@NL(This.Content()[1])

	  #---------------------#
	 #  MANAGING BRANCHES  #
	#---------------------#

	# Returns the path of every node, the root first, in depth-first order.
	#
	#   returns    a list of text such as [:root][:node1][:node11]
	#   note       AllBranches is the same call; a path is only names, never item positions
	#   see        Nodes, NodesZ, FindNode
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

	# Returns the name of every node, the root first, in depth-first order.
	#
	#   returns    a list of text such as root, node1, node11
	#   note       AllNodes is the same call
	#   see        Branches, TheseNodes
	def Nodes()
		_aResult_ = [ 'root' ]

		_aTree_ = super.Content()[1]
		_aRootContent_ = _aTree_[2]

		This._CollectNodes(_aRootContent_, _aResult_)

		return _aResult_

		def AllNodes()
			return This.Nodes()

	# Returns the content of each named node, in the order asked.
	#
	#   pacNodesNames   the list of node names
	#   returns         a list of lists
	#   note            names are matched without regard to case
	#   warning         an unknown name raises Inexistant node!
	#   see             Node, Nodes
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

	# Returns the path of a node from its name.
	#
	#   pcNodeName   the name of the node, matched without regard to case
	#   returns      a text such as [:root][:node1][:node11]
	#   note         NODE11 finds node11
	#   warning      an unknown name raises Inexistant node! and an empty name raises Can't proceed!
	#   see          FindTheseNodes, Node, Branches
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

	# Returns the content of a node from its name, nested nodes included.
	#
	#   pcNodeName   the name of the node, matched without regard to case
	#   returns      a list, such as [ 1, 2, 3 ] for node2
	#   note         node1 returns its own items together with the whole node11 entry
	#   warning      an unknown name raises Inexistant node!
	#   see          NodeAt, TheseNodes, FindNode
	def Node(pcNodeName)

		_cBranch_ = This.FindNode(pcNodeName)
		_aResult_ = This.NodeAt(_cBranch_)

		return _aResult_

	# Returns the content of the node found at a path, nested nodes included.
	#
	#   pcBranch   the path of the node, such as [:root][:node1][:node11]
	#   returns    a list; an empty text when no node lies at the path
	#   note       the path must start with the root
	#   warning    a path that names no node answers an empty text without any error; a text that is
	#              not a well formed path raises Can't proceed!
	#   see        Node, NodesAt, Branches
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

	# Returns the content of each node found at a list of paths.
	#
	#   pacBranches   the list of node paths
	#   returns       a list of lists
	#   note          an unknown but well formed path adds an empty text
	#   warning       a path that is not well formed raises Can't proceed!
	#   see           NodeAt, TheseNodes
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

	# Returns the path of each named node, in the order the names are given.
	#
	#   pacNodesNames   the list of node names
	#   returns         a list of text
	#   note            node2 then node11 gives the path of node2 and then the path of node11
	#   warning         an unknown name raises Inexistant node!
	#   see             FindNode, Branches
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

	# Returns every leaf item of the tree in document order, node names left out.
	#
	#   returns    a list; repeated items are repeated
	#   note       for the sample tree, 12 items in all, among them X three times; AllItems is the
	#              same call; ItemsCS(0) returns the same list
	#   see        FindItem, Nodes
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

	# Returns the path of every place where an item occurs, each path ending with the item's position in its node.
	#
	#   pItem      the item to look for
	#   returns    a list of text such as [:root][:node1][2]; [ ] when absent
	#   note       X in the sample tree gives three paths; a Hebrew, Arabic or emoji item is matched
	#              whole
	#   warning    the case flag does not widen the search: FindItemCS(x, 0) and FindItem(x) both
	#              answer [ ] while X is present
	#   see        FindItems, ItemAt, FindTheseItems
	def FindItem(pItem)
		return This.FindItemCS(pItem, 1)

		# Searches for an item as FindItem does, but returns an empty text instead of the paths.
		#
		#   pItem      the item to look for
		#   returns    an empty text, since the paths are computed and dropped
		#   note       use FindItem
		#   warning    it lacks a return: the call computes the paths and answers an empty text,
		#              where FindItem answers them
		#   see        FindItem
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
	
	# Returns paths for several items, but repeats the last path of each item as many times as the item occurs.
	#
	#   paItems    the list of items to look for
	#   returns    a list of text with wrong repeats
	#   note       call FindItem once per item
	#   warning    an item that occurs several times gives its LAST path that many times: X, which
	#              has three places, gives [:root][:node3][1] three times, and asking for X and 5
	#              gives that path three times and then [:root][:node3][3]; the cause is an index
	#              taken from the count of paths instead of the loop counter
	#   see        FindItem, FindItems
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

	# Returns the path of every item of the tree, each path ending with its position, grouped by item in order of first appearance.
	#
	#   returns    a list of text, one per item place
	#   note       the sample tree gives 12 paths; each repeated item lists all its places at its
	#              first appearance
	#   see        FindItem, Items, ItemsZ
	def FindItems()
		return This.FindItemsCS(1)

	# Returns the item found at an item path.
	#
	#   pcPath     the path of the item, a node path followed by a position, such as
	#              [:root][:node2][3]
	#   returns    the item
	#   note       FindItem gives the paths this one reads
	#   warning    a node path with no position raises Syntax error!, and a position past the node
	#              raises Array Access (Index out of range) (R2)
	#   see        ItemsAt, FindItem
	#@ aka  --
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

	# Returns the content of the node found at a node path, items and nested nodes.
	#
	#   pcNodePath   the path of the node, such as [:root][:node3]
	#   returns      a list
	#   note         the same answer as NodeAt for a well formed path
	#   warning      a path that is not well formed raises an error
	#   see          ItemAt, NodeAt
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

	# Adds a node at the end of the content of the node found at a path, in place.
	#
	#   paNode     the node to add, a pair of a name and a list
	#   pcBranch   the path of the node that receives it
	#   returns    nothing; the tree changes
	#   note       adding node4 with 7 and 8 at [:root] puts it after node3
	#   warning    a path that is not in Branches changes nothing and raises no error; a node that
	#              is not a name paired with a list raises an error
	#   see        AddItemAt, Branches
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

	
	# Adds an item at the end of the content of the node found at a path, in place.
	#
	#   pItem      the item to add
	#   pcBranch   the path of the node that receives it
	#   returns    nothing; the tree changes
	#   note       adding Z at [:root][:node2] gives 1, 2, 3, Z
	#   warning    a path that is not in Branches changes nothing and raises no error
	#   see        AddNodeAt, Items
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
	
	# Returns how many names a node path holds.
	#
	#   pcBranch   the node path
	#   returns    a number
	#   note       [:root][:node1][:node11] gives 3; CountNodesInBranch is the same call
	#   see        NodesInBranch, LastNodeInBranch
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

	# Returns the names along a node path, each written with its colon.
	#
	#   pcBranch   the node path
	#   returns    a list of text such as :root, :node1, :node11
	#   note       NodesInPath is the same call
	#   warning    the names keep their colon, where Nodes returns them without
	#   see        NthNodeInBranch, NumberOfNodesInBranch
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

	# Returns the name at a rank along a node path, counted from the root.
	#
	#   _n_        the rank of the name, 1 for the root
	#   pcBranch   the node path
	#   returns    a text such as :node1
	#   note       the name keeps its colon
	#   warning    a rank past the last name raises Array Access (Index out of range) (R2)
	#   see        FirstNodeInBranch, LastNodeInBranch, NodesInBranch
	def NthNodeInBranch(_n_, pcBranch)
		if isString(_n_) and isNumber(pcBranch)
			_temp_ = pcBranch
			pcPath = _n_
			_n_ = _temp_
		ok
	
		return This.NodesInBranch(pcBranch)[_n_]

		def NthNodeInPath(_n_, pcBranch)
			return This.NthNodeInBranch(_n_, pcBranch)

	# Returns the first name of a node path, which is the root.
	#
	#   pcBranch   the node path
	#   returns    a text such as :root
	#   note       the name keeps its colon
	#   see        NthNodeInBranch, LastNodeInBranch
	def FirstNodeInBranch(pcBranch)
		return This.NthNodeInBranch(1, pcBranch)

		def FirstNodeInPath(pcBranch)
			return This.FirstNodeInBranch(pcBranch)

	# Returns the last name of a node path, the deepest node.
	#
	#   pcBranch   the node path
	#   returns    a text such as :node11
	#   note       the name keeps its colon
	#   see        NthNodeInBranch, FirstNodeInBranch
	def LastNodeInBranch(pcBranch)
		return This.NthNodeInBranch(This.NumberOfNodesInBranch(pcBranch), pcBranch)

		def LastNodeInPath(pcBranch)
			return This.LastNodeInBranch(pcBranch)


	  #----------------------------#
	 #  REMOVING ITEMS AND NODES  #
	#----------------------------#


	# Takes every occurrence of an item out of the tree, at any depth, in place, with the case rule given.
	#
	#   pItem            the item to take out, a text, a number or a list
	#   pCaseSensitive   1 to match with case, 0 to ignore the case of texts
	#   returns          nothing; the tree changes
	#   note             a node is never an item: removing the text of a node name leaves that node
	#                    where it is, and the root stays; a node left with no item is kept empty; an
	#                    item that is absent changes nothing and raises no error; a number never
	#                    matches a text with the same digits
	#   warning          every occurrence goes, not only the first, as in stzList
	#   see              RemoveItem, RemoveTheseItemsCS, FindItem
	def RemoveItemCS(pItem, pCaseSensitive)
		_aOne_ = []
		_aOne_ + pItem
		This._PruneItems(_aOne_, pCaseSensitive, 0)

		def RemoveThisItemCS(pItem, pCaseSensitive)
			This.RemoveItemCS(pItem, pCaseSensitive)

	# Takes every occurrence of an item out of the tree, leaves at any depth, in place.
	#
	#   pItem      the item to take out, a text, a number or a list
	#   returns    nothing; the tree changes
	#   note       X in the sample tree goes from node1, node11 and node3 at once; nodes and the root
	#              stay, even when emptied; an absent item changes nothing and raises no error
	#   warning    the match is exact on case (RemoveItemCS(x, 0) ignores it) and every occurrence
	#              goes, not only the first
	#   see        RemoveTheseItems, RemoveAllItems, FindItem
	def RemoveItem(pItem)
		_aOne_ = []
		_aOne_ + pItem
		This._PruneItems(_aOne_, 1, 0)

	#--

	# Takes every occurrence of each given item out of the tree, in place, with the case rule given.
	#
	#   paItems          the list of items to take out
	#   pCaseSensitive   1 to match with case, 0 to ignore the case of texts
	#   returns          nothing; the tree changes
	#   note             the tree is walked once, so the order of the items does not matter and an
	#                    empty list changes nothing
	#   warning          a text is not a list of items: it raises Incorrect param type!
	#   see              RemoveTheseItems, RemoveItemCS
	def RemoveTheseItemsCS(paItems, pCaseSensitive)
		if NOT isList(paItems)
			stzraise("Incorrect param type! paItems must be a list.")
		ok

		This._PruneItems(paItems, pCaseSensitive, 0)

	# Takes every occurrence of each given item out of the tree, in place.
	#
	#   paItems    the list of items to take out
	#   returns    nothing; the tree changes
	#   note       the order of the items does not matter; nodes and the root stay; an item that is
	#              absent changes nothing
	#   warning    a text is not a list of items: it raises Incorrect param type!
	#   see        RemoveItem, RemoveAllItems
	def RemoveTheseItems(paItems)
		if NOT isList(paItems)
			stzraise("Incorrect param type! paItems must be a list.")
		ok

		This._PruneItems(paItems, 1, 0)

	# Empties the tree of its items, in place, and keeps every node and the root.
	#
	#   returns    nothing; the tree changes
	#   note       Items answers an empty list afterwards while Branches and Nodes answer what they
	#              did; items can be added again at once; RemoveAllItems is the same call
	#   see        RemoveAllItems, RemoveItem
	#@ aka  --
	def RemoveItems()
		_aNone_ = []
		This._PruneItems(_aNone_, 1, 1)

	# Strips every item from the tree, in place, while every node and the root stay where they were.
	#
	#   returns    nothing; the tree changes
	#   note       nodes that held items stay as empty nodes, so AddItemAt works on them again
	#   see        RemoveItems, RemoveItem
	def RemoveAllItems()
		_aNone_ = []
		This._PruneItems(_aNone_, 1, 1)

	# An internal method used by the removals: rebuilds the content without the matching items.

	def _PruneItems(paItems, pCaseSensitive, pbAll)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		_bCaseOk_ = 0
		if isNumber(pCaseSensitive)
			if pCaseSensitive = 0 or pCaseSensitive = 1
				_bCaseOk_ = 1
			ok
		ok

		if _bCaseOk_ = 0
			stzraise("Incorrect param type! pCaseSensitive must be 1 or 0.")
		ok

		_aKeys_ = []
		_nLenItems_ = len(paItems)
		for i = 1 to _nLenItems_
			_aKeys_ + This._ItemKey(paItems[i], pCaseSensitive)
		next

		_aNew_ = This._Content()
		_aNew_[1][2] = This._PruneContent(_aNew_[1][2], _aKeys_, pCaseSensitive, pbAll)
		This._SetContent(_aNew_)

	# An internal method used by the removals: the key of an item is its kind and a comparable value.

	def _ItemKey(pItem, pCaseSensitive)
		if isNumber(pItem)
			return [ "n", pItem ]
		ok

		if isString(pItem)
			if pCaseSensitive = 0
				return [ "s", StzLower(pItem) ]
			ok
			return [ "s", pItem ]
		ok

		if isList(pItem)
			_cList_ = @@(pItem)
			if pCaseSensitive = 0
				_cList_ = StzLower(_cList_)
			ok
			return [ "l", _cList_ ]
		ok

		return [ "x", "" ]

	# An internal method used by the removals: copies a node content without the matching items, and
	# walks into nested nodes the way Items does (a node is a list of 2 or more starting with a text).

	def _PruneContent(paContent, paKeys, pCaseSensitive, pbAll)
		_aOut_ = []
		_nLenContent_ = len(paContent)
		_nLenKeys_ = len(paKeys)

		for i = 1 to _nLenContent_
			_bNode_ = 0
			if isList(paContent[i])
				if len(paContent[i]) >= 2
					if isString(paContent[i][1])
						_bNode_ = 1
					ok
				ok
			ok

			if _bNode_ = 1
				_aNode_ = paContent[i]
				if isList(_aNode_[2])
					_aNode_[2] = This._PruneContent(_aNode_[2], paKeys, pCaseSensitive, pbAll)
				ok
				_aOut_ + _aNode_
				loop
			ok

			# a leaf item: kept unless it matches

			_bGo_ = pbAll
			if _bGo_ = 0
				_aKey_ = This._ItemKey(paContent[i], pCaseSensitive)
				if _aKey_[1] != "x"
					for j = 1 to _nLenKeys_
						if _aKey_[1] = paKeys[j][1]
							if _aKey_[1] = "n"
								if _aKey_[2] = paKeys[j][2]
									_bGo_ = 1
									exit
								ok
							else
								if strcmp(_aKey_[2], paKeys[j][2]) = 0
									_bGo_ = 1
									exit
								ok
							ok
						ok
					next
				ok
			ok

			if _bGo_ = 0
				_aOut_ + paContent[i]
			ok
		next

		return _aOut_

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

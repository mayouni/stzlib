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

	bResult = _TRUE_

	nLen = len(pacList)
	for i = 1 to nLen
		if NOT IsValidNodePath(pacList[i])
			bResult = _FALSE_
			exit
		ok
	next

	return bResult

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

	bResult = _TRUE_

	nLen = len(pacList)
	for i = 1 to nLen
		if NOT IsValidItemPath(pacList[i])
			bResult = _FALSE_
			exit
		ok
	next

	return bResult

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

		aTemp = []
		aTemp + paTree

		super.init(aTemp)

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
		aResult = [ '[:root]' ]

		aTree = super.Content()[1]

		aRootContent = aTree[2]
		This._CollectBranches("[:root]", aRootContent, aResult)
    
		return aResult

		def AllBranches()
			return This.Branches()

	def _CollectBranches(cCurrentPath, paContent, aResult)
		nLen = len(paContent)

		for i = 1 to nLen
			item = paContent[i]
        
			# Skip if item is not a list

			if NOT isList(item)
				loop
			ok
        
			nLenItem = len(item)

			# Process branch entries - they're lists
			# with string as first element

			if nLenItem >= 2 and isString(item[1])

				cBranchName = item[1]
				cBranchPath = cCurrentPath + "[:" + cBranchName + "]"
				aResult + cBranchPath

				# Process subbranches if exists

				if nLenItem >= 2 and isList(item[2])
					This._CollectBranches(cBranchPath, item[2], aResult)
				ok
			ok
		next

	  #------------------#
	 #  MANAGING NODES  #
	#------------------#

	def Nodes()
		aResult = [ 'root' ]

		aTree = super.Content()[1]
		aRootContent = aTree[2]

		This._CollectNodes(aRootContent, aResult)

		return aResult

		def AllNodes()
			return This.Nodes()

	def TheseNodes(pacNodesNames)

		if CheckParams()
			if NOT (isList(pacNodesNames) and @IsListOfStrings(pacNodesNames))
				stzraise("Incorrect param type! pacNodesNames must be a list of strings.")
			ok
		ok

		aResult = []
		nLen = len(pacNodesNames)

		for i = 1 to nLen
			aResult + This.Node(pacNodesNames[i])
		next

		return aResult

	def _CollectNodes(paContent, aResult)
		nLenContent = len(paContent)

		for i = 1 to nLenContent
			item = paContent[i]

			# Skip if item is not a list

			if NOT isList(item)
				loop
			ok

			nLenItem = len(item)

			# Process branch entries - they're lists
			# with string as first element

			if nLenItem >= 2 and isString(item[1])
				cNodeName = item[1]
				aResult + cNodeName

				# Process subnodes if exists

				if nLenItem >= 2 and isList(item[2])
					This._CollectNodes(item[2], aResult)
				ok
			ok
		next

	def NodesXT()
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

		pcNodeName = lower(pcNodeName)
		cResult = This.NodesXT()[pcNodeName]

		if cResult = ""
			stzraise("Inexistant node!")
		ok

		return cResult

	def Node(pcNodeName)

		cBranch = This.FindNode(pcNodeName)
		aResult = This.NodeAt(cBranch)

		return aResult

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

		nLen = len(pacBranches)
		aResult = []

		for i = 1 to nLen
			aResult + This.NodeAt(pacBranches[i])
		next

		return aResult

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
	
	def Items()
		aResult = []
		aTree = super.Content()[1]
		aRootContent = aTree[2]
		
		This._CollectItems(aRootContent, aResult)
		
		return aResult

		def AllItems()
			return This.Items()

	def _CollectItems(paContent, aResult)
		nLenContent = len(paContent)
    
		for i = 1 to nLenContent
			item = paContent[i]
        
			# If the item is not a list or it's
			# a simple value, it's an item in the tree semantic

			if NOT isList(item) OR (isList(item) AND len(item) = 0)
				aResult + item
				loop
			ok

			# If it is a list but not a branch
			# (doesn't have a string as first element)

			if isList(item) AND (len(item) < 2 OR NOT isString(item[1]))
				aResult + item
				loop
			ok
        
			# If it's a branch, check its contents

			if isList(item) AND len(item) >= 2 AND isString(item[1])
				# Only process the contents if it's a list
				if len(item) >= 2 AND isList(item[2])
					This._CollectItems(item[2], aResult)
				ok
			ok
		next
	
	def ItemsXTCS(pCaseSensitive)
		aItems = This.Items()
		aItemBranches = []
		
		for i = 1 to len(aItems)
			aItemBranches + []
		next
		
		aTree = super.Content()[1]
		aRootContent = aTree[2]
		
		This._MapItemsToBranchesCS(aRootContent, "[:root]", aItems, aItemBranches, pCaseSensitive)
		
		aResult = []
		for i = 1 to len(aItems)
			aResult + [ aItems[i], aItemBranches[i] ]
		next
		
		return aResult

		#< @FunctionAlternativeForms

		def ItemsAndTheirBranchesCS(pCaseSensitive)
			return This.ItemsXTCS(pCaseSensitive)

		#>

	def ItemsXT()
		return This.ItemsXTCS(_TRUE_)

		def ItemsAndTheirBranches()
			return This.ItemsXT()

	def _MapItemsToBranchesCS(paContent, cCurrentPath, aItems, aItemBranches, pCaseSensitive)
		nLenContent = len(paContent)
		
		for i = 1 to nLenContent
			item = paContent[i]
			
			# If the item is not a list or it's a simple value, then take it
			if NOT isList(item) OR (isList(item) AND len(item) = 0)
				nPos = StzListQ(aItems).FindFirstCS(item, pCaseSensitive)
				if nPos > 0
					aItemBranches[nPos] + cCurrentPath
				ok
				loop
			ok
			
			# If it is a list but not a branch (doesn't have a string as first element)
			if isList(item) AND (len(item) < 2 OR NOT isString(item[1]))

				nPos = StzListQ(aItems).FindFirstCS(item, pCaseSensitive)
				if nPos > 0
					aItemBranches[nPos] + cCurrentPath
				ok
				loop
			ok
			
			# If it's a branch, check its contents
			if isList(item) AND len(item) >= 2 AND isString(item[1])
				cBranchName = item[1]
				cBranchPath = cCurrentPath + "[:"+cBranchName+"]"
				
				# Only process the contents if it's a list
				if len(item) >= 2 AND isList(item[2])
					This._MapItemsToBranchesCS(item[2], cBranchPath, aItems, aItemBranches, pCaseSensitive)
				ok
			ok
		next

	def _MapItemsToBranches(paContent, cCurrentPath, aItems, aItemBranches)
		return This._MapItemsToBranchesCS(paContent, cCurrentPath, aItems, aItemBranches, _TRUE_)

	  #-----------------#
	 #  FINDING ITEMS  #
	#-----------------#

	def FindItemCS(pItem, pCaseSensitive)
		aResult = []
		aItemsAndBranches = This.ItmesXTCS(pCaseSensitive)
		
		for i = 1 to len(aItemsAndBranches)
			if aItemsAndBranches[i][1] = pItem
				aBranches = aItemsAndBranches[i][2]
				aPositions = This._FindItemPositionsAt(pItem, aBranches, pCaseSensitive)
				
				for j = 1 to len(aBranches)
					# Concatenate branch path with position directly
					if aPositions[j] != ""
						aResult + (aBranches[j] + aPositions[j])
					ok
				next
				
				exit
			ok
		next
		
		return aResult

	def FindItem(pItem)
		return This.FindItemCS(pItem, _TRUE_)
	
	# Helper function to find positions of an item in multiple branches

	def _FindItemPositionsAt(pItem, paBranches, pCaseSensitive)
		aPositions = []
		
		for i = 1 to len(paBranches)
			aNodeContent = This.Branch(paBranches[i])
			nPos = 0
			
			for j = 1 to len(aNodeContent)
				if pCaseSensitive = _TRUE_
					if aNodeContent[j] = pItem
						nPos = j
						exit
					ok
				else
					if lower(aNodeContent[j]) = lower(pItem)
						nPos = j
						exit
					ok
				ok
			next
			
			# Return the position as "[n]" instead of just "n"
			if nPos > 0
				aPositions + ("[" + nPos + "]")
			else
				aPositions + ""
			ok
		next
		
		return aPositions
	
	# Helper function to find position of an item in a specific branch

	def _FindItemPositionAt(pItem, pcBranch, pCaseSensitive)
		aNodeContent = This.Branch(pcBranch)
		nPos = 0
		
		for i = 1 to len(aNodeContent)
			if pCaseSensitive = _TRUE_
				if aNodeContent[i] = pItem
					nPos = i
					exit
				ok
			else
				if lower(aNodeContent[i]) = lower(pItem)
					nPos = i
					exit
				ok
			ok
		next
		
		# Return the position as "[n]" instead of just "n"
		if nPos > 0
			return "[" + nPos + "]"
		else
			return ""
		ok

	#--

	def FindItemsCS(paItems, pCaseSensitive)
		aResult = []
		
		for i = 1 to len(paItems)
			aBranchesWithPos = This.FindItemCS(paItems[i], pCaseSensitive)
			aResult + aBranchesWithPos
		next
		
		return aResult
	
	def FindItems(paItems)
		return This.FindItemsCS(paItems, _TRUE_)

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

		cCode = "result = This.Content()" + pcPath
		eval(cCode)
		return result

	def ItemsAt(pcNodePath)
		if NOT @IsValidNodePath(pcNodePath)
			stzraise("Incorrect param! pcNodePath is not a valid node path.")
		ok

		cCode = 'aResult = This.Content()' + pcNodePath
		eval(cCode)
		return aResult

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
		if NOT ring_find(This.Branches(), pcBranch) > 0
			return
		ok

		_cNodeName_ = paNode[1]
		_aNodeContent_ = paNode[2]

		cCode = 'This.Content()' + pcBranch + ' + [ _cNodeName_, _aNodeContent_ ]'
		eval(cCode)

	
	def AddItemAt(pItem, pcBranch)
		if CheckParams()
			if NOT isString(pcBranch)
				stzRaise("Can't add item! pcBranch must be a string.")
			ok
		ok
		
		# Check if branch exists
		if NOT ring_find(This.Branches(), pcBranch) > 0
			return
		ok
		
		cCode = 'This.Content()' + pcBranch + ' + pItem'
		eval(cCode)

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
			_acSplits_[1] = ring_substr2(_acSplits_[1], "[", "")
			_acSplits_[1] = ring_substr2(_acSplits_[1], "]", "")
		ok
	
		if _nLen_ > 1
			_acSplits_[_nLen_] = ring_substr2(_acSplits_[_nLen_], "]", "")
		ok
	
		return _acSplits_

		def NodesInPath(pcBranch)
			return This.NodesInBranch(pcBranch)

	def NthNodeInBranch(n, pcBranch)
		if isString(n) and isNumber(pcBranch)
			temp = pcBranch
			pcPath = n
			n = temp
		ok
	
		return This.NodesInBranch(pcBranch)[n]

		def NthNodeInPath(n, pcBranch)
			return This.NthNodeInBranch(n, pcBranch)

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

	def RemoveItems()
		super.DeepRemoveMany(This.Items())

	#-----------------#
	#  TODO FEATURES  #
	#-----------------#

	# Updating/Replacing Content
	# Moving/Reorganizing Tree Sections
	# Tree Merging and Comparison
	# Advanced Filtering and Searching
	# Serialization/Deserialization

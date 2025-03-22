# stzTree - Softanza Tree Class
# Extending stzList to provide tree-specific capabilities


func StzTreeQ(paTree)
	return new stzTree(paTree)

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

	  #--------------------------------#
	 #  VISUALIZING THE TREE CONTENT  #
	#--------------------------------#

	def Show()
		? @@NL(This.Content()[1])

	  #---------------------#
	 #  MANAGING BRANCHES  #
	#---------------------#

	def Branch(pcBranch)
		if pcBranch = ""
			return
		ok

		_cCode_ = '_aResult_ = This.Content()' + pcBranch
		eval(_cCode_)

		return _aResult_

	def Branches()
		aResult = [ '[:root]' ]

		aTree = super.Content()[1]

		aRootContent = aTree[2]
		This._CollectBranches("[:root]", aRootContent, aResult)
    
		return aResult

	def _CollectBranches(cCurrentPath, paContent, aResult)
		nLen = len(paContent)

		for i = 1 to nLen
			item = paContent[i]
        		nLenItem = len(item)

			# Process branch entries - they're lists with string as first element
			if isList(item) and nLenItem >= 2 and isString(item[1])
				cBranchName = item[1]
				cBranchPath = cCurrentPath + "[:"+cBranchName+"]"
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

	def _CollectNodes(paContent, aResult)

		nLenContent = len(paContent)

		for i = 1 to nLenContent

			item = paContent[i]
			nLenItem = len(item)

			# Process branch entries - they're lists
			# with string as first element

			if isList(item) and nLenItem >= 2 and isString(item[1])

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

	def FindNode(pcNode)
		return This.NodesXT()[pcNode]

	def Node(pcNode)
		return This.Branch(This.FindNode(pcNode))

	def NodeAt(pcBranch)
		return This.Branch(pcBranch)

	def FindNodes(pacNodes)

		_acNodes_ = U(pacNodes)
		_nLen_ = len(_acNodes_)
		_acResult_ = [] // Branches

		for @i = 1 to _nLen_
			_acResult_ + This.FindNode(_acNodes_[@i])
		next

		return _acResult_

	  #------------------#
	 #  MANAGING LEAFS  #
	#------------------#
	
	def Leafs()
		aResult = []
		aTree = super.Content()[1]
		aRootContent = aTree[2]
		
		This._CollectLeafs(aRootContent, aResult)
		
		return aResult

		def Items()
			return This.Leafs()

	def _CollectLeafs(paContent, aResult)
		nLenContent = len(paContent)
		
		for i = 1 to nLenContent
			item = paContent[i]
			
			# If the item is not a list or it's a simple value, it's a leaf
			if NOT isList(item) OR (isList(item) AND len(item) = 0)
				aResult + item
				loop
			ok
			
			# If it's a list but not a branch (doesn't have a string as first element)
			if isList(item) AND (len(item) < 2 OR NOT isString(item[1]))
				aResult + item
				loop
			ok
			
			# If it's a branch, check its contents
			if isList(item) AND len(item) >= 2 AND isString(item[1])
				# Only process the contents if it's a list
				if len(item) >= 2 AND isList(item[2])
					This._CollectLeafs(item[2], aResult)
				ok
			ok
		next
	
	def LeafsXTCS(pCaseSensitive)
		aLeafs = This.Leafs()
		aLeafBranches = []
		
		for i = 1 to len(aLeafs)
			aLeafBranches + []
		next
		
		aTree = super.Content()[1]
		aRootContent = aTree[2]
		
		This._MapLeafsToBranchesCS(aRootContent, "[:root]", aLeafs, aLeafBranches, pCaseSensitive)
		
		aResult = []
		for i = 1 to len(aLeafs)
			aResult + [ aLeafs[i], aLeafBranches[i] ]
		next
		
		return aResult

		#< @FunctionAlternativeForms

		def LeafsAndTheirBranchesCS(pCaseSensitive)
			return This.LeafsXTCS(pCaseSensitive)

		def ItemsXTCS(pCaseSensitive)
			return This.LeafsXTCS(pCaseSensitive)

		def ItemsAndTheirBranchesCS(pCaseSensitive)
			return This.LeafsXTCS(pCaseSensitive)

		#>

	def LeafsXT()
		return This.LeafsXTCS(_TRUE_)

		def LeafsAndTheirBranches()
			return This.LeafsXT()
	
		def ItemsXT()
			return This.LeafsXT()

		def ItemsAndTheirBranches()
			return This.LeafsXT()

	def _MapLeafsToBranchesCS(paContent, cCurrentPath, aLeafs, aLeafBranches, pCaseSensitive)
		nLenContent = len(paContent)
		
		for i = 1 to nLenContent
			item = paContent[i]
			
			# If the item is not a list or it's a simple value, it's a leaf
			if NOT isList(item) OR (isList(item) AND len(item) = 0)
				nPos = StzListQ(aLeafs).FindFirstCS(item, pCaseSensitive)
				if nPos > 0
					aLeafBranches[nPos] + cCurrentPath
				ok
				loop
			ok
			
			# If it's a list but not a branch (doesn't have a string as first element)
			if isList(item) AND (len(item) < 2 OR NOT isString(item[1]))

				nPos = StzListQ(aLeafs).FindFirstCS(item, pCaseSensitive)
				if nPos > 0
					aLeafBranches[nPos] + cCurrentPath
				ok
				loop
			ok
			
			# If it's a branch, check its contents
			if isList(item) AND len(item) >= 2 AND isString(item[1])
				cBranchName = item[1]
				cBranchPath = cCurrentPath + "[:"+cBranchName+"]"
				
				# Only process the contents if it's a list
				if len(item) >= 2 AND isList(item[2])
					This._MapLeafsToBranchesCS(item[2], cBranchPath, aLeafs, aLeafBranches, pCaseSensitive)
				ok
			ok
		next

	def _MapLeafsToBranches(paContent, cCurrentPath, aLeafs, aLeafBranches)
		return This._MapLeafsToBranchesCS(paContent, cCurrentPath, aLeafs, aLeafBranches, _TRUE_)

	#--

	def FindLeafCS(pLeaf, pCaseSensitive)
		aResult = []
		aLeafsAndBranches = This.LeafsXTCS(pCaseSensitive)
		
		for i = 1 to len(aLeafsAndBranches)
			if aLeafsAndBranches[i][1] = pLeaf
				aResult = aLeafsAndBranches[i][2]
				exit
			ok
		next
		
		return aResult

		def FindItemCS(pLeaf, pCaseSensitive)
			return This.FindLeafCS(pLeaf, pCaseSensitive)

	def FindLeaf(pLeaf)
		return This.FindLeafCS(pLeaf, _TRUE_)

		def FindItem(pLeaf)
			return This.FindLeaf(pLeaf)

	#--

	def FindLeafsCS(paLeafs, pCaseSensitive)
		aResult = []
		
		for i = 1 to len(paLeafs)
			aResult + This.FindLeafCS(paLeafs[i], pCaseSensitive)
		next
		
		return aResult

		def FindItemsCS(paLeafs, pCaseSensitive)
			return This.FindLeafsCS(paLeafs, pCaseSensitive)

	def FindLeafs(paLeafs)
		return This.FindLeafsCS(paLeafs, _TRUE_)

		def FindItems(paLeafs)
			return This.FindLeafs(paLeafs)

	def LeafsAt(pcBranch)
		return This.Branch(pcBranch)

		def ItemsAt(pcBranch)
			return This.LeafsAt(pcBranch)

	  #--------------------------#
	 #  ADDING NODES AND LEAFS  #
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
			return FALSE
		ok

		_cNodeName_ = paNode[1]
		_aNodeContent_ = paNode[2]

		cCode = 'This.Content()' + pcBranch + ' + [ _cNodeName_, _aNodeContent_ ]'
		eval(cCode)

	
	def AddLeafAt(pItem, pcBranch)
		if CheckParams()
			if NOT isString(pcBranch)
				stzRaise("Can't add leaf! pcBranch must be a string.")
			ok
		ok
		
		# Check if branch exists
		if NOT ring_find(This.Branches(), pcBranch) > 0
			return FALSE
		ok
		
		cCode = 'This.Content()' + pcBranch + ' + pItem'
		eval(cCode)

  #-----------------------------#
 #  GEETING NODES FROM A PATH  #
#-----------------------------#

def NumberOfNodesInPath(pcPath)
	return len( @split(pcPath, "]["))

	def CountNodesInPath(pcPath)
		return THis.NumberOfNodesInPath(pcPath)

	def HowManyNodesInPath(pcPath)
		return THis.NumberOfNodesInPath(pcPath)

def NodesInPath(pcPath)

	_acSplits_ = @split(pcPath, "][")
	_nLen_ = len(_acSplits_)

	if _nLen_ > 0
		_acSplits_[1] = ring_substr2(_acSplits_[1], "[", "")
		_acSplits_[1] = ring_substr2(_acSplits_[1], "]", "")
	ok

	if _nLen_ > 1
		_acSplits_[_nLen_] = ring_substr2(_acSplits_[_nLen_], "]", "")
	ok

	return _acSplits_

def NthNodeInPath(n, pcPath)
	if isString(n) and isNumber(pcPath)
		temp = pcPath
		pcPath = n
		n = temp
	ok

	return This.NodesInPath(pcPath)[n]

def FirstNodeInPath(pcPath)
	return This.NthNodeInPath(1, pcPath)

def LastNodeInPath(pcPath)
	return This.NthNodeInPath(This.NumberOfNodesInPath(pcPath), pcPath)

  #----------------------------#
 #  REMOVING NODES AND LEAFS  #
#----------------------------#

def RemoveNode(pcNode)
	This.RemoveNodeAt(FindNode(pcNode))

def RemoveNodeAt(pcNodePath)
	if CheckParams()
		if NOT isString(pcNodePath)
			stzRaise("Can't remove node! pcNodePath must be a string.")
		ok
	ok
    
	_cNode_ = @Simplify( @@([ This.LastNodeInPath(pcNodePath), This.NodeAt(pcNodePath) ]) )
	_cNode_ = ring_substr2(_cNode_, ":", "")

	_cTree_ = @Simplify( @@(This.Content()) )

	_cTree_ = ring_substr2(_cTree_, _cNode_, "")
	_cTree_ = ring_substr2(_cTree_, ", ,", ",")

	_cCode_ = 'This.UpdateWith(' + _cTree_ + ')'

	eval(_cCode_)

def RemoveLeaf(pLeaf)

	This.RemoveItem()

def RemoveLeafAt(pLeaf, pcBranchPath)
	if CheckParams()
		if NOT isString(pcBranchPath)
			stzRaise("Can't remove leaf! pcBranchPath must be a string.")
		ok
	ok

def RemoveLeafs(paLeafs)

def RemoveLeafsAt(paLeafs, pcBranchPath)

/*
  #-----------------------------#
 #  REPLACING NODES AND LEAFS  #
#-----------------------------#

def ReplaceNode(pcNode, paNewNode)
	This.ReplaceNodeAt(This.FindNode(pcNode), paNewNode)

def ReplaceNodeAt(pcNodePath, paNewNode)
	if CheckParams()
		if NOT isString(pcNodePath)
			stzRaise("Can't replace node! pcNodePath must be a string.")
		ok
		
		if NOT ( isList(paNewNode) and len(paNewNode) = 2 and
		         isString(paNewNode[1]) and isList(paNewNode[2]) )
			stzRaise("Incorrect param! paNewNode is not a valid node.")
		ok
	ok
	
	# Check if node exists
	if NOT ring_find(This.Branches(), pcNodePath) > 0
		return FALSE
	ok
	
	# Get parent branch path and node name
	oNodePath = new stzString(pcNodePath)
	nLastOpenBracket = oNodePath.FindLast("[")
	nLastCloseBracket = oNodePath.FindLast("]")
	
	if nLastOpenBracket <= 0 OR nLastCloseBracket <= 0
		return FALSE
	ok
	
	cParentPath = oNodePath.Left(nLastOpenBracket - 1)
	
	if cParentPath = ""
		cParentPath = "[:root]"
	ok
	
	# Remove the node first
	This.RemoveNodeAt(pcNodePath)
	
	# Add the new node
	return This.AddNodeAt(paNewNode, cParentPath)

def ReplaceLeaf(pOldLeaf, pNewLeaf)
	This.DeepReplace(pOldLeaf, pNewLeaf)

	def ReplaceItem(pOldLeaf, pNewLeaf)
		This.ReplaceLeaf(pOldLeaf, pNewLeaf)

def ReplaceLeafAt(pOldLeaf, pNewLeaf, pcBranchPath)
	if CheckParams()
		if NOT isString(pcBranchPath)
			stzRaise("Can't replace leaf! pcBranchPath must be a string.")
		ok
	ok
	
	# Check if branch exists
	if NOT ring_find(This.Branches(), pcBranchPath) > 0
		return FALSE
	ok
	
	# Get the branch content
	aBranchContent = This.Branch(pcBranchPath)
	
	# Find the leaf
	nPos = 0
	for i = 1 to len(aBranchContent)
		if Q(aBranchContent[i]).IsEqualTo(pOldLeaf)
			nPos = i
			exit
		ok
	next
	
	if nPos = 0
		return FALSE
	ok
	
	# Replace the leaf
	cCode = 'This.Content()' + pcBranchPath + '[' + nPos + '] = pNewLeaf'
	eval(cCode)
	return TRUE

	def ReplaceItemAt(pOldLeaf, pNewLeaf, pcBranchPath)
		This.ReplaceLeafAt(pOldLeaf, pNewLeaf, pcBranchPath)


def ReplaceLeafs(paOldLeafs, paNewLeafs)
	This.DeepReplace(paOldLeafs, pNewLeaf)

	def ReplaceItems(paOldLeafs, paNewLeafs)
		This.ReplaceLeaf(paOldLeafs, paNewLeafs)

def ReplaceLeafsAt(paOldLeafs, paNewLeafs, pcBranchPath)
	if CheckParams()
		if NOT (isList(paOldLeafs) and isList(paNewLeafs))
			stzRaise("Can't replace leafs! Both paOldLeafs and paNewLeafs must be lists.")
		ok
		
		if NOT isString(pcBranchPath)
			stzRaise("Can't replace leafs! pcBranchPath must be a string.")
		ok
		
		if len(paOldLeafs) != len(paNewLeafs)
			stzRaise("Can't replace leafs! Both lists must have the same length.")
		ok
	ok
	
	# Check if branch exists
	if NOT ring_find(This.Branches(), pcBranchPath) > 0
		return FALSE
	ok
	
	nSuccess = 0
	for i = 1 to len(paOldLeafs)
		if This.ReplaceLeafAt(paOldLeafs[i], paNewLeafs[i], pcBranchPath)
			nSuccess++
		ok
	next
	
	return nSuccess

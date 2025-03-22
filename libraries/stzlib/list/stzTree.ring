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
        
			# If the item is not a list or it's
			# a simple value, it's a leaf

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
			
			# If it is a list but not a branch (doesn't have a string as first element)
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
			aBranches = aLeafsAndBranches[i][2]
			aPositions = This._FindLeafPositionsAt(pLeaf, aBranches, pCaseSensitive)
			
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

def FindLeaf(pLeaf)
	return This.FindLeafCS(pLeaf, _TRUE_)

	def FindItem(pLeaf)
		return This.FindLeaf(pLeaf)

# Helper function to find positions of an item in multiple branches
def _FindLeafPositionsAt(pLeaf, paBranches, pCaseSensitive)
	aPositions = []
	
	for i = 1 to len(paBranches)
		aNodeContent = This.Branch(paBranches[i])
		nPos = 0
		
		for j = 1 to len(aNodeContent)
			if pCaseSensitive = _TRUE_
				if aNodeContent[j] = pLeaf
					nPos = j
					exit
				ok
			else
				if lower(aNodeContent[j]) = lower(pLeaf)
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
def _FindLeafPositionAt(pLeaf, pcBranch, pCaseSensitive)
	aNodeContent = This.Branch(pcBranch)
	nPos = 0
	
	for i = 1 to len(aNodeContent)
		if pCaseSensitive = _TRUE_
			if aNodeContent[i] = pLeaf
				nPos = i
				exit
			ok
		else
			if lower(aNodeContent[i]) = lower(pLeaf)
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

def FindLeafsCS(paLeafs, pCaseSensitive)
	aResult = []
	
	for i = 1 to len(paLeafs)
		aBranchesWithPos = This.FindLeafCS(paLeafs[i], pCaseSensitive)
		aResult + aBranchesWithPos
	next
	
	return aResult

	def FindItemsCS(paLeafs, pCaseSensitive)
		return This.FindLeafsCS(paLeafs, pCaseSensitive)

def FindLeafs(paLeafs)
	return This.FindLeafsCS(paLeafs, _TRUE_)

	def FindItems(paLeafs)
		return This.FindLeafs(paLeafs)

#--

	def LeafsAt(pcBranch)
		return This.Branch(pcBranch)

		def ItemsAt(pcBranch)
			return This.LeafsAt(pcBranch)
	def LeafsInNode(pcNode)
		return This.Node(pcNode)

		def ItemsInNode(pcNode)
			return This.Node(pcNode)

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
	 #  REMOVING NODES AND LEAFS  #
	#----------------------------#
	
	def RemoveNode(pcNode)
		This.RemoveNodeAt(This.FindNode(pcNode))
	
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
	
	def RemoveTheseNodes(pacNodes)
		This.RemoveNodesAt(This.FindNodes(pacNodes))

	def RemoveNodesAt(pacNodePaths)
		nLen = len(pacNodePaths)
		for i = 1 to nLen
			This.RemoveNodeAt(pacNodePaths[i])
		next

	def RemoveNodes()
		This.UpdateWith([ :root = [] ])

		def RemoveAllNodes()
			This.RemoveNodes()

	#==
	
	def RemoveLeafCS(pLeaf, pCaseSensitive)
		This.RemoveItemCS(pLeaf, pCaseSensitive)
	
		def RemoveItemCS(pLeaf, pCaseSensitive)
			This.DeepRemoveCS(pLeaf, pCaseSensitive)

	def RemoveLeaf(pLeaf)
		RemoveLeafCS(pLeaf, _TRUE_)
	
		def RemoveItem(pLeaf)
			This.DeepRemove(pLeaf)

	#--

	def RemoveLeafInNodeCS(pLeaf, pcNode, pCaseSensitive)
		This.RemoveLeafAtCS(pLeaf, This.FindNode(pcNode), pCaseSensitive)
	
		def RemoveItemInNodeCS(pLeaf, pcNode, pCaseSensitive)
			This.RemoveLeafInNodeCS(pLeaf, pcNode, pCaseSensitive)

	def RemoveLeafInNode(pLeaf, pcNode)
		This.RemoveLeafInNodeCS(pLeaf, pcNode, _TRUE_)
	
		def RemoveItemInNode(pLeaf, pcNode)
			This.RemoveLeafInNode(pLeaf, pcNode)
	#--

def RemoveLeafAtCS(pLeaf, pcBranchPath, pCaseSensitive)
	# Extract branch path and position
	nPosStart = ring_find_last(pcBranchPath, "[")
	nPosEnd = ring_find_last(pcBranchPath, "]")
	
	# Check if the path includes a position at the end
	if nPosStart > 0 and nPosEnd = len(pcBranchPath)
		# Get position number
		cPosition = substr(pcBranchPath, nPosStart + 1, nPosEnd - nPosStart - 1)
		if isNumber(cPosition)
			nPos = number(cPosition)
			
			# Get branch path without position
			cBranchPath = substr(pcBranchPath, 1, nPosStart - 1)
			
			# Get node content
			aNodeContent = This.Branch(cBranchPath)
			
			# Check if position is valid
			if nPos > 0 and nPos <= len(aNodeContent)
				# Remove the item at the specified position
				aNodeContent = del(aNodeContent, nPos)
				
				# Update the node
				_cNodeName_ = This.LastNodeInBranch(cBranchPath)
				_cNode1_ = @Simplify( @@([ _cNodeName_, This.Branch(cBranchPath) ]) )
				_cNode2_ = @Simplify( @@([ _cNodeName_, aNodeContent ]) )
				_cTree_ = @Simplify( @@(This.Content()) )
				
				_cNode1_ = ring_substr2(_cNode1_, ":", "")
				_cNode2_ = ring_substr2(_cNode2_, ":", "")
				_cTree_ = ring_substr2(_cTree_, _cNode1_, _cNode2_)
				
				_cCode_ = 'This.UpdateWith(' + _cTree_ + ')'
				eval(_cCode_)
				
				return
			ok
		ok
	ok
	
	# If no position specified or invalid format, use the original method
	# Preparing the stringified data elements
	_cNodeName_ = This.LastNodeInBranch(pcBranchPath)
	_aNodeContent_ = This.NodeAt(pcBranchPath)
	_cNode1_ = @Simplify( @@([ _cNodeName_, _aNodeContent_ ]) )
	
	_aNodeContent2_ = StzListQ(This.NodeAt(pcBranchPath)).RemoveQ(pLeaf).Content()
	_cNode2_ = @Simplify( @@([ _cNodeName_, _aNodeContent2_ ]) )
	
	_cTree_ = @Simplify( @@(This.Content()) )
	
	# Managing case sensitivity
	if CaseSensitive(pCaseSensitive) = FALSE
		_cNode1_ = lower(_cNode1_)
		_cNode2_ = lower(_cNode2_)
		_cTree_  = lower(_cTree_)
	ok
	
	# Processing the removal
	_cNode1_ = ring_substr2(_cNode1_, ":", "")
	_cNode2_ = ring_substr2(_cNode2_, ":", "")
	_cTree_ = ring_substr2(_cTree_, _cNode1_, _cNode2_)
	
	# Updating the tree (by evaluation)
	_cCode_ = 'This.UpdateWith(' + _cTree_ + ')'
	eval(_cCode_)

	def RemoveItemAtCS(pItem, pcBranchPath, pCaseSensitive)
		return This.RemoveLeafAtCS(pItem, pcBranchPath, pCaseSensitive)

	#--

	def RemoveTheseLeafsCS(paLeafs, pCaseSensitive)
		nLen = len(paLeafs)
	
		for i = 1 to nLen
			This.RemoveLeafCS(paLeafs[i], pCaseSensitive)
		next

		def RemoveTheseItemsCS(paLeafs, pCaseSensitive)
			This.RemoveTheseLeafsCS(paLeafs, pCaseSensitive)

	def RemoveTheseLeafs(paLeafs)
		This.RemoveTheseLeafsCS(paLeafs, _TRUE_)

		def RemoveTheseItems(paLeafs)
			This.RemoveTheseLeafsCS(paLeafs)

	#--

	def RemoveLeafsCS(pCaseSensitive)
		aLeafs = This.Leafs()
		aLeafBranches = This.LeafsXTCS(pCaseSensitive)

		for i = 1 to len(aLeafs)
			# For each leaf and its branches
			aLeafInfo = aLeafBranches[i]
			pLeaf = aLeafInfo[1]
			aBranches = aLeafInfo[2]

			# Remove from each branch where it appears
			for j = 1 to len(aBranches)
				This.RemoveLeafAtCS(pLeaf, aBranches[j], pCaseSensitive)
			next
		next

		def RemoveAllLeafsCS(pCaseSensitive)
			This.RemoveLeafsCS(pCaseSensitive)

		def RemoveItemsCS(pCaseSensitive)
			This.RemoveLeafsCS(pCaseSensitive)

	def RemoveLeafs()
		This.RemoveLeafsCS(_TRUE_)

		def RemoveAllLeafs()
			This.RemoveLeafs()

		def RemoveItems()
			This.RemoveLeafs()

	#--

	def RemoveTheseLeafsInNode(paLeafs, pcNode)
		This.RemoveTheseLeafsAt(paLeaf, This.FindNode(pcNode))
	
		def RemoveTheseItemsInNode(paLeafs, pcNode)
			This.RemoveTheseLeafsInNode(paLeafs, pcNode)
	
	def RemoveTheseLeafsAt(paLeafs, pcBranchPath)
		nLen = len(paLeafs)
	
		for i = 1 to nLen
			This.RemoveLeafAt(paLeafs[i], pcBranchPath)
		next

	#--

	def RemoveLeafsInNode(pcNode)
		This.RemoveLeafsAt(This.FindNode(pcNode))
	
		def RemoveItemsInNode(pcNode)
			This.RemoveLeafsInNode(pcNode)
	
		def RemoveAllLeafsInNode(pcNode)
			This.RemoveLeafsInNode(pcNode)

		def RemoveAllItemsInNode(pcNode)
			This.RemoveLeafsInNode(pcNode)

	def RemoveLeafsAt(pcBranchPath)
		nLen = len(paLeafs)
	
		for i = 1 to nLen
			This.RemoveLeafAt(pcBranchPath)
		next

		def RemoveItemsAt(pcBranchPath)
			This.RemoveLeafsAt(pcBranchPath)

		def RemoveAllLeafsAt(pcBranchPath)
			This.RemoveLeafsAt(pcBranchPath)

		def RemoveAllItemsAt(pcBranchPath)
			This.RemoveLeafsAt(pcBranchPath)

  #-----------------------------#
 #  REPLACING NODES AND LEAFS  #
#-----------------------------#

def ReplaceNodeAt(pcBranch, paNewNode)

    if isList(pcBranch) and isString(paNewNode)
		temp = paNewNode
		paNewNode = pcBranch
		pcBranch = temp
   ok

    if CheckParams()

	if isList(paNewNode) and StzListQ(paNewNode).IsByOrWithNamedParam()
		paNewNode = paNewNode[2]
	ok

        if NOT ( isList(paNewNode) and len(paNewNode) = 2 and
                 isString(paNewNode[1]) and isList(paNewNode[2]) )
            stzRaise("Incorrect param! paNewNode is not a valid node.")
        ok
        
        if NOT isString(pcBranch)
            stzRaise("Can't replace node! pcBranch must be a string.")
        ok
    ok
    
    # Check if branch exists

    if NOT ring_find(This.Branches(), pcBranch) > 0
        return FALSE
    ok

    # Removing the existing node first

    This.RemoveNodeAt(pcBranch)
    
    # Adding the new node

    _cNodeName_ = paNewNode[1]
    _aNodeContent_ = paNewNode[2]
    
    # Extract the parent branch path

    _acBranchParts_ = @split(pcBranch, "][")
    _nLen_ = len(_acBranchParts_)
    
    if _nLen_ <= 1
        cParentBranch = "[:root]"

    else

        cParentBranch = ""

        for i = 1 to _nLen_ - 1

            if i = 1
                cParentBranch += _acBranchParts_[i] + "]"

            else
                cParentBranch += "[" + _acBranchParts_[i] + "]"
            ok

        next

    ok
    
    # Add the new node to the parent branch

    cCode = 'This.Content()' + cParentBranch + ' + [ _cNodeName_, _aNodeContent_ ]'
    eval(cCode)
    
    return TRUE

def ReplaceNode(pcNode, paNewNode)

   if isList(paNewNode) and StzListQ(paNewNode).IsByOrWithNamedParam()
	paNewNode = paNewNode[2]
   ok

    return This.ReplaceNodeAt(This.FindNode(pcNode), paNewNode)

#--

def ReplaceLeafAtCS(pOldLeaf, pNewLeaf, pcBranchPath, pCaseSensitive)
	if isList(pNewLeaf) and StzListQ(pNewLeaf).IsByOrWithNamedParam()
		pNewLeaf = pNewLeaf[2]
	ok
	
	# Extract branch path and position
	nPosStart = ring_find_last(pcBranchPath, "[")
	nPosEnd = ring_find_last(pcBranchPath, "]")
	
	# Check if the path includes a position at the end
	if nPosStart > 0 and nPosEnd = len(pcBranchPath)
		# Get position number
		cPosition = substr(pcBranchPath, nPosStart + 1, nPosEnd - nPosStart - 1)
		if isNumber(cPosition)
			nPos = number(cPosition)
			
			# Get branch path without position
			cBranchPath = substr(pcBranchPath, 1, nPosStart - 1)
			
			# Get node content
			aNodeContent = This.Branch(cBranchPath)
			
			# Check if position is valid
			if nPos > 0 and nPos <= len(aNodeContent)
				# Replace the item at the specified position
				aNodeContent[nPos] = pNewLeaf
				
				# Update the node
				_cNodeName_ = This.LastNodeInBranch(cBranchPath)
				_cNode1_ = @Simplify( @@([ _cNodeName_, This.Branch(cBranchPath) ]) )
				_cNode2_ = @Simplify( @@([ _cNodeName_, aNodeContent ]) )
				_cTree_ = @Simplify( @@(This.Content()) )
				
				_cNode1_ = ring_substr2(_cNode1_, ":", "")
				_cNode2_ = ring_substr2(_cNode2_, ":", "")
				_cTree_ = ring_substr2(_cTree_, _cNode1_, _cNode2_)
				
				_cCode_ = 'This.UpdateWith(' + _cTree_ + ')'
				eval(_cCode_)
				
				return
			ok
		ok
	ok
	
	# If no position specified or invalid format, use the original method
	# Preparing the stringified data elements
	_cNodeName_ = This.LastNodeInBranch(pcBranchPath)
	
	_aNodeContent_ = This.NodeAt(pcBranchPath)
	_cNode1_ = @Simplify( @@([ _cNodeName_, _aNodeContent_ ]) )
	
	# Create new content by replacing the leaf
	_aNodeContent2_ = []
	for i = 1 to len(_aNodeContent_)
		if _aNodeContent_[i] = pOldLeaf
			_aNodeContent2_ + pNewLeaf
		else
			_aNodeContent2_ + _aNodeContent_[i]
		ok
	next
	
	_cNode2_ = @Simplify( @@([ _cNodeName_, _aNodeContent2_ ]) )
	
	_cTree_ = @Simplify( @@(This.Content()) )
	
	# Managing case sensitivity
	if CaseSensitive(pCaseSensitive) = FALSE
		_cNode1_ = lower(_cNode1_)
		_cNode2_ = lower(_cNode2_)
		_cTree_  = lower(_cTree_)
	ok
	
	# Processing the replacement
	_cNode1_ = ring_substr2(_cNode1_, ":", "")
	_cNode2_ = ring_substr2(_cNode2_, ":", "")
	_cTree_ = ring_substr2(_cTree_, _cNode1_, _cNode2_)
	
	# Updating the tree (by evaluation)
	_cCode_ = 'This.UpdateWith(' + _cTree_ + ')'
	eval(_cCode_)
    
    def ReplaceItemAtCS(pOldItem, pNewItem, pcBranchPath, pCaseSensitive)
        This.ReplaceLeafAtCS(pOldItem, pNewItem, pcBranchPath, pCaseSensitive)

   def ReplaceAtCS(pOldItem, pNewItem, pcBranchPath, pCaseSensitive)
	This.ReplaceLeafAtCS(pOldItem, pNewItem, pcBranchPath, pCaseSensitive)

def ReplaceLeafAt(pOldLeaf, pNewLeaf, pcBranchPath)
    This.ReplaceLeafAtCS(pOldLeaf, pNewLeaf, pcBranchPath, _TRUE_)
    
    def ReplaceItemAt(pOldItem, pNewItem, pcBranchPath)
        return This.ReplaceLeafAt(pOldItem, pNewItem, pcBranchPath)

   def ReplaceAt(pOldItem, pNewItem, pcBranchPath)
	This.ReplaceLeafAt(pOldItem, pNewItem, pcBranchPath)

#--

def ReplaceLeafCS(pOldLeaf, pNewLeaf, pCaseSensitive)
    aBranches = This.FindLeafCS(pOldLeaf, pCaseSensitive)
    
    for i = 1 to len(aBranches)
        This.ReplaceLeafAtCS(pOldLeaf, pNewLeaf, aBranches[i], pCaseSensitive)
    next
    
    def ReplaceItemCS(pOldItem, pNewItem, pCaseSensitive)
        This.ReplaceLeafCS(pOldItem, pNewItem, pCaseSensitive)

    def ReplaceCS(pOldLeaf, pNewLeaf, pCaseSensitive)
		This.ReplaceLeafCS(pOldLeaf, pNewLeaf, pCaseSensitive)

def ReplaceLeaf(pOldLeaf, pNewLeaf)
    This.ReplaceLeafCS(pOldLeaf, pNewLeaf, _TRUE_)
    
    def ReplaceItem(pOldItem, pNewItem)
        This.ReplaceLeaf(pOldItem, pNewItem)

    def Replace(pOldLeaf, pNewLeaf)
		This.ReplaceLeaf(pOldLeaf, pNewLeaf)

#--

def ReplaceLeafByManyCS(pOldLeaf, paNewLeafs, pCaseSensitive)
   aBranches = This.FindLeaf(pOldLeaf)
   ?@@(abranches)

    def ReplaceItemByManyCS(pOldItem, paNewItems, pCaseSensitive)
        This.ReplaceLeafByManyCS(pOldItem, paNewItems, pCaseSensitive)

    def ReplaceByManyCS(pOldLeaf, paNewLeafs, pCaseSensitive)
		This.ReplaceLeafByManyCS(pOldLeaf, paNewLeafs, pCaseSensitive)

def ReplaceLeafByMany(pOldLeaf, paNewLeafs)
    This.ReplaceLeafByManyCS(pOldLeaf, paNewLeafs, _TRUE_)
    
    def ReplaceItemByMany(pOldItem, paNewItems)
        This.ReplaceLeafByMany(pOldItem, paNewItems)

    def ReplaceByMany(pOldLeaf, paNewLeafs)
		This.ReplaceLeafByMany(pOldLeaf, paNewLeafs)

#--

def ReplaceLeafInNodeCS(pOldLeaf, pNewLeaf, pcNode, pCaseSensitive)
    This.ReplaceLeafAtCS(pOldLeaf, pNewLeaf, This.FindNode(pcNode), pCaseSensitive)
    
    def ReplaceItemInNodeCS(pOldItem, pNewItem, pcNode, pCaseSensitive)
        This.ReplaceLeafInNodeCS(pOldItem, pNewItem, pcNode, pCaseSensitive)

    def ReplaceInNodeCS(pOldLeaf, pNewLeaf, pcNode, pCaseSensitive)
	This.ReplaceLeafAtCS(pOldLeaf, pNewLeaf, This.FindNode(pcNode), pCaseSensitive)

def ReplaceLeafInNode(pOldLeaf, pNewLeaf, pcNode)
    This.ReplaceLeafInNodeCS(pOldLeaf, pNewLeaf, pcNode, _TRUE_)
    
    def ReplaceItemInNode(pOldItem, pNewItem, pcNode)
        This.ReplaceLeafInNode(pOldItem, pNewItem, pcNode)

    def ReplaceInNode(pOldLeaf, pNewLeaf, pcNode)
	This.ReplaceLeafAt(pOldLeaf, pNewLeaf, This.FindNode(pcNode))

#==

def ReplaceTheseLeafsCS(paOldLeafs, pNewLeaf, pCaseSensitive)
	if isList(pNewLeaf) and StzListQ(pNewLeaf).IsByOrWithNamedParam()
		pNewLeaf = pNewLeaf[2]
	ok

	This.ReplaceTheseLeafsByManyCSXT(paOldLeafs, [ pNewLeaf ], pCaseSensitive)

    def ReplaceTheseItemsCS(paOldItems, pNewItem, pCaseSensitive)
        This.ReplaceTheseLeafsCS(paOldLeafs, pNewLeaf, pCaseSensitive)

    def ReplaceTheseCS(paOldItems, pNewItem, pCaseSensitive)
        This.ReplaceTheseLeafsCS(paOldLeafs, pNewLeaf, pCaseSensitive)

def ReplaceTheseLeafs(paOldLeafs, pNewLeaf)
    This.ReplaceTheseLeafsCS(paOldLeafs, pNewLeaf, _TRUE_)
    
    def ReplaceTheseItems(paOldItems, pNewItem)
        This.ReplaceTheseLeafs(paOldLeafs, pNewLeaf)

    def ReplaceThese(paOldItems, pNewItem)
        This.ReplaceTheseLeafs(paOldItems, pNewItem)


def ReplaceTheseLeafsByManyCS(paOldLeafs, paNewLeafs, pCaseSensitive)

   if isList(paNewLeafs) and StzListQ(paNewLeafs).IsByOrWithNamedParam()
	paNewLeafs = paNewLeafs[2]
   ok

    nLen = @Min([ len(paOldLeafs), len(paNewLeafs) ])
    
    if len(paNewLeafs) != nLen
        stzRaise("Incorrect param! Number of new leafs doesn't match number of old leafs.")
    ok
    
    for i = 1 to nLen
        This.ReplaceLeafCS(paOldLeafs[i], paNewLeafs[i], pCaseSensitive)
    next
    
    def ReplaceTheseItemsByManyCS(paOldItems, paNewItems, pCaseSensitive)
        This.ReplaceTheseLeafsByManyCS(paOldItems, paNewItems, pCaseSensitive)

    def ReplaceTheseByManyCS(paOldItems, paNewItems, pCaseSensitive)
        This.ReplaceTheseLeafsByManyCS(paOldItems, paNewItems, pCaseSensitive)

def ReplaceTheseLeafsByMany(paOldLeafs, paNewLeafs)
    This.ReplaceTheseLeafsByManyCS(paOldLeafs, paNewLeafs, _TRUE_)
    
    def ReplaceTheseItemsByMany(paOldItems, paNewItems)
        This.ReplaceTheseLeafsByMany(paOldItems, paNewItems)

    def ReplaceTheseByMany(paOldItems, paNewItems)
        This.ReplaceTheseLeafsByMany(paOldItems, paNewItems)

#--

def ReplaceTheseLeafsByManyCSXT(paOldLeafs, paNewLeafs, pCaseSensitive)
   if isList(paNewLeafs) and StzListQ(paNewLeafs).IsByOrWithNamedParam()
	paNewLeafs = paNewLeafs[2]
   ok

   nLen1 = len(paOldLeafs)
   nLen2 = len(paNewLeafs)

  aNewLeafs = []
  if nLen1 = nLen2
	aNewLeafs = paNewLeafs

  but nLen2 > nLen1
	for i = 1 to nLen1
		aNewLeafs + paNewLeafs[i]
	next
  else
	nDiff = nLen1 - nLen2
	aNewLeafs = paNewLeafs
	j = 0
	for i = 1 to nDiff
		j++
		if j > nLen2
			j = 1
		ok
		aNewLeafs + paNewLeafs[j]
	next
   ok

   This.ReplaceTheseLeafsByManyCS(paOldLeafs, aNewLeafs, pCaseSensitive)

    def ReplaceTheseItemsByManyCSXT(paOldItems, paNewItems, pCaseSensitive)
        This.ReplaceTheseLeafsByManyCSXT(paOldItems, paNewItems, pCaseSensitive)

    def ReplaceTheseByManyCSXT(paOldItems, paNewItems, pCaseSensitive)
        This.ReplaceTheseLeafsByManyCSXT(paOldItems, paNewItems, pCaseSensitive)

def ReplaceTheseLeafsByManyXT(paOldLeafs, paNewLeafs)
    This.ReplaceTheseLeafsByManyCSXT(paOldLeafs, paNewLeafs, _TRUE_)
    
    def ReplaceTheseItemsByManyXT(paOldItems, paNewItems)
        This.ReplaceTheseLeafsByMany(paOldItems, paNewItems)

    def ReplaceTheseByManyXT(paOldItems, paNewItems)
        This.ReplaceTheseLeafsByManyXT(paOldItems, paNewItems)

#==

def ReplaceLeafsWithCS(pNewLeaf, pCaseSensitive)
    aLeafs = This.Leafs()
    
    for i = 1 to len(aLeafs)
        This.ReplaceLeafCS(aLeafs[i], pNewLeaf, pCaseSensitive)
    next
    
    def ReplaceItemsWithCS(pNewItem, pCaseSensitive)
        This.ReplaceAllLeafsWithCS(pNewItem, pCaseSensitive)

    def ReplaceAllLeafsWithCS(pNewLeaf, pCaseSensitive)
	This.ReplaceLeafsWithCS(pNewLeaf, pCaseSensitive)

    def ReplaceAllItemsWithCS(pNewItem, pCaseSensitive)
        This.ReplaceLeafsWithCS(pNewItem, pCaseSensitive)

def ReplaceLeafsWith(pNewLeaf)
    This.ReplaceLeafsWithCS(pNewLeaf, _TRUE_)
    
    def ReplaceItemsWith(pNewItem)
        This.ReplaceLeafsWith(pNewItem)

   def ReplaceAllLeafsWith(pNewLeaf)
	This.ReplaceLeafsWithCS(pNewLeaf)

    def ReplaceAllItemsWith(pNewItem)
        This.ReplaceLeafsWith(pNewItem)

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
		
		def LeafsAndTheirBranchesCS(pCaseSensitive)
			return This.LeafsXTCS(pCaseSensitive)

	def LeafsXT()
		return This.LeafsXTCS(_TRUE_)

		def LeafsAndTheirBranches()
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

	def FindLeaf(pLeaf)
		return This.FindLeafCS(pLeaf, _TRUE_)

	def FindLeafsCS(paLeafs, pCaseSensitive)
		aResult = []
		
		for i = 1 to len(paLeafs)
			aResult + This.FindLeafCS(paLeafs[i], pCaseSensitive)
		next
		
		return aResult

	def FindLeafs(paLeafs)
		return This.FindLeafsCS(paLeafs, _TRUE_)
	
	def LeafsAt(pcBranch)
		return This.Branch(pcBranch)

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

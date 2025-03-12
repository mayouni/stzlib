#---------------------------------#
#  FUNCTIONS FOR PATH MANAGEMENT  #
#---------------------------------#

# An internal function that generates paths of a nested list
# from a particular string representation of the list (formed
# from only "[", ",", and "]" and removing all the other chars)

func GeneratePaths(cStr)

	aResult = []
	aCurrentPath = []
	aLevelCounts = [1]    # Start with 1 for first position
    
	nLen = len(cStr)

	for i = 1 to nLen
		cChar = cStr[i]
        
		if cChar = "["
			# Start new level
			aLevelCounts + 1  # Start with position 1
			aCurrentPath + 1  # Add current position to path
			if len(aCurrentPath) > 0
				aResult + aCurrentPath
		ok
            
		but cChar = "]"
			# Close current level
			if len(aCurrentPath) > 0
				del(aCurrentPath, len(aCurrentPath))
			ok
			if len(aLevelCounts) > 0
				del(aLevelCounts, len(aLevelCounts))
			ok
            
		but cChar = ","
			# New item at current level
			if len(aLevelCounts) > 0
				# Increment count at current level
				aLevelCounts[len(aLevelCounts)] += 1
                
				# Update path with new position
				if len(aCurrentPath) > 0
					del(aCurrentPath, len(aCurrentPath))
				ok
				aCurrentPath + aLevelCounts[len(aLevelCounts)]
                
				# Add new path to result
				if len(aCurrentPath) > 0
					aResult + aCurrentPath
				ok
			ok
		ok
	next
    
	return aResult

	def GenPaths(str)
		return GeneratePaths(str)

func PathsIn(paPath)
	# EXAMPLE

	# ? PathsTo([ 2, 3, 2 ]) )
	#--> [
	# 	[ 2 ],
	# 	[ 2, 3 ],
	# 	[ 2, 3, 2 ]
	# ]

	if CheckParams()
		if NOT (isList(paPath) and IsListOfNumbers(paPath))
			StzRaise("Incorrect param type! paPath must be a list of numbers.")
		ok
	ok

	_aResult_ = []
	_nLen_ = len(paPath)
    
	# Handle empty path case
	if _nLen_ = 0
	        return []
    	ok
    
    	# Generate all possible subpaths

	for @i = 1 to _nLen_
		_aCurrentPath_ = 1 : @i  # Initialize list with size @i
		_nLenSubPath_ = @i
        
		# Build the current subpath

		for @j = 1 to _nLenSubPath_
			_aCurrentPath_[@j] = paPath[@j]  # First fill with the original values
		next
        
		# Add the current subpath to results

		_aTempList_ = 1 : @i  # Create a new list for this combination

		for @j = 1 to @i
			_aTempList_[@j] = _aCurrentPath_[@j]
		next

		_aResult_ + _aTempList_
	next
    
	return _aResult_

	#< @FunctionAlternativeForms

	func @PathsIn(paPath)
		return PathsIn(paPath)

	func PathsInPath(paPath)
		return PathsIn(paPath)

	func @PathsInPath(paPath)
		return PathsIn(paPath)

	#>

func LastPathIn(paPath)
	if CheckParams()
		if NOT ( isList(paPath) and IsListOfNumbers(paPath) )
			StzRaise("Incorrect param type! paPair muts be a list of numbers.")
		ok
	ok

	_nLen_ = len(paPath)
	_aResult_ = NthPathIn(_nLen_, paPath)
	return _aResult_

	#< @FunctionAlternativeForms

	func LastPathInPath(paPath)
		return LastPathIn(paPath)

	func @LastPathIn(paPath)
		return LastPathIn(paPath)

	func @LastPathInPath(paPath)
		return LastPathIn(paPath)

	#>

func NthPathIn(n, paPath)

	if CheckParams()
		if Not isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok
	ok

	_aPaths_ = PathsIn(paPath)
	_nLen_ = len(_aPaths_)

	if n < 1 or n > _nLen_
		StzRaise("Incorrect param value! n must be with in the path size.")
	ok

	_aResult_ = _aPaths_[n]
	return _aResult_

	#< @FunctionAlternativeForms

	func NthPathInPath(n, paPath)
		return NthPathIn(n, paPath)

	func @NthPathIn(n, paPath)
		return NthPathIn(n, paPath)

	func @NthPathInPath(n, paPath)
		return NthPathIn(n, paPath)

	#>

func PathsInXT(paPaths)
	# EXAMPLE

	# ? @@NL( PathsInXT([ [ 2, 3 ], [ 2, 3, 2 ], [ 4 ] ]) )
	#--> [
	# 	[ 2 ],
	# 	[ 2, 3 ],
	# 	[ 2, 3, 2 ],
	# 	[ 4 ]
	# ]

	if CheckParams()
		if NOT (isList(paPaths) and IsListOfListsOfNumbers(paPaths))
			StzRaise("Incorrect param type! paPaths must be a list of lists of numbers.")
		ok
	ok

	_aResult_ = []
	_nLen_ = len(paPaths)
    
	# Handle empty path case
	if _nLen_ = 0
	        return []
    	ok
    
    	# Generate all possible subpaths

	for @i = 1 to _nLen_
		_aTempPaths_ = PathsIn(paPaths[@i])
		_nLenTemp_ = len(_aTempPaths_)

		for @j = 1 to _nLenTemp_
			_aResult_ + _aTempPaths_[@j]
		next

	next
    
	return U(_aResult_)

	#< @FunctionAlternativeForms

	func @PathsInXT(paPath)
		return PathsInXT(paPath)

	func PathsInPathXT(paPath)
		return PathsInXT(paPath)

	func @PathsInPathXt(paPath)
		return PathsInXt(paPath)

	#>

func LastPathInXT(paPath)
	if CheckParams()
		if NOT ( isList(paPath) and IsListOfNumbers(paPath) )
			StzRaise("Incorrect param type! paPair muts be a list of numbers.")
		ok
	ok

	_n_ = len(paPath)
	_aResult_ = NthPathInXT(_n_, paPath)
	return _aResult_

	#< @FunctionAlternativeForms

	func LastPathInPathXT(paPath)
		return LastPathInXT(paPath)

	func @LastPathInXT(paPath)
		return LastPathInXT(paPath)

	func @LastPathInPathXT(paPath)
		return LastPathInXT(paPath)

	#>

func NthPathInXT(n, paPath)

	if CheckParams()
		if Not isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok
	ok

	_aPaths_ = PathsToXT(paPath)
	_nLen_ = len(_aPaths_)

	if n < 1 or n > _nLen_
		StzRaise("Incorrect param value! n must be with in the path size.")
	ok

	_aResult_ = _aPaths_[n]
	return _aResult_

	#< @FunctionAlternativeForms

	func NthPathInPathXT(n, paPath)
		return NthPathInXT(n, paPath)

	func @NthPathInXT(n, paPath)
		return NthPathInXT(n, paPath)

	func @NthPathInPathXT(n, paPath)
		return NthPathInXT(n, paPath)

	#>

func ReducePaths(paPaths)
	# Returns the shortest unique ancestor paths
    	# For example, between [2] and [2,2], we keep [2]
    	# Between [3,1] and [3,1,2], we keep [3,1]

	_nLenPaths_ = len(paPaths)
   	_aResult_ = []

	for @i = 1 to _nLenPaths_

		_aPath_ = paPaths[@i]
        	_bShouldAdd_ = _TRUE_
        
		for @j = 1 to _nLenPaths_

			_aOtherPath_ = paPaths[@j]

            		if _aOtherPath_ != _aPath_ and
               		   IsSubPathOf(_aOtherPath_, _aPath_)

                	   # If we find a shorter path that is a prefix of
                	   # our current path, we skip the current path

                		_bShouldAdd_ = _FALSE_
                			exit
            		ok
        	next
        
        	if _bShouldAdd_
			_aResult_ + _aPath_
        	ok
    	next

    	return _aResult_

	#< @FunctionAlternativeForms

    	func ShortestCommonPaths(paPaths)
		return ReducePaths(paPaths)

   	func CollapsePaths(paPaths)
		return ReducePaths(paPaths)

	#--

	func @ReducePaths(paPaths)
		return ReducePaths(paPaths)

    	func @ShortestCommonPaths(paPaths)
		return ReducePaths(paPaths)

   	func @CollapsePaths(paPaths)
		return ReducePaths(paPaths)

	#>

func SortPaths(paPaths)
    	# Sorts paths in ascending order:
    	# [4] should come after [3,1,2] because 4 > 3
    	# [2,2] should come after [2,1] because at position 2: 2 > 1

    	_aResult_ = paPaths
    	_nLen_ = len(_aResult_)

    	_nLen1_ = _nLen_ - 1

    	for @i = 1 to _nLen1_

		_nLen2_ = _nLen_ - @i

        	for @j = 1 to _nLen2_

            		if PathIsGreaterThan(_aResult_[@j], _aResult_[@j+1])

                		_temp_ = _aResult_[@j]
                		_aResult_[@j] = _aResult_[@j+1]
                		_aResult_[@j+1] = _temp_

            		ok
        	next
    	next

    	return _aResult_

	func @SortPaths(paPaths)
		return SortPaths(paPaths)

func PathIsGreaterThan(paPath1, paPath2)
    	# Compare paths lexicographically - first values matter most
   	# [4] should come after [3,1,2] because 4 > 3
    	# [2,2] should come after [2,1] because at position 2: 2 > 1

	_nLen1_ = len(paPath1)
	_nLen2_ = len(paPath2)

   	_nMin_ = Min([ _nLen1_, _nLen2_ ])
    
    	# Compare common positions first

	for @i = 1 to _nMin_
		if paPath1[@i] != paPath2[@i]
			return paPath1[@i] > paPath2[@i]
		ok
	next
    
    	# If one is ancestor of other, shorter comes first

    	return _nLen1_ > _nLen2_

	func @PathIsGreaterThan(paPath1, paPath2)
		return PathIsGreaterThan(paPath1, paPath2)

func IsSubPathOf(paShortPath, paLongPath)
    	# Returns TRUE if paShortPath is an initial segment of paLongPath
   	 # Example: [2,1] is a subpath of [2,1,3] but not of [2,2]

	_nLenShort_ = len(paShortPath)

    	if _nLenShort_ >= len(paLongPath)

        	return _FALSE_
    	ok
    
    	for @i = 1 to _nLenShort_
        	if paShortPath[@i] != paLongPath[@i]
            		return _FALSE_
        	ok
    	next
    
    	return _TRUE_

	func @IsSubPathOf(paShortPath, paLongPath)
		return IsSubPathOf(paShortPath, paLongPath)

func CommonPath(paPaths)
	if len(paPaths) = 0
		return []
	ok

	_aShortestPath_ = paPaths[1]
	_nLenPaths_ = len(paPaths)

	# Find shortest path
	for @i = 1 to _nLenPaths_
		if len(paPaths[@i]) < len(_aShortestPath_)
			_aShortestPath_ = paPaths[@i]
		ok
	next

	# Try each length from longest to shortest
	_nLen_ = len(_aShortestPath_)
	
	for @n = _nLen_ to 1 step -1
		_aCandidate_ = []
		
		# Build candidate of length @n
		for @j = 1 to @n
			_aCandidate_ + _aShortestPath_[@j]
		next

		_bAllMatch_ = TRUE
		
		# Check if all paths match this candidate at length @n
		for @i = 1 to _nLenPaths_
			if len(paPaths[@i]) < @n
				_bAllMatch_ = FALSE
				exit
			ok
			
			for @j = 1 to @n
				if paPaths[@i][@j] != _aCandidate_[@j]
					_bAllMatch_ = FALSE
					exit
				ok
			next
		next

		if _bAllMatch_ = TRUE
			return _aCandidate_
		ok
	next

	return []

	#< @FunctionAlternativeForms

	func PathsIntersection(paPaths)
		return CommonPath(paPaths)

	#--

	func @CommonPath(paPaths)
		return CommonPath(paPaths)

	func @PathsIntersection(paPaths)
		return CommonPath(paPaths)

	#>

func DeepestPath(paPaths)
	if CheckParams()
		if NOT (isList(paPaths) and IsListOfListsOfNumbers(paPaths))
			StzRaise("Incorrect param type! paPaths must be a list of lists of numbers.")
		ok
	ok

	_aSorted_ = SortPaths(paPaths)
	_nLen_ = len(_aSorted_)
	_aResult_ = _aSorted_[_nLen_]
	return _aResult_

	func HighestPath(paPaths)
		return DeepestPath(paPaths)

	func @DeepestPath(paPaths)
		return DeepestPath(paPaths)

	func @HighestPath(paPaths)
		return DeepestPath(paPaths)

	func LargestPath(paPaths)
		return DeepestPath(paPaths)

	func @LargestPath(paPaths)
		return DeepestPath(paPaths)

func ShallowestPath(paPaths)
	if CheckParams()
		if NOT (isList(paPaths) and IsListOfListsOfNumbers(paPaths))
			StzRaise("Incorrect param type! paPaths must be a list of lists of numbers.")
		ok
	ok

	_aSorted_ = SortPaths(paPaths)
	_aResult_ = _aSorted_[1]
	return _aResult_

	func LowestPath(paPaths)
		return ShallowestPath(paPaths)

	func @ShallowestPath(paPaths)
		return ShallowestPath(paPaths)

	func @LowestPath(paPaths)
		return ShallowestPath(paPaths)

	func SmallestPath(paPaths)
		return ShallowestPath(paPaths)

	func @SmallestPath(paPaths)
		return ShallowestPath(paPaths)

func PathsSection(paPath1, paPath2)
	# Returns all paths from paPath1 to paPath2, where
	# paPath1 must be a subpath of paPath2
	# Example: [2] and [2,3,1] -> [ [2], [2,3], [2,3,1] ]
    
    	if NOT IsSubPathOf(paPath1, paPath2)
        	return []
    	ok
    
    	_aResult_ = []
   	_nStart_ = len(paPath1)
    	_nEnd_ = len(paPath2)
    
    	for @i = _nStart_ to _nEnd_

        	_aTemp_ = []

        	for @j = 1 to @i
            		_aTemp_ + paPath2[@j]
        	next

        	_aResult_ + _aTemp_
    	next
    
    	return _aResult_

	func @PathsSection(paPath1, paPath2)
		return PathsSection(paPath1, paPath2)

# Returns the longest path in terms of number of elements

func LongestPath(aPaths)
    if len(aPaths) = 0
        return []
    ok

    aLongest = aPaths[1]
    nMaxLen = len(aLongest)
    
    for i = 2 to len(aPaths)
        if len(aPaths[i]) > nMaxLen
            aLongest = aPaths[i]
            nMaxLen = len(aLongest)
        ok
    next
    
    return aLongest

    func @LongestPath(aPaths)
	return LongestPath(aPaths)

# Returns the shortest path in terms of number of elements

func ShortestPath(aPaths)
    if len(aPaths) = 0
        return []
    ok

    aShortest = aPaths[1]
    nMinLen = len(aShortest)
    
    for i = 2 to len(aPaths)
        if len(aPaths[i]) < nMinLen
            aShortest = aPaths[i]
            nMinLen = len(aShortest)
        ok
    next
    
    return aShortest

    func @ShortestPath(aPaths)
	return ShortestPath(aPaths)

# Returns all paths whose depth is equal to a specified value

func PathsWithDepth(aPaths, nDepth)
    aResult = []
    
    for path in aPaths
        if len(path) = nDepth
            add(aResult, path)
        ok
    next
    
    return aResult

    func @PathsWithPath(aPaths, n)
	return PathsWithDepth(aPaths, nDepth)

# Returns all paths that are superpaths of a given path

func SuperPathsOf(aPaths, aBasePath)
    aResult = []
    
    for path in aPaths
        if IsSubPathOf(aBasePath, path) and aBasePath != path
            add(aResult, path)
        ok
    next
    
    return aResult

    func @SuperPathsOf(aPaths, aBasePath)
	return SuperPathsOf(aPaths, aBasePath)

# Checks if a nested list forms a valid tree structure

func IsTree(paList)

	# If it's not a list, it's not a tree
	if NOT isList(paList)
		return false
	ok
    
	# An empty list is not considered a valid tree

	if len(paList) = 0
		return FALSE
	ok
    
	# Checks each element of the list

	nLen = len(paList)

	for i = 1 to nLen
		# If the element is a list, recursively checks that it's a valid tree
		if isList(item)
			if NOT IsTree(item)
				return FALSE
			ok
		ok
	next
    
	# If all tests pass, it's a valid tree
	return TRUE

	func IsATree(paList)
		return IsTree(paList)

	func @IsTree(paList)
		return IsTree(paList)

	func @IsATree(paList)
		return IsTree(paList)

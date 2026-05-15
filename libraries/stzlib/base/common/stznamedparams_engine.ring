
#=================================================================#
#  ENGINE-BACKED NAMED PARAM CHECKING                             #
#  Replaces 1,566 IsXxxNamedParam() methods in stzList with       #
#  a single hash-lookup via the Zig meta-engine.                  #
#=================================================================#

# These functions are the engine-backed replacements for the
# named-param checking pattern. They can be called from anywhere
# in stzlib without instantiating a stzList object.
#
# BEFORE (1,566 methods in stzList, each 7 lines):
#
#   def IsOfNamedParam()
#       if This.NumberOfItems() = 2 and
#          (isString(This.Item(1)) and This.Item(1) = :Of)
#           return 1
#       else
#           return 0
#       ok
#
# AFTER (one function, one hash lookup):
#
#   IsNamedParamList(paList)  -->  1 or 0

func IsNamedParamList(paList)
	if NOT isList(paList)
		return 0
	ok

	if len(paList) != 2
		return 0
	ok

	if NOT isString(paList[1])
		return 0
	ok

	return EngineIsNamedParam(paList[1])

# Check if a list is a specific named param
# Replaces: StzListQ(p).IsOfNamedParam()
func IsThisNamedParam(paList, cKeyword)
	if NOT isList(paList)
		return 0
	ok

	if len(paList) != 2
		return 0
	ok

	if NOT isString(paList[1])
		return 0
	ok

	if ring_lower(paList[1]) = ring_lower(cKeyword)
		return 1
	ok

	return 0

# Check if a list matches any of the given named param keywords
# Replaces: StzListQ(p).IsOneOfTheseNamedParams([:At, :AtPosition, :Before])
func IsOneOfTheseNamedParamsList(paList, pacKeywords)
	if NOT isList(paList)
		return 0
	ok

	if len(paList) != 2
		return 0
	ok

	if NOT isString(paList[1])
		return 0
	ok

	cParam = ring_lower(paList[1])
	nLen = len(pacKeywords)

	for i = 1 to nLen
		if cParam = ring_lower(pacKeywords[i])
			return 1
		ok
	next

	return 0

# Unwrap a named param: if paList is [:Keyword, value], return value
# Otherwise return paList unchanged
# Replaces the pattern:
#   if isList(p) and StzListQ(p).IsOfNamedParam()
#       p = p[2]
#   ok
func UnwrapNamedParam(paList)
	if IsNamedParamList(paList)
		return paList[2]
	ok
	return paList

# Unwrap if the param matches a specific keyword
func UnwrapIfNamedParam(paList, cKeyword)
	if IsThisNamedParam(paList, cKeyword)
		return paList[2]
	ok
	return paList

# Unwrap if the param matches any of the given keywords
func UnwrapIfOneOfTheseNamedParams(paList, pacKeywords)
	if IsOneOfTheseNamedParamsList(paList, pacKeywords)
		return paList[2]
	ok
	return paList

# Combined unwrap + type check (the most common CheckingParams pattern)
# Returns the unwrapped value or raises an error if type doesn't match
#
# Replaces:
#   if isList(p) and StzListQ(p).IsOneOfTheseNamedParams([:Of, :OfItem])
#       p = p[2]
#   ok
#   if NOT isString(p)
#       StzRaise("Incorrect param type! p must be a string.")
#   ok
#
# With:
#   p = CheckParam(p, [:Of, :OfItem], :string, "p")
#
func CheckParam(pValue, pacNamedAliases, cExpectedType, cParamName)
	if NOT CheckingParams()
		if isList(pValue) and len(pValue) = 2 and isString(pValue[1])
			nLen = len(pacNamedAliases)
			for i = 1 to nLen
				if ring_lower(pValue[1]) = ring_lower(pacNamedAliases[i])
					return pValue[2]
				ok
			next
		ok
		return pValue
	ok

	# Unwrap named param
	if isList(pValue) and len(pValue) = 2 and isString(pValue[1])
		nLen = len(pacNamedAliases)
		for i = 1 to nLen
			if ring_lower(pValue[1]) = ring_lower(pacNamedAliases[i])
				pValue = pValue[2]
				exit
			ok
		next
	ok

	# Type check
	bOk = 0

	switch cExpectedType
	on :string
		bOk = isString(pValue)
	on :number
		bOk = isNumber(pValue)
	on :list
		bOk = isList(pValue)
	on :object
		bOk = isObject(pValue)
	on :string_or_number
		bOk = isString(pValue) or isNumber(pValue)
	on :string_or_list
		bOk = isString(pValue) or isList(pValue)
	on :any
		bOk = 1
	other
		bOk = 1
	off

	if NOT bOk
		cMsg = EngineFormatError(:PARAM_TYPE, [
			[:param, cParamName],
			[:expected, cExpectedType]
		])
		StzRaise(cMsg)
	ok

	return pValue

# Specialized: unwrap + check for CaseSensitive parameter
# The most common secondary param pattern in Softanza
func CheckCSParam(pValue)
	if isList(pValue) and len(pValue) = 2 and isString(pValue[1])
		cKey = ring_lower(pValue[1])
		if cKey = "casesensitive" or cKey = "cs"
			pValue = pValue[2]
		ok
	ok

	if NOT isNumber(pValue)
		if CheckingParams()
			StzRaise("Incorrect param type! pCaseSensitive must be a number (0 or 1).")
		ok
		return 1
	ok

	return pValue

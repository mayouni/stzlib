
#=================================================================#
#  ENGINE-BACKED NAMED PARAM CHECKING                             #
#  Replaces 1,566 IsXxxNamedParam() methods in stzList with       #
#  a single hash-lookup via the Zig meta-engine.                  #
#=================================================================#

# These functions are the engine-backed replacements for the
# named-param checking pattern. They can be called from anywhere
# in stzlib without instantiating a stzList object.
#
# BEFORE (15 lines of boilerplate per method):
#
#   if CheckingParams()
#       if isList(pItem) and StzListQ(pItem).IsOneOfTheseNamedParams([:Of, :OfItem])
#           pItem = pItem[2]
#       ok
#       if NOT isString(pItem)
#           StzRaise("Incorrect param type! pItem must be a string.")
#       ok
#   ok
#
# AFTER -- expressive form:
#
#   pItem = StzCheckParam(pItem, :Skipping = [:Of, :OfItem], :MustBe = :string)
#
# Or short form:
#
#   pItem = StzCheckParam(pItem, [:Of, :OfItem], :string)

  ///////////////////
 ///  CHECKPARAM  ///
///////////////////

# Two calling conventions:
#
#   Expressive:  StzCheckParam(pValue, :Skipping = [:Of, :OfItem], :MustBe = :string)
#   Short:       StzCheckParam(pValue, [:Of, :OfItem], :string)
#
# Both skip past the named-param wrapper (if any) and assert the type.
# When CheckingParams() is off, skipping still happens but type is not checked.

func StzCheckParam(pValue, p2, p3)

	# Resolve the two calling conventions

	if isList(p2) and len(p2) = 2 and isString(p2[1]) and p2[1] = :Skipping
		# Expressive form: :Skipping = [:Of, :OfItem]
		pacSkipping = p2[2]
	else
		# Short form: [:Of, :OfItem]
		pacSkipping = p2
	ok

	if isList(p3) and len(p3) = 2 and isString(p3[1]) and p3[1] = :MustBe
		# Expressive form: :MustBe = :string
		cMustBe = p3[2]
	else
		# Short form: :string
		cMustBe = p3
	ok

	# Skip past the named-param wrapper

	if isList(pValue) and len(pValue) = 2 and isString(pValue[1])
		cKey = ring_lower(pValue[1])
		nLen = len(pacSkipping)
		for i = 1 to nLen
			if cKey = ring_lower(pacSkipping[i])
				pValue = pValue[2]
				exit
			ok
		next
	ok

	# Type assertion (only when param checking is active)

	if CheckingParams()
		bOk = _CheckType(pValue, cMustBe)
		if NOT bOk
			StzRaise("Incorrect param type! " +
				 "Expected " + cMustBe + ".")
		ok
	ok

	return pValue

	func CheckParam(pValue, p2, p3)
		return StzCheckParam(pValue, p2, p3)

  ////////////////////////
 ///  CHECKPARAM (CS)  ///
////////////////////////

# Specialized form for the CaseSensitive parameter,
# the most frequent secondary param in Softanza.
#
#   pCaseSensitive = StzCheckParamCS(pCaseSensitive)

func StzCheckParamCS(pValue)
	if isList(pValue) and len(pValue) = 2 and isString(pValue[1])
		cKey = ring_lower(pValue[1])
		if cKey = "casesensitive" or cKey = "cs"
			pValue = pValue[2]
		ok
	ok

	if NOT isNumber(pValue)
		if CheckingParams()
			StzRaise("Incorrect param type! " +
				 "CaseSensitive must be a number (0 or 1).")
		ok
		return 1
	ok

	return pValue

	func CheckParamCS(pValue)
		return StzCheckParamCS(pValue)

  ////////////////////////////
 ///  NAMED PARAM CHECKS  ///
////////////////////////////

# Low-level helpers for code that needs finer control
# than StzCheckParam() provides.

# Is this value a [:Keyword, value] pair with a registered keyword?
func StzIsNamedParamList(paList)
	if NOT isList(paList)
		return 0
	ok

	if len(paList) != 2
		return 0
	ok

	if NOT isString(paList[1])
		return 0
	ok

	return StzMetaIsNamedParam(paList[1])

	func IsNamedParamList(paList)
		return StzIsNamedParamList(paList)

# Is this value a specific named param?
func StzIsThisNamedParam(paList, cKeyword)
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

	func IsThisNamedParam(paList, cKeyword)
		return StzIsThisNamedParam(paList, cKeyword)

# Does this value match any of these named param keywords?
func StzIsOneOfTheseNamedParamsList(paList, pacKeywords)
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

	func IsOneOfTheseNamedParamsList(paList, pacKeywords)
		return StzIsOneOfTheseNamedParamsList(paList, pacKeywords)

  /////////////////////////
 ///  TYPE CHECK LOGIC  ///
/////////////////////////

func _CheckType(pValue, cExpected)
	switch cExpected
	on :string
		return isString(pValue)
	on :number
		return isNumber(pValue)
	on :list
		return isList(pValue)
	on :object
		return isObject(pValue)
	on :string_or_number
		return isString(pValue) or isNumber(pValue)
	on :number_or_string
		return isString(pValue) or isNumber(pValue)
	on :string_or_list
		return isString(pValue) or isList(pValue)
	on :list_or_string
		return isString(pValue) or isList(pValue)
	on :any
		return 1
	other
		return 1
	off

  ///////////////////////////////////////////
 ///  ENGINE-BACKED NAMED PARAM CHECKS  ///
///////////////////////////////////////////

# These replace IsXxxNamedParamList(x) calls with direct
# function calls -- no object creation, O(1) check.

# Is this a [:Of, value] pair?
func StzIsOfNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Of

	func IsOfNamedParamList(paList)
		return StzIsOfNamedParamList(paList)

# Is this a [:CaseSensitive, 0/1] or [:CS, 0/1] pair?
func StzIsCaseSensitiveNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	if NOT isNumber(paList[2]) return 0 ok
	if NOT (paList[1] = :CaseSensitive or paList[1] = :CS) return 0 ok
	if NOT (paList[2] = 0 or paList[2] = 1) return 0 ok
	return 1

	func IsCaseSensitiveNamedParamList(paList)
		return StzIsCaseSensitiveNamedParamList(paList)

# Is this a [:And, value] or [:And@, value] pair?
func StzIsAndNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :And or paList[1] = :And@

	func IsAndNamedParamList(paList)
		return StzIsAndNamedParamList(paList)

# Is this a [:With, value], [:With@, value], [:By, value], or [:By@, value] pair?
func StzIsWithOrByNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	cKey = paList[1]
	return cKey = :With or cKey = :With@ or cKey = :By or cKey = :By@

	func IsWithOrByNamedParamList(paList)
		return StzIsWithOrByNamedParamList(paList)

# Is this a [:To, value] pair?
func StzIsToNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :To

	func IsToNamedParamList(paList)
		return StzIsToNamedParamList(paList)

func StzIsStartingAtNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :StartingAt

	func IsStartingAtNamedParamList(paList)
		return StzIsStartingAtNamedParamList(paList)

func StzIsStartingAtOrStartingAtPositionNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :StartingAt or paList[1] = :StartingAtPosition

	func IsStartingAtOrStartingAtPositionNamedParamList(paList)
		return StzIsStartingAtOrStartingAtPositionNamedParamList(paList)

func StzIsAtNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :At

	func IsAtNamedParamList(paList)
		return StzIsAtNamedParamList(paList)

func StzIsAtOrAtSubStringNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :At or paList[1] = :AtSubString

	func IsAtOrAtSubStringNamedParamList(paList)
		return StzIsAtOrAtSubStringNamedParamList(paList)

func StzIsAtOrAtItemNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :At or paList[1] = :AtItem

	func IsAtOrAtItemNamedParamList(paList)
		return StzIsAtOrAtItemNamedParamList(paList)

func StzIsInNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :In

	func IsInNamedParamList(paList)
		return StzIsInNamedParamList(paList)

func StzIsBoundedByNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :BoundedBy

	func IsBoundedByNamedParamList(paList)
		return StzIsBoundedByNamedParamList(paList)

func StzIsBoundedByOrBoundsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :BoundedBy or paList[1] = :Bounds

	func IsBoundedByOrBoundsNamedParamList(paList)
		return StzIsBoundedByOrBoundsNamedParamList(paList)

func StzIsBoundsOrBoundedByNamedParamList(paList)
	return StzIsBoundedByOrBoundsNamedParamList(paList)

	func IsBoundsOrBoundedByNamedParamList(paList)
		return StzIsBoundsOrBoundedByNamedParamList(paList)

func StzIsPatternNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Pattern

	func IsPatternNamedParamList(paList)
		return StzIsPatternNamedParamList(paList)

func StzIsWithOrByOrUsingNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :With or paList[1] = :By or paList[1] = :Using

	func IsWithOrByOrUsingNamedParamList(paList)
		return StzIsWithOrByOrUsingNamedParamList(paList)

func StzIsWhereNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Where

	func IsWhereNamedParamList(paList)
		return StzIsWhereNamedParamList(paList)

func StzIsFromNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :From or paList[1] = :FromPosition

	func IsFromNamedParamList(paList)
		return StzIsFromNamedParamList(paList)

func StzIsByNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :By or paList[1] = :By@

	func IsByNamedParamList(paList)
		return StzIsByNamedParamList(paList)

func StzIsEachNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Each or paList[1] = :Each@

	func IsEachNamedParamList(paList)
		return StzIsEachNamedParamList(paList)

func StzIsReturnedAsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :ReturnedAs

	func IsReturnedAsNamedParamList(paList)
		return StzIsReturnedAsNamedParamList(paList)

func StzIsBetweenNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Between

	func IsBetweenNamedParamList(paList)
		return StzIsBetweenNamedParamList(paList)

func StzIsItemNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Item

	func IsItemNamedParamList(paList)
		return StzIsItemNamedParamList(paList)

func StzIsWithNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :With or paList[1] = :With@

	func IsWithNamedParamList(paList)
		return StzIsWithNamedParamList(paList)

func StzIsOfOrOfSubStringNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Of or paList[1] = :OfSubString

	func IsOfOrOfSubStringNamedParamList(paList)
		return StzIsOfOrOfSubStringNamedParamList(paList)

func StzIsOrNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Or

	func IsOrNamedParamList(paList)
		return StzIsOrNamedParamList(paList)

func StzIsUsingOrWithOrByOrWhereNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Using or paList[1] = :With or paList[1] = :By or paList[1] = :Where

	func IsUsingOrWithOrByOrWhereNamedParamList(paList)
		return StzIsUsingOrWithOrByOrWhereNamedParamList(paList)

func StzIsPositionNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Position

	func IsPositionNamedParamList(paList)
		return StzIsPositionNamedParamList(paList)

func StzIsNorNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Nor

	func IsNorNamedParamList(paList)
		return StzIsNorNamedParamList(paList)

func StzIsInSectionNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :InSection

	func IsInSectionNamedParamList(paList)
		return StzIsInSectionNamedParamList(paList)

func StzIsThanNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Than

	func IsThanNamedParamList(paList)
		return StzIsThanNamedParamList(paList)

func StzIsToOrToPositionNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :To or paList[1] = :ToPosition

	func IsToOrToPositionNamedParamList(paList)
		return StzIsToOrToPositionNamedParamList(paList)

func StzIsWithOrUsingOrByNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :With or paList[1] = :Using or paList[1] = :By

	func IsWithOrUsingOrByNamedParamList(paList)
		return StzIsWithOrUsingOrByNamedParamList(paList)

func StzIsPositionOrPositionsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Position or paList[1] = :Positions

	func IsPositionOrPositionsNamedParamList(paList)
		return StzIsPositionOrPositionsNamedParamList(paList)

func StzIsPositionOrSubStringNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Position or paList[1] = :SubString

	func IsPositionOrSubStringNamedParamList(paList)
		return StzIsPositionOrSubStringNamedParamList(paList)

func StzIsAndThenNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :AndThen

	func IsAndThenNamedParamList(paList)
		return StzIsAndThenNamedParamList(paList)

func StzIsForNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :For

	func IsForNamedParamList(paList)
		return StzIsForNamedParamList(paList)

func StzIsSubStringNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :SubString

	func IsSubStringNamedParamList(paList)
		return StzIsSubStringNamedParamList(paList)

func StzIsUpToNCharsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :UpToNChars

	func IsUpToNCharsNamedParamList(paList)
		return StzIsUpToNCharsNamedParamList(paList)

func StzIsAsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :As

	func IsAsNamedParamList(paList)
		return StzIsAsNamedParamList(paList)

func StzIsNthNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Nth

	func IsNthNamedParamList(paList)
		return StzIsNthNamedParamList(paList)

func StzIsBeforeNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Before

	func IsBeforeNamedParamList(paList)
		return StzIsBeforeNamedParamList(paList)

func StzIsUsingNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Using

	func IsUsingNamedParamList(paList)
		return StzIsUsingNamedParamList(paList)

func StzIsAfterNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :After

	func IsAfterNamedParamList(paList)
		return StzIsAfterNamedParamList(paList)

func StzIsAtOrAtPositionNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :At or paList[1] = :AtPosition

	func IsAtOrAtPositionNamedParamList(paList)
		return StzIsAtOrAtPositionNamedParamList(paList)

func StzIsAtPositionNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :AtPosition

	func IsAtPositionNamedParamList(paList)
		return StzIsAtPositionNamedParamList(paList)

func StzIsAtPositionsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :AtPositions

	func IsAtPositionsNamedParamList(paList)
		return StzIsAtPositionsNamedParamList(paList)

func StzIsBeforePositionNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :BeforePosition

	func IsBeforePositionNamedParamList(paList)
		return StzIsBeforePositionNamedParamList(paList)

func StzIsAfterPositionNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :AfterPosition

	func IsAfterPositionNamedParamList(paList)
		return StzIsAfterPositionNamedParamList(paList)

func StzIsBeforeOrAfterNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Before or paList[1] = :After

	func IsBeforeOrAfterNamedParamList(paList)
		return StzIsBeforeOrAfterNamedParamList(paList)

func StzIsBetweenIBNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :BetweenIB

	func IsBetweenIBNamedParamList(paList)
		return StzIsBetweenIBNamedParamList(paList)

func StzIsBoundedByIBNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :BoundedByIB

	func IsBoundedByIBNamedParamList(paList)
		return StzIsBoundedByIBNamedParamList(paList)

func StzIsByOrWithNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :By or paList[1] = :With

	func IsByOrWithNamedParamList(paList)
		return StzIsByOrWithNamedParamList(paList)

func StzIsDirectionNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Direction

	func IsDirectionNamedParamList(paList)
		return StzIsDirectionNamedParamList(paList)

func StzIsDirectionOrGoingNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Direction or paList[1] = :Going

	func IsDirectionOrGoingNamedParamList(paList)
		return StzIsDirectionOrGoingNamedParamList(paList)

func StzIsEqualToNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :EqualTo

	func IsEqualToNamedParamList(paList)
		return StzIsEqualToNamedParamList(paList)

func StzIsFirstNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :First

	func IsFirstNamedParamList(paList)
		return StzIsFirstNamedParamList(paList)

func StzIsLastNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Last

	func IsLastNamedParamList(paList)
		return StzIsLastNamedParamList(paList)

func StzIsListNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :List

	func IsListNamedParamList(paList)
		return StzIsListNamedParamList(paList)

func StzIsRangeNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Range

	func IsRangeNamedParamList(paList)
		return StzIsRangeNamedParamList(paList)

func StzIsRespectivelyNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Respectively

	func IsRespectivelyNamedParamList(paList)
		return StzIsRespectivelyNamedParamList(paList)

func StzIsReturnTypeNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :ReturnType

	func IsReturnTypeNamedParamList(paList)
		return StzIsReturnTypeNamedParamList(paList)

func StzIsSectionsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Sections

	func IsSectionsNamedParamList(paList)
		return StzIsSectionsNamedParamList(paList)

func StzIsStringNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :String

	func IsStringNamedParamList(paList)
		return StzIsStringNamedParamList(paList)

func StzIsStringOrSubStringNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :String or paList[1] = :SubString

	func IsStringOrSubStringNamedParamList(paList)
		return StzIsStringOrSubStringNamedParamList(paList)

func StzIsSubStringsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :SubStrings

	func IsSubStringsNamedParamList(paList)
		return StzIsSubStringsNamedParamList(paList)

func StzIsSubStringOrSubStringsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :SubString or paList[1] = :SubStrings

	func IsSubStringOrSubStringsNamedParamList(paList)
		return StzIsSubStringOrSubStringsNamedParamList(paList)

func StzIsUsingOrByOrWithNamedParamList(paList)
	return StzIsWithOrByOrUsingNamedParamList(paList)

	func IsUsingOrByOrWithNamedParamList(paList)
		return StzIsUsingOrByOrWithNamedParamList(paList)

func StzIsUsingOrWithOrByNamedParamList(paList)
	return StzIsWithOrByOrUsingNamedParamList(paList)

	func IsUsingOrWithOrByNamedParamList(paList)
		return StzIsUsingOrWithOrByNamedParamList(paList)

func StzIsWithOrUsingNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :With or paList[1] = :Using

	func IsWithOrUsingNamedParamList(paList)
		return StzIsWithOrUsingNamedParamList(paList)

func StzIsWithOrUsingOrInNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :With or paList[1] = :Using or paList[1] = :In

	func IsWithOrUsingOrInNamedParamList(paList)
		return StzIsWithOrUsingOrInNamedParamList(paList)

func StzIsInOrInsideNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :In or paList[1] = :Inside

	func IsInOrInsideNamedParamList(paList)
		return StzIsInOrInsideNamedParamList(paList)

func StzIsOfTypeNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :OfType

	func IsOfTypeNamedParamList(paList)
		return StzIsOfTypeNamedParamList(paList)

func StzIsOrOrAndNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Or or paList[1] = :And

	func IsOrOrAndNamedParamList(paList)
		return StzIsOrOrAndNamedParamList(paList)

func StzIsStartingAtOrAfterNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :StartingAt or paList[1] = :After

	func IsStartingAtOrAfterNamedParamList(paList)
		return StzIsStartingAtOrAfterNamedParamList(paList)

func StzIsStartingAtOrBeforeNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :StartingAt or paList[1] = :Before

	func IsStartingAtOrBeforeNamedParamList(paList)
		return StzIsStartingAtOrBeforeNamedParamList(paList)

func StzIsStoppingAtNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :StoppingAt

	func IsStoppingAtNamedParamList(paList)
		return StzIsStoppingAtNamedParamList(paList)

func StzIsANamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :A

	func IsANamedParamList(paList)
		return StzIsANamedParamList(paList)

func StzIsNameOrNamedNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Name or paList[1] = :Named

	func IsNameOrNamedNamedParamList(paList)
		return StzIsNameOrNamedNamedParamList(paList)

func StzIsNCharsAfterNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :NCharsAfter

	func IsNCharsAfterNamedParamList(paList)
		return StzIsNCharsAfterNamedParamList(paList)

func StzIsNCharsBeforeNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :NCharsBefore

	func IsNCharsBeforeNamedParamList(paList)
		return StzIsNCharsBeforeNamedParamList(paList)

func StzIsLastCharsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :LastChars

	func IsLastCharsNamedParamList(paList)
		return StzIsLastCharsNamedParamList(paList)

func StzIsLastNCharsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :LastNChars

	func IsLastNCharsNamedParamList(paList)
		return StzIsLastNCharsNamedParamList(paList)

func StzIsNLastCharsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :NLastChars

	func IsNLastCharsNamedParamList(paList)
		return StzIsNLastCharsNamedParamList(paList)

func StzIsUpToOrUpToNItemsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :UpTo or paList[1] = :UpToNItems

	func IsUpToOrUpToNItemsNamedParamList(paList)
		return StzIsUpToOrUpToNItemsNamedParamList(paList)

func StzIsAndOrAndPositionOrAndSubStringNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :And or paList[1] = :AndPosition or paList[1] = :AndSubString

	func IsAndOrAndPositionOrAndSubStringNamedParamList(paList)
		return StzIsAndOrAndPositionOrAndSubStringNamedParamList(paList)

func StzIsOfOrToNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Of or paList[1] = :To

	func IsOfOrToNamedParamList(paList)
		return StzIsOfOrToNamedParamList(paList)

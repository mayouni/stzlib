
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
#   pItem = CheckParam(pItem, :Skipping = [:Of, :OfItem], :MustBe = :string)
#
# Or short form:
#
#   pItem = CheckParam(pItem, [:Of, :OfItem], :string)

  ///////////////////
 ///  CHECKPARAM  ///
///////////////////

# Two calling conventions:
#
#   Expressive:  CheckParam(pValue, :Skipping = [:Of, :OfItem], :MustBe = :string)
#   Short:       CheckParam(pValue, [:Of, :OfItem], :string)
#
# Both skip past the named-param wrapper (if any) and assert the type.
# When CheckingParams() is off, skipping still happens but type is not checked.

func CheckParam(pValue, p2, p3)

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

  ////////////////////////
 ///  CHECKPARAM (CS)  ///
////////////////////////

# Specialized form for the CaseSensitive parameter,
# the most frequent secondary param in Softanza.
#
#   pCaseSensitive = CheckParamCS(pCaseSensitive)

func CheckParamCS(pValue)
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

  ////////////////////////////
 ///  NAMED PARAM CHECKS  ///
////////////////////////////

# Low-level helpers for code that needs finer control
# than CheckParam() provides.

# Is this value a [:Keyword, value] pair with a registered keyword?
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

# Is this value a specific named param?
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

# Does this value match any of these named param keywords?
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
func IsOfNamedParamList(paList)
	if NOT isList(paList)
		return 0
	ok
	if len(paList) != 2
		return 0
	ok
	if NOT isString(paList[1])
		return 0
	ok
	return paList[1] = :Of

# Is this a [:CaseSensitive, 0/1] or [:CS, 0/1] pair?
func IsCaseSensitiveNamedParamList(paList)
	if NOT isList(paList)
		return 0
	ok
	if len(paList) != 2
		return 0
	ok
	if NOT isString(paList[1])
		return 0
	ok
	if NOT isNumber(paList[2])
		return 0
	ok
	if NOT (paList[1] = :CaseSensitive or paList[1] = :CS)
		return 0
	ok
	if NOT (paList[2] = 0 or paList[2] = 1)
		return 0
	ok
	return 1

# Is this a [:And, value] or [:And@, value] pair?
func IsAndNamedParamList(paList)
	if NOT isList(paList)
		return 0
	ok
	if len(paList) != 2
		return 0
	ok
	if NOT isString(paList[1])
		return 0
	ok
	return paList[1] = :And or paList[1] = :And@

# Is this a [:With, value], [:With@, value], [:By, value], or [:By@, value] pair?
func IsWithOrByNamedParamList(paList)
	if NOT isList(paList)
		return 0
	ok
	if len(paList) != 2
		return 0
	ok
	if NOT isString(paList[1])
		return 0
	ok
	cKey = paList[1]
	return cKey = :With or cKey = :With@ or cKey = :By or cKey = :By@

# Is this a [:To, value] pair?
func IsToNamedParamList(paList)
	if NOT isList(paList)
		return 0
	ok
	if len(paList) != 2
		return 0
	ok
	if NOT isString(paList[1])
		return 0
	ok
	return paList[1] = :To

func IsStartingAtNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :StartingAt

func IsStartingAtOrStartingAtPositionNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :StartingAt or paList[1] = :StartingAtPosition

func IsAtNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :At

func IsAtOrAtSubStringNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :At or paList[1] = :AtSubString

func IsAtOrAtItemNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :At or paList[1] = :AtItem

func IsInNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :In

func IsBoundedByNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :BoundedBy

func IsBoundedByOrBoundsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :BoundedBy or paList[1] = :Bounds

func IsBoundsOrBoundedByNamedParamList(paList)
	return IsBoundedByOrBoundsNamedParamList(paList)

func IsPatternNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Pattern

func IsWithOrByOrUsingNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :With or paList[1] = :By or paList[1] = :Using

func IsWhereNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Where

func IsFromNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :From or paList[1] = :FromPosition

func IsByNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :By or paList[1] = :By@

func IsEachNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Each or paList[1] = :Each@

func IsReturnedAsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :ReturnedAs

func IsBetweenNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Between

func IsItemNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Item

func IsWithNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :With or paList[1] = :With@

func IsOfOrOfSubStringNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Of or paList[1] = :OfSubString

func IsOrNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Or

func IsUsingOrWithOrByOrWhereNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Using or paList[1] = :With or paList[1] = :By or paList[1] = :Where

func IsPositionNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Position

func IsNorNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Nor

func IsInSectionNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :InSection

func IsThanNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Than

func IsToOrToPositionNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :To or paList[1] = :ToPosition

func IsWithOrUsingOrByNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :With or paList[1] = :Using or paList[1] = :By

func IsPositionOrPositionsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Position or paList[1] = :Positions

func IsPositionOrSubStringNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Position or paList[1] = :SubString

func IsAndThenNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :AndThen

func IsForNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :For

func IsSubStringNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :SubString

func IsUpToNCharsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :UpToNChars

func IsAsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :As

func IsNthNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Nth

func IsBeforeNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Before

func IsUsingNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Using

func IsAfterNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :After

func IsAtOrAtPositionNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :At or paList[1] = :AtPosition

func IsAtPositionNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :AtPosition

func IsAtPositionsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :AtPositions

func IsBeforePositionNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :BeforePosition

func IsAfterPositionNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :AfterPosition

func IsBeforeOrAfterNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Before or paList[1] = :After

func IsBetweenIBNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :BetweenIB

func IsBoundedByIBNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :BoundedByIB

func IsByOrWithNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :By or paList[1] = :With

func IsDirectionNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Direction

func IsDirectionOrGoingNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Direction or paList[1] = :Going

func IsEqualToNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :EqualTo

func IsFirstNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :First

func IsLastNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Last

func IsListNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :List

func IsRangeNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Range

func IsRespectivelyNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Respectively

func IsReturnTypeNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :ReturnType

func IsSectionsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Sections

func IsStringNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :String

func IsStringOrSubStringNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :String or paList[1] = :SubString

func IsSubStringsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :SubStrings

func IsSubStringOrSubStringsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :SubString or paList[1] = :SubStrings

func IsUsingOrByOrWithNamedParamList(paList)
	return IsWithOrByOrUsingNamedParamList(paList)

func IsUsingOrWithOrByNamedParamList(paList)
	return IsWithOrByOrUsingNamedParamList(paList)

func IsWithOrUsingNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :With or paList[1] = :Using

func IsWithOrUsingOrInNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :With or paList[1] = :Using or paList[1] = :In

func IsInOrInsideNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :In or paList[1] = :Inside

func IsOfTypeNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :OfType

func IsOrOrAndNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Or or paList[1] = :And

func IsStartingAtOrAfterNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :StartingAt or paList[1] = :After

func IsStartingAtOrBeforeNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :StartingAt or paList[1] = :Before

func IsStoppingAtNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :StoppingAt

func IsANamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :A

func IsNameOrNamedNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Name or paList[1] = :Named

func IsNCharsAfterNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :NCharsAfter

func IsNCharsBeforeNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :NCharsBefore

func IsLastCharsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :LastChars

func IsLastNCharsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :LastNChars

func IsNLastCharsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :NLastChars

func IsUpToOrUpToNItemsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :UpTo or paList[1] = :UpToNItems

func IsAndOrAndPositionOrAndSubStringNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :And or paList[1] = :AndPosition or paList[1] = :AndSubString

func IsOfOrToNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Of or paList[1] = :To


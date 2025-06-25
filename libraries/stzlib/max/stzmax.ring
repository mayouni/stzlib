# This file loads the MAX layer of SoftanzaLib (along with it's CORE and BASE layers)

# Loading the Softanza Base layer (which loads Core layer in behind)

	load "../base/stzbase.ring"

# Loading files related to the COMMON module

	load "common/stzWalker.ring"
	load "common/stzListOfWalkers.ring"
	load "common/stzWalker2D.ring"
	load "common/stzListOfWalkers2D.ring"
	load "common/stzParser.ring"

# Loading files related to the DATA module

	load "data/stzBoxDrawCharsData.ring"
	load "data/stzConstraintsData.ring"
	load "data/stzLocaleData.ring"
	load "data/stzStopWordsData.ring"
	load "data/stzStringArtData.ring"

# Loading files related to OBJECT module

	#TODO // Abstract stzTrueObject, stzFalseObject, stzNullObject,
	# and stzNamedObject here in the MAX layer

# Loading files related to the NUMBER module

	load "number/stzBigNumber.ring"
	load "number/stzListOfListsOfNumbers.ring"
	load "number/stzListOfPairsOfNumbers.ring"

	load "number/stzNumberLowLevelType.ring"
	load "number/stzPairOfNumbers.ring"

# Loading files related to STRING module

	load "string/stzMultiString.ring"
	load "string/stzSringConstraints.ring"
	load "string/stzTextEncoding.ring"

# Loading files related to the LIST module

	load "list/stzList2D.ring"
	load "list/stzListParser.ring"
	load "list/stzListProvidedAsString.ring"

	load "list/stzSortedList.ring"
	load "list/stzPivotTable.ring"
	load "list/stzPivotTableShow.ring"

	load "list/stzTree.ring"

	load "list/stzGrid.ring"
	load "list/stzListOfGrids.ring"
	load "list/stzTile.ring"

# Loading files related to the SYSTEM module

	load "system/stzBinaryFile.ring"

# Loading files related to the TEST module

	load "test/stzTestoor.ring"

# Loading files related to the ERROR module

	load "error/stzCountryError.ring"
	load "error/stzCurrencyError.ring"
	load "error/stzEntityError.ring"
	load "error/stzGridError.ring"
	load "error/stzLanguageError.ring"
	load "error/stzListOfEntitiesError.ring"
	load "error/stzListOfSetsError.ring"
	load "error/stzLocaleError.ring"
	load "error/stzMultiStringError.ring"
	load "error/stzScriptError.ring"
	load "error/stzSetError.ring"
	load "error/stzTextEncodingSystemError.ring"

# Loading files related to WINGS modules

	load "wings/stzwings.ring"


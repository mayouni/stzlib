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
	load "data/stzCharData.ring"
	load "data/stzConstraintsData.ring"
	load "data/stzLocaleData.ring"
	load "data/stzRandomData.ring"
	load "data/stzRegexData.ring"
	load "data/stzStopWordsData.ring"
	load "data/stzStringArtData.ring"
	load "data/stzUnicodeData.ring"

# Loading files related to the DATAPHORE module

	load "dataphore/stzDataModel.ring"

# Loading files related to the ERROR module

	load "error/stzCharError.ring"
	load "error/stzCountryError.ring"
	load "error/stzCurrencyError.ring"
	load "error/stzEntityError.ring"
	load "error/stzGridError.ring"
	load "error/stzLanguageError.ring"
	load "error/stzListOfCharsError.ring"
	load "error/stzListOfEntitiesError.ring"
	load "error/stzListOfSetsError.ring"
	load "error/stzLocaleError.ring"
	load "error/stzMultiStringError.ring"
	load "error/stzScriptError.ring"
	load "error/stzSetError.ring"
	load "error/stzTextEncodingSystemError.ring"

# Loading files related to the GEO module

	load "geo/stzGeoMap.ring"

# Loading files related to the I18N module

	load "i18n/stzCountry.ring"
	load "i18n/stzCurrency.ring"
	load "i18n/stzDate.ring"
	load "i18n/stzLanguage.ring"
	load "i18n/stzLocale.ring"
	load "i18n/stzScript.ring"
	load "i18n/stzStopWords.ring"
	load "i18n/stzTime.ring"

# Loading files related to the EXCIS module

	load "io/stzBinaryFile.ring"

# Loading files related to the EXCIS module

	load "excis/stzExtCode.ring"
	load "excis/stzExtCodeTransFuncs.ring"
	load "excis/stzExtCodeXT.ring"
	load "excis/stzJuliaCode.ring"
	load "excis/stzPrologCode.ring"
	load "excis/stzPythonCode.ring"
	load "excis/stzRCode.ring"

# Loading files related to the LIST module

	load "list/stzList2D.ring"
	load "list/stzListFormatter.ring"
	load "list/stzListParser.ring"
	load "list/stzListProvidedAsString.ring"
	load "list/stzSortedList.ring"

# Loading files related to the TREE module

	load "tree/stzTree.ring"

# Loading files related to the GRID module

	load "grid/stzGrid.ring"
//	load "grid/stzListOfGrids.ring"
	load "grid/stzTile.ring"

# Loading files related to the TABLE module

	load "table/stzTable.ring"
	load "table/stzListOfTables.ring"

	load "table/stzPivotTable.ring"
	load "table/stzPivotTableShow.ring"

# Loading files related to the NATURAL module

	load "natural/stzAdverb.ring"
	load "natural/stzCCode.ring"
	load "natural/stzChainOfTruth.ring"

	load "natural/stzChainOfValue.ring"
	load "natural/stzConstraints.ring"

	load "natural/stzEntity.ring"
	load "natural/stzListOfEntities.ring"

	load "natural/stzNatural.ring"

	load "natural/stzNaturalCode.ring"
	load "natural/stzPlural.ring"

	load "natural/stzSingular.ring"
	load "natural/stzText.ring"

# Loading files related to the NUMBER module

	load "number/stzBigNumber.ring"
	load "number/stzListOfListsOfNumbers.ring"
	load "number/stzListOfPairsOfNumbers.ring"

	load "number/stzNumberLowLevelType.ring"
	load "number/stzPairOfNumbers.ring"

# Loading files related to the MATH module

	load "math/stzMatrix.ring"
	load "math/stzRandom.ring"

# Loading files related to the STATS module

	load "stats/stzDataSet.ring"
	load "stats/stzDataWrangler.ring"

# Loading files related to the SOLVERS module

	load "solvers/stzLinearSolver.ring"
	load "solvers/stzCoeffExtractor.ring"

# Loading files related to PERF module

	load "perf/stzFastPro.ring" 				# Used by /math/stzMatrix.ring
	load "perf/stzFastProBinary.ring"

	load "perf/stzDataPerfEngine.ring" 	# Used by /dataphore/stzDataModel.ring

# Loading files related to OBJECT module

	#TODO // Abstract stzTrueObject, stzFalseObject, stzNullObject,
	# and stzNamedObject here in the MAX layer


# Loading files related to STRING module

	load "string/stzMultiString.ring"
	load "string/stzSringConstraints.ring"

# Loading files related to REGEX module

	load "regex/stzRegex.ring"
	load "regex/stzRegexMaker.ring"
	load "regex/stzListex.ring"
	load "regex/stzRegexuter.ring"
	#NOTE // we hava also stzRegexData.ring in /data/ folder

# Loading files related to the SYSTEMS module

	load "systems/stzArchitectureSystem.ring"
	load "systems/stzProfilingSystem.ring"
	load "systems/stzRingStateSystem.ring"
	load "systems/stzTextEncodingSystem.ring"

	# load "systems/stzCodeAnalysisSystem.ring"
	# load "systems/stzCoordinateSystem.ring"
	# load "systems/stzErrorSystem.ring"
	# load "systems/stzEventSystem.ring"
	# load "systems/stzMarketSystem.ring"
	# load "systems/stzPluginSystem.ring"
	# load "systems/stzSimulationSystem.ring"
	# load "systems/stzSocialSystem.ring"
	# load "systems/stzTranslationSystem.ring"

# Loading files related to the TEST module

	load "test/stzTestoor.ring"

# Loading files related to the WEB module

	load "web/stzAppServer.ring"
	# load "web/stzExterServer.ring" #TODO
	# load "web/ringjs.ring"

# Loading files related to the ZAI module

	# load "zai/nothing.ring"

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

# Loading files related to the DATAPHORE module

	load "dataphore/stzDataModel.ring"
	load "dataphore/stzDataModel.ring"

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

# Loading files related to the EXCIS module

	load "excis/stzExtCodeTransFuncs.ring"
	load "excis/stzExtCodeXT.ring"
	load "excis/stzJuliaCode.ring"
	load "excis/stzPrologCode.ring"
	load "excis/stzPythonCode.ring"
	load "excis/stzRCode.ring"

# Loading files related to the GEO module

	load "geo/stzGeoMap.ring"

# Loading files related to the GRID module

	load "grid/stzGrid.ring"
	load "grid/stzListOfGrids.ring"
	load "grid/stzTile.ring"

# Loading files related to the I18N module

	load "i18n/stzCountry.ring"
	load "i18n/stzCurrency.ring"
	load "i18n/stzDate.ring"
	load "i18n/stzLanguage.ring"
	load "i18n/stzLocale.ring"
	load "i18n/stzScript.ring"
	load "i18n/stzStopWords.ring"
	load "i18n/stzTime.ring"

# Loading files related to the IO module

	load "io/stzBinaryFile.ring"

# Loading files related to the LIST module

	load "list/stzList2D.ring"
	load "list/stzListParser.ring"
	load "list/stzListProvidedAsString.ring"
	load "list/stzSortedList.ring"

# Loading files related to the MATH module

	load "math/stzMatrix.ring"
	load "math/stzFastPro.ring"
	load "math/stzFastProBinary.ring"

# Loading files related to the NATURAL module

	load "natural/stzAdverb.ring"
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


# Loading files related to OBJECT module

	#TODO // Abstract stzTrueObject, stzFalseObject, stzNullObject,
	# and stzNamedObject here in the MAX layer

# Loading files related to PLOT module

	load "plot/stzPlot.ring"
	load "plot/stzBarPlot.ring"
	load "plot/stzHBarPlot.ring"
	load "plot/stzHistogram.ring"
	load "plot/stzMBarPlot.ring"
	load "plot/stzScatterPlot.ring"
	load "plot/stzSurfacePlot.ring"

# Loading files related to PLUGINS module

	load "plugins/stzPluginSystem.ring"

# Loading files related to REGEX module

	load "regex/stzListex.ring"
	load "regex/stzRegexuter.ring"

# Loading files related to the SOLVERS module

	load "solvers/stzLinearSolver.ring"
	load "solvers/stzCoeffExtractor.ring"


# Loading files related to the STATS module

	load "stats/stzDataSet.ring"
	load "stats/stzDataWrangler.ring"

# Loading files related to STRING module

	load "string/stzMultiString.ring"
	load "string/stzSringConstraints.ring"
	load "string/stzTextEncoding.ring"


# Loading files related to the TABLE module

	load "table/stzPivotTable.ring"
	load "table/stzPivotTableShow.ring"


# Loading files related to the TEST module

	load "test/stzTestoor.ring"

# Loading files related to the TREE module

	load "tree/stzTree.ring"

# Loading files related to the WEB module

	load "web/stzAppServer.ring"
	# load "web/stzExterServer.ring" #TODO
	# load "web/ringjs.ring"

# Loading files related to the ZAI module

	# load "zai/stzZai.ring"

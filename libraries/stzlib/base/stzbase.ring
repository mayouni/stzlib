# This file loads the BASE layer of SoftanzaLib (along with its CORE layer)


# Loding the files related to the CORE layer

	load "../core/stzcore.ring"	

# Loading files related tp the COMMON module

	load "common/stzCounter.ring"
	load "common/stzFuncs.ring"
	load "common/stzNamedParams.ring" #TODO Use it instead the equivalent code in stzList

	load "common/stzOccurrences.ring"
	load "common/stzQtFuncs.ring"
	load "common/stzRingFuncs.ring"

	load "common/stzRingLibs.ring"
	load "common/stzSmallFuncs.ring"
	load "common/stzSplitter.ring"

	load "common/stzCCode.ring"
	load "common/stzNamedVars.ring"

# Loading files related to the DATA module

	load "data/stzCharData.ring"
	load "data/stzUnicodeData.ring"
	load "data/stzLocaleData.ring"
	load "data/stzRegexData.ring"
	load "data/stzRandomData.ring"

# Loading files related to the OBJECT module

	load "object/stzObject.ring"
	load "object/stzObjectHistory.ring"

	load "object/stzListOfObjects.ring"
	load "object/stzListOfNamedObjects.ring"
	load "object/stzNullObject.ring"
	load "object/stzTrueObject.ring"
	load "object/stzFalseObject.ring"

# Loading files related to the NUMBER module

	load "number/stzNumber.ring" #TODO Check compatibiiliy with stkNumber in CORE layer
	load "number/stzListOfNumbers.ring"

	load "number/stzBinaryNumber.ring"
	load "number/stzDecimalToBinary.ring"
	load "number/stzHexNumber.ring"
	load "number/stzOctalNumber.ring"

	load "number/stzListOfBytes.ring"

	load "number/stzRandom.ring"
	load "number/stzSciNumber.ring"

	load "number/stzFastPro.ring"
	load "number/stzMatrix.ring"

# Loading files related to the STRING module

	load "string/stzStringFuncs.ring"
	load "string/stzString.ring"

	load "string/stzListOfStrings.ring"
	load "string/stzBoxedString.ring"
	load "string/stzChar.ring"
	load "string/stzListOfChars.ring"
	load "string/stzListOfUnicodes.ring"
	load "string/stzStringArt.ring"
	load "string/stzSubString.ring"

	load "string/stzText.ring"
	load "string/stzStopWords.ring"

# Loading files related to REGEX module

	load "regex/stzRegex.ring"
	load "regex/stzRegexMaker.ring"
	load "regex/stzListex.ring"
	load "regex/stzNumbrex.ring"
	load "regex/stzTimex.ring"

	load "regex/stzGraphex.ring"

	load "regex/stzListexuter.ring"
	load "regex/stzRegexuter.ring"

# Loading files related to the LIST module

	load "list/stzHashList.ring"
	load "list/stzItem.ring"
	load "list/stzList.ring"
	load "list/stzListInString.ring"

	load "list/stzListOfHashlists.ring"
	load "list/stzListOfLists.ring"
	load "list/stzListOfPairs.ring"
	load "list/stzListOfSections.ring"

	load "list/stzListOfSets.ring"
	load "list/stzListPaths.ring"
	load "list/stzListShow.ring"
	load "list/stzPair.ring"

	load "list/stzPairOfLists.ring"
	load "list/stzSection.ring"
	load "list/stzSet.ring"
	load "list/stzSetOfSections.ring"

	load "list/stzTable.ring"
	load "list/stzListOfTables.ring"

# Loading files related to the GRAPH module

	load "graph/stzGraph.ring"
	load "graph/stzDiagram.ring"

# Loading files related to SYSTEM module

	load "system/stzMemoryGlobals.ring"
	load "system/stzMemoryConvertors.ring"
	load "system/stzOperatingSystem.ring"

	load "system/stzMemoryProfiler.ring"
	load "system/stzMemoryProfiler32Bit.ring"
	load "system/stzMemoryProfiler64Bit.ring"

	load "system/stzProfilingTimer.ring"

	load "system/stzPointer.ring"

	load "system/stzUUID.ring"

# Loading files related to the FILE module

	load "file/stzFile.ring"
	load "file/stzZipFile.ring"

	load "file/stzFolder.ring"

	load "file/stzJson.ring"
	load "file/stzCSV.ring"
	load "file/stzHtml.ring"

# Loading files related to the ERROR module

	load "error/stzObjectError.ring"
	load "error/stzStringError.ring"

	load "error/stzCounterError.ring"
	load "error/stzFileError.ring"

	load "error/stzListError.ring"
	load "error/stzListOfBytesError.ring"
	load "error/stzListOfStringsError.ring"

	load "error/stzNumberError.ring"
	load "error/stzBinaryNumberError.ring"
	load "error/stzHexNumberError.ring"
	load "error/stzOctalNumberError.ring"
	load "error/stzDecimalToBinaryError.ring"

	load "error/stzCountryError.ring"

# Loading files related to the DATETIME module

	load "datetime/stzDate.ring"
	load "datetime/stzTime.ring"
	load "datetime/stzDateTime.ring"
	load "datetime/stzDuration.ring"
	load "datetime/stzTimeLine.ring"
	load "datetime/stzCalendar.ring"

	load "datetime/stzListOfTimeLines.ring"

# Loading files related to the I18N module

	load "i18n/stzCountry.ring"
	load "i18n/stzCurrency.ring"
	load "i18n/stzLanguage.ring"
	load "i18n/stzLocale.ring"
	load "i18n/stzScript.ring"
	load "i18n/stzCurrency.ring"

# Loading files related to the EXTINCODE module

	load "extincode/stzExtinCode.ring"
	load "extincode/stzExtinCSharp.ring"
	load "extincode/stzExtinPython.ring"
	load "extincode/stzExtinJS.ring"
	load "extincode/stzExtinSql.ring"
	load "extincode/stzExtinPerl.ring"
	load "extincode/stzExtinC.ring"

# Loading files related to the EXERCODE module

	load "extercode/stzExterCode.ring"
	load "extercode/stzPythonCode.ring"
	load "extercode/stzRCode.ring"
	load "extercode/stzJuliaCode.ring"
	load "extercode/stzPrologCode.ring"

	load "extercode/stzDotCode.ring"
	load "extercode/stzDiagramBuilder.ring"

# Loading files related to the NEtwORK module

	load "network/stzNetwork.ring"
	load "network/stzHttpClient.ring"
	load "network/stzWebSocket.ring"
	load "network/stzTcpClient.ring"
	load "network/stzTcpServer.ring"
	load "network/stzNetworkUtils.ring"

# Loading files related to the REACTIVE module

	load "reactive/stzReactiveGlobals.ring"
	load "reactive/stzReactive.ring"
	load "reactive/stzReactiveTask.ring"

	load "reactive/stzReactiveFunc.ring"
	load "reactive/stzReactiveObject.ring"

	load "reactive/stzReactiveTimer.ring"
	load "reactive/stzReactiveStream.ring"
	load "reactive/stzReactiveHttp.ring"

# Loading files related to APPSERVER module (FUTURE)

	load "appserver/stzAppServer.ring"
	load "appserver/stzAppRequest.ring"
	load "appserver/stzAppResponse.ring"
	load "appserver/stzAppRouter.ring"
	load "appserver/stzComputeEngine.ring"
	load "appserver/stzContextPool.ring"

# Loading files related to CLUSTER module (FUTURE)

	load "cluster/stzCluster.ring"
	load "cluster/stzClusterNode.ring"
	load "cluster/stzRequestClassifier.ring"
	load "cluster/stzLoadBalancer.ring"
	load "cluster/stzClusterManager.ring"
	load "cluster/stzClusterMonitor.ring"

# Loading files related to NATURAL module

	load "natural/stzChainOfTruth.ring"
	load "natural/stzChainOfValue.ring"
	load "natural/stzConstraints.ring"

	load "natural/stzEntity.ring"
	load "natural/stzListOfEntities.ring"

	load "natural/stzNaturalCode.ring"
	load "natural/stzNatural.ring"

	load "natural/stzAdverb.ring"
	load "natural/stzPlural.ring"
	load "natural/stzSingular.ring"
	load "natural/stzOrdinal.ring"

# Loading files related to STATS module

	load "stats/stzDataSet.ring"
	load "stats/stzBarPlot.ring"
	load "stats/stzHBarPlot.ring"
	load "stats/stzMBarPlot.ring"
	load "stats/stzSurfacePlot.ring"
	load "stats/stzScatterPlot.ring"
	load "stats/stzHistogram.ring"
	load "stats/stzDataWRangler.ring"
	load "stats/stzCoeffExtractor.ring"
	load "stats/stzLinearSolver.ring"


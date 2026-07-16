# This file loads the BASE layer of SoftanzaLib (along with its CORE layer)

# Giving priority to user code config (suggested by Mahmoud)
if NOT isGlobal(:$aStzLibConfig ) #TODO // Make it a stzlibconfig.ring file
    $aStzLibConfig = []
ok

// tz0 = clock()

# Loding the files related to the CORE layer

    load "../core/stzCore.ring" 

# Loading files related tp the COMMON module

    load "common/stzIntSeq.ring"
    load "common/stzCounter.ring"
    load "common/stzFuncs.ring"

    load "common/stzOccurrences.ring"
    load "common/stzRingFuncs.ring"

    load "common/stzRingLibs.ring"
    load "common/stzPrimitives.ring"
    load "common/stzNamedParams.ring"
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
    load "data/stzSystemCallData.ring"

    # stzDatabase -- the sqlite-backed data store (data domain, R7)
    load "data/stzDatabase.ring"

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
    load "number/stzPairOfNumbers.ring"

    load "number/stzBinaryNumber.ring"
    load "number/stzDecimalToBinary.ring"
    load "number/stzHexNumber.ring"
    load "number/stzOctalNumber.ring"

    load "number/stzListOfBytes.ring"

    load "number/stzRandom.ring"
    load "number/stzSciNumber.ring"

    # stzFastPro deprecated 2026-06-13 (M-DEP1): wrapped the RingFastPro
    # C++ extension whose only consumer was its own test suite. Engine
    # stzMatrix covers the hot paths; the file is preserved under
    # base/archive/number/ for reference.
    load "number/stzMatrix.ring"

# Loading files related to the STRING module

    load "string/stzStringFunc.ring"
    load "string/stzString.ring"

    load "string/stzStringList.ring"
    load "string/stzStringBoxed.ring"
    load "string/stzStringChar.ring"
    load "string/stzStringCharList.ring"
    load "string/stzStringUnicodeList.ring"
    load "string/stzStringSubString.ring"

    load "string/stzStringText.ring"

    # linguistic/ -- TEXT PROCESSING / NLP as a domain (R3): stzText is
    # its ENTRY OBJECT (promoted from natural/, which keeps
    # language-as-code only). It is
    # loaded here (early) because it depends on stzStringText, loaded just above.
    load "linguistic/stzParseTree.ring"
    load "linguistic/stzText.ring"
    # stzListOfTexts (from stzStringList): a list of texts (sentences carry
    # meaning) with the natural/meaning list ops. SentencesQ() returns it.
    load "linguistic/stzListOfTexts.ring"
    load "linguistic/stzCorpus.ring"

    # Modern / neural domain (base/neural/): stzNeural base -> engine + model
    load "neural/stzNeural.ring"
    load "neural/stzNeuralEngine.ring"
    load "neural/stzNeuralModel.ring"
    load "neural/stzLLMFunction.ring"

    # Reflection: self-describing objects -- harvest a class's methods + docs from
    # source, then Ask()/ExplainMethod() via the neural tier (near-natural
    # programming, no heavy LLM). Loaded after neural (uses its globals at runtime).
    load "reflect/stzReflectFuncs.ring"

    # meta/ -- the library's knowledge of ITSELF as a domain (R2):
    # self-doc (promoted from reflect/, which keeps the parsing
    # primitives), structure (stzCodeGraph), runnable house rules
    # (stzCodeRules), governance checks + signable predicate sets.
    load "meta/stzSelfDoc.ring"
    load "meta/stzLibDoc.ring"
    load "meta/stzCodeGraph.ring"
    load "meta/stzRingCodeGraph.ring"
    load "meta/stzPyCodeGraph.ring"
    load "meta/stzJsCodeGraph.ring"
    load "meta/stzCodeRules.ring"
    load "meta/stzGovernanceChecks.ring"
    load "meta/stzPredicateSet.ring"

    load "string/stzWordStream.ring"

    # Modular subclasses

    load "string/stzStringFinder.ring"
    load "string/stzStringReplacer.ring"
    load "string/stzStringSplitter.ring"

    load "string/stzStringBounder.ring"
    load "string/stzStringChecker.ring"
    load "string/stzStringFormatter.ring"

    load "string/stzStringWalker.ring"
    load "string/stzStringVisualizer.ring"

    load "string/stzStringLines.ring"
    load "string/stzStringWords.ring"
    load "string/stzStringEncoder.ring"
    load "string/stzStringNumbers.ring"
    load "string/stzStringDuplicates.ring"
    load "string/stzStringCode.ring"
    load "string/stzStringIO.ring"
    load "string/stzStringRandomizer.ring"
    load "string/stzStringLocale.ring"
    load "string/stzStringCrypto.ring"

    load "string/stzStringRemover.ring"
    load "string/stzStringInserter.ring"
    load "string/stzStringCounter.ring"
    load "string/stzStringSections.ring"
    load "string/stzStringGetter.ring"
    load "string/stzStringExtractor.ring"
    load "string/stzStringTrimmer.ring"
    load "string/stzStringComparator.ring"
    load "string/stzStringLeadTrail.ring"
    load "string/stzStringPerformer.ring"
    load "string/stzStringConcat.ring"
    load "string/stzStringCaseChanger.ring"
    load "string/stzStringAligner.ring"
    load "string/stzTextStream.ring"

# Loading files related to REGEX module

    load "regex/stzRegex.ring"
    load "regex/stzRegexMaker.ring"
    load "regex/stzListex.ring"
    load "regex/stzNumbrex.ring"
    load "regex/stzTimex.ring"
    load "regex/stzMatrex.ring"
    load "regex/stzTablex.ring"
    load "regex/stzGraphex.ring"

    load "regex/stzListexUter.ring"
    load "regex/stzRegexUter.ring"

# Loading files related to the LIST module

    load "list/stzHashList.ring"
    load "list/stzItem.ring"
    load "list/stzList.ring"
    load "list/stzDeepList.ring"
    load "list/stzListInString.ring"

    load "list/stzListOfHashLists.ring"
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

# Loading files related to the TABLE module

    load "table/stzTable.ring"

    load "table/stzTableFinder.ring"
    load "table/stzTableColumnAccess.ring"
    load "table/stzTableRowAccess.ring"
    load "table/stzTableCellAccess.ring"
    load "table/stzTableSearch.ring"
    load "table/stzTableReplacer.ring"
    load "table/stzTableStructure.ring"
    load "table/stzTableSubset.ring"
    load "table/stzTableSorter.ring"
    load "table/stzTableAggregator.ring"
    load "table/stzTableDisplay.ring"

    load "table/stzListOfTables.ring"

    load "list/stzGrid.ring"
    load "list/stzList2D.ring"
    load "list/stzListOfGrids.ring"
    load "list/stzListParser.ring"
    load "list/stzListProvidedAsString.ring"
    load "table/stzPivotTable.ring"
    load "table/stzPivotTableShow.ring"
    load "list/stzSortedList.ring"
    load "list/stzTile.ring"
    load "list/stzTree.ring"

    # List global functions and Q-constructors

    load "list/stzListFunc.ring"

    # Modular subclasses (domain modules — base layer)

    load "list/stzListFinder.ring"
    load "list/stzListReplacer.ring"
    load "list/stzListRemover.ring"
    load "list/stzListInserter.ring"
    load "list/stzListSorter.ring"
    load "list/stzListWalker.ring"
    load "list/stzListChecker.ring"
    load "list/stzListDuplicates.ring"
    load "list/stzListBounder.ring"
    load "list/stzListFlattener.ring"
    load "list/stzListCounter.ring"
    load "list/stzListSections.ring"
    load "list/stzListRandom.ring"
    load "list/stzListSplits.ring"
    load "list/stzListStringify.ring"
    load "list/stzListNamedParams.ring"
    load "list/stzListGetter.ring"
    load "list/stzListExtractor.ring"
    load "list/stzListTrimmer.ring"
    load "list/stzListMover.ring"
    load "list/stzListClassifier.ring"
    load "list/stzListComparator.ring"
    load "list/stzListLeadTrail.ring"
    load "list/stzListPerformer.ring"
    load "list/stzListMerger.ring"

# Loading files related to the GRAPH module

    load "graph/stzGraph.ring"
    load "graph/stzGraphRule.ring"

    load "graph/stzGraphQuery.ring"
    load "graph/stzGraphView.ring"

    load "graph/stzGraphPlanner.ring"
    load "graph/stzGraphGoal.ring"
    load "graph/stzKnowledgeGraph.ring"

    load "graph/stzDiagram.ring"
    load "graph/stzDiagramColor.ring"

    load "graph/stzOrgChart.ring"

    load "graph/stzWorkflow.ring"

# Loading files related to the ENGINE WRAPPER modules

    load "common/stzStateMachine.ring"
    load "common/stzValidator.ring"
    load "common/stzCache.ring"
    load "common/stzConstraint.ring"
    load "number/stzSequence.ring"
    load "common/stzRelation.ring"
    load "number/stzSimilarity.ring"
    load "common/stzEngineTimeline.ring"
    load "common/stzCancelToken.ring"
    load "common/stzRetryBudget.ring"
    load "common/stzLatencyHistogram.ring"
    load "common/stzRateLimiter.ring"
    load "common/stzRequestSigner.ring"
    load "common/stzTraceContext.ring"
    load "graph/stzGridNav.ring"

# Loading files related to the VISUAL module

    #TODO// Put here all visual-oriented functions and classes

# Loading files related to SYSTEM module

    # NOTE: stzProfiler.ring is a demo script, not a loadable module
    load "system/stzSystemCall.ring"

    load "system/stzMemoryGlobals.ring"
    load "system/stzMemoryConvertors.ring"
    load "system/stzOperatingSystem.ring"

    load "system/stzMemoryProfiler.ring"
    load "system/stzMemoryProfiler32Bit.ring"
    load "system/stzMemoryProfiler64Bit.ring"

    load "system/stzProfilingTimer.ring"

    load "system/stzPointer.ring"

    load "system/stzUUID.ring"     # Engine-backed UUID v4 (Zig)

# Loading files related to the FILE module

    load "file/stzFile.ring"
    load "file/stzZipFile.ring"

    load "file/stzFolder.ring"

    load "file/stzJson.ring"
    load "file/stzCSV.ring"
    load "file/stzHtml.ring"     # Engine-backed HTML parser (Zig)

    load "file/stzFolderWatcher.ring"  # Engine-backed folder watcher (Zig)

# Loading the YIELDER module (functional map/filter/reduce)

    load "list/stzYielder.ring"

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
    load "error/stzError.ring"

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
    load "extercode/stzQmlCode.ring"

# Loading files related to the NETWORK module

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

    # stzReactor / stzReactorPool -- the vendored-libuv reactor surface
    # (real async; the declarative Reaxis surface above is being re-based
    # onto this -- see the R7 reactive-substrate work)
    load "reactive/stzReactor.ring"
    load "reactive/stzReactorPool.ring"
    load "reactive/stzEventBus.ring"

# Loading files related to APPSERVER module (FUTURE)

    load "app/stzApp.ring"
    load "app/stzSuperApp.ring"

    load "appserver/stzAppServer.ring"
    load "appserver/stzAppRequest.ring"
    load "appserver/stzAppResponse.ring"
    load "appserver/stzAppRouter.ring"

# cluster/ -- THE SCALE PLANE (R8): the delivery plane's horizontal
# axis. Specialization is a WORKER PROFILE (capability tag + resource
# budget) over the ONE resident engine, NOT a preloading class tree
# (5.10 ruling; section 7). R8.1 = the worker model. The pre-engine
# stzCluster* prototype it replaced is DELETED, not kept as tombstones:
# superseded code that still loads is still debt (it carried its own
# conventions, its own tests, and a second answer to a settled question).

    load "cluster/stzWorkerProfile.ring"
    load "cluster/stzFacetCatalog.ring"
    load "cluster/stzWorkerPool.ring"
    load "cluster/stzClusterTelemetry.ring"
    load "cluster/stzAppCluster.ring"
    load "cluster/stzClusterSupervisor.ring"
    load "cluster/stzComputePipeline.ring"
    load "cluster/stzComputeFederation.ring"

    load "cluster/stzRequestClassifier.ring"

# Loading files related to NATURAL module

    load "natural/stzChainOfTruth.ring"
    load "natural/stzChainOfValue.ring"

    load "natural/stzEntity.ring"
    load "natural/stzListOfEntities.ring"
    load "natural/stzKnowledgeWorld.ring"

    load "natural/stzNaturalCode.ring"
    load "natural/stzNNL.ring"
    load "natural/stzQuestion.ring"
    load "natural/stzConstraints.ring"
    load "natural/stzTruthChain.ring"
    load "natural/stzSemanticResolver.ring"
    load "natural/stzNatural.ring"
    load "natural/stzNaturalLangData.ring"

    # conversation/ -- CONVERSATIONAL PROGRAMMING as a domain (R3b):
    # stzConversation (entry) runs the wise-coding loop over the R1
    # knowledge graph; stzGoal generates questions from gaps;
    # stzNarration is the system's side of the dialogue.
    load "conversation/stzNarration.ring"
    load "conversation/stzGoal.ring"
    load "conversation/stzConversation.ring"

    # learning/ -- MODEL CREATION as a domain (R4, step 0: the classic
    # ML floor -- zero-setup, fully explainable learners riding
    # stzTrainingSet + stzSimilarity + the linguistic domain).
    load "learning/stzTrainingSet.ring"
    load "learning/stzKnn.ring"
    load "learning/stzNaiveBayes.ring"
    load "learning/stzDecisionTree.ring"
    load "learning/stzApriori.ring"
    load "learning/stzKMeans.ring"
    load "learning/stzLogisticRegression.ring"
    load "learning/stzModelEval.ring"
    load "learning/stzNeuralNetwork.ring"
    load "learning/stzTrainer.ring"
    load "learning/stzDLM.ring"

    # governance/ -- PROGRAMMATIC GOVERNANCE as declarable contracts
    # (R4b): risk tiers, permission-vs-authority, commitment states,
    # decommission contracts, decision lineage, trust postures.
    load "governance/stzGovernance.ring"

    # platform/ -- THE OPERATIONAL ENVELOPE (5.10, R7): stzPlatform =
    # generation (Reach -> shells), the governance-gated capability
    # seam, the Commons runtime (identity/messaging/stores over
    # sqlite), the networked body (world served via the reactor host),
    # and the world registry with norm-enforced cross-world calls.
    load "platform/stzPlatform.ring"

    # agentic/ -- THE CONVERGENCE (R5): the PI-agent assembled from the
    # roadmap's parts -- skills (precondition+plan+verification),
    # memory (knowledge graph), governance gate (R4b), the
    # perceive-decide-act cycle to fixpoint.
    load "agentic/stzAgentSkill.ring"
    load "agentic/stzAgentMemory.ring"
    load "agentic/stzPIAgent.ring"
    load "agentic/stzAgentGraph.ring"
    load "agentic/stzLLMAgent.ring"
    load "agentic/stzOwnAgentStack.ring"
    load "agentic/stzAgentHost.ring"

    # refine/ -- REFINEMENT PROGRAMMING (R6): stzPolyCode comes home --
    # code carries typed refinement points; a change is a typed proposal
    # through the gate, with cascade preview + reversibility.
    load "refine/stzRefinableCode.ring"

    load "linguistic/stzAdverb.ring"
    load "linguistic/stzPlural.ring"
    load "linguistic/stzSingular.ring"
    load "linguistic/stzOrdinal.ring"

# Loading files related to STATS module

    load "stats/stzDataSet.ring"
    load "stats/stzBarPlot.ring"
    load "stats/stzHBarPlot.ring"
    load "stats/stzMBarPlot.ring"
    load "stats/stzSurfacePlot.ring"
    load "stats/stzScatterPlot.ring"
    load "stats/stzHistogram.ring"
    load "stats/stzDataWrangler.ring"
    load "stats/stzCoeffExtractor.ring"
    load "stats/stzLinearSolver.ring"
    load "stats/stzMultiObjectiveSolver.ring"
    load "stats/stzStochasticSolver.ring"

// tz1 = clock()
// ? "Softanza laoding time:"
// ? (tz1 - tz0) / clockspersecond() + NL

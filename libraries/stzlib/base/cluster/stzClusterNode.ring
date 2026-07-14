# stzClusterNode: Individual server node in a computational cluster
#
# RETIRED BY R8 (the SCALE plane, 2026-07-14): this is the pre-engine
# PARALLEL CLASS TREE (a subclass per domain, each PRELOADING libraries
# via the no-op oComputeEngine). The resident Zig engine makes
# preloading moot -- every worker shares the one hot engine -- so
# specialization is now a stzWorkerProfile (a capability tag + resource
# budget), NOT a subclass. This class stays only so old scripts load;
# the SCALE plane is built on stzWorkerProfile / stzWorkerPool (R8.1)
# and the reactor-spawn fleet (R8.3). See section 7 of
# SOFTANZA_INTELLIGENCE_ARCHITECTURE.md.
class stzClusterNode from stzAppServer
    cNodeId = ""
    cClusterType = ""      # "nlp", "math", "vision", "search", etc.
    oClusterManager = NULL
    # own slot: the R7 reactor re-base removed stzAppServer's retired
    # oComputeEngine attribute; stays NULL (preloads were always no-ops)
    oComputeEngine = NULL
    nLoad = 0              # Current load percentage (0-100)
    nQueueLength = 0       # Current request queue length
    nAvgResponseTime = 0   # Average response time in ms
    bIsHealthy = True
    oLastHeartbeat = NULL
    aSpecializedEngines = []

    def init(cType, cId)
        # NOTE: Ring's auto-inheritance does not auto-call parent
        # init(); previous `stzAppServer.init()` was an R24 (static
        # call to non-static). We keep parent init() uncalled here --
        # tests use only fields/methods that don't depend on
        # InitializeCore/LoadSoftanzaEngine. Wire up parent state
        # explicitly when a method that needs it gets exercised.
        cClusterType = cType
        cNodeId = cId
        oLastHeartbeat = clock()
        This.LoadSpecializedEngines()

    def LoadSpecializedEngines()
        switch cClusterType
        on "nlp"
            This.LoadNLPEngines()
        on "math" 
            This.LoadMathEngines()
        on "vision"
            This.LoadVisionEngines()
        on "search"
            This.LoadSearchEngines()
        off

    def LoadNLPEngines()
        if isObject(oComputeEngine)
            oComputeEngine {
                PreloadLanguageModels(["english", "french", "spanish", "arabic"])
                PreloadSentimentAnalysis()
                PreloadEntityRecognition()
                PreloadTranslationEngines()
                PreloadTextClassification()
            }
        ok
        aSpecializedEngines + "nlp_ready"

    def LoadMathEngines()
        if isObject(oComputeEngine)
            oComputeEngine {
                PreloadStatisticalModels()
                PreloadLinearAlgebra()
                PreloadOptimizationEngines()
                PreloadTimeSeriesAnalysis()
                PreloadNumericalSolvers()
            }
        ok
        aSpecializedEngines + "math_ready"

    def LoadVisionEngines()
        if isObject(oComputeEngine)
            oComputeEngine {
                PreloadImageProcessing()
                PreloadOCREngines()
                PreloadPatternRecognition()
                PreloadColorAnalysis()
                PreloadDocumentAnalysis()
            }
        ok
        aSpecializedEngines + "vision_ready"

    def LoadSearchEngines()
        if isObject(oComputeEngine)
            oComputeEngine {
                PreloadSearchIndices()
                PreloadTextRetrieval()
                PreloadSimilarityEngines()
                PreloadRankingAlgorithms()
                PreloadSemanticSearch()
            }
        ok
        aSpecializedEngines + "search_ready"

    def UpdateMetrics(nNewLoad, nNewQueue, nNewResponseTime)
        nLoad = nNewLoad
        nQueueLength = nNewQueue
        nAvgResponseTime = nNewResponseTime
        oLastHeartbeat = clock()

    def IsOverloaded()
        return nLoad > 85 or nQueueLength > 50 or nAvgResponseTime > 200

    def GetHealthStatus()
        return [
            :node_id = cNodeId,
            :cluster_type = cClusterType,
            :load = nLoad,
            :queue_length = nQueueLength,
            :avg_response_time = nAvgResponseTime,
            :is_healthy = bIsHealthy,
            :specialized_engines = aSpecializedEngines,
            :last_heartbeat = oLastHeartbeat
        ]

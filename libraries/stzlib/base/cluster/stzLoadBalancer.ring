# stzLoadBalancer: Routes requests based on computational domain
class stzLoadBalancer
    aClusters = []         # Available clusters by type
    oRequestClassifier = NULL
    aRoutingRules = []
    nTotalRequests = 0
    
    def init()
        oRequestClassifier = new stzRequestClassifier()
        This.SetupDefaultRouting()

    def SetupDefaultRouting()
        aRoutingRules + [
            :pattern = "/api/analyze-text",
            :domain = "nlp"
        ]
        aRoutingRules + [
            :pattern = "/api/calculate",
            :domain = "math"
        ]
        aRoutingRules + [
            :pattern = "/api/process-image",
            :domain = "vision"
        ]
        aRoutingRules + [
            :pattern = "/api/search",
            :domain = "search"
        ]

    def RegisterCluster(cType, aNodes)
        _nClusters2Len_ = len(aClusters)
        for _iLoopClusters2_ = 1 to _nClusters2Len_
        	aCluster = aClusters[_iLoopClusters2_]
            if aCluster[:type] = cType
                aCluster[:nodes] = aNodes
                return
            ok
        next
        aClusters + [
            :type = cType,
            :nodes = aNodes
        ]

    def RouteRequest(oRequest)
        nTotalRequests++
        cDomain = This.ClassifyRequest(oRequest)
        oTargetCluster = This.FindCluster(cDomain)
        
        if oTargetCluster = NULL
            # Fallback to general cluster
            oTargetCluster = This.FindCluster("general")
        ok
        
        if oTargetCluster != NULL
            oNode = This.SelectBestNode(oTargetCluster[:nodes])
            return oNode
        ok
        
        return NULL

    def ClassifyRequest(oRequest)
        # Check explicit routing rules first
        cPath = oRequest.Path()
        _nRoutingRules1Len_ = len(aRoutingRules)
        for _iLoopRoutingRules1_ = 1 to _nRoutingRules1Len_
        	aRule = aRoutingRules[_iLoopRoutingRules1_]
            if StzFind(cPath, aRule[:pattern]) > 0
                return aRule[:domain]
            ok
        next
        
        # Use AI classifier for complex requests
        return oRequestClassifier.ClassifyComputationalDomain(oRequest)

    def FindCluster(cType)
        _nClusters1Len_ = len(aClusters)
        for _iLoopClusters1_ = 1 to _nClusters1Len_
        	aCluster = aClusters[_iLoopClusters1_]
            if aCluster[:type] = cType
                return aCluster
            ok
        next
        return NULL

    def SelectBestNode(aNodes)
        # Select node with lowest load and shortest queue
        oSelected = NULL
        nBestScore = 1000
        
        _nNodes1Len_ = len(aNodes)
        for _iLoopNodes1_ = 1 to _nNodes1Len_
        	oNode = aNodes[_iLoopNodes1_]
            if not oNode.bIsHealthy loop ok
            nScore = oNode.nLoad + (oNode.nQueueLength * 2)
            if nScore < nBestScore
                nBestScore = nScore
                oSelected = oNode
            ok
        next
        
        return oSelected

    def GetRoutingStats()
        return [
            :total_requests = nTotalRequests,
            :clusters_count = len(aClusters),
            :routing_rules = len(aRoutingRules)
        ]

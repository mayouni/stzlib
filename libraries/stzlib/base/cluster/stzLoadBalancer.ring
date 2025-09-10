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
        for aCluster in aClusters
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
        for aRule in aRoutingRules
            if substr(cPath, aRule[:pattern]) > 0
                return aRule[:domain]
            ok
        next
        
        # Use AI classifier for complex requests
        return oRequestClassifier.ClassifyComputationalDomain(oRequest)

    def FindCluster(cType)
        for aCluster in aClusters
            if aCluster[:type] = cType
                return aCluster
            ok
        next
        return NULL

    def SelectBestNode(aNodes)
        # Select node with lowest load and shortest queue
        oSelected = NULL
        nBestScore = 1000
        
        for oNode in aNodes
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

# stzLoadBalancer: Routes requests based on computational domain
class stzLoadBalancer from stzObject
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
        # Ring copies a list-of-lists slot on index read, so
        # `aCluster = aClusters[i]; aCluster[:nodes] = ...` mutates
        # the copy and discards the change. Mutate in-place via the
        # index instead.
        _nClusters2Len_ = len(aClusters)
        for _iLoopClusters2_ = 1 to _nClusters2Len_
            if aClusters[_iLoopClusters2_][:type] = cType
                aClusters[_iLoopClusters2_][:nodes] = aNodes
                return
            ok
        next
        aClusters + [
            :type = cType,
            :nodes = aNodes
        ]

    def RouteRequest(oRequest)
        nTotalRequests++
        _cDomain_ = This.ClassifyRequest(oRequest)
        _oTargetCluster_ = This.FindCluster(_cDomain_)
        
        if _oTargetCluster_ = NULL
            # Fallback to general cluster
            _oTargetCluster_ = This.FindCluster("general")
        ok
        
        if _oTargetCluster_ != NULL
            _oNode_ = This.SelectBestNode(_oTargetCluster_[:nodes])
            return _oNode_
        ok
        
        return NULL

    def ClassifyRequest(oRequest)
        # Check explicit routing rules first
        _cPath_ = oRequest.Path()
        _nRoutingRules1Len_ = len(aRoutingRules)
        for _iLoopRoutingRules1_ = 1 to _nRoutingRules1Len_
        	_aRule_ = aRoutingRules[_iLoopRoutingRules1_]
            if StzFindFirst(_cPath_, _aRule_[:pattern]) > 0
                return _aRule_[:domain]
            ok
        next
        
        # Use AI classifier for complex requests
        return oRequestClassifier.ClassifyComputationalDomain(oRequest)

    def FindCluster(cType)
        _nClusters1Len_ = len(aClusters)
        for _iLoopClusters1_ = 1 to _nClusters1Len_
        	_aCluster_ = aClusters[_iLoopClusters1_]
            if _aCluster_[:type] = cType
                return _aCluster_
            ok
        next
        return NULL

    def SelectBestNode(aNodes)
        # Select node with lowest load and shortest queue
        _oSelected_ = NULL
        _nBestScore_ = 1000
        
        _nNodes1Len_ = len(aNodes)
        for _iLoopNodes1_ = 1 to _nNodes1Len_
        	_oNode_ = aNodes[_iLoopNodes1_]
            if not _oNode_.bIsHealthy loop ok
            _nScore_ = _oNode_.nLoad + (_oNode_.nQueueLength * 2)
            if _nScore_ < _nBestScore_
                _nBestScore_ = _nScore_
                _oSelected_ = _oNode_
            ok
        next
        
        return _oSelected_

    def GetRoutingStats()
        return [
            :total_requests = nTotalRequests,
            :clusters_count = len(aClusters),
            :routing_rules = len(aRoutingRules)
        ]

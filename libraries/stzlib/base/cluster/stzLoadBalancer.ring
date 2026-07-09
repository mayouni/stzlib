# stzLoadBalancer: Routes requests based on computational domain
class stzLoadBalancer from stzObject
    _aClusters_ = []         # Available clusters by type
    _oRequestClassifier_ = NULL
    _aRoutingRules_ = []
    _nTotalRequests_ = 0
    
    def init()
        _oRequestClassifier_ = new stzRequestClassifier()
        This.SetupDefaultRouting()

    def SetupDefaultRouting()
        _aRoutingRules_ + [
            :pattern = "/api/analyze-text",
            :domain = "nlp"
        ]
        _aRoutingRules_ + [
            :pattern = "/api/calculate",
            :domain = "math"
        ]
        _aRoutingRules_ + [
            :pattern = "/api/process-image",
            :domain = "vision"
        ]
        _aRoutingRules_ + [
            :pattern = "/api/search",
            :domain = "search"
        ]

    def RegisterCluster(cType, aNodes)
        # Ring copies a list-of-lists slot on index read, so
        # `aCluster = aClusters[i]; aCluster[:nodes] = ...` mutates
        # the copy and discards the change. Mutate in-place via the
        # index instead.
        _nClusters2Len_ = len(_aClusters_)
        for _iLoopClusters2_ = 1 to _nClusters2Len_
            if _aClusters_[_iLoopClusters2_][:type] = cType
                _aClusters_[_iLoopClusters2_][:nodes] = aNodes
                return
            ok
        next
        _aClusters_ + [
            :type = cType,
            :nodes = aNodes
        ]

    def RouteRequest(oRequest)
        _nTotalRequests_++
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
        _nRoutingRules1Len_ = len(_aRoutingRules_)
        for _iLoopRoutingRules1_ = 1 to _nRoutingRules1Len_
        	_aRule_ = _aRoutingRules_[_iLoopRoutingRules1_]
            if StzFindFirst(_cPath_, _aRule_[:pattern]) > 0
                return _aRule_[:domain]
            ok
        next
        
        # Use AI classifier for complex requests
        return _oRequestClassifier_.ClassifyComputationalDomain(oRequest)

    def FindCluster(cType)
        _nClusters1Len_ = len(_aClusters_)
        for _iLoopClusters1_ = 1 to _nClusters1Len_
        	_aCluster_ = _aClusters_[_iLoopClusters1_]
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
            :total_requests = _nTotalRequests_,
            :clusters_count = len(_aClusters_),
            :routing_rules = len(_aRoutingRules_)
        ]

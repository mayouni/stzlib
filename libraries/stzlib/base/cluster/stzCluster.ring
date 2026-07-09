# stzCluster: Main cluster orchestration class
class stzCluster from stzObject
    _oClusterManager_ = NULL
    
    def init()
        _oClusterManager_ = new stzClusterManager()

    def CreateNLPCluster(nNodes)
        if nNodes = 0 nNodes = 3 ok
        return _oClusterManager_.CreateCluster("nlp", nNodes)

    def CreateMathCluster(nNodes) 
        if nNodes = 0 nNodes = 3 ok
        return _oClusterManager_.CreateCluster("math", nNodes)

    def CreateVisionCluster(nNodes)
        if nNodes = 0 nNodes = 3 ok  
        return _oClusterManager_.CreateCluster("vision", nNodes)

    def CreateSearchCluster(nNodes)
        if nNodes = 0 nNodes = 3 ok
        return _oClusterManager_.CreateCluster("search", nNodes)

    def Start(nPort)
        if nPort = 0 nPort = 8080 ok
        return _oClusterManager_.Start(nPort)

    def Stop()
        _oClusterManager_.Stop()

    def GetStatus()
        return _oClusterManager_.GetClusterStatus()

    def GetHealth()
        return _oClusterManager_.oHealthMonitor.GetHealthReport()

    # Simple builder pattern for easy setup
    def WithNLP(nNodes)
        This.CreateNLPCluster(nNodes)
        return This

    def WithMath(nNodes)
        This.CreateMathCluster(nNodes) 
        return This

    def WithVision(nNodes)
        This.CreateVisionCluster(nNodes)
        return This

    def WithSearch(nNodes)
        This.CreateSearchCluster(nNodes)
        return This

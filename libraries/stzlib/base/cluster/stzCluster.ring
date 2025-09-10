# stzCluster: Main cluster orchestration class
class stzCluster
    oClusterManager = NULL
    
    def init()
        oClusterManager = new stzClusterManager()

    def CreateNLPCluster(nNodes)
        if nNodes = 0 nNodes = 3 ok
        return oClusterManager.CreateCluster("nlp", nNodes)

    def CreateMathCluster(nNodes) 
        if nNodes = 0 nNodes = 3 ok
        return oClusterManager.CreateCluster("math", nNodes)

    def CreateVisionCluster(nNodes)
        if nNodes = 0 nNodes = 3 ok  
        return oClusterManager.CreateCluster("vision", nNodes)

    def CreateSearchCluster(nNodes)
        if nNodes = 0 nNodes = 3 ok
        return oClusterManager.CreateCluster("search", nNodes)

    def Start(nPort)
        if nPort = 0 nPort = 8080 ok
        return oClusterManager.Start(nPort)

    def Stop()
        oClusterManager.Stop()

    def GetStatus()
        return oClusterManager.GetClusterStatus()

    def GetHealth()
        return oClusterManager.oHealthMonitor.GetHealthReport()

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

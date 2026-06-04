# Narrative
# --------
# Example 6: Real-time Monitoring and Management
#
# Extracted from stzappserverclustertest.ring, block #6.
#ERR Error (R24) : Using uninitialized variable: ocluster

load "../../stzBase.ring"

pr()

    # Simple cluster monitoring
    while oCluster.oClusterManager.bIsRunning
        aStatus = oCluster.GetStatus()
        aHealth = oCluster.GetHealth()
        
        ? "=== Cluster Status ==="
        _aStatusclusters1_ = aStatus[:clusters]
        _nStatusclusters1Len_ = ring_len(_aStatusclusters1_)
        for _iLoopStatusclusters1_ = 1 to _nStatusclusters1Len_
        	aClusterInfo = _aStatusclusters1_[_iLoopStatusclusters1_]
            ? aClusterInfo[:cluster_type] + ": " + 
              aClusterInfo[:healthy_nodes] + "/" + 
              aClusterInfo[:total_nodes] + " healthy"
        next
        
        ? "Total requests: " + aStatus[:load_balancer][:total_requests]
        ? "==================="
        
        # Check for overloaded clusters
        _aHealthclusters1_ = aHealth[:clusters]
        _nHealthclusters1Len_ = ring_len(_aHealthclusters1_)
        for _iLoopHealthclusters1_ = 1 to _nHealthclusters1Len_
        	aClusterHealth = _aHealthclusters1_[_iLoopHealthclusters1_]
            if aClusterHealth[:overloaded_nodes] > 0
                ? "WARNING: " + aClusterHealth[:cluster_type] + 
                  " cluster has " + aClusterHealth[:overloaded_nodes] + 
                  " overloaded nodes"
            ok
        next
        
        # Sleep equivalent (simplified)
        for i = 1 to 1000000 next  # Busy wait for demo
    end

pf()

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
        for aClusterInfo in aStatus[:clusters]
            ? aClusterInfo[:cluster_type] + ": " + 
              aClusterInfo[:healthy_nodes] + "/" + 
              aClusterInfo[:total_nodes] + " healthy"
        next
        
        ? "Total requests: " + aStatus[:load_balancer][:total_requests]
        ? "==================="
        
        # Check for overloaded clusters
        for aClusterHealth in aHealth[:clusters]  
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

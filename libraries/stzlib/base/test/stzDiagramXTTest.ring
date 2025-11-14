load "../stzbase.ring"

#=====================================================
#  USAGE EXAMPLES
#=====================================================

/*---

pr()

oDiag = new stzDiagramXT("SecurityFlow")
oDiag.AddNodeWithMetadata("auth", "Authentication", :Process, :Primary,
    ["risk_score" = 85], [:security])
oDiag.AddNodeWithMetadata("db", "Database", :Storage, :Info,
    ["risk_score" = 45], [:security])

# Add edge with simple string label
oDiag.AddEdgeWithMetadata("auth", "db", "query", [], [])

# Check what the edge structure looks like
aEdges = oDiag.Edges()
? "Edge label is:"
? aEdges[1]["label"]
? "Label type: " + type(aEdges[1]["label"])

? "Edge structure:"
? @@(oDiag.Edges()[1])

? oDiag.Dot()
? oDiag.View()

pf()

/*---  Example 1: Security Risk Visualization
*/
pr()

oDiag = new stzDiagramXT("SecurityFlow")

# Define visual rules based on metadata
oHighRiskRule = new stzVisualRule("high_risk")
oHighRiskRule.WhenMetadataInRange("risk_score", 70, 100).
	      ApplyColor("#FF4444").
	      ApplyPenWidth(3).
	      ApplyIcon("⚠️")

oSecureRule = new stzVisualRule("secure")
oSecureRule.WhenTagExists(:security).
	    ApplyIcon("🔒").
	    ApplyBadge("SEC", :top_right)

oDiag.AddVisualRule(oHighRiskRule)
oDiag.AddVisualRule(oSecureRule)

# Add nodes with metadata
oDiag.AddNodeWithMetadata("auth", "Authentication", :Process, :Primary,
	["risk_score" = 85, "sla_ms" = 100],
	[:security, :critical])

oDiag.AddNodeWithMetadata("db", "Database", :Storage, :Info,
	["risk_score" = 45, "encrypted" = TRUE],
	[:security])

oDiag.AddEdgeWithMetadata("auth", "db", "query",
	["type" = :requires],
	[:data_flow])

? oDiag.Code()
oDiag.View()

pf()

/*---  Example 2: Performance Monitoring

oDiag = new stzDiagramXT("APIFlow")

# Performance-based coloring
oSlowRule = new stzVisualRule("slow_api")
oSlowRule.WhenMetadataInRange("latency_ms", 500, 9999).
	  ApplyColor("#FFA500").
	  ApplyBadge("SLOW", :bottom_right)

oFastRule = new stzVisualRule("fast_api")
oFastRule.WhenMetadataInRange("latency_ms", 0, 100).
	  ApplyColor("#44FF44").
	  ApplyIcon("⚡")

oDiag.AddVisualRule(oSlowRule)
oDiag.AddVisualRule(oFastRule)

oDiag.AddNodeWithMetadata("api1", "User API", :Process, :Primary,
	["latency_ms" = 50, "throughput" = 1000], [:api])

oDiag.AddNodeWithMetadata("api2", "Payment API", :Process, :Primary,
	["latency_ms" = 800, "throughput" = 100], [:api, :critical])

oDiag.View()

---*/

/*---  Example 3: Compliance Tagging

oDiag = new stzDiagramXT("DataFlow")

# GDPR compliance visualization
oGdprRule = new stzVisualRule("gdpr")
oGdprRule.WhenTagExists(:gdpr).
	  ApplyIcon("🇪🇺").
	  ApplyBadge("GDPR", :top_left).
	  ApplyPenWidth(2)

# PCI-DSS compliance
oPciRule = new stzVisualRule("pci")
oPciRule.WhenTagExists(:pci).
	 ApplyIcon("💳").
	 ApplyColor("#0066CC")

oDiag.AddVisualRule(oGdprRule)
oDiag.AddVisualRule(oPciRule)

oDiag.AddNodeWithMetadata("collect", "Data Collection", :Process, :Info,
	["retention_days" = 90], [:gdpr])

oDiag.AddNodeWithMetadata("payment", "Payment Processing", :Process, :Warning,
	["encryption" = TRUE], [:pci, :critical])

oDiag.View()

---*/

# Narrative
# --------
# Data pipeline health with visual rules
#
# Extracted from stzdiagramtest.ring, block #57.

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("DataPipeline")
oDiag {
    SetTheme("dark")
    
    # Pipeline stages with health status
    AddNodeXTT("ingest", "Ingest", [:status = "healthy", :recordsPerHour = 50000])
    AddNodeXTT("clean", "Cleansing", [:status = "degraded", :recordsPerHour = 45000])
    AddNodeXTT("transform", "Transform", [:status = "healthy", :recordsPerHour = 44000])
    AddNodeXTT("enrich", "Enrichment", [:status = "down", :recordsPerHour = 0])
    AddNodeXTT("load", "Load to DW", [:status = "healthy", :recordsPerHour = 40000])
    
    ConnectSequence(["ingest", "clean", "transform", "enrich", "load"])
    
    # Status colors
    RegisterVisualRule("HEALTHY", [
        :conditionType = "property_equals",
        :conditionParams = ["status", "healthy"],
        :effects = [["color", "green+"]]
    ])
    
    RegisterVisualRule("DEGRADED", [
        :conditionType = "property_equals",
        :conditionParams = ["status", "degraded"],
        :effects = [["color", "orange"], ["style", "dashed"]]
    ])
    
    RegisterVisualRule("DOWN", [
        :conditionType = "property_equals",
        :conditionParams = ["status", "down"],
        :effects = [["color", "red"], ["penwidth", 3], ["style", "bold"]]
    ])
    
    # High volume stages
    RegisterVisualRule("HIGH_VOLUME", [
        :conditionType = "property_range",
        :conditionParams = ["recordsPerHour", 40000, 999999],
        :effects = [["shape", "hexagon"]]
    ])
    
    ApplyVisualRules()
    # Pipeline status
    ? @@(NodesAffectedByVisualRules())
    #--> [ "ingest", "clean", "transform", "enrich", "load" ]

    View()
}

pf()
# Executed in 0.59 second(s) in Ring 1.25

# Narrative
# --------
#
# Extracted from stzdiagramtest.ring, block #58.

load "../../stzBase.ring"

pr()

pr()

oDiag = new stzDiagram("SystemAccess")
oDiag {
    
    # Resources with access levels
    AddNodeXTT("public_web", "Public Website", [:accessLevel = "public", :encrypted = FALSE])
    AddNodeXTT("user_portal", "User Portal", [:accessLevel = "authenticated", :encrypted = TRUE])
    AddNodeXTT("admin_panel", "Admin Panel", [:accessLevel = "admin", :encrypted = TRUE])
    AddNodeXTT("db_config", "DB Config", [:accessLevel = "system", :encrypted = TRUE])
    AddNodeXTT("audit_log", "Audit Log", [:accessLevel = "admin", :encrypted = TRUE])
    
    Connect("public_web", "user_portal")
    Connect("user_portal", "admin_panel")
    Connect("admin_panel", "db_config")
    Connect("admin_panel", "audit_log")
    
    # Access level colors
    RegisterVisualRule("PUBLIC", [
        :conditionType = "property_equals",
        :conditionParams = ["accessLevel", "public"],
        :effects = [["color", "green"]]
    ])
    
    RegisterVisualRule("AUTHENTICATED", [
        :conditionType = "property_equals",
        :conditionParams = ["accessLevel", "authenticated"],
        :effects = [["color", "blue"]]
    ])
    
    RegisterVisualRule("ADMIN", [
        :conditionType = "property_equals",
        :conditionParams = ["accessLevel", "admin"],
        :effects = [["color", "orange"], ["penwidth", 2]]
    ])
    
    RegisterVisualRule("SYSTEM", [
        :conditionType = "property_equals",
        :conditionParams = ["accessLevel", "system"],
        :effects = [["color", "red"], ["shape", "octagon"], ["penwidth", 3]]
    ])
    
    # Encryption indicator
    RegisterVisualRule("ENCRYPTED", [
        :conditionType = "property_equals",
        :conditionParams = ["encrypted", TRUE],
        :effects = [["style", "bold,filled"]]
    ])
    
    ApplyVisualRules()
    View()
}

pf()

# Narrative
# --------
# Error handling examples
#
# Extracted from stzentitytest.ring, block #15.

load "../../stzBase.ring"

pr()

// This will raise an error
try
    oWrong = new stzEntity([ :type = "person" ])  # Missing name
catch
    ? "Error: Entity must have a name"
end
#--> Error: Entity must have a name

// This will raise an error
try
    oEntity1.RemoveProperty("name")  # Can't remove core property
catch
    ? "Error: Cannot remove core property"
end
#--> Error: Cannot remove core property

pf()

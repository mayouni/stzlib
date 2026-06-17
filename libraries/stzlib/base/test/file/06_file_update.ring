# Narrative
# --------
# UPDATING FILES (read + sophisticated update intent)
#
# Intent: "I want to modify parts of this existing file."
# Extracted from stzfiletest.ring, block #6. Made portable: a local sandbox
# is created (the original assumed a pre-existing settings.txt).
#
# FileModifier gives targeted edits (ReplaceLineContaining / InsertLineAtEnd /
# RemoveLinesContaining) with read access to the original state.

load "../../stzBase.ring"

pr()

cSbx = CurrentDir() + "/_t06"
if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok
StzMakeDir(cSbx)
write(cSbx + "/settings.txt",
    "DatabaseHost=localhost" + nl +
    "DatabasePort=5432" + nl +
    "DebugMode=true" + nl +
    "ObsoleteSetting=remove_me")

oUpdater = FileUpdateQ(cSbx + "/settings.txt")

    # Replace a line containing a given text
    if oUpdater.ContainsText("DatabaseHost")
        oUpdater.ReplaceLineContaining("DatabaseHost", "DatabaseHost=newserver")
    ok
    ? oUpdater.Content() + NL
    #-->
    '
    DatabaseHost=newserver
    DatabasePort=5432
    DebugMode=true
    ObsoleteSetting=remove_me
    '

    # Sophisticated updates
    oUpdater.InsertLineAtEnd("NewSetting=DefaultValue")
    oUpdater.RemoveLinesContaining("ObsoleteSetting")
    ? oUpdater.Content()
    #-->
    '
    DatabaseHost=newserver
    DatabasePort=5432
    DebugMode=true
    NewSetting=DefaultValue
    '

oUpdater.Close()

if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok

pf()
# Executed in 0.01 second(s) in Ring 1.23

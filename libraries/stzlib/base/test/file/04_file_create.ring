# Narrative
# --------
# CREATING NEW FILES (read + create intent)
#
# Intent: "I want to create a new file."
# Extracted from stzfiletest.ring, block #4. Made portable: a local sandbox.
#
# FileCreateQ returns a creator with formatted-writing methods and read
# access, so you can check your work as you go. (FileCreate() without the Q
# just creates+closes and returns 1 -- use the Q form for the object.)

load "../../stzBase.ring"

pr()

cSbx = CurrentDir() + "/_t04"
if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok
StzMakeDir(cSbx)

oCreator = FileCreateQ(cSbx + "/settings.txt")
    oCreator.WriteLine("DatabaseHost=localhost")

    # Can check our work as we go (built-in read access)
    if oCreator.ContainsText("DatabaseHost")
        oCreator.WriteLine("DatabasePort=5432")
    ok

    oCreator.WriteLine("DebugMode=true")

    ? oCreator.Content()
    #-->
    '
    DatabaseHost=localhost
    DatabasePort=5432
    DebugMode=true
    '
oCreator.Close()

if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok

pf()
# Executed in almost 0 second(s) in Ring 1.23

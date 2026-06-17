# Narrative
# --------
# APPENDING TO FILES (read + append intent)
#
# Intent: "I want to add to the end of this file."
# Extracted from stzfiletest.ring, block #3. Made portable: a local sandbox
# log file.
#
# FileAppendQ returns an appender with BUILT-IN read access, so you can
# examine existing content (IsEmpty / ContainsText) before adding to it --
# ideal for context-aware logging.

load "../../stzBase.ring"

pr()

cSbx = CurrentDir() + "/_t03"
if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok
StzMakeDir(cSbx)
cLog = cSbx + "/app.log"

# FileAppend is OBJECT-ONLY: FileAppend(file) and FileAppendQ(file) both
# return the appender object (creating the file if needed).
oLog = FileAppend(cLog)

if oLog.IsEmpty()
    oLog.WriteLine("=== Log Started ===")
ok

if NOT oLog.ContainsText("Session started")
    oLog.WriteLine("Session started")
ok

oLog.WriteLine("New event occurred")

? oLog.Content()
#-->
'
=== Log Started ===
Session started
New event occurred
'

oLog.Close()

if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok

pf()
# Executed in almost 0 second(s) in Ring 1.23

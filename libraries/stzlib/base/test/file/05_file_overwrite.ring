# Narrative
# --------
# OVERWRITING FILES (read + overwrite intent)
#
# Intent: "I want to replace this file's contents."
# Extracted from stzfiletest.ring, block #5. Made portable: a local sandbox.
#
# FileOverwriter lets you read the ORIGINAL content (OriginalContent /
# OriginalLines) BEFORE replacing it -- informed overwriting.

load "../../stzBase.ring"

pr()

cSbx = CurrentDir() + "/_t05"
if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok
StzMakeDir(cSbx)
write(cSbx + "/output.txt", "old line one")   # 1 original line

oWriter = FileOverwriter(cSbx + "/output.txt")
    # Access original content before overwriting
    aOriginalLines = oWriter.OriginalLines()

    # Write new content
    oWriter.WriteLine("Status: Completed")
    oWriter.WriteLine("Original had " + len(aOriginalLines) + " lines")

    ? oWriter.Content()
    #-->
    '
    Status: Completed
    Original had 1 lines
    '
oWriter.Close()

if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok

pf()
# Executed in 0.01 second(s) in Ring 1.23

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

oWriter = FileOverwriteQ(cSbx + "/output.txt")
    # Access original content before overwriting
    aOriginalLines = oWriter.OriginalLines()

    # Write new content
    oWriter.WriteLine("Status: Completed")
    oWriter.WriteLine("Original had " + len(aOriginalLines) + " lines")

# CAPTURED FROM A RUN, NOT AUTHORED. The promise below is a REGRESSION
# BASELINE taken on haro 21317660327e7241, engine stzlib c2b930b71,
# 2026-11-23. The arrow was left empty by whoever wrote this file, so nobody
# has ever judged the value: it records what the code DOES, not what it
# SHOULD do. If it and the code disagree later, read BOTH -- the promise may
# be the defect. (That is how 192 came to be promised for a draw from a list
# not containing it; see listofnumbers/36_anynumberbefore.ring.)
    ? oWriter.Content()
#--> Status: Completed
#--> Original had 1 lines
    '
    Status: Completed
    Original had 1 lines
    '
oWriter.Close()

if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok

pf()
# Executed in 0.01 second(s) in Ring 1.23

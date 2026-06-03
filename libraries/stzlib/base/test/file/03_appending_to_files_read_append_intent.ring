# Narrative
# --------
# APPENDING TO FILES (read + append intent)
#
# Extracted from stzfiletest.ring, block #3.

load "../../stzBase.ring"

pr()

#TODO Add:
FileRemove("log.txt")
#	- FileErase("log.txt")


FileAppend("log.txt") {
    # Can read existing content
    if IsEmpty()
        WriteLine("=== Log Started ===")
    ok
    
    # Can examine existing content before appending
    if not ContainsText("Session started")
        WriteLogEntry("Session started")
    ok
    
    # Append new content
    WriteLogEntry("New event occurred")
    WriteSeparator("=")

	? Content()

	Close()
}
#-->
'
=== Log Started ===
17/07/2025-23:57:40 - Session started
17/07/2025-23:57:40 - New event occurred
==================================================
'
pf()
# Executed in almost 0.01 second(s) in Ring 1.22

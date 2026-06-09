# Narrative
# --------
# OVERWRITING FILES (read + overwrite intent)
#
# Extracted from stzfiletest.ring, block #5.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oOverwriter = FileOverwriter("output.txt") # Created if inexistant
    # Can access original content before overwriting
    cOriginal = oOverwriter.OriginalContent()
    aOriginalLines = oOverwriter.OriginalLines()
    
    # Write new content
    oOverwriter.WriteHeader("Processing Results")
    oOverwriter.WriteLine("Status: Completed")
    oOverwriter.WriteLine("Original had " + len(aOriginalLines) + " lines")
    
    # Can read what we've written
    ? oOverwriter.Size()
    ? oOverwriter.Content()

oOverwriter.Close()
#-->
'
120
# Processing Results
# Updated: 18/07/2025-00:04:27
#====================

Status: Completed
Original had 1 lines
'

pf()
# Executed in 0.01 second(s) in Ring 1.22

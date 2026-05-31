# Narrative
# --------
# CREATING NEW FILES (read + create intent)
#
# Extracted from stzfiletest.ring, block #4.

load "../../../stzBase.ring"


pr()

oCreator = FileCreate("settings.txt")
    # Can read what we've written so far
    oCreator.WriteHeader("Configuration Settings")
    oCreator.WriteLine("DatabaseHost=localhost")
    
    # Can check our work as we go
    if oCreator.ContainsText("DatabaseHost")
        oCreator.WriteLine("DatabasePort=5432")
    ok
    
    oCreator.WriteLine("DebugMode=true")
    ? oCreator.Size()  # Check current size
	#--> 146
    ? oCreator.Content()
#-->
'
# Configuration Settings
# Created: 18/07/2025-10:42:30
#========================

DatabaseHost=localhost
DatabasePort=5432
DebugMode=true
'

oCreator.Close()

pf()
# Executed in almost 0 second(s) in Ring 1.22

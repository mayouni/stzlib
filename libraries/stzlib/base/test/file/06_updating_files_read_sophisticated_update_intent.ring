# Narrative
# --------
# UPDATING FILES (read + sophisticated update intent)
#
# Extracted from stzfiletest.ring, block #6.

load "../../stzBase.ring"


pr()

# The file "settings.txt" should have been created and contain:
'
# Configuration Settings
# Created: 18/07/2025-11:04:19
#========================
DatabaseHost=localhost
DatabasePort=5432
DebugMode=true
ObsoleteSetting=remove_me
'

# Create it manually (or by code) before runnin the sample

oUpdater = FileModifier("settings.txt")
    # Can read original and current content
    aOriginalLines = oUpdater.OriginalLines()
    cCurrentContent = oUpdater.Content()
    
	# Checking original content

	? cCurrentContent + NL
#-->
'
# Configuration Settings
# Created: 18/07/2025-11:04:19
#========================
DatabaseHost=localhost
DatabasePort=5432
DebugMode=true
ObsoleteSetting=remove_me
'

    # Replace a line containing a given text

    if oUpdater.ContainsText("DatabaseHost")
        oUpdater.ReplaceLineContaining("DatabaseHost", "DatabaseHost=newserver")
	   ? oUpdater.Content() + NL
    ok
#-->
'
# Configuration Settings
# Created: 18/07/2025-11:04:19
#========================
DatabaseHost=newserver		#<-- Change happened here
DatabasePort=5432
DebugMode=true
ObsoleteSetting=remove_me
'

    # Sophisticated updates
    oUpdater.InsertLineAtEnd("NewSetting=DefaultValue") # Or AppendWithLine()
	? oUpdater.Content() + NL
#-->
'
# Configuration Settings
# Created: 18/07/2025-11:04:19
#========================
DatabaseHost=localhost
DatabasePort=5432
DebugMode=true
ObsoleteSetting=remove_me
NewSetting=DefaultValue		#<-- The line is inserted here
'

    oUpdater.RemoveLinesContaining("ObsoleteSetting")
	? oUpdater.Content() + NL
#-->
'
# Configuration Settings
# Created: 18/07/2025-11:04:19
#========================
DatabaseHost=localhost
DatabasePort=5432
DebugMode=true
'


oUpdater.Close()

pf()
# Executed in 0.01 second(s) in Ring 1.22

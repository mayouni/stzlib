load "../stzbase.ring"
load "../../max/wings/international-wings/stzTime.ring"

/*--- READING FILES (pure intent)

pr()

oReader = FileRead("tabdata.csv") # No write methods available - pure reading intent

? oReader.Content() + NL
#-->
'
tree_id;block_id;created_at;tree_dbh;alive
180683;348711;08/27/2015;3;Alive
200540;315986;09/03/2015;21;Alive
204026;218365;09/05/2015;3;Dead
204337;217969;09/05/2015;10;Alive
189565;223043;08/30/2015;21;Alive
190422;106099;08/30/2015;11;Dead
190426;106099;08/30/2015;11;Alive
208649;103940;09/07/2015;9;Alive
209610;407443;09/08/2015;6;Alive
180683;348711;08/27/2015;3;Alive
'

? @@Nl(oReader.Lines() ) + NL
#-->
'
[
	"tree_id;block_id;created_at;tree_dbh;alive",
	"180683;348711;08/27/2015;3;Alive",
	"200540;315986;09/03/2015;21;Alive",
	"204026;218365;09/05/2015;3;Dead",
	"204337;217969;09/05/2015;10;Alive",
	"189565;223043;08/30/2015;21;Alive",
	"190422;106099;08/30/2015;11;Dead",
	"190426;106099;08/30/2015;11;Alive",
	"208649;103940;09/07/2015;9;Alive",
	"209610;407443;09/08/2015;6;Alive",
	"180683;348711;08/27/2015;3;Alive"
]
'

? oReader.Size()
#--> 385

oReader.Close()

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- APPENDING TO FILES (read + append intent)

pr()

oAppender = FileAppend("log.txt")
    # Can read existing content
    if oAppender.IsEmpty()
        oAppender.WriteLine("=== Log Started ===")
    ok
    
    # Can examine existing content before appending
    if not oAppender.ContainsText("Session started")
        oAppender.WriteLogEntry("Session started")
    ok
    
    # Append new content
    oAppender.WriteLogEntry("New event occurred")
    oAppender.WriteSeparator("=")

	? oAppender.Content()

oAppender.Close()
#-->
'
=== Log Started ===
17/07/2025-23:57:40 - Session started
17/07/2025-23:57:40 - New event occurred
==================================================
'

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- CREATING NEW FILES (read + create intent)

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

oCreator.Close()

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- OVERWRITING FILES (read + overwrite intent)

pr()

oOverwriter = FileOverwrite("output.txt") # Created if inexistant
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

/*--- UPDATING FILES (read + sophisticated update intent)
*/
pr()

oUpdater = FileUpdate("settings.txt")
    # Can read original and current content
    aOriginalLines = oUpdater.OriginalLines()
    cCurrentContent = oUpdater.Content()
    
	? cCurrentContent + NL

    # Check what we're working with
    if oUpdater.ContainsText("DatabaseHost")
        oUpdater.ReplaceLineContaining("DatabaseHost", "DatabaseHost=newserver")
    ok
    
    # Sophisticated updates
    oUpdater.InsertLineAtEnd("NewSetting=DefaultValue")
    oUpdater.RemoveLinesContaining("ObsoleteSetting")
    
    # Can verify our changes
    aNewLines = oUpdater.Lines()
    nChanges = len(aNewLines) - len(aOriginalLines)

	? oUpdater.Content()

oUpdater.Close()

pf()

# All handlers provide universal read access!
# This reflects the natural mental model of file interaction.


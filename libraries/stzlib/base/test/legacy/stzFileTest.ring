load "../stzbase.ring"
load "../../max/wings/international-wings/stztime.ring"

/*--- GETTiNG INFORMATION ABOUT FILES

pr()

FileInfo("stzFileTest.ring") {

    ? Exists()			#--> TRUE
    ? IsWritable()		#--> TRUE
    ? SizeInBytes()		#--> 140
    ? LastModified()	#--> 18/07/2025 20:28:51
    ? IsExecutable()	#--> FALSE

}

pf()
# Executed in 0.02 second(s) in Ring 1.22

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

? oReader.Size() # Or SizeInBytes()
#--> 385

oReader.Close()

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- APPENDING TO FILES (read + append intent)
*/
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

oUpdater = FileModify("settings.txt")
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


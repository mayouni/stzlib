# Narrative
# --------
# Test Graphviz dot command (if installed)
#
# Extracted from stzsystemfunctest.ring, block #4.

load "../../stzBase.ring"


pr()


# Create test directories
CreateFolderIfInexistant("temp")
CreateFolderIfInexistant("output")

# Simple DOT code
cDotCode = '
digraph G {
	A -> B;
	B -> C;
	A -> C [label="direct"];
}
'

# Write to temp file
cDotFile = "temp\test.dot"
fp = fopen(cDotFile, "w")
fwrite(fp, cDotCode)
fclose(fp)

# Try to execute dot
cDotPath = "d:/graphviz/bin/dot.exe"  # Adjust to your path
cOutputFile = "output/test_graph.png"

if fexists(cDotPath)
	? "Found Graphviz at: " + cDotPath
	
	aArgs = [
		"-Tpng",
		cDotFile,
		"-o",
		cOutputFile
	]
	
	bResult = stzsystem(cDotPath, aArgs)
	? "Execution result: " + bResult
	
	if fexists(cOutputFile)
		? "SUCCESS! Output file created: " + cOutputFile
		? "File size: " + len(cOutputFile) + " bytes"
		View(cOutputFile)
	else
		? "WARNING: Command executed but output file not found"
	ok

else
	? "Graphviz not found at: " + cDotPath
	? "Please update the path in the test file"
ok

#--> the png is correctly created (why the ERROR line then?
'
Found Graphviz at: d:/graphviz/bin/dot.exe
Execution result: 
SUCCESS! Output file created: output/test_graph.png
File size: 21 bytes
'

pf()
# Executed in 5.27 second(s) in Ring 1.24

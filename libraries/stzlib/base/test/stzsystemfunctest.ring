load "../stzbase.ring"


/*-- Basic command execution (echo/ver on Windows, echo on Unix)

pr()

if isWindows()
	# Test with cmd.exe /c (Windows command processor)
	? stzsystem("cmd.exe", ["/c", "echo", "Hello from QProcess"])
else
	# Unix/Linux
	? stzsystem("echo", ["Hello from QProcess"])
ok
#--> "Hello from QProcess"

pf()
# Executed in 0.04 second(s) in Ring 1.24


/*-- Command with output capture

pr()

if isWindows()
	? stzsystem("cmd.exe", ["/c", "echo", "Test output"])
else
	?stzsystemOutput("echo", ["Test output"])
ok
#--> "Test output"

pf()
# Executed in 0.06 second(s) in Ring 1.24

/*-- File listing

pr()

if isWindows()
	? ShowShortNL( split(
		stzsystem("cmd.exe", ["/c", "dir", "/B"])
	, NL ) )
else
	? ShowShortNL( split(
		stzsystem("ls", ["-la"]) )
	, NL ) )
ok
#-->
'
[
	"banking_corporate.stzstyl", 
	"bank_structure.stzorg", 
	"bigtext.txt", 
	"...", 
	"test_diagram.mmd", 
	"test_diagram.stzdiag", 
	"txtfiles"
]
'

pf()
# Executed in 0.06 second(s) in Ring 1.24

/*-- Test Graphviz dot command (if installed)

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

/*-- Test with stzDotCode class
*/
pr()

try
	oDot = new stzDotCode()
	oDot.SetVerbose(TRUE)
	oDot.SetOutputFormat("svg")
	
	cCode = '
	digraph TestGraph {
		node [shape=box];
		Start -> Process;
		Process -> End;
		Process -> Error [color=red];
		Error -> Process [style=dashed];
	}
	'
	
	oDot.SetCode(cCode)
	oDot.Execute()
	
	? "Output file: " + oDot.OutputFile()
	? "Duration: " + oDot.Duration() + " seconds"
	
	# Uncomment to view the generated diagram
	oDot.View()
	
catch
	? "ERROR in stzDotCode test: " + cCatchError
done
? ""

? "Tests completed!"

#--> svg correctly generated and displayed

pf()

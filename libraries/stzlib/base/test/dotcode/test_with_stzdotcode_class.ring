# Narrative
# --------
# Test with stzDotCode class
#
# Extracted from stzsystemfunctest.ring, block #5.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

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

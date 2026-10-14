# stzJsCodeGraph -- JAVASCRIPT as a code graph (a peer language on the
# tree-sitter substrate). A SIBLING of stzPyCodeGraph, not a child: both
# inherit the language-agnostic query surface from stzCodeGraph and
# declare only their own identity. JavaScript is tree-sitter-only (no
# indentation floor, no external interpreter) -- it parses through the
# vendored grammar in the engine, with NO Node runtime.
#
#   oJG = StzJsCodeGraphFromSourceTS(cJsSource)   # a source string
#   oJG = StzJsCodeGraphTS("path/to/pkg")         # a directory of .js
#   ? oJG.OwnersOf("run")  ? oJG.AncestryOf("Worker")  ? oJG.CyclicCalls()

func StzJsCodeGraphFromSourceTS(pcSource)
	oG = new stzJsCodeGraph("")
	oG.ScanSourceViaTreeSitter(pcSource, "<source>")
	oG.BuildGraph()
	return oG

func StzJsCodeGraphTS(pcRootPath)
	oG = new stzJsCodeGraph("")
	oG.SetRoot(pcRootPath)
	oG._ScanViaTreeSitter(pcRootPath)
	oG.BuildGraph()
	return oG


# Holds JavaScript source as a code graph, parsed by the tree-sitter grammar in the engine with no Node runtime.
#
# A sibling of stzPyCodeGraph under stzCodeGraph: it inherits the whole query surface (classes,
# methods, owners, ancestry, call edges, dead code, cyclic calls) and declares only its own
# identity. Build one from a source string with StzJsCodeGraphFromSourceTS or from a directory of
# .js files with StzJsCodeGraphTS.
#
#   receiver   o1 = StzJsCodeGraphFromSourceTS("class Worker { run() { this.step(); } step() {} }")
#   example    ? o1.Language()
#              #--> javascript
#              ? o1.FileExtension()
#              #--> .js
#              ? @@( o1.Classes() )
#              #--> [ "Worker" ]
#              ? @@( o1.MethodsOf("Worker") )
#              #--> [ "run", "step" ]
#   see        stzCodeGraph, stzPyCodeGraph, stzRingCodeGraph
class stzJsCodeGraph from stzCodeGraph

	# Returns the name of the language this graph models.
	#
	#   returns    the text javascript
	#   see        FileExtension
	def Language()
		return "javascript"

	# Returns the file extension of the source files it scans, with the dot.
	#
	#   returns    the text .js
	#   see        Language
	def FileExtension()
		return ".js"

# stzJsCodeGraph -- JAVASCRIPT as a code graph (a peer language on the
# tree-sitter substrate). A SIBLING of stzPyCodeGraph, not a child: both
# inherit the language-agnostic query surface from stzPolyglotCodeGraph and
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


class stzJsCodeGraph from stzPolyglotCodeGraph

	def Language()
		return "javascript"

	def FileExtension()
		return ".js"

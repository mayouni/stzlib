load "../../stzBase.ring"
load "../_narrated.ring"

# POLYGLOT SUBSTRATE, 2nd language -- JavaScript via tree-sitter IN the
# engine (no Node runtime). The whole query surface is language-agnostic
# once source is parsed to the shared line protocol, so stzJsCodeGraph
# INHERITS stzPyCodeGraph and overrides only the parse entry. This suite
# proves the same queries (classes/methods/inheritance/impact/call edges/
# DeadCode/CyclicCalls) answer over JavaScript.
#
# Guarded on StzTreeSitterAvailable() -- engine DLLs are build-from-source,
# so this skips cleanly until `zig build` runs.

if StzTreeSitterAvailable()

	$cJs = "import http from 'http';" + nl +
	       "import { readFile } from 'fs';" + nl +
	       "class Base {" + nl +
	       "  greet() { return 'hi'; }" + nl +
	       "}" + nl +
	       "class Worker extends Base {" + nl +
	       "  run() { return helper(); }" + nl +
	       "  if_stub() { return this.run(); }" + nl +
	       "}" + nl +
	       "class Sub extends Worker {}" + nl +
	       "function helper() { return recurse(2); }" + nl +
	       "function recurse(n) { return recurse(n - 1); }" + nl +
	       "const orphan = () => 42;" + nl
	$oJG = StzJsCodeGraphFromSourceTS($cJs)

	Scenario("JS declarations parse: classes, methods, funcs, ES imports")
		Then("three classes are found", $oJG.NumberOfClasses(), 3)
		Then("a class method is captured",
			ring_find($oJG.MethodsOf("Worker"), "run") > 0, TRUE)
		Then("a top-level function is captured",
			ring_find($oJG.Functions(), "helper") > 0, TRUE)
		Then("an arrow-function const is a function too",
			ring_find($oJG.Functions(), "orphan") > 0, TRUE)
		Then("an ES import records the module (quotes stripped)",
			ring_find($oJG.ImportsOf("<source>"), "http") > 0, TRUE)
	EndScenario()

	Scenario("JS inheritance: the extends chain resolves")
		Then("Sub -> Worker -> Base up the chain",
			$oJG.AncestryOf("Sub")[2] = "Worker" and $oJG.AncestryOf("Sub")[3] = "Base", TRUE)
		Then("OwnersOf finds the defining class", $oJG.OwnersOf("run")[1], "Worker")
		Then("Sub is a descendant of Base",
			ring_find($oJG.DescendantsOf("Base"), "Sub") > 0, TRUE)
	EndScenario()

	Scenario("JS call edges + DeadCode + CyclicCalls (no Node runtime)")
		Then("call edges were extracted in-engine", $oJG.HasCallEdges(), TRUE)
		Then("who calls helper() is known", $oJG.CallersOf("helper")[1], "run")
		Then("the uncalled arrow function is flagged dead",
			ring_find($oJG.DeadCode(), "orphan") > 0, TRUE)
		Then("self-recursion is a call cycle",
			ring_find($oJG.CyclicCalls(), "recurse") > 0, TRUE)
	EndScenario()

	Scenario("the substrate holds: one query surface, two languages")
		Then("stzJsCodeGraph reuses the inherited Cascade query",
			$oJG.Cascade("Base")[:blastRadius] >= 2, TRUE)
	EndScenario()

else
	? "  [skip] stz_polyglot.dll not built -- JS scenarios skipped"
ok

Summary()

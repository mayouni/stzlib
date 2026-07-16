load "../../stzBase.ring"
load "../_narrated.ring"

# R6 (polyglot refinement) -- stzPyCodeGraph: the code-graph, ONE
# LANGUAGE OVER. Same structure queries as stzCodeGraph (classes,
# methods, inheritance, impact, cascade) over PYTHON source, so
# cross-language impact analysis / refinement reasoning reach a Python
# codebase. Parser is an indentation-aware structural scan (no braces
# in Python); handles multiple inheritance, module functions, imports.
# Deterministic + offline: it parses a source STRING, no Python needed.

$cPy = "import os" + nl +
       "from collections import OrderedDict" + nl +
       "" + nl +
       "class Animal:" + nl +
       "    def __init__(self, name):" + nl +
       "        self.name = name" + nl +
       "    def speak(self):" + nl +
       "        return '...'" + nl +
       "" + nl +
       "class Dog(Animal):" + nl +
       "    def speak(self):" + nl +
       "        return 'woof'" + nl +
       "    async def fetch(self):" + nl +
       "        return True" + nl +
       "" + nl +
       "class Puppy(Dog):" + nl +
       "    pass" + nl +
       "" + nl +
       "class Mixin:" + nl +
       "    def helper(self):" + nl +
       "        return 1" + nl +
       "" + nl +
       "class Service(Dog, Mixin):" + nl +
       "    def run(self):" + nl +
       "        return self.speak()" + nl +
       "" + nl +
       "def module_level(x):" + nl +
       "    return x * 2"

$oPG = StzPyCodeGraphFromSource($cPy)

Scenario("classes, methods, functions and imports are parsed")
	Then("five classes found", $oPG.NumberOfClasses(), 5)
	Then("Animal is present", ring_find($oPG.Classes(), "Animal") > 0, TRUE)
	Then("the module-level function is separate from methods",
		ring_find($oPG.Functions(), "module_level") > 0, TRUE)
	Then("both imports captured (os + collections)", $oPG.NumberOfImports(), 2)
	Then("an async def is still a method", ring_find($oPG.MethodsOf("Dog"), "fetch") > 0, TRUE)
EndScenario()

Scenario("single inheritance forms a chain")
	Then("Dog inherits Animal", $oPG.ParentsOf("Dog")[1], "Animal")
	aChain = $oPG.AncestryOf("Puppy")
	Then("the chain is length 3", len(aChain), 3)
	Then("it starts at Puppy", aChain[1], "Puppy")
	Then("through Dog", aChain[2], "Dog")
	Then("up to Animal", aChain[3], "Animal")
EndScenario()

Scenario("multiple inheritance is captured as several bases")
	aP = $oPG.ParentsOf("Service")
	Then("Service has two bases", len(aP), 2)
	Then("first base is Dog", aP[1], "Dog")
	Then("second base is Mixin", aP[2], "Mixin")
	Then("Service is a subclass of Mixin too",
		ring_find($oPG.SubclassesOf("Mixin"), "Service") > 0, TRUE)
EndScenario()

Scenario("OwnersOf finds every definer of a method")
	aOwn = $oPG.OwnersOf("speak")
	Then("Animal and Dog both define speak", len(aOwn), 2)
	Then("Animal owns it", ring_find(aOwn, "Animal") > 0, TRUE)
	Then("Dog overrides it", ring_find(aOwn, "Dog") > 0, TRUE)
EndScenario()

Scenario("ImpactOf: who feels a change to speak()")
	aI = $oPG.ImpactOf("speak")
	Then("owners are Animal + Dog", len(aI[:owners]), 2)
	# Puppy inherits Dog.speak (doesn't redefine); Service redefines run
	# but not speak, so it inherits too. Both feel a speak() change.
	Then("Puppy inherits it", ring_find(aI[:inheritedBy], "Puppy") > 0, TRUE)
	Then("Service inherits it", ring_find(aI[:inheritedBy], "Service") > 0, TRUE)
EndScenario()

Scenario("Cascade: the blast radius of touching Animal")
	aC = $oPG.Cascade("Animal")
	Then("Animal has descendants", aC[:blastRadius] >= 3, TRUE)
	Then("Dog is a descendant", ring_find(aC[:descendants], "Dog") > 0, TRUE)
	Then("Puppy is a (transitive) descendant", ring_find(aC[:descendants], "Puppy") > 0, TRUE)
	Then("Service is a descendant", ring_find(aC[:descendants], "Service") > 0, TRUE)
EndScenario()

Scenario("call-edge queries are refused, not faked (LAW 3)")
	bRaised = FALSE
	try
		$oPG.DeadCode()
	catch
		bRaised = TRUE
	done
	Then("DeadCode raises without body parsing", bRaised, TRUE)
EndScenario()

Scenario("Stats summarizes the declaration graph")
	aS = $oPG.Stats()
	Then("classes counted", aS[:classes], 5)
	Then("functions counted", aS[:functions], 1)
	Then("inherits edges present", aS[:inheritsEdges] >= 4, TRUE)
EndScenario()

# ---- the TRUE-AST backend (Python's own ast, via async spawn) ----------
# Guarded: skips cleanly where Python is not on PATH so the scan-floor
# scenarios above still stand on any box.

if StzPyAstAvailable()

	# constructs the indentation SCAN cannot see: a decorated method, a
	# def inside a conditional block, a dotted import, and -- the payoff --
	# CALL edges (recursion + who-calls-whom).
	$cPyAst = "import os.path" + nl +
	          "from collections import OrderedDict as OD" + nl +
	          "class Base:" + nl +
	          "    @property" + nl +
	          "    def label(self): return self._n" + nl +
	          "class Worker(Base):" + nl +
	          "    @staticmethod" + nl +
	          "    def run(): return helper()" + nl +
	          "    if True:" + nl +
	          "        def maybe(self): return self.run()" + nl +
	          "def helper(): return recurse(2)" + nl +
	          "def recurse(n): return recurse(n - 1)" + nl +
	          "def orphan(): return 1" + nl
	$oAst = StzPyCodeGraphFromSourceAst($cPyAst)

	Scenario("AST backend: it sees defs the indentation scan cannot")
		Then("the decorated @staticmethod is a method of Worker",
			ring_find($oAst.MethodsOf("Worker"), "run") > 0, TRUE)
		Then("the def inside 'if True:' is ALSO captured",
			ring_find($oAst.MethodsOf("Worker"), "maybe") > 0, TRUE)
		Then("the @property method is captured too",
			ring_find($oAst.MethodsOf("Base"), "label") > 0, TRUE)
		Then("a DOTTED import is recorded",
			ring_find($oAst.ImportsOf("<source>"), "os.path") > 0, TRUE)
		Then("inheritance still resolves", $oAst.AncestryOf("Worker")[2], "Base")
	EndScenario()

	Scenario("AST backend: CALL edges are REAL now (not refused)")
		Then("call edges were extracted", $oAst.HasCallEdges(), TRUE)
		Then("who calls helper() is known", $oAst.CallersOf("helper")[1], "run")
		Then("what run() calls is known",
			ring_find($oAst.CalleesOf("run"), "helper") > 0, TRUE)
	EndScenario()

	Scenario("AST backend: DeadCode + CyclicCalls now ANSWER (LAW 3 upheld)")
		Then("the uncalled function is flagged dead",
			ring_find($oAst.DeadCode(), "orphan") > 0, TRUE)
		Then("a called function is NOT dead",
			ring_find($oAst.DeadCode(), "recurse"), 0)
		Then("self-recursion is a call cycle",
			ring_find($oAst.CyclicCalls(), "recurse") > 0, TRUE)
	EndScenario()

else
	? "  [skip] Python not on PATH -- AST-backend scenarios skipped"
ok

# ---- the TREE-SITTER backend (real parse IN the engine, NO runtime) ----
# The polyglot substrate: vendored tree-sitter runtime + Python grammar,
# compiled into the engine. Same real-parse quality + call edges as the
# Python-ast path, but with ZERO external dependency.

if StzTreeSitterAvailable()

	$cPyTs = "import os.path" + nl +
	         "from collections import OrderedDict as OD" + nl +
	         "class Base:" + nl +
	         "    @property" + nl +
	         "    def label(self): return self._n" + nl +
	         "class Worker(Base):" + nl +
	         "    @staticmethod" + nl +
	         "    def run(): return helper()" + nl +
	         "    if True:" + nl +
	         "        def maybe(self): return self.run()" + nl +
	         "def helper(): return recurse(2)" + nl +
	         "def recurse(n): return recurse(n - 1)" + nl +
	         "def orphan(): return 1" + nl
	$oTs = StzPyCodeGraphFromSourceTS($cPyTs)

	Scenario("tree-sitter: a REAL parse in the engine, no Python runtime")
		Then("the decorated @staticmethod is a method of Worker",
			ring_find($oTs.MethodsOf("Worker"), "run") > 0, TRUE)
		Then("the def inside 'if True:' is captured too",
			ring_find($oTs.MethodsOf("Worker"), "maybe") > 0, TRUE)
		Then("the @property method is captured",
			ring_find($oTs.MethodsOf("Base"), "label") > 0, TRUE)
		Then("a DOTTED import is recorded",
			ring_find($oTs.ImportsOf("<source>"), "os.path") > 0, TRUE)
		Then("inheritance resolves", $oTs.AncestryOf("Worker")[2], "Base")
	EndScenario()

	Scenario("tree-sitter: CALL edges + DeadCode + CyclicCalls, runtime-free")
		Then("call edges were extracted in-engine", $oTs.HasCallEdges(), TRUE)
		Then("who calls helper() is known", $oTs.CallersOf("helper")[1], "run")
		Then("the uncalled function is flagged dead",
			ring_find($oTs.DeadCode(), "orphan") > 0, TRUE)
		Then("self-recursion is a call cycle",
			ring_find($oTs.CyclicCalls(), "recurse") > 0, TRUE)
	EndScenario()

else
	? "  [skip] stz_polyglot.dll not built -- tree-sitter scenarios skipped"
ok

Summary()

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

Summary()

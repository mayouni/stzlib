load "../../stzBase.ring"
load "../_narrated.ring"

# stzCoeffExtractor -- the three register rows (numericalDerivative, evaluateExpression,
# validateExpression), one family: evaluateExpression handed ManyReplaced a LIST of new texts, so the
# formula it evaluated was empty and every non-linear extraction died with R42; validateExpression
# called createTestValues with an argument that method does not take, so it answered 0 for everything.
#
# And the security half (threat-model R17, 79ae39e15): an expression given as TEXT must never run as
# code. The class evaluates the text with Ring's eval, by design, so the text is JUDGED first: only
# numbers, the declared variables, + - * / ( ) , and the functions pow, sqrt, abs, min, max are
# accepted, and the formula is REBUILT from those tokens. The hostile corpus below uses a harmless
# canary, a global that injected text would set, and asserts it stays 0.
#
# Run from inside its folder: cd base/test/stats

canary = 0

o1 = new stzCoeffExtractor([ "x", "y" ])

Scenario("A control: the canary does detect code that runs")
	canary = 0
	oProbe = new CanaryProbe
	oProbe.Run("x = 1; canary = 1")
	Then("an assignment evaluated in a class method sets the canary", canary, 1)
	canary = 0
	oProbe.Run("x = CanaryFn()")
	Then("a function call evaluated in a class method sets the canary", canary, 1)
	canary = 0
	Then("and a fresh canary reads 0", canary, 0)
EndScenario()

Scenario("evaluateExpression computes the value at a point (hand-computed)")
	aV = [ [ "x", 3 ], [ "y", 4 ] ]
	aCases = [
		[ "x + 1", 4 ],
		[ "x - y - 1", -2 ],
		[ "x / y / 2", 0.375 ],
		[ "10 / 4", 2.5 ],
		[ "(x + y) * 2", 14 ],
		[ "2 * (x + (y - 1))", 12 ],
		[ "pow(x, 2)", 9 ],
		[ "pow(x, 2) + pow(y, 2)", 25 ],
		[ "pow(2, pow(x, 2))", 512 ],
		[ "pow(x, 2) / 2", 4.5 ],
		[ "sqrt(x*x + y*y)", 5 ],
		[ "abs(x - y)", 1 ],
		[ "abs(y - x)", 1 ],
		[ "abs(-x)", 3 ],
		[ "max([0, x - 10])", 0 ],
		[ "max(0, x - 1)", 2 ],
		[ "min([x, y])", 3 ],
		[ "min(x, y, 1)", 1 ],
		[ "MAX(x, y)", 4 ],
		[ "max([x, y])", 4 ],
		[ "1e3 * x", 3000 ],
		[ "2.5E-2 * x", 0.075 ],
		[ "1e-3 + x", 3.001 ],
		[ ".5 * y", 2 ],
		[ "5. * x", 15 ],
		[ "007 + x", 10 ],
		[ "-x", -3 ],
		[ "+x", 3 ],
		[ "x - -y", 7 ],
		[ "x * -y", -12 ],
		[ "x++y", 7 ],
		[ "x--y", 7 ],
		[ "-(x + y)", -7 ],
		[ "2 / -x", -0.6666666666666666 ],
		[ "  x  +  y  ", 7 ],
		[ "x" + char(9) + "+ y", 7 ]
	]
	nCases = len(aCases)
	for i = 1 to nCases
		nGot = o1.evaluateExpression(aCases[i][1], aV)
		nOk = Near(nGot, aCases[i][2], 0.000000001)
		Then("[" + aCases[i][1] + "] at x=3, y=4 is " + aCases[i][2], nOk, 1)
	next
	nGot = o1.evaluateExpression("x/8 + y/4", [ [ "x", 10 ], [ "y", 4 ] ])
	Then("x/8 + y/4 at x=10, y=4 is 2.25 (integer division is a float: 10/8 = 1.25)", Near(nGot, 2.25, 0.000000001), 1)
	nGot = o1.evaluateExpression("pow(x, 2)", [ [ "x", 3 ] ])
	Then("pow(x, 2) at x=3 is 9, and y is not needed when it is not used", Near(nGot, 9, 0.000000001), 1)
	nGot = o1.evaluateExpression("y + x", [ [ "y", 4 ], [ "x", 3 ] ])
	Then("the order of the pairs does not matter", Near(nGot, 7, 0.000000001), 1)
EndScenario()

Scenario("A value is exact: it is not printed through the 4-decimal display precision")
	nGot = o1.evaluateExpression("x", [ [ "x", 1.23456789 ] ])
	Then("a variable keeps all its digits", Near(nGot, 1.23456789, 0.000000000001), 1)
	nGot = o1.evaluateExpression("x * 0.123456789", [ [ "x", 1 ] ])
	Then("a decimal literal keeps all its digits", Near(nGot, 0.123456789, 0.000000000001), 1)
	nGot = o1.evaluateExpression("x", [ [ "x", 0.00000123 ] ])
	Then("a tiny value is not printed as 0.0000", Near(nGot, 0.00000123, 0.000000000000001), 1)
	Then("and the negative of the same is just as exact",
		Near(o1.evaluateExpression("-x", [ [ "x", 0.00000123 ] ]), -0.00000123, 0.000000000000001), 1)
EndScenario()

Scenario("A name that is a prefix of another, or inside a function name, is not clobbered")
	oP = new stzCoeffExtractor([ "x", "x2", "xy" ])
	nGot = oP.evaluateExpression("x2 + x*10 + xy", [ [ "x", 1 ], [ "x2", 2 ], [ "xy", 3 ] ])
	Then("x2 + 10x + xy with x=1, x2=2, xy=3 is 15 (x did not eat the x of x2)", Near(nGot, 15, 0.000000001), 1)
	oM = new stzCoeffExtractor([ "x", "max" ])
	nGot = oM.evaluateExpression("max(1, max)", [ [ "x", 0 ], [ "max", 5 ] ])
	Then("a variable named max and the function max live together: max(1, 5) is 5", Near(nGot, 5, 0.000000001), 1)
	nGot = oM.evaluateExpression("max + 1", [ [ "x", 0 ], [ "max", 5 ] ])
	Then("a variable named max alone is the variable: 6", Near(nGot, 6, 0.000000001), 1)
	oC = new stzCoeffExtractor([ "x", "X" ])
	nGot = oC.evaluateExpression("x + 2*X", [ [ "x", 1 ], [ "X", 10 ] ])
	Then("x and X are two variables: 1 + 2*10 is 21", Near(nGot, 21, 0.000000001), 1)
	cMsg = RaiseOf("oP.evaluateExpression('exp + 1', [ [ 'x', 1 ], [ 'x2', 2 ], [ 'xy', 3 ] ])")
	Then("exp is not a variable here and is refused, not read as x inside exp", Has(cMsg, "refused"), 1)
EndScenario()

Scenario("evaluateExpression refuses with a plain message, and raw eval errors do not escape")
	cMsg = RaiseOf("o1.evaluateExpression('x + y', [ [ 'x', 3 ] ])")
	Then("a variable that needs a value and has none is named", Has(cMsg, "no value was given for the variable y"), 1)
	Then("the message is the class's own", Has(cMsg, "stzCoeffExtractor:"), 1)
	Then("it is not Ring's eval error", Has(cMsg, "R42"), 0)
	cMsg = RaiseOf("o1.evaluateExpression('x + 1', [ [ 'x', 3 ] ])")
	Then("while x + 1 with x supplied raises nothing", cMsg, "")
	cMsg = RaiseOf("o1.evaluateExpression('x / (y - 4)', [ [ 'x', 3 ], [ 'y', 4 ] ])")
	Then("a division by zero is named", Has(cMsg, "divides by zero"), 1)
	Then("and is not Ring's own text", Has(cMsg, "Can't divide"), 0)
	cMsg = RaiseOf("o1.evaluateExpression('x / (y - 5)', [ [ 'x', 3 ], [ 'y', 4 ] ])")
	Then("while the same formula away from zero raises nothing", cMsg, "")
	cMsg = RaiseOf("o1.evaluateExpression('sqrt(x)', [ [ 'x', -3 ] ])")
	Then("a square root of a negative number is reported, not leaked", Has(cMsg, "could not be evaluated"), 1)
	cMsg = RaiseOf("o1.evaluateExpression('sqrt(x)', [ [ 'x', 3 ] ])")
	Then("while a square root of a positive number raises nothing", cMsg, "")
	cMsg = RaiseOf("o1.evaluateExpression('x + 1', [ [ 'x', 'ten' ] ])")
	Then("a value that is not a number is refused", Has(cMsg, "is not a number"), 1)
	cMsg = RaiseOf("o1.evaluateExpression('x + 1', 'x=3')")
	Then("values that are not a list of pairs are refused", Has(cMsg, "list of [ name, value ] pairs"), 1)
	cMsg = RaiseOf("o1.evaluateExpression('x + z', [ [ 'x', 3 ], [ 'z', 4 ] ])")
	Then("a name that is not declared is refused even when a value is offered for it", Has(cMsg, "z is neither a known variable"), 1)
	cMsg = RaiseOf("o1.evaluateExpression('1e999 * x', [ [ 'x', 3 ] ])")
	Then("an overflow is reported as not finite", Has(cMsg, "finite"), 1)
	cMsg = RaiseOf("o1.evaluateExpression('', [ [ 'x', 3 ] ])")
	Then("an empty text is refused", Has(cMsg, "empty"), 1)
	cMsg = RaiseOf("o1.evaluateExpression(12, [ [ 'x', 3 ] ])")
	Then("a number given as the expression is refused", Has(cMsg, "not a text"), 1)
EndScenario()

Scenario("numericalDerivative: a central difference at the test point 10")
	n = o1.numericalDerivative("x/8 + y/4", "x")
	Then("d/dx of x/8 + y/4 is 0.125", Near(n, 0.125, 0.000001), 1)
	n = o1.numericalDerivative("x/8 + y/4", "y")
	Then("d/dy of x/8 + y/4 is 0.25", Near(n, 0.25, 0.000001), 1)
	n = o1.numericalDerivative("pow(x, 2)", "x")
	Then("d/dx of pow(x, 2) at 10 is 20", Near(n, 20, 0.0001), 1)
	n = o1.numericalDerivative("pow(x, 2)", "y")
	Then("an expression that does not contain the variable gives 0", n, 0)
	n = o1.numericalDerivative("x/8 + y/4", "x")
	Then("the slope is not the forward one: 20.001 would be the forward slope of pow(x, 2)",
		Near(o1.numericalDerivative("pow(x, 2)", "x"), 20.001, 0.0001), 0)
	n = o1.numericalDerivative("3*x - 2*y + 5", "x")
	Then("d/dx of 3x - 2y + 5 is 3", Near(n, 3, 0.000001), 1)
	n = o1.numericalDerivative("3*x - 2*y + 5", "y")
	Then("d/dy of 3x - 2y + 5 is -2", Near(n, -2, 0.000001), 1)
	n = o1.numericalDerivative("sqrt(x)", "x")
	Then("d/dx of sqrt(x) at 10 is 1/(2 sqrt 10) = 0.158114", Near(n, 0.158114, 0.000001), 1)
	n = o1.numericalDerivative("abs(x - 10)", "x")
	Then("abs(x - 10) at its kink reads 0 on a symmetric step", Near(n, 0, 0.000001), 1)
	n = o1.numericalDerivative("max([0, x - 5])", "x")
	Then("max([0, x - 5]) is on its rising branch at 10: slope 1", Near(n, 1, 0.000001), 1)
	n = o1.numericalDerivative("max([0, x - 50])", "x")
	Then("max([0, x - 50]) is on its flat branch at 10: slope 0", Near(n, 0, 0.000001), 1)
	n = o1.numericalDerivative("x * y", "x")
	Then("d/dx of x*y at y=10 is 10", Near(n, 10, 0.000001), 1)
	o1.setPerturbationDelta(0.01)
	n = o1.numericalDerivative("pow(x, 2)", "x")
	Then("with a step of 0.01 the central slope of pow(x, 2) is still 20", Near(n, 20, 0.0001), 1)
	o1.setPerturbationDelta(0.001)
	o1.setPerturbationDelta(0)
	cMsg = RaiseOf("o1.numericalDerivative('x/8', 'x')")
	Then("a step of 0 is refused, not divided by", Has(cMsg, "must be positive"), 1)
	o1.setPerturbationDelta("big")
	cMsg = RaiseOf("o1.numericalDerivative('x/8', 'x')")
	Then("a step that is not a number is refused", Has(cMsg, "is not a number"), 1)
	o1.setPerturbationDelta(0.001)
	cMsg = RaiseOf("o1.numericalDerivative('x/8', 'x')")
	Then("and with the step put back it raises nothing", cMsg, "")
	cMsg = RaiseOf("o1.numericalDerivative('x/8', 'z')")
	Then("a variable the extractor does not know is refused", Has(cMsg, "not one of the names"), 1)
	canary = 0
	cMsg = RaiseOf("o1.numericalDerivative('x/8 + CanaryFn()', 'x')")
	Then("an unsafe expression is refused", Has(cMsg, "refused"), 1)
	Then("and nothing ran", canary, 0)
EndScenario()

Scenario("extract, extractAllCoefficients and the alias names, on every kind of input")
	Then("x/8 + y/4: the coefficient of x is 0.125", Near(o1.extract("x/8 + y/4", "x"), 0.125, 0.000001), 1)
	Then("x/8 + y/4: the coefficient of y is 0.25", Near(o1.extract("x/8 + y/4", "y"), 0.25, 0.000001), 1)
	Then("pow(x, 2): the coefficient of x is its slope at 10, 20", Near(o1.extract("pow(x, 2)", "x"), 20, 0.0001), 1)
	Then("pow(x, 2): y is not in it, 0", o1.extract("pow(x, 2)", "y"), 0)
	Then("3*x - 2*y + 5: x is 3 by the plain path", o1.extract("3*x - 2*y + 5", "x"), 3)
	Then("3*x - 2*y + 5: y is -2", o1.extract("3*x - 2*y + 5", "y"), -2)
	Then("a constant has no x: 0", o1.extract("7", "x"), 0)
	Then("an empty text has no x: 0", o1.extract("", "x"), 0)
	Then("5*x - 2*y + 3 read for y: -2", o1.extract("5*x - 2*y + 3", "y"), -2)
	Then("x alone has coefficient 1", o1.extract("x", "x"), 1)
	Then("-x has coefficient -1", o1.extract("-x", "x"), -1)
	Then("sqrt(x) + x/2: 0.158114 + 0.5, the slope of the sum", Near(o1.extract("sqrt(x) + x/2", "x"), 0.658114, 0.000001), 1)
	Then("min/max form: max([0, x - 5]) has slope 1", Near(o1.extract("max([0, x - 5])", "x"), 1, 0.000001), 1)
	aAll = o1.extractAllCoefficients("x/8 + y/4")
	Then("extractAllCoefficients of x/8 + y/4 has two entries", len(aAll), 2)
	Then("the first is 0.125", Near(aAll[1], 0.125, 0.000001), 1)
	Then("the second is 0.25", Near(aAll[2], 0.25, 0.000001), 1)
	aAll = o1.extractAllCoefficients("3*x - 2*y + 5")
	Then("extractAllCoefficients of 3*x - 2*y + 5 is [3, -2]", "" + aAll[1] + " " + aAll[2], "3 -2")
	Then("ExtractCoefficient is extract", Near(o1.ExtractCoefficient("x/8", "x"), 0.125, 0.000001), 1)
	Then("ExtractCoeff is extract", Near(o1.ExtractCoeff("x/8", "x"), 0.125, 0.000001), 1)
	Then("a plain absent name stays 0 through the alias", o1.ExtractCoeff("3*y", "x"), 0)
	oOne = new stzCoeffExtractor([ "x" ])
	Then("with one variable, x/8 gives 0.125", Near(oOne.extract("x/8", "x"), 0.125, 0.000001), 1)
	Then("with one variable, pow(x, 2) gives 20", Near(oOne.extract("pow(x, 2)", "x"), 20, 0.0001), 1)
	oMany = new stzCoeffExtractor([ "a1", "a2", "a3", "a4", "a5", "a6", "a7", "a8" ])
	aAll = oMany.extractAllCoefficients("a1/2 + a2/4 + a3/8 + a4/16 + pow(a5, 2) + 3*a6")
	Then("with eight variables there are eight coefficients", len(aAll), 8)
	Then("a1 is 0.5", Near(aAll[1], 0.5, 0.000001), 1)
	Then("a3 is 0.125", Near(aAll[3], 0.125, 0.000001), 1)
	Then("a4 is 0.0625", Near(aAll[4], 0.0625, 0.000001), 1)
	Then("a5 is the slope of its square at 10: 20", Near(aAll[5], 20, 0.0001), 1)
	Then("a6 is 3, the star form riding along with the non-linear terms", Near(aAll[6], 3, 0.000001), 1)
	Then("a8 is not in the expression: 0", aAll[8], 0)
	cMsg = RaiseOf("o1.extract('x/8 + CanaryFn()', 'x')")
	Then("a non-linear expression outside the grammar is refused by extract", Has(cMsg, "refused"), 1)
	Then("and nothing ran", canary, 0)
EndScenario()

Scenario("validateExpression answers 1 only for an expression that is safe AND computable, and never raises")
	Then("x + 1 is valid", o1.validateExpression("x + 1"), 1)
	Then("x + y is valid", o1.validateExpression("x + y"), 1)
	Then("2*x + 3*y is valid", o1.validateExpression("2*x + 3*y"), 1)
	Then("x/8 + y/4 is valid", o1.validateExpression("x/8 + y/4"), 1)
	Then("pow(x, 2) is valid", o1.validateExpression("pow(x, 2)"), 1)
	Then("max([0, x - 1000]) is valid", o1.validateExpression("max([0, x - 1000])"), 1)
	Then("invalid_function(x) + y is not valid (the register's test 15)", o1.validateExpression("invalid_function(x) + y"), 0)
	Then("x + z is not valid: z is not known", o1.validateExpression("x + z"), 0)
	Then("x + is not valid: it is incomplete", o1.validateExpression("x +"), 0)
	Then("an empty text is not valid", o1.validateExpression(""), 0)
	Then("a number given as the expression is not valid", o1.validateExpression(12), 0)
	Then("a list given as the expression is not valid", o1.validateExpression([ "x" ]), 0)
	Then("x/(y - 10) is safe but not computable at the test point (y = 10): not valid", o1.validateExpression("x/(y - 10)"), 0)
	Then("and the same safe text one step away is valid", o1.validateExpression("x/(y - 9)"), 1)
	Then("sqrt(x - 20) is not computable at 10: not valid", o1.validateExpression("sqrt(x - 20)"), 0)
	Then("sqrt(x - 5) is: valid", o1.validateExpression("sqrt(x - 5)"), 1)
	Then("1e999 * x overflows at the test point: not valid", o1.validateExpression("1e999 * x"), 0)
	canary = 0
	Then("x + CanaryFn() is not valid", o1.validateExpression("x + CanaryFn()"), 0)
	Then("x + 1;canary=1 is not valid", o1.validateExpression("x + 1;canary=1"), 0)
	Then("and nothing ran", canary, 0)
	oNone = new stzCoeffExtractor([])
	Then("with no variable known, 2 + 3 is valid", oNone.validateExpression("2 + 3"), 1)
	Then("and x + 1 is not", oNone.validateExpression("x + 1"), 0)
EndScenario()

Scenario("The grammar: what judgeExpression accepts (empty text) and refuses (a sentence)")
	aOk = [ "x", "x + 1", "x/8 + y/4", "pow(x, 2)", "pow(x,2)", "POW(x, 2)", "sqrt(x)", "abs(x)", "min(x, y)", "max(x, y)",
		"max([0, profit])", "1", "1.5", ".5", "5.", "1e3", "1E3", "1e+3", "1e-3", "2.5e-2", "((x))", "-x", "+x", "- x", "x * -y",
		"x - -y", "x++y", "x--y", "pow ( x , 2 )", "2*(x+y)", "max ( [ 1 , 2 ] )" ]
	nOk = len(aOk)
	oJ = new stzCoeffExtractor([ "x", "y", "profit" ])
	for i = 1 to nOk
		cJ = oJ.judgeExpression(aOk[i])
		Then("accepted: [" + aOk[i] + "]", cJ, "")
	next
	aNo = [
		[ "", "empty" ],
		[ "x +", "ends before" ],
		[ "+", "ends before" ],
		[ "x y", "no operator" ],
		[ "1 2", "no operator" ],
		[ "x 2", "no operator" ],
		[ "2 x", "no operator" ],
		[ "2x", "glued" ],
		[ "x(2)", "function x is not" ],
		[ "(x)(y)", "no operator" ],
		[ "x(", "function x is not" ],
		[ "(x", "never closed" ],
		[ "x)", "no ( open" ],
		[ "()", "after an operator" ],
		[ "*x", "no operand before" ],
		[ "x * * y", "no operand before" ],
		[ "x ** 2", "no operand before" ],
		[ "x // 2", "no operand before" ],
		[ "x +++ y", "two signs" ],
		[ "x --- y", "two signs" ],
		[ "++x", "two signs" ],
		[ "- - x", "two signs" ],
		[ "x ^ 2", "character ^" ],
		[ "x % 2", "character %" ],
		[ "x = 1", "character =" ],
		[ "x == 1", "character =" ],
		[ "x < 1", "character <" ],
		[ "x ! 1", "character !" ],
		[ "x & y", "character &" ],
		[ "x | y", "character |" ],
		[ "x ; y", "character ;" ],
		[ "x : y", "character :" ],
		[ "x ? y", "character ?" ],
		[ "@x", "character @" ],
		[ "$x", "character $" ],
		[ "#x", "character #" ],
		[ "x.y", "character ." ],
		[ "x. 5", "character ." ],
		[ "1.2.3", "glued" ],
		[ "0x10", "glued" ],
		[ "1e", "malformed exponent" ],
		[ "1e+", "malformed exponent" ],
		[ "x, y", "outside a function" ],
		[ ", x", "outside a function" ],
		[ "pow(, 2)", "no argument" ],
		[ "pow(x)", "exactly two" ],
		[ "pow(x, 2, 3)", "too many" ],
		[ "pow()", "after an operator" ],
		[ "sqrt(x, y)", "too many" ],
		[ "abs(x, y)", "too many" ],
		[ "exp(x)", "function exp is not" ],
		[ "sin(x)", "function sin is not" ],
		[ "log(x)", "function log is not" ],
		[ "floor(x)", "function floor is not" ],
		[ "[x]", "only straight after" ],
		[ "pow([x], 2)", "only straight after" ],
		[ "max([x)", "never closed" ],
		[ "max(x])", "no [ open" ],
		[ "max([x] + 1)", "only ) may follow" ],
		[ "max([x], 2)", "only ) may follow" ],
		[ "max([[x]])", "only straight after" ],
		[ "x{y}", "character {" ],
		[ "x'y'", "character '" ]
	]
	nNo = len(aNo)
	for i = 1 to nNo
		cJ = oJ.judgeExpression(aNo[i][1])
		Then("refused: [" + aNo[i][1] + "] (" + aNo[i][2] + ")", Has(cJ, aNo[i][2]), 1)
	next
	cJ = oJ.judgeExpression("x" + char(10) + "+1")
	Then("refused: a newline (code 10)", Has(cJ, "code 10"), 1)
	cJ = oJ.judgeExpression("x" + char(13) + "+1")
	Then("refused: a carriage return (code 13)", Has(cJ, "code 13"), 1)
	cJ = oJ.judgeExpression("x" + char(0) + "+1")
	Then("refused: a character of code 0 (the text may stop there)", Has(cJ, "code 0"), 1)
	cJ = oJ.judgeExpression("x" + char(200) + "1")
	Then("refused: a byte above 127", Has(cJ, "code 200"), 1)
	cLong = "x"
	for i = 1 to 1100
		cLong += "+x"
	next
	cJ = oJ.judgeExpression(cLong)
	Then("refused: a text of 2201 characters", Has(cJ, "longer than 2000"), 1)
	cDeep = ""
	for i = 1 to 60
		cDeep += "("
	next
	cDeep += "x"
	for i = 1 to 60
		cDeep += ")"
	next
	cJ = oJ.judgeExpression(cDeep)
	Then("refused: 60 nested parentheses", Has(cJ, "more than 50"), 1)
	cDeep = ""
	for i = 1 to 40
		cDeep += "("
	next
	cDeep += "x"
	for i = 1 to 40
		cDeep += ")"
	next
	cJ = oJ.judgeExpression(cDeep)
	Then("while 40 nested parentheses are accepted", cJ, "")
	nGot = oJ.evaluateExpression(cDeep, [ [ "x", 7 ] ])
	Then("and give x: 7", Near(nGot, 7, 0.000000001), 1)
	cJ = oJ.judgeExpression([ 1, 2 ])
	Then("refused: a list given as the expression", Has(cJ, "not a text"), 1)
EndScenario()

Scenario("A hostile corpus: none of it runs, all of it is refused")
	aHost = HostileCorpus()
	nHost = len(aHost)
	Then("the corpus has at least 20 strings", nHost >= 20, 1)
	Then("it has more than 50, in fact", nHost > 50, 1)
	canary = 0
	nRefused = 0
	nBadSurface = 0
	for i = 1 to nHost
		cText = aHost[i][2]
		cJudge = o1.judgeExpression(cText)
		nValid = o1.validateExpression(cText)
		cEval = RaiseOf("o1.evaluateExpression(aHost[" + i + "][2], [ [ 'x', 3 ], [ 'y', 4 ] ])")
		cDeriv = RaiseOf("o1.numericalDerivative(aHost[" + i + "][2], 'x')")
		cExtr = RaiseOf("o1.extract(aHost[" + i + "][2], 'x')")
		aAllCo = RaiseOf("o1.extractAllCoefficients(aHost[" + i + "][2])")
		nOkAll = 0
		if cJudge != "" and nValid = 0 and Has(cEval, "stzCoeffExtractor: refused") and Has(cDeriv, "stzCoeffExtractor: refused")
			nOkAll = 1
		ok
		nRefused += nOkAll
		Then("refused by judge, validate, evaluate and derivative: " + aHost[i][1], nOkAll, 1)
		Then("the canary is still 0 after: " + aHost[i][1], canary, 0)
		canary = 0
	next
	Then("every string of the corpus was refused", nRefused, nHost)
EndScenario()

Scenario("The same hostile texts through extract on the plain path never run either")
	aHost = HostileCorpus()
	nHost = len(aHost)
	canary = 0
	for i = 1 to nHost
		RaiseOf("o1.extract(aHost[" + i + "][2], 'y')")
		RaiseOf("o1.trySimpleExtraction(aHost[" + i + "][2], 'x')")
		RaiseOf("o1.extractLinearCoefficient(aHost[" + i + "][2], 'x')")
	next
	Then("the canary is still 0 after " + nHost + " strings through the plain path", canary, 0)
EndScenario()

Scenario("The library does not leak: the old route's own symptoms are gone")
	cMsg = RaiseOf("o1.evaluateExpression('x + 1', [ [ 'x', 3 ] ])")
	Then("no R42 'Error in eval() function' on x + 1", Has(cMsg, "R42"), 0)
	cMsg = RaiseOf("o1.numericalDerivative('x/8 + y/4', 'x')")
	Then("no R42 on x/8 + y/4", Has(cMsg, "R42"), 0)
	cMsg = RaiseOf("o1.numericalDerivative('pow(x, 2)', 'x')")
	Then("no R42 on pow(x, 2)", Has(cMsg, "R42"), 0)
	Then("validateExpression(x + 1) is no longer the constant 0", o1.validateExpression("x + 1"), 1)
	Then("and validateExpression(x + y) neither", o1.validateExpression("x + y"), 1)
EndScenario()

Scenario("The rest of the public surface still answers")
	Then("VarNames lists the names", o1.VarNames()[1] + o1.VarNames()[2], "xy")
	Then("VariableNames is VarNames", len(o1.VariableNames()), 2)
	oS = new stzCoeffExtractor([ "x" ])
	oS.setVariableNames([ "a", "b", "c" ])
	Then("setVariableNames replaces the names", len(oS.VarNames()), 3)
	aTv = oS.createTestValues()
	Then("createTestValues has one pair per name", len(aTv), 3)
	Then("each pair is [ name, 10 ]", aTv[2][1] + aTv[2][2], "b10")
	aTv2 = o1.createTestValues()
	Then("createTestValues ignores nothing it was not given", len(aTv2), 2)
	Then("normalizeExpression drops spaces", o1.normalizeExpression("  5 * x  +  3 ") , "5*x+3")
	Then("normalizeExpression drops tabs", o1.normalizeExpression("5" + char(9) + "*x"), "5*x")
	Then("isSimpleLinearExpression is 1 for 5*x+3*y", o1.isSimpleLinearExpression("5*x+3*y"), 1)
	Then("isSimpleLinearExpression is 0 for x/8", o1.isSimpleLinearExpression("x/8"), 0)
	Then("isSimpleLinearExpression is 0 for pow(x,2)", o1.isSimpleLinearExpression("pow(x,2)"), 0)
	Then("trySimpleExtraction reads 5 in 5*x", o1.trySimpleExtraction("5*x", "x"), 5)
	Then("trySimpleExtraction hands x/8 to the numerical path with an empty text", o1.trySimpleExtraction("x/8", "x"), "")
	Then("extractLinearCoefficient reads 3 for y in 5*x+3*y", o1.extractLinearCoefficient("5*x+3*y", "y"), 3)
	Then("extractLinearCoefficient reads -1 for -y", o1.extractLinearCoefficient("-y", "y"), -1)
	Then("roundCoefficient turns 2.0000001 into 2", o1.roundCoefficient(2.0000001), 2)
	Then("roundCoefficient keeps 0.1234567 at 0.123457", Near(o1.roundCoefficient(0.1234567), 0.123457, 0.0000001), 1)
	Then("roundCoefficient turns -0.0000001 into 0", o1.roundCoefficient(-0.0000001), 0)
	nBefore = CurrentRound()
	decimals(2)
	oB = new stzCoeffExtractor([ "x" ])
	Then("building an extractor sets the display precision to 4", CurrentRound(), 4)
	oB.BraceEnd()
	Then("BraceEnd puts back the precision that was set before the build: 2", CurrentRound(), 2)
	decimals(nBefore)
EndScenario()

Summary()

# helpers go at the END: top-level code after a func belongs to that func

func CanaryFn()
	canary = 1
	return 1

func Near(a, b, nTol)
	if abs(a - b) <= nTol
		return 1
	ok
	return 0

func Has(cText, cNeedle)
	if NOT isString(cText)
		return 0
	ok
	if substr(cText, cNeedle) > 0
		return 1
	ok
	return 0

func RaiseOf(cCode)
	gRaised = ""
	try
		eval("gDummy = " + cCode)
	catch
		gRaised = cCatchError
	done
	return gRaised

func HostileCorpus()
	aH = []
	aH + [ "statement after a semicolon", "x+1;canary=1" ]
	aH + [ "semicolon then a call", "x+1;CanaryFn()" ]
	aH + [ "eval of a string", 'x+eval("canary=1")' ]
	aH + [ "bare assignment", "canary=1" ]
	aH + [ "assignment inside", "x+(canary=1)" ]
	aH + [ "a call of a global function", "x+CanaryFn()" ]
	aH + [ "a call alone", "CanaryFn()" ]
	aH + [ "a string break-out", 'x" + CanaryFn() + "' ]
	aH + [ "a single-quote break-out", "x' + CanaryFn() + '" ]
	aH + [ "newline injection", "x+1" + char(10) + "canary=1" ]
	aH + [ "newline injection, call", "x+1" + char(10) + "CanaryFn()" ]
	aH + [ "carriage return injection", "x+1" + char(13) + "canary=1" ]
	aH + [ "crlf injection", "x+1" + char(13) + char(10) + "canary=1" ]
	aH + [ "load a file", 'load "canary.ring"' ]
	aH + [ "load after an expression", 'x+1 load "canary.ring"' ]
	aH + [ "a second statement with no separator", "x+1 canary=1" ]
	aH + [ "a second statement, a call", "1 CanaryFn()" ]
	aH + [ "two operands then a call", "x 1 CanaryFn()" ]
	aH + [ "a name containing pow, before", "xpow(x,2)" ]
	aH + [ "a name containing pow, after", "powx(x,2)" ]
	aH + [ "a name containing sqrt", "sqrt2(x)" ]
	aH + [ "a name containing max", "maxx([x,1])" ]
	aH + [ "a function glued after a call", "pow(x,2)CanaryFn()" ]
	aH + [ "braces", "x+{canary=1}" ]
	aH + [ "backticks", "x+`canary=1`" ]
	aH + [ "brackets with an assignment", "x+[canary=1]" ]
	aH + [ "the call keyword", "x+call CanaryFn()" ]
	aH + [ "system with a canary argument", 'system("canary=1")' ]
	aH + [ "system after an expression", 'x+system("canary=1")' ]
	aH + [ "eval as a name", 'eval("canary=1")' ]
	aH + [ "import as a name", "import canary" ]
	aH + [ "a dot call", "x.CanaryFn()" ]
	aH + [ "a method call on a number", "1.CanaryFn()" ]
	aH + [ "a comparison", "x==canary" ]
	aH + [ "an assignment to x", "x=CanaryFn()" ]
	aH + [ "a comment tail", "x+1 # CanaryFn()" ]
	aH + [ "a slash comment", "x+1 //CanaryFn()" ]
	aH + [ "a block comment", "x/*CanaryFn()*/" ]
	aH + [ "a power operator", "x**CanaryFn()" ]
	aH + [ "an increment", "x++ CanaryFn()" ]
	aH + [ "hex", "0x1" ]
	aH + [ "a comma statement", "x,CanaryFn()" ]
	aH + [ "a comma then assignment", "x,canary=1" ]
	aH + [ "max with an assignment", "max(canary=1)" ]
	aH + [ "max of a call", "max([CanaryFn(), 1])" ]
	aH + [ "pow with a call", "pow(CanaryFn(), 2)" ]
	aH + [ "sqrt of a name", "sqrt(canary)" ]
	aH + [ "a dollar name", "$canary" ]
	aH + [ "an at name", "@canary" ]
	aH + [ "a colon name", ":canary" ]
	aH + [ "a bracket index", "x[1]" ]
	aH + [ "a bracket call", "[CanaryFn()]" ]
	aH + [ "a pipe", "x|CanaryFn()" ]
	aH + [ "a bitwise and", "x&CanaryFn()" ]
	aH + [ "a modulus", "x%CanaryFn()" ]
	aH + [ "an undeclared name", "canary" ]
	aH + [ "an undeclared name with an operator", "x+canary" ]
	aH + [ "a name used in a nonlinear form", "x/8+CanaryFn()" ]
	aH + [ "a nonlinear form then a statement", "x/8; canary=1" ]
	aH + [ "a nonlinear form then a statement after a space", "pow(x,2) canary=1" ]
	aH + [ "NUL then a statement", "x+1" + char(0) + "canary=1" ]
	aH + [ "a tab then a statement", "x+1" + char(9) + ";" + char(9) + "canary=1" ]
	aH + [ "a vertical tab", "x+1" + char(11) + "CanaryFn()" ]
	aH + [ "a form feed", "x+1" + char(12) + "CanaryFn()" ]
	aH + [ "the Unicode line separator", "x+1" + char(226) + char(128) + char(168) + "canary=1" ]
	aH + [ "a zero-width space inside pow", "p" + char(226) + char(128) + char(139) + "ow(x,2)" ]
	aH + [ "a Cyrillic o (D0 BE) inside pow", "p" + char(208) + char(190) + "w(x,2)" ]
	aH + [ "a Cyrillic a (D0 B0) as a name", "x+" + char(208) + char(176) ]
	aH + [ "a Greek omicron (CE BF) inside pow", "p" + char(206) + char(191) + "w(x,2)" ]
	aH + [ "a fullwidth plus (EF BC 8B)", "x" + char(239) + char(188) + char(139) + "1" ]
	aH + [ "a fullwidth parenthesis (EF BC 88)", "pow" + char(239) + char(188) + char(136) + "x,2)" ]
	aH + [ "a fullwidth semicolon (EF BC 9B)", "x+1" + char(239) + char(188) + char(155) + "canary=1" ]
	aH + [ "a fullwidth x (EF BD 98)", char(239) + char(189) + char(152) + "+1" ]
	aH + [ "a non-breaking space (C2 A0)", "x" + char(194) + char(160) + "+1" ]
	aH + [ "a byte order mark inside", "x" + char(239) + char(187) + char(191) + "+1" ]
	aH + [ "an overlong slash (C0 AF)", "x" + char(192) + char(175) + "2" ]
	aH + [ "a raw high byte", "x+" + char(255) ]
	aH + [ "a very long text", LongText(2500) ]
	aH + [ "a very deep text", DeepText(80) ]
	return aH

func LongText(n)
	cT = "x"
	for i = 1 to n
		cT += "+x"
	next
	return cT

func DeepText(n)
	cT = ""
	for i = 1 to n
		cT += "("
	next
	cT += "x"
	for i = 1 to n
		cT += ")"
	next
	return cT

# a class goes last of all: a func written after a class would belong to it

class CanaryProbe
	def Run(cCode)
		eval(cCode)

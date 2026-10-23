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
$ceSeed = 1   # the seed of the random cross-check, a global so the generator can advance it

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

# ----------------------------------------------------------------------------------------------
# extract reads a coefficient by EVALUATING the judged expression (CE2). The plain path used to
# scan the text: it took x for the x inside xx, ignored a factor outside a parenthesis, and stopped
# at the first occurrence of a variable. Every value below is computed by hand from the expression.
# ----------------------------------------------------------------------------------------------

oC = new stzCoeffExtractor([ "x", "xx", "y", "z" ])

Scenario("The three defects of the plain path, hand-computed, with their wrong old answers as negative siblings")
	n = oC.extract("5*xx + 2*x", "x")
	Then("5*xx + 2*x: the coefficient of x is 2", Near(n, 2, 0.000000001), 1)
	Then("and it is not 5, the coefficient of xx that the old scan found inside the name", Near(n, 5, 0.000000001), 0)
	n = oC.extract("5*xx + 2*x", "xx")
	Then("5*xx + 2*x: the coefficient of xx is 5", Near(n, 5, 0.000000001), 1)
	Then("and it is not 2", Near(n, 2, 0.000000001), 0)
	n = oC.extract("(x + y) * 2 + z", "x")
	Then("(x + y) * 2 + z: the coefficient of x is 2, the factor outside the parentheses counted", Near(n, 2, 0.000000001), 1)
	Then("and it is not 1, what the old scan said", Near(n, 1, 0.000000001), 0)
	n = oC.extract("(x + y) * 2 + z", "y")
	Then("(x + y) * 2 + z: the coefficient of y is 2", Near(n, 2, 0.000000001), 1)
	n = oC.extract("(x + y) * 2 + z", "z")
	Then("(x + y) * 2 + z: the coefficient of z is 1", Near(n, 1, 0.000000001), 1)
	Then("(x + y) * 2 + z: a variable that is not in it, xx, is 0", oC.extract("(x + y) * 2 + z", "xx"), 0)
	n = oC.extract("x + 2*x", "x")
	Then("x + 2*x: the two occurrences are added up: 3", Near(n, 3, 0.000000001), 1)
	Then("and it is not 1, the first term alone", Near(n, 1, 0.000000001), 0)
EndScenario()

Scenario("extract on linear expressions of every shape (hand-computed), each with a wrong neighbour refused")
	aRows = [
		[ "3*x - 2*y + 5", "x", 3 ],
		[ "3*x - 2*y + 5", "y", -2 ],
		[ "3*x - 2*y + 5", "z", 0 ],
		[ "x/8 + y/4", "x", 0.125 ],
		[ "x/8 + y/4", "y", 0.25 ],
		[ "0.5*x", "x", 0.5 ],
		[ "x*3", "x", 3 ],
		[ "3*x*2", "x", 6 ],
		[ "2*(x+1)", "x", 2 ],
		[ "x - x", "x", 0 ],
		[ "7", "x", 0 ],
		[ "-x", "x", -1 ],
		[ "-(x - y)", "y", 1 ],
		[ "-(x - y)", "x", -1 ],
		[ "((x))", "x", 1 ],
		[ "4*(3*(2*x))", "x", 24 ],
		[ "x/4/2", "x", 0.125 ],
		[ "(x + 1)/4", "x", 0.25 ],
		[ "3 - x", "x", -1 ],
		[ "3 * -x", "x", -3 ],
		[ "x - -x", "x", 2 ],
		[ "1e2*x", "x", 100 ],
		[ "2.5E-1*x", "x", 0.25 ],
		[ ".5*x + 5.*x", "x", 5.5 ],
		[ "0.1*x + 0.2*x", "x", 0.3 ],
		[ "1000000 + 0.3*x", "x", 0.3 ],
		[ "2*(x + y*3) - y", "y", 5 ],
		[ "2*(x + y*3) - y", "x", 2 ],
		[ "x*xx", "z", 0 ],
		[ "xx + xx + xx", "xx", 3 ],
		[ "xx + xx + xx", "x", 0 ],
		[ "z*0 + x", "z", 0 ],
		[ "  5 *" + char(9) + "x +  3" + char(9) + "* y  ", "x", 5 ],
		[ "  5 *" + char(9) + "x +  3" + char(9) + "* y  ", "y", 3 ],
		[ "pow(x, 2) * 0 + 2*y", "y", 2 ],
		[ "pow(x, 2) + 3*y", "y", 3 ],
		[ "sqrt(x) + 3*y", "y", 3 ],
		[ "abs(3) * x", "x", 3 ],
		[ "max(2, 5) * x - min(1, 4) * y", "x", 5 ],
		[ "max(2, 5) * x - min(1, 4) * y", "y", -1 ]
	]
	nRows = len(aRows)
	for i = 1 to nRows
		n = oC.extract(aRows[i][1], aRows[i][2])
		Then("[" + aRows[i][1] + "] for " + aRows[i][2] + " is " + aRows[i][3], Near(n, aRows[i][3], 0.000000001), 1)
		Then("[" + aRows[i][1] + "] for " + aRows[i][2] + " is not " + (aRows[i][3] + 1), Near(n, aRows[i][3] + 1, 0.000000001), 0)
	next
EndScenario()

Scenario("The answer does not depend on the order in which the variables are declared")
	oRev = new stzCoeffExtractor([ "z", "y", "xx", "x" ])
	aTexts = [ "5*xx + 2*x", "(x + y) * 2 + z", "x + 2*x", "3*x - 2*y + 5", "x/8 + y/4", "pow(x, 2) + 3*y", "-(x - y)" ]
	aVarsAsked = [ "x", "xx", "y", "z" ]
	nTexts = len(aTexts)
	nSame = 0
	for i = 1 to nTexts
		for j = 1 to 4
			nA = oC.extract(aTexts[i], aVarsAsked[j])
			nB = oRev.extract(aTexts[i], aVarsAsked[j])
			bSame = Near(nA, nB, 0.000000001)
			nSame += bSame
			Then("[" + aTexts[i] + "] for " + aVarsAsked[j] + " is the same in the reverse declaration", bSame, 1)
		next
	next
	Then("all 28 answers agree", nSame, 28)
	Then("and the reverse extractor reads 2 for x in 5*xx + 2*x", Near(oRev.extract("5*xx + 2*x", "x"), 2, 0.000000001), 1)
	aAllRev = oRev.extractAllCoefficients("(x + y) * 2 + z")
	Then("extractAllCoefficients follows the declared order: z y xx x is 1 2 0 2", "" + aAllRev[1] + " " + aAllRev[2] + " " + aAllRev[3] + " " + aAllRev[4], "1 2 0 2")
	aAllC = oC.extractAllCoefficients("(x + y) * 2 + z")
	Then("and in the original order x xx y z it is 2 0 2 1", "" + aAllC[1] + " " + aAllC[2] + " " + aAllC[3] + " " + aAllC[4], "2 0 2 1")
EndScenario()

Scenario("Eight variables, each read exactly")
	oE = new stzCoeffExtractor([ "a1", "a2", "a3", "a4", "a5", "a6", "a7", "a8" ])
	aAll = oE.extractAllCoefficients("a1 + 2*a2 + 3*a3 + 4*a4 + 5*a5 + 6*a6 + 7*a7 + 8*a8")
	Then("eight coefficients come back", len(aAll), 8)
	nOk = 0
	for i = 1 to 8
		nOk += Near(aAll[i], i, 0.000000001)
	next
	Then("they are 1 2 3 4 5 6 7 8", nOk, 8)
	aAll = oE.extractAllCoefficients("(a1 + a2)*3 + a8/4 - 2*(a3 - a4)")
	aWant8 = [ 3, 3, -2, 2, 0, 0, 0, 0.25 ]
	nOk = 0
	for i = 1 to 8
		nOk += Near(aAll[i], aWant8[i], 0.000000001)
	next
	Then("(a1 + a2)*3 + a8/4 - 2*(a3 - a4) gives 3 3 -2 2 0 0 0 0.25", nOk, 8)
	Then("and a name that only starts like another, a1 against a10, is not confused", Near(oE.extract("a8 + 5", "a1"), 0, 0.000000001), 1)
	oE2 = new stzCoeffExtractor([ "a1", "a10" ])
	Then("a10 is read as a10: 2*a10 + a1 gives 1 for a1", Near(oE2.extract("2*a10 + a1", "a1"), 1, 0.000000001), 1)
	Then("and 2 for a10", Near(oE2.extract("2*a10 + a1", "a10"), 2, 0.000000001), 1)
EndScenario()

Scenario("When the expression is not linear in the variable, extract gives the slope at the test point 10, as documented")
	Then("pow(x, 2): 20", Near(oC.extract("pow(x, 2)", "x"), 20, 0.0001), 1)
	Then("and not 1, what a straight line through x = 0 and x = 1 would say", Near(oC.extract("pow(x, 2)", "x"), 1, 0.0001), 0)
	Then("x*x: 20", Near(oC.extract("x*x", "x"), 20, 0.0001), 1)
	Then("abs(x): 1, the rising side at 10", Near(oC.extract("abs(x)", "x"), 1, 0.000001), 1)
	Then("abs(x - 20): -1, the falling side at 10", Near(oC.extract("abs(x - 20)", "x"), -1, 0.000001), 1)
	Then("abs(x - 10): 0, the kink sits at the test point and the central step reads 0", Near(oC.extract("abs(x - 10)", "x"), 0, 0.000001), 1)
	Then("max(x, 0): 1, on its rising branch at 10", Near(oC.extract("max(x, 0)", "x"), 1, 0.000001), 1)
	Then("max(x, 20): 0, on its flat branch at 10", Near(oC.extract("max(x, 20)", "x"), 0, 0.000001), 1)
	Then("max([0, x - 5]): 1", Near(oC.extract("max([0, x - 5])", "x"), 1, 0.000001), 1)
	Then("min(x, 20): 1", Near(oC.extract("min(x, 20)", "x"), 1, 0.000001), 1)
	Then("sqrt(x): 0.158114", Near(oC.extract("sqrt(x)", "x"), 0.158114, 0.000001), 1)
	Then("x*y: 10 for x, the value of y at the test point", Near(oC.extract("x*y", "x"), 10, 0.000001), 1)
	Then("x*y: 10 for y too", Near(oC.extract("x*y", "y"), 10, 0.000001), 1)
	Then("and x*y for x is not 0, what the old scan read as the coefficient before the star", Near(oC.extract("x*y", "x"), 0, 0.000001), 0)
	Then("10/x: -0.1 at x = 10", Near(oC.extract("10/x", "x"), -0.1, 0.00001), 1)
	Then("x/y: 0.1 for x", Near(oC.extract("x/y", "x"), 0.1, 0.00001), 1)
	Then("pow(x, 2) + 3*y: x is 20", Near(oC.extract("pow(x, 2) + 3*y", "x"), 20, 0.0001), 1)
	Then("and y is exactly 3, the expression being linear in y", Near(oC.extract("pow(x, 2) + 3*y", "y"), 3, 0.000000001), 1)
	Then("extractLinearCoefficient says no (an empty text) for pow(x, 2)", oC.extractLinearCoefficient("pow(x, 2)", "x"), "")
	Then("and no for x*y", oC.extractLinearCoefficient("x*y", "x"), "")
	Then("and no for a division by the variable, 10/x", oC.extractLinearCoefficient("10/x", "x"), "")
	Then("and no for sqrt(x), which fails below 0", oC.extractLinearCoefficient("sqrt(x)", "x"), "")
	Then("and no for a kink between the probe points, max(x, 10.5)", oC.extractLinearCoefficient("max(x, 10.5)", "x"), "")
	Then("and no for a kink at the test point, abs(x - 10)", oC.extractLinearCoefficient("abs(x - 10)", "x"), "")
	Then("but a number for a straight line, x/8", Near(oC.extractLinearCoefficient("x/8", "x"), 0.125, 0.000000001), 1)
	Then("and 0 for a variable the text does not use", oC.extractLinearCoefficient("pow(y, 2)", "x"), 0)
EndScenario()

Scenario("Text is judged, never run, on the exact path too: a refused text raises and the canary stays 0")
	canary = 0
	aRef = [
		[ "a statement after a semicolon", "x+1;canary=1" ],
		[ "an incomplete expression", "x +" ],
		[ "a caret", "x ^ 2" ],
		[ "an assignment", "x = 1" ],
		[ "a function that is not listed", "exp(x)" ],
		[ "two operands", "x y" ],
		[ "an eval call", 'x+eval("canary=1")' ],
		[ "a call of a global function", "x+CanaryFn()" ],
		[ "a call alone", "CanaryFn()" ],
		[ "a newline injection", "x" + char(10) + "canary=1" ],
		[ "a brace", "x+{canary=1}" ],
		[ "a comparison", "x==canary" ],
		[ "an empty argument list", "pow()" ],
		[ "a very deep text", DeepText(80) ]
	]
	nRef = len(aRef)
	for i = 1 to nRef
		cMsg = RaiseOf("oC.extract(aRef[" + i + "][2], 'x')")
		Then("refused for x: " + aRef[i][1], Has(cMsg, "stzCoeffExtractor: refused"), 1)
		Then("and the canary is still 0", canary, 0)
		cMsg = RaiseOf("oC.extract(aRef[" + i + "][2], 'z')")
		Then("refused for z as well, the name asked does not change the verdict: " + aRef[i][1], Has(cMsg, "stzCoeffExtractor: refused"), 1)
		cMsg = RaiseOf("oC.extractLinearCoefficient(aRef[" + i + "][2], 'x')")
		Then("refused by extractLinearCoefficient: " + aRef[i][1], Has(cMsg, "stzCoeffExtractor: refused"), 1)
		cMsg = RaiseOf("oC.trySimpleExtraction(aRef[" + i + "][2], 'x')")
		Then("trySimpleExtraction does not run it either: " + aRef[i][1], canary, 0)
		canary = 0
	next
	cMsg = RaiseOf("oC.extract('x+1;canary=1', 'x')")
	Then("the message names the character that stopped it", Has(cMsg, "character ;"), 1)
	cMsg = RaiseOf("oC.extract('x+1', 'x')")
	Then("while the clean sibling x+1 raises nothing", cMsg, "")
	Then("and answers 1", Near(oC.extract("x+1", "x"), 1, 0.000000001), 1)
	cMsg = RaiseOf("oC.extract(12, 'x')")
	Then("an expression that is not a text is refused with a plain message", Has(cMsg, "must be texts"), 1)
	cMsg = RaiseOf("oC.extract('x+1', 12)")
	Then("so is a variable name that is not a text", Has(cMsg, "must be texts"), 1)
	Then("an empty expression has no x: 0", oC.extract("", "x"), 0)
	Then("so does a text of spaces", oC.extract("   ", "x"), 0)
	Then("and an empty variable name is 0", oC.extract("x + 1", ""), 0)
	Then("the declared names are still the four after the refusals", len(oC.VarNames()), 4)
EndScenario()

Scenario("Names the extractor was not told about (the solvers declare theirs late) and names that look alike")
	oU = new stzCoeffExtractor([ "x", "y" ])
	cExpr = "0.15*stocks + 0.04*bonds"
	Then("stocks is not declared and is read as a variable: 0.15", Near(oU.extract(cExpr, "stocks"), 0.15, 0.000000001), 1)
	Then("bonds likewise: 0.04", Near(oU.extract(cExpr, "bonds"), 0.04, 0.000000001), 1)
	Then("x is declared and not in the text: 0", oU.extract(cExpr, "x"), 0)
	Then("a name nobody mentions, declared or not, is 0", oU.extract(cExpr, "cash"), 0)
	Then("a bare undeclared name is 1 for itself", oU.extract("foo", "foo"), 1)
	Then("and 0 for another name", oU.extract("foo", "x"), 0)
	Then("3*x + w: w is not declared and x is still 3", Near(oU.extract("3*x + w", "x"), 3, 0.000000001), 1)
	Then("and w is 1", Near(oU.extract("3*x + w", "w"), 1, 0.000000001), 1)
	Then("the declared names are untouched by all of that", oU.VarNames()[1] + oU.VarNames()[2] + len(oU.VarNames()), "xy2")
	oN = new stzCoeffExtractor([])
	Then("an extractor with no declared name reads 5 for x in 5*x + 3*y", Near(oN.extract("5*x + 3*y", "x"), 5, 0.000000001), 1)
	Then("and 3 for y", Near(oN.extract("5*x + 3*y", "y"), 3, 0.000000001), 1)
	Then("and 0.125 for x/8", Near(oN.extract("x/8", "x"), 0.125, 0.000000001), 1)
	cMsg = RaiseOf("oN.extract('pow(x, 2)', 'x')")
	Then("a non-linear expression still needs the name declared: the numerical path says so", Has(cMsg, "not one of the names"), 1)
	cMsg = RaiseOf("oU.extract('pow(x, 2)', 'x')")
	Then("while with x declared the same call raises nothing", cMsg, "")
	oCS = new stzCoeffExtractor([ "x", "X" ])
	Then("x and X are two variables: x + 2*X gives 1 for x", Near(oCS.extract("x + 2*X", "x"), 1, 0.000000001), 1)
	Then("and 2 for X", Near(oCS.extract("x + 2*X", "X"), 2, 0.000000001), 1)
	oLo = new stzCoeffExtractor([ "x" ])
	Then("with only x declared, X is another name: X + 2*x gives 2 for x", Near(oLo.extract("X + 2*x", "x"), 2, 0.000000001), 1)
	Then("and not 3", Near(oLo.extract("X + 2*x", "x"), 3, 0.000000001), 0)
	oMx = new stzCoeffExtractor([ "x", "max" ])
	Then("a variable named max beside the function: max + 2*x gives 2 for x", Near(oMx.extract("max + 2*x", "x"), 2, 0.000000001), 1)
	Then("and 1 for max", Near(oMx.extract("max + 2*x", "max"), 1, 0.000000001), 1)
	Then("a call of max(1, x) is the function: its slope at 10 is 1", Near(oMx.extract("max(1, x)", "x"), 1, 0.000001), 1)
	Then("and max is not a variable there: 0", oMx.extract("max(1, x)", "max"), 0)
EndScenario()

Scenario("collectNames, runFormula, runFormulaMany and probeLinear, one by one")
	acN = oC.collectNames("2*max(x, y1) + 1e3*foo - .5e-2*x_2 + x + Foo + 7")
	Then("collectNames skips the function and the numbers and counts each name once: x y1 foo x_2 Foo", "" + len(acN) + " " + acN[1] + " " + acN[2] + " " + acN[3] + " " + acN[4], "5 x y1 foo x_2")
	Then("and keeps the case: the fifth is Foo, not foo again", acN[5], "Foo")
	Then("a name before a parenthesis after spaces is a function", len(oC.collectNames("pow  (x, 2)")), 1)
	Then("a text of numbers has no name", len(oC.collectNames("1.5e3 + 2.E+2 + .25")), 0)
	Then("a value that is not a text has no name", len(oC.collectNames(12)), 0)
	aT = oC.translateExpression("2*x + y")
	nRun = oC.runFormula(aT[2], [ 3, 0, 4, 0 ])
	Then("runFormula runs the translated 2*x + y at x=3, y=4: 10", Near(nRun, 10, 0.000000001), 1)
	anMany = oC.runFormulaMany(aT[2], [ [ 3, 0, 4, 0 ], [ 0, 0, 0, 0 ], [ 1, 0, -1, 0 ] ])
	Then("runFormulaMany gives one number per point", len(anMany), 3)
	Then("they are 10, 0 and 1", "" + anMany[1] + " " + anMany[2] + " " + anMany[3], "10 0 1")
	aTd = oC.translateExpression("x / y")
	cMsg = RaiseOf("oC.runFormulaMany(aTd[2], [ [ 1, 0, 2, 0 ], [ 1, 0, 0, 0 ] ])")
	Then("one point that divides by zero fails the whole call, in plain words", Has(cMsg, "divides by zero"), 1)
	cMsg = RaiseOf("oC.runFormulaMany(aTd[2], [ [ 1, 0, 2, 0 ] ])")
	Then("while the point away from zero raises nothing", cMsg, "")
	aTs = oC.translateExpression("sqrt(x)")
	cMsg = RaiseOf("oC.runFormulaMany(aTs[2], [ [ -4, 0, 0, 0 ] ])")
	Then("a square root of a negative number is reported as not evaluable", Has(cMsg, "could not be evaluated"), 1)
	aTo = oC.translateExpression("1e999 * x")
	cMsg = RaiseOf("oC.runFormulaMany(aTo[2], [ [ 3, 0, 0, 0 ] ])")
	Then("an overflow is reported as not finite", Has(cMsg, "finite"), 1)
	Then("probeLinear reads 2 in 2*x + y for x (position 1 of 4)", Near(oC.probeLinear(aT[2], 4, 1), 2, 0.000000001), 1)
	Then("and 1 for y (position 3)", Near(oC.probeLinear(aT[2], 4, 3), 1, 0.000000001), 1)
	aTp = oC.translateExpression("x * y")
	Then("probeLinear says no for x * y, whose rise depends on y", oC.probeLinear(aTp[2], 4, 1), "")
	Then("trySimpleExtraction reads 3 in x*3 (it used to raise a numeric-string error)", Near(oC.trySimpleExtraction("x*3", "x"), 3, 0.000000001), 1)
	Then("trySimpleExtraction reads 3 in x*3 for the right variable only: y is 0", oC.trySimpleExtraction("x*3", "y"), 0)
	Then("trySimpleExtraction still hands pow(x, 2) to the numerical path with an empty text", oC.trySimpleExtraction("pow(x, 2)", "x"), "")
	Then("and a text without function or slash that is not linear, x*y, with an empty text too", oC.trySimpleExtraction("x*y", "x"), "")
	cMsg = RaiseOf("oC.extractLinearCoefficient(12, 'x')")
	Then("extractLinearCoefficient refuses a number as the expression", Has(cMsg, "must be texts"), 1)
EndScenario()

Scenario("The memory of answers is emptied when the names or the step change, and it never keeps an error")
	oK = new stzCoeffExtractor([ "x", "y" ])
	Then("pow(x, 2) asked once: 20", Near(oK.extract("pow(x, 2)", "x"), 20, 0.0001), 1)
	Then("asked again it gives the same 20", Near(oK.extract("pow(x, 2)", "x"), 20, 0.0001), 1)
	oK.setPerturbationDelta(0)
	cMsg = RaiseOf("oK.extract('pow(x, 2)', 'x')")
	Then("after the step is set to 0 the same call raises, so the old answer was not served", Has(cMsg, "must be positive"), 1)
	oK.setPerturbationDelta(0.001)
	Then("with the step put back it answers 20 again", Near(oK.extract("pow(x, 2)", "x"), 20, 0.0001), 1)
	oK.setVariableNames([ "y" ])
	cMsg = RaiseOf("oK.extract('pow(x, 2)', 'x')")
	Then("after the names change to y alone, x is not one of them and the same call raises", Has(cMsg, "not one of the names"), 1)
	oK.setVariableNames([ "x", "y" ])
	Then("with the names put back it answers 20 again", Near(oK.extract("pow(x, 2)", "x"), 20, 0.0001), 1)
	Then("a linear answer is remembered too: 3*x + 2*y gives 3", Near(oK.extract("3*x + 2*y", "x"), 3, 0.000000001), 1)
	oK.setVariableNames([ "x", "y" ])
	Then("and still 3 after the names are set again to the same list", Near(oK.extract("3*x + 2*y", "x"), 3, 0.000000001), 1)
	nBad = 0
	for i = 1 to 410
		nGot = oK.extract("x + " + i + "*y", "y")
		if NOT Near(nGot, i, 0.000000001)
			nBad++
		ok
	next
	Then("410 different expressions, more than the memory holds, are all answered right", nBad, 0)
	Then("and the first one is still right after the memory was emptied on the way: 1", Near(oK.extract("x + 1*y", "y"), 1, 0.000000001), 1)
	Then("as is 3*x + 2*y", Near(oK.extract("3*x + 2*y", "x"), 3, 0.000000001), 1)
	cMsg = RaiseOf("oK.extract('x+1;canary=1', 'x')")
	cMsg2 = RaiseOf("oK.extract('x+1;canary=1', 'x')")
	Then("a refusal is not remembered as an answer: it raises the second time too", Has(cMsg2, "refused"), 1)
EndScenario()

Scenario("200 random linear expressions in three spellings, every coefficient of x, xx, y, yy read exactly")
	# The generator (CeGenCases, at the end of the file) writes each text and computes its true
	# coefficients on the way, from a fixed LCG seed, independently of the extractor. Spellings:
	# a*x + b*y + c, (a*x + b*y + c)*k + d, a*x + b*y + c*x + d, with a*v, v*a and a bare v.
	# Against the plain path of 35c721a03, 187 of these 200 were answered wrongly or raised an error
	# (118 with a silent wrong answer), measured on 2026-10-23.
	aCases = CeGenCases(200)
	Then("200 expressions were generated", len(aCases), 200)
	oR4 = new stzCoeffExtractor([ "x", "xx", "y", "yy" ])
	aNames4 = [ "x", "xx", "y", "yy" ]
	nWithXX = 0
	nExact = 0
	for i = 1 to 200
		cWant = ""
		nAll = 1
		for v = 1 to 4
			nGot = oR4.extract(aCases[i][1], aNames4[v])
			nAll *= Near(nGot, aCases[i][2][v], 0.000001)
			cWant += "" + aCases[i][2][v] + " "
		next
		nExact += nAll
		if Has(aCases[i][1], "xx")
			nWithXX++
		ok
		Then("case " + i + " [" + aCases[i][1] + "]: want " + cWant, nAll, 1)
	next
	Then("all 200 are exact", nExact, 200)
	Then("the corpus is not vacuous: at least 60 texts use xx next to x", nWithXX >= 60, 1)
	aAllFirst = oR4.extractAllCoefficients(aCases[1][1])
	nAgree = 0
	for v = 1 to 4
		nAgree += Near(aAllFirst[v], aCases[1][2][v], 0.000001)
	next
	Then("extractAllCoefficients agrees with the generator on the first case", nAgree, 4)
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

func CeRand(nMax)
	$ceSeed = ($ceSeed * 16807) % 2147483647
	return $ceSeed % nMax

# nCases random linear expressions over x, xx, y, yy, in three spellings; each is [ text, [ c(x), c(xx), c(y), c(yy) ] ],
# the true coefficients being computed here while the text is written, independently of the extractor
func CeGenCases(nCases)
	$ceSeed = 20261022
	aNames = [ "x", "xx", "y", "yy" ]
	aOut = []
	for iCase = 1 to nCases
		nStyle = (iCase - 1) % 3 + 1
		nTerms = CeRand(4) + 1
		anCoef = [ 0, 0, 0, 0 ]
		cBody = ""
		iFirstVar = 0
		for iT = 1 to nTerms
			iVar = CeRand(4) + 1
			nA = CeRand(19) - 9
			if iT = 1
				iFirstVar = iVar
			ok
			nSpell = CeRand(3)
			nAbs = nA
			if nA < 0
				nAbs = -nA
			ok
			if nSpell = 0
				cTerm = "" + nAbs + "*" + aNames[iVar]
			but nSpell = 1
				cTerm = aNames[iVar] + "*" + nAbs
			else
				if nAbs = 1
					cTerm = aNames[iVar]
				else
					cTerm = "" + nAbs + "*" + aNames[iVar]
				ok
			ok
			cSep = " "
			if CeRand(2) = 0
				cSep = ""
			ok
			if iT = 1
				if nA < 0
					cBody = "-" + cTerm
				else
					cBody = cTerm
				ok
			else
				if nA < 0
					cBody = cBody + cSep + "-" + cSep + cTerm
				else
					cBody = cBody + cSep + "+" + cSep + cTerm
				ok
			ok
			anCoef[iVar] = anCoef[iVar] + nA
		next
		nConst = CeRand(19) - 9
		if nStyle = 1
			cText = cBody + " + " + nConst
			if nConst < 0
				cText = cBody + " - " + (-nConst)
			ok
		but nStyle = 2
			nK = CeRand(4) + 2
			cInner = "(" + cBody + " + " + nConst + ")"
			if nConst < 0
				cInner = "(" + cBody + " - " + (-nConst) + ")"
			ok
			if CeRand(2) = 0
				cText = cInner + " * " + nK + " + 4"
			else
				cText = "" + nK + "*" + cInner + " - 3"
			ok
			for i = 1 to 4
				anCoef[i] = anCoef[i] * nK
			next
		else
			nC = CeRand(9) + 1
			cText = cBody + " + " + nC + "*" + aNames[iFirstVar] + " + " + nConst
			if nConst < 0
				cText = cBody + " + " + nC + "*" + aNames[iFirstVar] + " - " + (-nConst)
			ok
			anCoef[iFirstVar] = anCoef[iFirstVar] + nC
		ok
		aOut + [ cText, anCoef ]
	next
	return aOut

# a class goes last of all: a func written after a class would belong to it

class CanaryProbe
	def Run(cCode)
		eval(cCode)

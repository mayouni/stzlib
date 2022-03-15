
new MyMath {

	Sum {
		1	2	3
		4	5	6
		7	8	9
	}

	Mul {
		1	2	3
		4	5	6
		7	8	9
	}
}


class MyMath
	Sum Mul

	def getSum
		return new Sum

	def getMul
		return new Mul

class Mul from Program
	def BraceEnd()
		nMul = 1
		for n in aList
			nMul *= n
		next

		? "Sum: " + nMul

class Sum from Program
	def BraceEnd()
		nSum = 0
		for n in aList
			nSum += n
		next

		? "Sum: " + nSum
class Program
	aList = []

	def BraceExprEval(value)
		if isNumber(value)
			aList + value
		ok


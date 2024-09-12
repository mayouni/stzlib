/*
This class manages the 3 low level types of numbers
supported by SoftanzaLib:
	- int type
	- float type 
	- double type (standard type used internally by Ring)

The term "type" should be understood here as the form the number
is stored in, in the computer memory, as bytes.

The class accepts a number of one of these forms:
	- decimal: example '12500'
	- binary: example 'b10011'
	- hexadecimal: example 'xHE0A'
	- octal: example 'o322'

And offers methods to translate their internal type to:
	- int, by returning a stzListOfBytes of 4 bytes
	- float, by returning a stzListOfBytes of 5 bytes
	- double, by returning a stzListOfBytes of 8 bytes

*/

class stzNumberLowLevelType from stzObject
	cNumber
	cForm # Decimal, Binary, Hexadecimal, Octal.

	def init(pNumber)

	def ToInt()

	def ToFloat()

	def ToDouble()

load "stzlib.ring"

/*================== PHP

# This code snippet is written in PHP. It calculates the min
# and max of two lists of numbers:
"
	echo(min(0, 150, 30, 20, -8, -200));  #--> -200
	echo(max(0, 150, 30, 20, -8, -200));  #--> 150
"

# Nearly the same code can be written in Ring thanks to the
# Min(), Max() and echo() functions of SoftanzaLib:

StartProfiler()

	echo( Min([0, 150, 30, 20, -8, -200]) );   #--> -200
	echo( Max([0, 150, 30, 20, -8, -200]) );   #--> 150

StopProfiler()
# Executed in 0.03 second(s)

/*================== C#

StartProfiler()

	# This is a C# code showing string interpolation:
	'
	int max = int.MaxValue;
	int min = int.MinValue;
	Console.WriteLine($"The range of integers is {min} to {max}");
	'

# And here is the same code translated to Ring:

	int max = RingMaxIntegerXT();
	int min = RingMinIntegerXT();
	Console.WriteLine( $("The range of integers is {min} to {max}") );
	
	#--> The range of integers is '-999_999_999_999_999' to '999_999_999_999_999'
	# NOTE the use of the XT() extension to return the number spacified by "_"
	
StopProfiler()


/*================== JavaScript

# The following JS code translate some string to
# uppercase in a locale sensitive way:
# (you can paste/test it here: https://bit.ly/3WdzMdF)
	"
	console.log('tunis'.toUpperCase());
	//--> TUNIS
	console.log('Iİıi'.toLocaleUpperCase('TR'));
	//--> IİIİ
	console.log('ß'.toLocaleUpperCase('de'));
	//--> SS
	"
# You can write nearly the same code, with almost the
# same JS-style, in Ring, using Softanza:
StartProfiler()

	console.log( Q("tunis").toUpperCase() );
	#--> "TUNIS"
	
	console.log( Q("Iİıi").toLocaleUpperCase('TR') );
	#--> "IİII"
	
	console.log( Q("ß").toLocaleUppercase('de') );
	#--> "SS"

StopProfiler()
# Executed in 0.03 second(s)

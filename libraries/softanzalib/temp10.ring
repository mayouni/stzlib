load "stzlib.ring"


# Ternary operator in C
# variable = (condition) ? value1 : value2;

'
	n = -12;
	sign = (n > 0) ? "postive" : "negative";
	printf(sign);
	#--> negative
'

# The same syntax in Ring (with Softanza)

	n = -12;
	vr([ :sign ]) '=' b(n > 0) '?' bv("positive", "negative");
	printf( v(:sign) );
	#--> negative

proff()



/*-----

	# Program in Python to demonstrate conditional operator
	a, b = 10, 20
	 
	# Copy value of a in min if a < b else copy b
	min = a if a < b else b
	 
	print(min)

/*-----

pron()

o1 = new stzString("")

? o1.FindSSZ("", -1, 0)
#--> 0

? @@( o1.FindSSZZ("", -1, 0) )
#-->  []

proff()

/*-----


pron()

o1 = new stzString("123♥♥678♥♥123♥♥678")
? @@( o1.FindSSZZ("♥♥", 7, 17) )
#--> [ [ 9, 10 ], [ 14, 15 ] ]

? @@( o1.FindInSectionZZ("♥♥", 7, 17) )
#--> [ [ 9, 10 ], [ 14, 15 ] ]

? @@( o1.FindBetweenZZ("♥♥", 7, 17) )
#--> [ [ 9, 10 ], [ 14, 15 ] ]

proff()
# Executed in 0.05 second(s)

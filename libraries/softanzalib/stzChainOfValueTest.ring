load "stzlib.ring"

/*---------------
*/
# We initialize a value in v variable
v = "12"

/*---------------

# we start speeking in Compuer-natural Code (CnC)...
Whatever(:v).DoThis('{ ? "Done! Anyway." }') # or if you want...
Whatever(:v).Is.DoThis('{ ? "Done! Anyway." }')

# But if you say:
Whatever(:v).Is(5) # you get nothing and the chain is stopped!

# Let's see why:
? Whatever(:v).Is(5).WhyChainStopped() # --> Well: it's semantic error!

/*---------------

# Now we say:
OnlyWhen(:v).Is("12").DoThis('{ ? "Done! Only because you requested it." }')
# It works! And if you ask abusively why chain stopped...
? OnlyWhen(:v).Is("12").WhychainStopped() # Softanza tells you chain is not stopped!
/*---------------

# Now, what if you want the chain to execute randomly?
? SometimesWhen(:v).Is("12").DoThis('{ ? "Done! Because I am lucky ;)" }')
# --> Sometimes, it will say: Done! Because I am lucky ;)

/*---------------

# Of course, when values are different, this will never execute:
SometimesWhen(:v).Is("3").DoThis('{ ? "Done! Because I am lucky ;)" }') # --> NULL
SometimesWhen(:v).Is("3").ChainStatus() # --> :Stopped
? SometimesWhen(:v).Is("3").WhyChainStopped() # Because equality will never happen,
# since values are actually different!

/*---------------

# Now, let's experiment with an other construction, using Until():
Until(:v).Is("12000").DoThis('{ v += "0" ? v }') # --> [ "120", "1200", "12000" ]

/*---------------

# Here (using "Until()"), you need to be careful, because you could easily fall
# in an infinite loop problem! Try this for example (execute it in the console
# to be able to interrupt it without blocking Ring Notepad):

Until(:v).Is("11000").DoThis('{ v += "0" ? v }') # --> Infinite loop (stackoverflow)
# That's because v, beeing equal to "12", and the incrementation code (in "DoThis()")
# would never elevate it to react the value 11000.

/*---------------

# We've seen the use of Until(), what if we try Since() instead...

# First thing to note is that Since() requires a StopValue() to stop
? Since(:v).Is("12").RequiresStopValue() # --> TRUE

# Therefore, if we provide a code in DoThis(), it's not executed:
? Since(:v).Is("12").DoThis('{ v += "0" ? v }').CodeStatus() # --> :NotYetExecuted

# And we can ask why it is the case, just after DoThis()...
? Since(:v).Is("12").DoThis('{ v += "0" ? v }').WhyCodeNotYetExecuted()
# -->	Because "Since(:v)" requires "DoThis(:v)" not to execute until
#	it knows where it should stop, using "StopWhen().Becomes()"!

# or we can ask the same question after StopWhen():
? Since(:v).Is("12").DoThis('{ v += "0" ? v }').StopWhen(:v).WhyCodeNotYetExecuted()

# This beeing understood, let's write a complete chain and see what it returns:
Since(:v).Is("12").DoThis('{ v += "0" ? v }').StopWhen(:v).Becomes("1200000")
# -->	[ "120", "1200", "12000", "120000", "1200000" ]




/*--------------- TODO

OnlyWhen(v).Is.AStringQ().DoThis('{ ? "Done! As requested." }') # --> DoThis() : Do_().This_()

OnlyWhen(v).IsNotANumberQ().DoThis('{ ? "Done! As requested." }')
OnlyWhen(v).Is.NotANumberQ().DoThis('{ ? "Done! As requested." }')
OnlyWhen(v).IsNot.ANumberQ().DoThis('{ ? "Done! As requested." }')
OnlyWhen(v).Is.Not_.ANumberQ().DoThis('{ ? "Done! As requested." }')

SometimesWhen(n).IsANumberQ().DoThis('{ ? "Done! Because I am lucky ;)" }')

/*--------------- TODO

Until(v).Becomes(12).DoThis('{ v += 2 ? v }')

Until(v).BecomesEqualTo(12).DoThis('{ v += 2 ? v }')
Until(v).BecomesEqualTo(12).Do_.This_('{ v += 2 ? v }')
Until(v).BecomesEqualTo(12).Do_('{ v += 2 ? v }')

/*--------------- TODO

Until(v).BecomesEqualTo("1000").Execute('{ v += "0" ? v }')
Execute('{ v += "0" ? v }').Until(v).BecomesEqualTo("1000")
Unless.

/*--------------- TODO

? Until(v).Becomes.ANumber().DoThis('{
		v += "0"

		if v = "1000"
			v = 0+ v
		ok

		? v + " : " + ring_type(v)
}')

/*--------------- TODO

//Until(v).Becomes.EqualTo(12).DoThis('{ v += 2 ? v }')
#Until(v).Becomes.DoubleOf(6).DoThis('{ v += 2 ? v }')

/*--------------- TODO

//? ThisValue(5).IsANumber()

/*--------------- TODO


/*----------------- TODO

BeforeDoingThis('{ ? 24 / v }').CheckThat('{ v != 0 }')
DoThis('{ ? "Hi!" + NL }')._(10).Times
DoThis('{ v++ ? v }').While('{ v < 9 }')
Until('{ v = "12000" '}).DoThis('{ v += "0" ? v }')




load "../number/stkNumber.ring"

/*== Flexible initialisation

# The object is initialised with a number

o1 = new stzCoreNumber(123.4)

	# We can check that numeric value

	? o1.NValue()
	#--> 123.40

	# along with its string representation

	? o1.SValue()
	#--> '123.40'

	#NOTE

	# As you can see, the string value contains 2 rounds.
	# That's because even though we wrote 123.4 in the
	# initialisation of the object, its effective value
	# is 123.40.

	# In this case, the current round (which is 2 by default)	
	# is used to transform the number into a string:

	? CurrentRound()
	#--> 2

	decimals(3)
	o1 = new stkNumber(123.4)

	? o1.SValue() + NL
	#--> '123.400'

# The other way around, we can provide a number in string

decimals(2) # to set the default round back

o2 = new stzCoreNumber("678.908")

	# The string value stays the same

	? o2.SValue()
	#--> "678.908"

	# And the object identifies the round 3 defined by the string

	? o2.Round()
	#--> 3

	# But the numeric value is impacted by the current round
	# in the program (which is 2 in our case)

	? o1.NValue()
	#--> 123.40

	# The advantage of storing the round provided by the string
	# is that we can use it to make calculations:

	? o2 - "0.201"
	#--> '678.707'

/*---

oNum = new stzCoreNumber(1234.56)

cQuery = "INSERT INTO transactions (amount) VALUES ('" +
	  oNum.SValue() + "')"

? cQuery
#--> "INSERT INTO transactions (amount) VALUES ('1234.56')"

/*== Rounding protection

decimals(2)  # Default in Ring

o1 = new stzCoreNumber("123.4567")
? o1.Round()
#--> 4

? o1.SValue()
#--> "123.4567"

? o1.NValue()
#--> 123.46 (affected by global decimals)

/*=== Sign

oPositive = new stzCoreNumber(42)
oNegative = new stzCoreNumber(-42)

? oPositive.Sign()
#--> "+"

? oNegative.Sign()
#--> "-"

/*---

o1 = new stkNumber("-23.656")

# Including the minus in decimal part of negative numbers

	? o1.DecimalPart()
	#--> 0.66
	
	o1.WithMinusInDecimalPart()
	
	? o1.DecimalPart()
	#--> -0.66
	
	o1.NoMinusInDecimalPart()
	
	? o1.DecimalPart() + NL
	#--> 0.66

# Same test using the string representation of the number
# (note how the value keeps the defined round in the string)

	? o1.StringDecimalPart()
	#--> '0.656'
	
	o1.WithMinusInDecimalPart()
	
	? o1.StringDecimalPart()
	#--> '-0.656'
	
	o1.NoMinusInDecimalPart()
	
	? o1.StringDecimalPart() + NL
	#--> '0.656'

/*=== Integer and Decimal Parts

o1 = new stzCoreNumber(123.45)

? o1.IntPart()
#--> 123

? o1.SIntPart()
#--> "123"

? o1.DecPart()
#--> 0.45

? o1.SDecPart()
#--> "0.45"

/*-- Show and hide positive sign in string display

o1 = new stkNumber("12.4")
? o1.SValue()
#--> '12.4'

? o1.@bShowPositive
#--> FALSE

o1.ShowPositive()

? o1.@bShowPositive
#--> TRUE

? o1.SValue()
#--> '+12.4'

o1.HidePositive()

? o1.@bShowPositive
#--> FALSE

? o1.SValue()
#--> '12.4'

/*---

oDuration = new stzCoreNumber(3.75)  # 3 hours and 45 minutes
nHours = oDuration.IntPart()
nMinutes = oDuration.DecPart() * 60

? "Duration: " + nHours + " hours and " + nMinutes + " minutes"
#--> Duration: 3 hours and 45 minutes

/*--- Number spacification

o1 = new stzCoreNumber(1234567890.123456)

? o1.Spacified()
#--> 1_234_567_890.12"

# we get 2 rounds in the string representation because 2 is
# the courrent rount in the program:

? CurrentRound()
#--> 2

# Hence, the number we provided (1234567890.123456) is automatically
# orounded by Ring to 2 positions:

? 1234567890.123456
#--> 1234567890.12

# Then, the stzNumber object just stringifies it to get
# the corresponding output ("1234567890.12")

# You can internally change the round of the number independently
# from the gloabl round in the Ring program:

o1.SetRound(5)
? o1.Spacified()
#--> 1_234_567_890.12346

o1.SetRound(3)
? o1.Spacified()
#--> 1_234_567_890.123

/*--------

? NumberSpacify(-511_234_567_890.123456, "_", 3, 3)
#--> '-511_234_567_890.12'

/*--------
*/

o1 = new stzCoreNumber("-511_234_567_890.1234")

? o1.SIntegerPart()
# -511_234_567_890

? o1.SValue()
#--> -511_234_567_890.1234

? o1.Spacified()
#--> -511_234_567_890.1234

o1.Unspacify()
? o1.SValue()
#--> -511234567890.12

o1.Spacify()
? o1.SValue()
#--> -511_234_567_890.12


/*--------

o1 = new stkNumber("12_300")

? o1 + "250"
#--> 12_550

? o1.Value()
#--> 12550

/*--------

o1 = new stkNumber("12300")

? o1 + "2_200"	# spacifies the number, does not alter its value
#--> 14_500

? o1.Value()
#--> 12300

? o1 * 2
#--> 24600	#~> a number because 2 is a number

? o1 * "1_000"
#--> 24_600_000	#~> a spacified string because "1_000" intsructed it to do so

? o1 / 2
#--> 12300000	#~> a number

? o1 / "2_000"
#--> 6_150	#~> a string

*--------


o1 = new stkNumber(14500.90)
? o1.Spacified()
#--> 14_500.90

/*------- #ring

# By default, Ring rounds numbers to 2 positions

n = 12.8745
? n
#--> 12.87

# But internally, the hole decimal part is not lost:

decimals(4)
? n
#--> 14500.90

# That's why stzCoreNumber class, although it has a
# dual representation of numbers (in number and string)
# for practical reasons, the number representation
# should stay it's single source of the truth.

/*------- #ring

? CurrentRound()
#--> 2

decimals(3)
? CurrentRound()
#--> 3

decimals(12)
? CurrentRound()
12

/*-------

o1 = new stkNumber("12300.112")

? o1.NValue()
#--> 12300.11

? o1.Spacified() + NL
#--> '12_300.112'

o1.Add("2_200.789")

? o1.NValue()
#--> 14500.90

? o1.Spacified()

? o1.SValue()


/*--------

o1 = new stkNumber("-12_150_340")

o1.Add(-660)
? o1.NValue()
#--> -12151000

? o1.Spacified()
#--> '-12_151_000'

? o1 - 4800
#--> -12155800		#~> a number because 4800 is a number

? o1 + "800"
#--> -12_155_000	#~> a string because "800" is a string,
			#   spacified because the initial number
			#   "-12_150_340" is spacified



/*--- Precision calculations ///////////////


oNumber = new stzCoreNumber("12.345")
? oNumber * 7.1878
#--> 88.64 (numeric output, global decimals applied)

? oNumber * "5_100.87335"
#--> "88.6371" (string output, maximum precision)
/*
oNumber.SetRound(2)
? oNumber * "7.18"
#--> "88.64" (string output, specified precision)


/*---- //////////////////////////

oNumber = new stzCoreNumber("12_340_560.12")
? oNumber / "2"
#--> "6_170_280.06"

oNumber.Unspacify()
? oNumber / "2"
#--> "6170280.06"

/*---

oNumber = new stzCoreNumber("12340560.12")
? oNumber / "2"
#--> "6170280.06"

oNumber.Spacify()
? oNumber / "2"
#--> "6_170_280.06"


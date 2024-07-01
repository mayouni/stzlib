/*
#TODO: Implement it with QDate and QDateTime()
#TODO review the class design to be consistent with all other classes

*/

/*
d1 = new stzDate([ :Year = 2020, :Day = "12", :Month = "12"  ])
d2 = new stzDate("10/12/2020")
d3 = new stzDate(10122020)

? d + "28 days"
? d + "11 months"
? d + "3 years"
*/

/*

Read this nice article about dates and times:
https://www.infoq.com/articles/java.time
By Stephen Colebourne
Here is an abstract:

	The truth is that when today’s applications are examined, most code
	that tries to operate in a calendar system neutral manner is broken.
	For example, you cannot assume that there are 12 months in a year,
	yet developers do and add 12 months assuming that they have added
	a whole year. You cannot assume that all months are roughly the
	same length - the Coptic calendar system has 12 months of 30 days
	and one month of five or six days. Nor can you assume that the next
	year has a number one larger than the current year, as calendars like
	the Japanese restart year numbering when the Emperor changes, which
	is typically mid-year (you can’t even assume that two days in the
	same month have the same year!).

Also, read about these false assumptions about dates and think of avoiding them
in softanza (taken from JavaDoc here:
https://bit.ly/2S9y7dU

	These false assumptions cause  bugs in multi-calendar system code:

	Code that queries the day-of-month and assumes that the value will
	never be more than 31 is invalid. Some calendar systems have more
	than 31 days in some months.
	
	Code that adds 12 months to a date and assumes that a year has been
	added is invalid. Some calendar systems have a different number of
	months, such as 13 in the Coptic or Ethiopic.
	
	Code that adds one month to a date and assumes that the month-of-year
	value will increase by one or wrap to the next year is invalid.
	Some calendar systems have a variable number of months in a year,
	such as the Hebrew.
	
	Code that adds one month, then adds a second one month and assumes
	that the day-of-month will remain close to its original value is invalid.
	Some calendar systems have a large difference between the length of the
	longest month and the length of the shortest month. For example, the Coptic or Ethiopic have 12 months of 30 days and 1 month of 5 days.
	
	Code that adds seven days and assumes that a week has been added is
	invalid. Some calendar systems have weeks of other than seven days,
	such as the French Revolutionary.
	
	Code that assumes that because the year of date1 is greater than the
	year of date2 then date1 is after date2 is invalid. This is invalid
	for all calendar systems when referring to the year-of-era, and
	especially untrue of the Japanese calendar system where the
	year-of-era restarts with the reign of every new Emperor.
	
	Code that treats month-of-year one and day-of-month one as the start
	of the year is invalid. Not all calendar systems start the year when
	the month value is one.

#NOTE // Get insipration from Time&Money library design
// Link: https://timeandmoney.sourceforge.net/

*/

_aDaysOfWeek = [
	[ "1", :Monday ],
	[ "2", :Tuesday ],
	[ "3", :Wednesday ],
	[ "4", :Thursday ],
	[ "5", :Friday ],
	[ "6", :Saturday ],
	[ "7", :Sunday ]
]

func StzDate(pDat)
	return new stzDate(pDate)

func StzDateQ(pDat)
	return new stzDate(pDate)

func DefaultDaysOfWeek()
	return _aDaysOfWeek

func SysDate()
	return date()

func ring_addDays(cDate, n)
	return addDays(cDate, n)

class stzDate from stzObject
	cDate
	cDay
	cMonth
	cYear

	oQDate = new QDate()

	def init(pDate)
		/*
		pDate can be a Number, a String, or a Hash list
		In other terms, you can write:
			new stzDate(10102020), or
			new stzDate("10/10/2020"), or
			new stzDate([ :Day = 10, :Month = 10, :Year = 2020 ])
		In all cases, you get the date "10/10/2020"

		So, first of all we will transform any input to a String.
		Then, we will verify if the input corresponds to a valid date.
		Only then, we take it, otherwise we reject it.
		*/

		if isString(pDate)
			
			This.cDate = ""+ pDate

		but isNumber(pDate)
			oTemp = new stzString(""+ pDate)
			This.cDate =	oTemp.NLeftChars(2)   + "/"   +
				  	oTemp.Section(3,4) + "/"   +
				  	oTemp.NRightChars(4)

		but isList(pDate) 
			This.cDate = ""+ pDate[:Day] +   "/"  +
				         pDate[:Month] + "/"  +
				         pDate[:Year]
		ok
		
	def operator(op,v)

		n = v

		if isString(v)
			oStr = new stzString(v)
			if oStr.BeginsWithANumber()

				n = 0+ oStr.Numbers()[1]

				cVType = lower( oStr.RemoveSpacesQ().NumbersRemoved() )
				if NOT ( cVType = "days" or cVType = "months" or cVType = "years" )
					Stzraise("Incorrect value! You must provide a string in the form 'n days', 'n months', or 'n years' with n beeing a number.")
				ok
			ok
		ok

		if op = "+"
			switch cVType
			on "days"
				return This.AddDays(n)

			on "months"
				return This.AddMonths(n)

			on "years"
				return This.AddYears(n)
			off

		but op = "-"
			switch cVType
			on "days"
				return This.SubStructDays(n)

			on "months"
				return This.SubStructMonths(n)

			on "years"
				return This.SubStructYears(n)
			off

		else
			StzRaise("Can't proceed! Only + and - operators are supported on dates.")

		ok

	def AddDays( nDays )

		// If the number of added days is zero then return the current date
		if nDays = 0 { return This.cDate }

		// Else, let's do the job

		// Using the Ring standard function for adding days
		cResult = ring_addDays( This.cDate,(0+ nDays) )

		// Reading the years part and controlling it so it does not exceed 9999
		nYears = 0+ right(cResult, len(cResult)-6)	
		if nYears > 9999
			StzRaise("Can't proceed. The years part ("+ nYears + ") must be under 9999!")
		ok
			
		// Everything is ok, returning the new date
		return cResult	


	def SubstructDays( pDays )
		nDays = 0- pDays
		return stzAddDays(nDays)
	
		def SubstractDays(pDay)
			return This.SubstructDays( pDays )

		def Subtract(pDay)
			return This.SubstructDays( pDays )

		def Subtruct(pDays)
			return This.SubstructDays( pDays )

	// Adding n months to the current date
	def AddMonths(pMonths)
		// If the number of months is zero then return the current date
		if 0+ pMonths = 0
			return This.cDate
		ok

		// Else, let's do the job...

		// Calculating the sum of (existant + new) months
		n = 0+ pMonths + This.Months()

		// Calculating how many years in this sum of months
		cTemp = ""+ (n / 12)

		cYearsToAdd = ""
		for c in cTemp
			if c = "."
				exit
			ok
			cYearsToAdd += c
		next

		// Calculating the rest of months less then a year
		nYearsToAdd = 0+ cYearsToAdd
		nMonthsToAdd = n - nYearsToAdd * 12

		// Calculating the months part of the new date
		nMonths = 0+ Months() + nMonthsToAdd
		cMonths = "" + nMonths
		if len(cMonths) = 1 { cMonths = "0" + cMonths }
	
		// Calculating the years part of the new date
		nYears = 0+ Years() + nYearsToAdd

		// Checking the maximum number of years allowed (9999)
		if nYears > 9999
			StzRaise("Can't proceed. The years part ("+ nYears + ") must be under 9999!")
		ok

		// Constructing the new date and returning it
		This.cDate = Days() + "/" + cMonths + "/" + nYears
		return This.cDate

	def AddYears( pYears )
		// If the number of years is zero then return the current date
		if 0+ pYears = 0
			return This.sDate
		ok

		// Else, let's do the job...

		// Calculating the sum of (existant + new) years
		nYears = 0+ pYears + This.Years()

		// Checking the maxim number of years allowed (9999)
		if nYears > 9999
			StzRaise("Can't proceed. The years part in stzDate can't exceed 9999!")
		ok

		// Constructing the new date and returning it
		This.cDate = Days() + "/" + Months() + "/" + nYears
		return This.cDate


	def Years()

		oTemp = new stzString(This.cDate)
		return oTemp.NRightCharsAsString(4)
	
	def Months()
		oTemp = new stzString(This.cDate)
		cTemp = oTemp.OnlyNumbers()
		oTemp = new stzString(cTemp)
		return oTemp.Section(3,4)

	def Days()
		oTemp = new stzString(This.cDate)
		return oTemp.NLeftCharsAsString(2)

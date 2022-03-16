/*
DEPRECATED: Delete this class and use stzDate instead
*/

/*
d1 = new stzDate([ :Year = 2020, :Day = "12", :Month = "12"  ])
d2 = new stzDate("10/12/2020")
d3 = new stzDate(10122020)

? d + "28 days"
? d + "11 months"
? d + "3 years"
*/

func SysDate()
	return date()


class stzDate from stzObject
	cDate
	cDay
	cMonth
	cYear

	def init(pDate)
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
		if op = "+"
			return stzAddDays( This.cDate,(0+ v) )

		but op = "-"
			return stzAddDays( This.cDate, (0- v) )
		ok

	def stzAddDays( nDays )
		// If the number of added days is zero then return the current date
		if nDays = 0 { return This.cDate }

		// Else, let's do the job

		// Using the Ring standard function for adding days
		cResult = addDays( This.cDate,(0+ nDays) )

		// Reading the years part and controlling it so it does not exceed 9999
		nYears = 0+ right(cResult, len(cResult)-6)	
		if nYears > 9999
			stzRaise("Can't proceed. The years part ("+ nYears + ") must be under 9999!")
		ok
			
		// Everything is ok, returning the new date
		return cResult	


	def SubstructDays( pDays )
		nDays = 0- pDays
		return stzAddDays(nDays)
	
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
			stzRaise("Can't proceed. The years part ("+ nYears + ") must be under 9999!")
		ok

		// Constructing the new date and returning it
		This.cDate = Days() + "/" + cMonths + "/" + nYears
		return This.sDate

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
			stzRaise("Can't proceed. The years part in stzDate can't exceed 9999!")
		ok

		// Constructing the new date and returning it
		This.cDate = Days() + "/" + Months() + "/" + nYears
		return This.cDate


	def Years()
		oTemp = new stzString(This.sDate)
		return oTemp.NRightChars(4)
	
	def Months()
		oTemp = new stzString(This.sDate)
		cTemp = oTemp.OnlyNumbers()
		oTemp = new stzString(cTemp)
		return oTemp.Section(3,4)

	def Days()
		oTemp = new stzString(This.cDate)
		return oTemp.NLeftChars(2)


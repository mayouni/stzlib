
#NOTE // Get insipration from Time&Money library design
// Link: https://timeandmoney.sourceforge.net/

_cDefaultTimeFormat = "hh:mm:ss"

func Now()
	return time()

func StzTimeQ(pTime)
	return new stzTime(pTime)

// TODO: Change it with the method TimeStamp after completing the class
func TimeStamp()
	return date() + "-" + time()

# Implementation of mktime function in Ring
# Converts calendar time components to Unix timestamp
# Made during a conversation in the Ring Group with Bert
# Link: https://groups.google.com/g/ring-lang/c/_byfajtY8mc/m/-GUt_sRGBAAJ

func mktime(year, month, day, hour, minute, second) # By ClaudeAI
    # Validate input ranges
    if year < 1970 or month < 1 or month > 12 or 
       day < 1 or day > 31 or 
       hour < 0 or hour > 23 or 
       minute < 0 or minute > 59 or 
       second < 0 or second > 59
        return 0  # Invalid input
    ok

    # Days in each month (non-leap year)
    days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

    # Adjust for leap years
    if year % 4 = 0 and (year % 100 != 0 or year % 400 = 0)
        days_in_month[2] = 29
    ok

    # Validate day against month
    if day > days_in_month[month]
        return 0  # Invalid day for the month
    ok

    # Calculate total days since Unix epoch (1970-01-01)
    total_days = 0

    # Count days from years before the given year
    for y = 1970 to year - 1
        total_days += 365
        # Add leap day for leap years
        if y % 4 = 0 and (y % 100 != 0 or y % 400 = 0)
            total_days += 1
        ok
    end

    # Add days for months in the current year
    for m = 1 to month - 1
        total_days += days_in_month[m]
    end

    # Add days in current month
    total_days += day - 1

    # Calculate total seconds
    timestamp = (total_days * 24 * 60 * 60) +  # Days to seconds
                (hour * 60 * 60) +             # Hours to seconds
                (minute * 60) +                # Minutes to seconds
                second                         # Remaining seconds

    return timestamp

#-------------#
#  THE CLASS  #
#-------------#

class stzTime from stzObject
	oQTime

	def init()
		oQTime = new QTime()
		
	def Content()
		return oQTime

		def Value()
			return Content()

	def QTimeObject()
		return oQTime

	def CurrentTime()
		return oQTime.currentTime().tostring(_cDefaultTimeFormat)

	def ToString(cFormat)
		if cFormat = "" or cFormat = :Default
			cFormat = _cDefaultTimeFormat
		ok

		return oQTime.toString(cFormat)
		/*
		By default, cFormat take the value hosted in the global variable
		_cDefaultTimeFormat = "hh:mm:ss"

		Or cFormat can be defined freely like in these examples:
			"hh:mm:ss", "h:m:ss", "HH:MM:SS", "hh:mm:ss.zzz", etc.

		Hence, Possible expressions you can include are:

		h 	: the hour without a leading zero (0 to 23 or 1 to 12 if AM/PM display)
		hh 	: the hour with a leading zero (00 to 23 or 01 to 12 if AM/PM display)
		H 	: the hour without a leading zero (0 to 23, even with AM/PM display)
		HH 	: the hour with a leading zero (00 to 23, even with AM/PM display)
		m 	: the minute without a leading zero (0 to 59)
		mm 	: the minute with a leading zero (00 to 59)
		s 	: the second without a leading zero (0 to 59)
		ss 	: the second with a leading zero (00 to 59)
		z 	: the milliseconds without leading zeroes (0 to 999)
		zzz 	: the milliseconds with leading zeroes (000 to 999)
		AP or A : use AM/PM display. AP will be replaced by either "AM" or "PM".
		ap or a : use am/pm display. ap will be replaced by either "am" or "pm".
		t 	: the timezone (for example "CEST")
		*/

	def TimeStamp()
		return date() + " " + time()

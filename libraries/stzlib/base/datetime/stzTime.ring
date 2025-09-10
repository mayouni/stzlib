
#NOTE // Get insipration from Time&Money library design
// Link: https://timeandmoney.sourceforge.net/

_cDefaultTimeFormat = "hh:mm:ss"

func StzTimeQ(pTime)
	return new stzTime(pTime)

// TODO: Change it with the method TimeStamp after completing the class
func TimeStamp()
	return date() + "-" + time()

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

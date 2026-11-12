# Narrative
# --------
# Example 15: Counting from Islamic calendar
#
# Extracted from stzdatetimetest.ring, block #76.
#
# CORRECTED 2026-11-12. This block asked for :CountingFromIslamicCalendar, which
# is not an option this library has: the name is :CountingFromIslamicHijra. The
# constructor used to answer an unrecognised key by falling through a long HasKey
# chain into the explicit-components branch, which filled in its defaults and
# returned 2000-01-01 reporting success. So this block had stopped exercising the
# Islamic epoch entirely while still looking like it did. The constructor refuses
# an unknown key now.
#
# The value below is recorded as what the API ANSWERS, and it is not 1400 AH.
# 1400 AH began on 1979-11-21, and 1400 LUNAR years after the Hijra is about
# 1980-11-09. This API counts a year as 365 SOLAR days, so 1400 of them from the
# Hijra epoch (-42521587200000 ms, 622 CE) lands on epoch day 18852 -- which is
# 2021-08-13, forty-one years late. The number is right for the arithmetic the
# method performs and wrong for the calendar its name invokes.
#
# Routed to the culture module (C8), which owns calendars: a calendar is
# interpretation, not formatting. It is not patched here, because inventing
# Islamic calendar arithmetic inside a defect fix would be a second facade.

load "../../stzBase.ring"


pr()

# (a) A key the library does not have is refused, not answered.

try
	oUnknown = new stzDateTime([
		:CountingFromIslamicCalendar = [ :Years = 1400 ]
	])
	? "NOT REFUSED"

catch
	? "Unsupported option refused"
done
#--> Unsupported option refused

# (b) The real key, and the solar-year arithmetic it uses today.

oDateTime = new stzDateTime([
	:CountingFromIslamicHijra = [ :Years = 1400 ]
])

? oDateTime.Content()
#--> 2021-08-13 00:00:00

pf()

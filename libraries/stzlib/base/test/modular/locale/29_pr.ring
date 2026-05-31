# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #29.

load "../../../stzBase.ring"


? StzLocaleQ([ :Country = :Tunisia ]).NthDayOfWeek(3)		# tuesday
? StzLocaleQ([ :Country = :Tunisia ]).NthNativeDayOfWeek(3)	# الأربعاء

? StzLocaleQ("ar-TN").NthDayOfWeek(3)		# tuesday
? StzLocaleQ("ar-TN").NthNativeDayOfWeek(3)	# الأربعاء

pf()
# Executed in 0.03 second(s) in Ring 1.23

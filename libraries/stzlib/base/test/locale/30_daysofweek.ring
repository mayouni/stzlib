# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #30.

load "../../stzBase.ring"

pr()

? StzLocaleQ("ar-TN").DaysOfWeek()
#-->
'
monday
tuesady
wednesday
thirsday
friday
saturday
sunday
'
? StzLocaleQ("ar-TN").NativeDaysOfWeek()
#-->
'
الاثنين
الثلاثاء
الأربعاء
الخميس
الجمعة
السبت
الأحد
'

pf()
# Executed in 0.01 second(s) in Ring 1.23

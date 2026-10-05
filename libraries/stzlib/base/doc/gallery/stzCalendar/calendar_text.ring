# made cal1.ring ; run: cd libraries/stzlib/base/test/reflect && ring <this file>  (picture: calendar_text.txt)
load "../../../stzlib.ring"
# chdir("<an output folder>") here, after the load, so the picture lands there (the engine DLL path breaks if Ring starts elsewhere: run from base/test/reflect)
oCal = new stzCalendar([2024, 10])
oCal.SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
oCal.SetBusinessHours("09:00:00", "17:00:00")
oCal.AddBreak("12:00:00", "13:00:00", "Lunch")
oCal.AddHoliday("2024-10-09", "Midweek Holiday")
? "== Show =="
oCal.Show()
? "== ShowHeatMap =="
oCal.ShowHeatMap()
? "== ShowTable =="
oCal.ShowTable()
? "== feb 2024 =="
o2 = new stzCalendar([2024, 2])
o2.Show()
? "TotalDays=" + oCal.TotalDays() + " working=" + len(oCal.WorkingDays()) + " avail=" + len(oCal.AvailableDays())

# made t1.ring ; run: cd libraries/stzlib/base/test/reflect && ring <this file>  (picture: timeline_text.txt)
load "../../../stzlib.ring"
# chdir("<an output folder>") here, after the load, so the picture lands there (the engine DLL path breaks if Ring starts elsewhere: run from base/test/reflect)
o1 = new stzTimeLine("2024-01-01", "2024-12-31")
o1.AddPoint("launch", "2024-02-14 10:00:00")
o1.AddPoint("review", "2024-09-02 09:00:00")
o1.AddSpan("ALPHA", "2024-03-01", "2024-04-30")
o1.AddSpan("BETA", "2024-06-01", "2024-08-15")
? "-- ToString --"
? o1.ToString()
? "-- ShowShort --"
o1.ShowShort()

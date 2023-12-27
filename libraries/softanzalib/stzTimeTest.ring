load "stzlib.ring"


? TimeStamp()
#--> 27/12/2023-11:12:08

? "start..."
	StzWait(5) # Based on Ilir contribution on the Ring Group
? "end" + NL

? "Start again..."
	o1 = new stzTime()
	o1.Wait(5)
	? o1.CurrentTime()
? "end"

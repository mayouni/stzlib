load "guilib.ring"

o1 = new QByteArray()
o1.append("سلاما حارا")
? o1.constdata()
? o1.size()

? ""
for i=1 to o1.size()
	? o1.at(i)
next i

? ""
? o1.EndsWith("را")

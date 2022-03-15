load "guilib.ring"

// create an time object from QT
o1 = new QTime()

// Set the time as hours, minutes, seconds and milliseconds
o1.setHMS(10,5,20,15)

// Read time in that object
? o1.hour()
? o1.minute()
? o1.second()
? o1.msec()
? ""

// Add some milliseconds to the the current time object
o2 = o1.addMSecs(934_550) # returns a new time object

// Read time in the new object
? o2.hour()
? o2.minute()
? o2.second()
? o2.msec()




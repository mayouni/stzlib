
o1 = new Thing
o1 {
	val = att1 	#--> att1 is read!
	att2 = "hi!"	#--> att2 is updated with hi!
df
}

class thing
	att1
	att2

	def getAtt1
		? "att1 is read!"

	def setAtt2(v)
		? "att2 is updated with " + v

	def bracestart
		? "Object is accessed with { brace..."

	def braceend
		? "Onject is closed with } brace."

	def braceerror
		? "!!! " + cCatchError + " !!!"


/*
em = new stzEventManager
em {
	AddEvent("INIT", "Show" )
	AddEvent("ADD", "Show" )
	AddEvent("UPDATE", "Show" )
	AddEvent("REMOVE", "Show" )
	? Events()

	Perform() Perform() Perform() Perform() Perform()

	? Events()
}
*/

func Show()
	? "Yesss!"

class stzEventManager from stzObject
	aEvents = []

	def AddEvent(id, pcName, pcFunc)
		aEvents + [ id, pcName, pcFunc ]

	def Events()
		return aEvents

	def NumberOfEvents()
		return len(aEvents)

	def PerformEvent()
		while NumberOfEvents() > 0
			if aEvents[1][3] != _NULL_
				eval( aEvents[1][3]+"()" )
			ok
		end



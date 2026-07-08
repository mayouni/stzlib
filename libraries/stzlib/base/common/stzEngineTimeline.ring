#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZENGINETIMELINE           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Engine-backed timeline class for the        #
#                  Softanza Engine (stz_timeline module).       #
#                  Named events with timestamps and queries.    #
#                  (Distinct from stzTimeLine in datetime/)     #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  #=============#
 #  FUNCTIONS  #
#=============#

func StzEngineTimelineQ()
	return new stzEngineTimeline()

func IsStzEngineTimeline(pObj)
	if isObject(pObj) and classname(pObj) = "stzenginetimeline"
		return 1
	else
		return 0
	ok

	func @IsStzEngineTimeline(pObj)
		return IsStzEngineTimeline(pObj)


  /////////////////
 ///   CLASS   ///
/////////////////

class stzEngineTimeline from stzObject

	  #--------------#
	 #     INIT     #
	#--------------#

	def init()
		# Engine manages global timeline store

	  #-------------------------------#
	 #     EVENTS                    #
	#-------------------------------#

	def AddEvent(cLabel, nTimestamp)
		if CheckingParams()
			if NOT isString(cLabel) or cLabel = ""
				StzRaise("Incorrect param! cLabel must be a non-empty string.")
			ok
			if NOT isNumber(nTimestamp)
				StzRaise("Incorrect param! nTimestamp must be a number.")
			ok
		ok

		nResult = StzEngineTimelineAddEvent(cLabel, nTimestamp)
		if nResult < 0
			StzRaise("Can't add event! Event slots full.")
		ok

		def AddEventQ(cLabel, nTimestamp)
			This.AddEvent(cLabel, nTimestamp)
			return This

	def EventCount()
		return StzEngineTimelineEventCount()

		def NumberOfEvents()
			return This.EventCount()

	def EventLabel(nIndex)
		return StzEngineTimelineEventLabel(nIndex)

	def EventTime(nIndex)
		return StzEngineTimelineEventTime(nIndex)

		def EventTimestamp(nIndex)
			return This.EventTime(nIndex)

	def EventsBetween(nStartTime, nEndTime)
		return StzEngineTimelineEventsBetween(nStartTime, nEndTime)

	def EventsSorted()
		return StzEngineTimelineEventsSorted()

		def SortedEvents()
			return This.EventsSorted()

	def Duration()
		return StzEngineTimelineDuration()

		def TotalDuration()
			return This.Duration()

	  #-------------------------------#
	 #     REMOVAL AND CLEANUP       #
	#-------------------------------#

	def RemoveEvent(cLabel)
		nResult = StzEngineTimelineRemove(cLabel)
		if nResult < 0
			StzRaise("Event '" + cLabel + "' not found!")
		ok

	def Clear()
		StzEngineTimelineClear()

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

# Keeps named events with timestamps in the engine and answers questions about them, such as how many fall in a range.
#
# The store lives in the engine and is shared by every stzEngineTimeline object of the process, so
# call Clear() first when you want a fresh one. Positions are counted from 0, in the order the
# events were added. Timestamps are plain numbers in the unit you choose. Duration() answers 0
# today. It is not the stzTimeLine class of the datetime module.
#
#   receiver   o1 = new stzEngineTimeline() o1.Clear() o1.AddEvent("start", 100)
#              o1.AddEvent("build", 200)
#   example    ? o1.EventCount()
#              #--> 2
#              ? o1.EventLabel(1)
#              #--> build
#              ? o1.EventsBetween(100, 150)
#              #--> 1
#              o1.Clear()
#   see        stzLatencyHistogram, stzTraceContext
class stzEngineTimeline from stzObject

	  #--------------#
	 #     INIT     #
	#--------------#

	# Opens the engine's timeline store, one list of named, timestamped events that every stzEngineTimeline object shares.
	#
	#   returns    nothing; the object is built
	#   warning    the store is global to the process: events added through one object are seen by
	#              every other
	#   see        Clear
	def init()
		# Engine manages global timeline store

	  #-------------------------------#
	 #     EVENTS                    #
	#-------------------------------#

	# Appends an event with a label and a numeric timestamp to the timeline; the same label may be added twice.
	#
	#   cLabel       the event's name, a non-empty text
	#   nTimestamp   when it happened, as a number in any unit you choose
	#   returns      nothing
	#   note         events keep the order in which they were added
	#   warning      a label that is empty or not a text, and a timestamp that is not a number,
	#                raise an error
	#   see          EventCount, RemoveEvent
	def AddEvent(cLabel, nTimestamp)
		if CheckingParams()
			if NOT isString(cLabel) or cLabel = ""
				StzRaise("Incorrect param! cLabel must be a non-empty string.")
			ok
			if NOT isNumber(nTimestamp)
				StzRaise("Incorrect param! nTimestamp must be a number.")
			ok
		ok

		_nResult_ = StzEngineTimelineAddEvent(cLabel, nTimestamp)
		if _nResult_ < 0
			StzRaise("Can't add event! Event slots full.")
		ok

		def AddEventQ(cLabel, nTimestamp)
			This.AddEvent(cLabel, nTimestamp)
			return This

	# Returns how many events the timeline holds.
	#
	#   returns    a number
	#   see        AddEvent, Clear
	def EventCount()
		return StzEngineTimelineEventCount()

		def NumberOfEvents()
			return This.EventCount()

	# Returns the label of the event at a position, counted from 0 in the order the events were added.
	#
	#   nIndex     the position of the event, starting at 0
	#   returns    a text; empty when the position is out of range
	#   see        EventTime, EventCount
	def EventLabel(nIndex)
		return StzEngineTimelineEventLabel(nIndex)

	# Returns the timestamp of the event at a position, counted from 0 in the order the events were added.
	#
	#   nIndex     the position of the event, starting at 0
	#   returns    a number; 0 when the position is out of range
	#   see        EventLabel, EventCount
	def EventTime(nIndex)
		return StzEngineTimelineEventTime(nIndex)

		def EventTimestamp(nIndex)
			return This.EventTime(nIndex)

	# Returns how many events have a timestamp from nStartTime to nEndTime, both included.
	#
	#   nStartTime   the lower end of the time range
	#   nEndTime     the upper end of the time range
	#   returns      a number
	#   note         it answers a count, not the events themselves
	#   warning      a reversed range (end before start) is not refused: it counted every event
	#   see          EventsSorted, EventTime
	def EventsBetween(nStartTime, nEndTime)
		return StzEngineTimelineEventsBetween(nStartTime, nEndTime)

	# Returns how many events the timeline holds, after asking the engine to sort them by time.
	#
	#   returns    a number
	#   warning    the labels read back by position keep their insertion order afterwards, so the
	#              sort is not visible through EventLabel or EventTime
	#   see        EventCount
	def EventsSorted()
		return StzEngineTimelineEventsSorted()

		def SortedEvents()
			return This.EventsSorted()

	# Returns 0 on every call today, whatever the events are.
	#
	#   returns    0
	#   warning    answered 0 for timestamps 100, 200, 300, then 1000 and 5000, then 2.5 and 9, then
	#              1700000000 and 1700000060, sorted or not; the span between the first and the last
	#              event is not computed
	#   see        EventTime
	def Duration()
		return StzEngineTimelineDuration()

		def TotalDuration()
			return This.Duration()

	  #-------------------------------#
	 #     REMOVAL AND CLEANUP       #
	#-------------------------------#

	# Removes the event that has a given label.
	#
	#   cLabel     the label of the event to remove
	#   returns    nothing
	#   warning    an unknown label is silently ignored: the not-found error the code intends is
	#              never raised
	#   see        AddEvent, Clear
	def RemoveEvent(cLabel)
		_nResult_ = StzEngineTimelineRemove(cLabel)
		if _nResult_ < 0
			StzRaise("Event '" + cLabel + "' not found!")
		ok

	# Empties the timeline for every object that shares it.
	#
	#   returns    nothing
	#   see        EventCount, RemoveEvent
	def Clear()
		StzEngineTimelineClear()

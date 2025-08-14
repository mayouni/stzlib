/*
	stzTimer - Softanza Timer Class
	A reactive timer wrapper around Qt's QTimer for the Softanza library
	Supports reactive programming patterns and fluent interface design
*/

func CurrentTime() #TODO // Move it inside stzTime.ring when made
	return time() # Ring function

class stzTimer from stzObject

	@oQTimer		# Internal QTimer object
	@cTimeoutEvent		# Timeout event handler

	def init(p)
		if isObject(p) and classname(p) = "qobject"
			@oQTimer = new QTimer(p)
		else
			@oQTimer = new QTimer(NULL)
		ok
		
		@cTimeoutEvent = ""
		
		# Connect timeout signal to internal handler
		@oQTimer.settimeoutEvent("timeoutHandler()")

	def content()
		return @oQTimer

	def copy()
		oResult = new stzTimer(NULL)
		oResult.setInterval(this.interval())
		oResult.setSingleShot(this.isSingleShot())
		oResult.setTimeoutEvent(this.timeoutEvent())
		return oResult

	# Core Timer Methods
	
	def start()
		@oQTimer.start()
		return this

	def stop()
		@oQTimer.stop()
		return this

	def restart()
		this.stop()
		this.start()
		return this

	def pause()
		return this.stop()

	def resume()
		return this.start()

	# Timer Properties

	def interval()
		return @oQTimer.interval()

	def setInterval(nMsec)
		if NOT isNumber(nMsec) or nMsec < 0
			stzRaise("Invalid interval value!")
		ok
		@oQTimer.setInterval(nMsec)
		return this

	def intervalInSeconds()
		return this.interval() / 1000

	def setIntervalInSeconds(nSeconds)
		return this.setInterval(nSeconds * 1000)

	def isActive()
		return @oQTimer.isActive()

	def isSingleShot()
		return @oQTimer.isSingleShot()

	def setSingleShot(bSingleShot)
		@oQTimer.setSingleShot(bSingleShot)
		return this

	def timerId()
		return @oQTimer.timerId()

	# Event Handling

	def timeoutEvent()
		return @oQTimer.gettimeoutEvent()

	def setTimeoutEvent(cEvent)
		@cTimeoutEvent = cEvent
		@oQTimer.settimeoutEvent(cEvent)
		return this

	def onTimeout(cHandler)
		return this.setTimeoutEvent(cHandler)

	# Fluent Configuration Methods

	def everyMilliseconds(nMs)
		return this.setInterval(nMs).setSingleShot(FALSE)

	def everySeconds(nSeconds)
		return this.setIntervalInSeconds(nSeconds).setSingleShot(FALSE)

	def everyMinutes(nMinutes)
		return this.setInterval(nMinutes * 60 * 1000).setSingleShot(FALSE)

	def onceAfterMilliseconds(nMs)
		return this.setInterval(nMs).setSingleShot(TRUE)

	def onceAfterSeconds(nSeconds)
		return this.setIntervalInSeconds(nSeconds).setSingleShot(TRUE)

	def onceAfterMinutes(nMinutes)
		return this.setInterval(nMinutes * 60 * 1000).setSingleShot(TRUE)

	# Quick Timer Creation (Static-like methods)

	def createRepeatingTimer(nInterval, cHandler)
		return this.setInterval(nInterval).setSingleShot(FALSE).onTimeout(cHandler)

	def createSingleShotTimer(nInterval, cHandler)
		return this.setInterval(nInterval).setSingleShot(TRUE).onTimeout(cHandler)

	# Timer State Queries

	def isRunning()
		return this.isActive()

	def isStopped()
		return NOT this.isActive()

	def isRepeating()
		return NOT this.isSingleShot()

	def remainingTime()
		if this.isActive()
			# Note: QTimer doesn't provide remainingTime, this is an approximation
			return this.interval()
		else
			return 0
		ok

	# String Representation

	def toString()
		cActive = ""
		if this.isActive()
			cActive = "ACTIVE"
		else
			cActive = "STOPPED"
		ok
		
		cType = ""
		if this.isSingleShot()
			cType = "SINGLE-SHOT"
		else
			cType = "REPEATING"
		ok
		
		cResult = "stzTimer(" + cActive + ", " + cType + 
			  ", interval=" + this.interval() + "ms" + ")"
			  
		return cResult

	# Comparison and Equality

	def isEqualTo(oOther)
		if NOT isObject(oOther) or ring_classname(oOther) != "stztimer"
			return FALSE
		ok
		
		return this.interval() = oOther.interval() and
		       this.isSingleShot() = oOther.isSingleShot() and
		       this.isActive() = oOther.isActive()

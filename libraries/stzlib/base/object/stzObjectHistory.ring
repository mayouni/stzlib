# Global flag to prevent recursive history tracking
//_bInHistoryUpdate = _FALSE_


func KeepingHistory()
	return _bKeepHisto

	func KeepingHisto()
		return KeepingHistory()

	func KeepingObjectHistory()
		return KeepingHistory()

	func KeepingObjectHisto()
		return KeepingHistory()

	func KeepingObjHist()
		return KeepingHistory()

func KeepingHistoryXT()
	return _aKeepHistoXT[1]

	func KeepingHistoXT()
		return KeepingHistoryXT()

	func KeepingObjectHistoryXT()
		return KeepingHistoryXT()

	func KeepingObjectHistoXT()
		return KeepingHistoryXT()

	func KeepingObjHistXT()
		return KeepingHistoryXT()

#-- Enhanced History Control Functions

func KeepHistoryON()
	_bKeepHisto = _TRUE_

	func KeepHistory()
		KeepHistoryON()

	func KeepHistoON()
		KeepHistoryON()

	func KeepHisto()
		KeepHistoryON()

func KeepHistoryOFF()
	_bKeepHisto = _FALSE_

	func DontKeepHistory()
		KeepHistoryOFF()

	func KeepHistoOFF()
		KeepHistoryOFF()

	func DontKeepHisto()
		KeepHistoryOFF()

#-- Enhanced TraceObjectHistory with Recursion Prevention

func TraceObjectHistory(poStzObj)
	# CRITICAL: Prevent recursive calls
	if _bInHistoryUpdate = _TRUE_
		return
	ok

	# Check if history tracking is enabled
	if KeepingHistory() = _FALSE_ and KeepingHistoryXT() = _FALSE_
		return
	ok

	_obj_ = poStzObj
	
	# Set flag to prevent recursion
	_bInHistoryUpdate = _TRUE_

	try
		# Basic history tracking
		if KeepingHistory() = _TRUE_
			_obj_.AddHistoricValueInternal(_obj_.Content())
		ok

		# Extended history tracking
		if KeepingHistoryXT() = _TRUE_
			_cDisp_ = _aKeepHistoXT[2]
			_aHistoryData_ = []

			switch _cDisp_
			on "vtms"
				_aHistoryData_ = [
					_obj_.Content(),
					_obj_.StzType(),
					_obj_.ExecTime(),
					_obj_.SizeInBytes()
				]

			on "vtm"
				_aHistoryData_ = [
					_obj_.Content(),
					_obj_.StzType(),
					_obj_.ExecTime()
				]

			on "vts"
				_aHistoryData_ = [
					_obj_.Content(),
					_obj_.StzType(),
					_obj_.SizeInBytes()
				]

			on "tms"
				_aHistoryData_ = [
					_obj_.StzType(),
					_obj_.ExecTime(),
					_obj_.SizeInBytes()
				]

			on "vt"
				_aHistoryData_ = [
					_obj_.Content(),
					_obj_.StzType()
				]

			on "vm"
				_aHistoryData_ = [
					_obj_.Content(),
					_obj_.ExecTime()
				]

			on "vs"
				_aHistoryData_ = [
					_obj_.Content(),
					_obj_.SizeInBytes()
				]

			on "tm"
				_aHistoryData_ = [
					_obj_.StzType(),
					_obj_.ExecTime()
				]

			on "ts"
				_aHistoryData_ = [
					_obj_.StzType(),
					_obj_.SizeInBytes()
				]

			on "ms"
				_aHistoryData_ = [
					_obj_.ExecTime(),
					_obj_.SizeInBytes()
				]

			other
				StzRaise("Unsupported history mode: " + _cDisp_)
			off

			_obj_.AddHistoricValueXTInternal(_aHistoryData_)
		ok

	catch
		# Handle any errors during history tracking
		# Log error but don't break the main operation
		# Could add logging here if needed
	done

	# Always reset the flag
	_bInHistoryUpdate = _FALSE_

	func @TraceObjectHistory(pStzObj)
		TraceObjectHistory(pStzObj)

	func TraceStzObjectHistory(pStzObj)
		TraceObjectHistory(pStzObj)

	func @TraceStzObjectHistory(pStzObj)
		TraceObjectHistory(pStzObj)


#-- Utility Functions for Debugging

func IsInHistoryUpdate()
	return _bInHistoryUpdate

func GetHistoryUpdateState()
	return _bInHistoryUpdate

func ResetHistoryUpdateState()
	_bInHistoryUpdate = _FALSE_

#-- Enhanced Error Handling

func SafeTraceObjectHistory(poStzObj)
	# Extra safety wrapper
	if poStzObj = NULL
		return
	ok
	
	if _bInHistoryUpdate = _TRUE_
		return
	ok
	
	try
		TraceObjectHistory(poStzObj)
	catch
		# Log error and continue
		# Could add proper error logging here
		_bInHistoryUpdate = _FALSE_
	done

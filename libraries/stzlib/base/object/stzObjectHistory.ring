# Global flag to prevent recursive history tracking
//_bInHistoryUpdate = 0


func KeepingHistory()
	return _bKeepHisto

	func KeepingHisto()
		return _bKeepHisto

	func KeepingObjectHistory()
		return _bKeepHisto

	func KeepingObjectHisto()
		return_bKeepHisto

	func KeepingObjHist()
		return _bKeepHisto


func KeepingHistoryXT()
	return _aKeepHistoXT[1]

	func KeepingHistoXT()
		return _aKeepHistoXT[1]

	func KeepingObjectHistoryXT()
		return _aKeepHistoXT[1]

	func KeepingObjectHistoXT()
		return _aKeepHistoXT[1]

	func KeepingObjHistXT()
		return _aKeepHistoXT[1]

#-- Enhanced History Control Functions

func KeepHistoryON()
	_bKeepHisto = 1

	func KeepHistory()
		_bKeepHisto = 1

	func KeepHistoON()
		_bKeepHisto = 1

	func KeepHisto()
		_bKeepHisto = 1

func KeepHistoryOFF()
	_bKeepHisto = 0

	func DontKeepHistory()
		_bKeepHisto = 0

	func KeepHistoOFF()
		_bKeepHisto = 0

	func DontKeepHisto()
		_bKeepHisto = 0

#-- Enhanced TraceObjectHistory with Recursion Prevention

func TraceObjectHistory(poStzObj)
	# CRITICAL: Prevent recursive calls
	if _bInHistoryUpdate = 1
		return
	ok

	# Check if history tracking is enabled
	if KeepingHistory() = 0 and KeepingHistoryXT() = 0
		return
	ok

	_obj_ = poStzObj
	
	# Set flag to prevent recursion
	_bInHistoryUpdate = 1

	try
		# Basic history tracking
		if KeepingHistory() = 1
			_obj_.AddHistoricValueInternal(_obj_.Content())
		ok

		# Extended history tracking
		if KeepingHistoryXT() = 1
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
	_bInHistoryUpdate = 0

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
	_bInHistoryUpdate = 0

#-- Enhanced Error Handling

func SafeTraceObjectHistory(poStzObj)
	# Extra safety wrapper
	if poStzObj = NULL
		return
	ok
	
	if _bInHistoryUpdate = 1
		return
	ok
	
	try
		TraceObjectHistory(poStzObj)
	catch
		# Log error and continue
		# Could add proper error logging here
		_bInHistoryUpdate = 0
	done

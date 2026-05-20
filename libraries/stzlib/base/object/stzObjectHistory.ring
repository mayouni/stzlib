# Global flag to prevent recursive history tracking
//_bInHistoryUpdate = 0


func StzKeepingHistory()
	return _bKeepHisto

	func KeepingHistory()
		return StzKeepingHistory()

	func KeepingHisto()
		return StzKeepingHistory()

	func KeepingObjectHistory()
		return StzKeepingHistory()

	func KeepingObjectHisto()
		return StzKeepingHistory()

	func KeepingObjHist()
		return StzKeepingHistory()


func StzKeepingHistoryXT()
	return _aKeepHistoXT[1]

	func KeepingHistoryXT()
		return StzKeepingHistoryXT()

	func KeepingHistoXT()
		return StzKeepingHistoryXT()

	func KeepingObjectHistoryXT()
		return StzKeepingHistoryXT()

	func KeepingObjectHistoXT()
		return StzKeepingHistoryXT()

	func KeepingObjHistXT()
		return StzKeepingHistoryXT()

#-- Enhanced History Control Functions

func StzKeepHistoryON()
	_bKeepHisto = 1

	func KeepHistoryON()
		StzKeepHistoryON()

	func KeepHistory()
		StzKeepHistoryON()

	func KeepHistoON()
		StzKeepHistoryON()

	func KeepHisto()
		StzKeepHistoryON()

func StzKeepHistoryOFF()
	_bKeepHisto = 0

	func KeepHistoryOFF()
		StzKeepHistoryOFF()

	func DontKeepHistory()
		StzKeepHistoryOFF()

	func KeepHistoOFF()
		StzKeepHistoryOFF()

	func DontKeepHisto()
		StzKeepHistoryOFF()

#-- Enhanced TraceObjectHistory with Recursion Prevention

func StzTraceObjectHistory(poStzObj)
	# CRITICAL: Prevent recursive calls
	if _bInHistoryUpdate = 1
		return
	ok

	# Check if history tracking is enabled
	if StzKeepingHistory() = 0 and StzKeepingHistoryXT() = 0
		return
	ok

	_obj_ = poStzObj

	# Set flag to prevent recursion
	_bInHistoryUpdate = 1

	try
		# Basic history tracking
		if StzKeepingHistory() = 1
			_obj_.AddHistoricValueInternal(_obj_.Content())
		ok

		# Extended history tracking
		if StzKeepingHistoryXT() = 1
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
	done

	# Always reset the flag
	_bInHistoryUpdate = 0

	func TraceObjectHistory(pStzObj)
		StzTraceObjectHistory(pStzObj)

	func @TraceObjectHistory(pStzObj)
		StzTraceObjectHistory(pStzObj)

	func TraceStzObjectHistory(pStzObj)
		StzTraceObjectHistory(pStzObj)

	func @TraceStzObjectHistory(pStzObj)
		StzTraceObjectHistory(pStzObj)


#-- Utility Functions for Debugging

func StzIsInHistoryUpdate()
	return _bInHistoryUpdate

	func IsInHistoryUpdate()
		return StzIsInHistoryUpdate()

func StzGetHistoryUpdateState()
	return _bInHistoryUpdate

	func GetHistoryUpdateState()
		return StzGetHistoryUpdateState()

func StzResetHistoryUpdateState()
	_bInHistoryUpdate = 0

	func ResetHistoryUpdateState()
		StzResetHistoryUpdateState()

#-- Enhanced Error Handling

func StzSafeTraceObjectHistory(poStzObj)
	if poStzObj = NULL
		return
	ok

	if _bInHistoryUpdate = 1
		return
	ok

	try
		StzTraceObjectHistory(poStzObj)
	catch
		_bInHistoryUpdate = 0
	done

	func SafeTraceObjectHistory(poStzObj)
		StzSafeTraceObjectHistory(poStzObj)

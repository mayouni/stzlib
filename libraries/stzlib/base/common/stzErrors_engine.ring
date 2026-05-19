
#=================================================================#
#  ENGINE-BACKED ERROR FORMATTING                                 #
#  Convenience wrappers around EngineFormatError() for the        #
#  most common error patterns in stzlib.                          #
#=================================================================#

# These functions replace hand-crafted StzRaise() strings like:
#
#   StzRaise("Incorrect param type! pItem must be a string.")
#
# With catalog-based formatting:
#
#   StzRaiseParamType("pItem", "string")

func StzRaiseParamType(cParam, cExpected)
	StzRaise(EngineFormatError(:PARAM_TYPE, [
		[:param, cParam],
		[:expected, cExpected]
	]))

func StzRaiseParamTypeOneOf(cParam, cExpected1, cExpected2)
	StzRaise(EngineFormatError(:PARAM_TYPE_ONE_OF, [
		[:param, cParam],
		[:expected1, cExpected1],
		[:expected2, cExpected2]
	]))

func StzRaiseParamTypeListOf(cParam, cExpected)
	StzRaise(EngineFormatError(:PARAM_TYPE_LIST_OF, [
		[:param, cParam],
		[:expected, cExpected]
	]))

func StzRaiseOutOfRange(nIndex, nMax)
	StzRaise(EngineFormatError(:OUT_OF_RANGE, [
		[:n, "" + nIndex],
		[:max, "" + nMax]
	]))

func StzRaiseEmptyList(cOp)
	StzRaise(EngineFormatError(:EMPTY_LIST, [
		[:op, cOp]
	]))

func StzRaiseEmptyString(cOp)
	StzRaise(EngineFormatError(:EMPTY_STRING, [
		[:op, cOp]
	]))

func StzRaiseSizeMismatch(nSize1, nSize2)
	StzRaise(EngineFormatError(:LIST_SIZE_MISMATCH, [
		[:size1, "" + nSize1],
		[:size2, "" + nSize2]
	]))

func StzRaiseConflict(cParam1, cParam2)
	StzRaise(EngineFormatError(:CONFLICTING_PARAMS, [
		[:param1, cParam1],
		[:param2, cParam2]
	]))

func StzRaiseNotImplemented(cFeature)
	StzRaise(EngineFormatError(:NOT_IMPLEMENTED, [
		[:feature, cFeature]
	]))

func StzRaiseDeprecated(cOld, cNew)
	StzRaise(EngineFormatError(:DEPRECATED, [
		[:old, cOld],
		[:new, cNew]
	]))

# Structured error (Where/What/Why/Todo) -- engine-backed version
func StzRaiseStructured(cWhere, cWhat, cWhy, cTodo)
	StzRaise(EngineFormatError(:STRUCTURED, [
		[:where, cWhere],
		[:what, cWhat],
		[:why, cWhy],
		[:todo, cTodo]
	]))


#=================================================================#
#  ENGINE-BACKED ERROR FORMATTING                                 #
#  Convenience wrappers around StzMetaFormatError() for the       #
#  most common error patterns in stzlib.                          #
#=================================================================#

func StzRaiseParamType(cParam, cExpected)
	StzRaise(StzMetaFormatError(:PARAM_TYPE, [
		[:param, cParam],
		[:expected, cExpected]
	]))

func StzRaiseParamTypeOneOf(cParam, cExpected1, cExpected2)
	StzRaise(StzMetaFormatError(:PARAM_TYPE_ONE_OF, [
		[:param, cParam],
		[:expected1, cExpected1],
		[:expected2, cExpected2]
	]))

func StzRaiseParamTypeListOf(cParam, cExpected)
	StzRaise(StzMetaFormatError(:PARAM_TYPE_LIST_OF, [
		[:param, cParam],
		[:expected, cExpected]
	]))

func StzRaiseOutOfRange(nIndex, nMax)
	StzRaise(StzMetaFormatError(:OUT_OF_RANGE, [
		[:n, "" + nIndex],
		[:max, "" + nMax]
	]))

func StzRaiseEmptyList(cOp)
	StzRaise(StzMetaFormatError(:EMPTY_LIST, [
		[:op, cOp]
	]))

func StzRaiseEmptyString(cOp)
	StzRaise(StzMetaFormatError(:EMPTY_STRING, [
		[:op, cOp]
	]))

func StzRaiseSizeMismatch(nSize1, nSize2)
	StzRaise(StzMetaFormatError(:LIST_SIZE_MISMATCH, [
		[:size1, "" + nSize1],
		[:size2, "" + nSize2]
	]))

func StzRaiseConflict(cParam1, cParam2)
	StzRaise(StzMetaFormatError(:CONFLICTING_PARAMS, [
		[:param1, cParam1],
		[:param2, cParam2]
	]))

func StzRaiseNotImplemented(cFeature)
	StzRaise(StzMetaFormatError(:NOT_IMPLEMENTED, [
		[:feature, cFeature]
	]))

func StzRaiseDeprecated(cOld, cNew)
	StzRaise(StzMetaFormatError(:DEPRECATED, [
		[:old, cOld],
		[:new, cNew]
	]))

func StzRaiseStructured(cWhere, cWhat, cWhy, cTodo)
	StzRaise(StzMetaFormatError(:STRUCTURED, [
		[:where, cWhere],
		[:what, cWhat],
		[:why, cWhy],
		[:todo, cTodo]
	]))

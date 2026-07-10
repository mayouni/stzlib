#---------------------------------------------------------------------------#
#  stzNaturalCode -- context memory for near-natural coding (Era-1 residue)  #
#                                                                            #
#  TRIMMED 2026-07-10 per doc/design/NATURAL_VISION.md sequencing step 1.    #
#  What left, and where its ideas live now:                                  #
#    - the _aFuture deferred-action queue (AddFuture/ExecuteFuture/          #
#      BeforeQ/AfterQ, FQ/FFQ suffixes) -> the plan: the stzNatural engine   #
#      builds the full token plan BEFORE executing (SOV reordering,          #
#      StzNaturalPlanFor). The FQ/FFQ method wrappers were already dropped   #
#      during string modularization.                                         #
#    - the _ActionsXT form glossary -> stzNaturalLangData.ring (pure         #
#      lexicon data, Source 2 of StzSemanticLexicon).                        #
#  What REMAINS here is the context-memory trio, still consumed by live      #
#  code (stzObject B-suffix comparisons, the stzFuncs QM family, and the     #
#  stzChainOfTruth surface pending its NATURAL_VISION step-4 decision):      #
#    - _oMainObject  (MainObject/SetMainObject, set by QM)                   #
#    - _LastValue    (LastValue/SetLastValue, read by *B() comparisons)      #
#    - QRT()         (Q with an explicit return type -- a general utility)   #
#  Full original: git history / natural/archive of this file's ancestors.   #
#---------------------------------------------------------------------------#

_oMainObject = ANullObject() # Used for chains of truth
_LastValue = NULL

func QM(p)
	_obj_ = Q(p)
	SetMainObject(_obj_)
	return _obj_

func QRT(p, pcType)
	if NOT isString(pcType)
		StzRaise("Invalid param type! pcType should be a string containing the name of a softanza class.")
	ok

	if Q(pcType).IsStzClassName()
		_cCode_ = "oResult = new " + pcType + '(' + @@(p) + ')'

		eval(_cCode_)

		return oResult
	else
		StzRaise("Unsupported Softanza type!")
	ok

func MainObject() # Used in Chains of truth
	return _oMainObject

	func @MainObject()
		return _oMainObject

func SetMainObject(_obj_)
	_oMainObject = _obj_

func LastValue()
	return _LastValue

func SetLastValue(value)
	_LastValue = value

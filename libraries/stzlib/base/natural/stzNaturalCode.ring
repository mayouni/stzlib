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
#    - _LastValue    (LastValue/SetLastValue, read by *B() comparisons)      #
#    - QRT()         (Q with an explicit return type -- a general utility)   #
#  Full original: git history / natural/archive of this file's ancestors.   #
#---------------------------------------------------------------------------#

$_LastValue = ""

func QRT(p, pcType)
	if NOT isString(pcType)
		StzRaise("Invalid param type! pcType should be a string containing the name of a softanza class.")
	ok

	if Q(pcType).IsStzClassName()
		# eval() assigns in THIS scope, so the generated code creates a
		# local `oResult` -- reading `$oResult` was reading a global that
		# nothing ever writes, and QRT() raised R24 on every call.
		_cCode_ = "oResult = new " + pcType + '(' + @@(p) + ')'

		eval(_cCode_)

		return oResult
	else
		StzRaise("Unsupported Softanza type!")
	ok

func LastValue()
	return $_LastValue

func SetLastValue(value)
	# $_LastValue, declared on line 21 and read by LastValue() above. The
	# unprefixed name made this a local, so SetLastValue() was a no-op and
	# the *B() comparisons named in this file's header never saw a value.
	$_LastValue = value
	$cStzExpectMode = :Exactly

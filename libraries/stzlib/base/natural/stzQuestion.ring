#---------------------------------------------------------------------------#
#  stzQuestion -- ILLOCUTIONARY FORCE for NNL chains (the author's design)   #
#                                                                            #
#  A question is a FRAME: a sentence-initial force word opens it, particles  #
#  and nouns fill its constituent slots, and the first PLAIN-form word (no   #
#  Q) closes it and returns the ANSWER as data -- the house Q-convention     #
#  applied to interrogation: Q chains, plain answers.                        #
#                                                                            #
#      WhatIsQ().TheQ().FirstCharQ().Of("Ring")          --> "R"             #
#      WhatQ().TheQ().FirstCharQ().OfQ("Ring").Is()      --> "R"             #
#      IsQ().TheQ().LengthQ().OfQ("Ring").IsQ().                             #
#          TheSameAsQ().TheQ().LengthQ().Of("Ruby")      --> 1               #
#      HowManyQ().VowelsQ().Of("Ring")                   --> 1               #
#                                                                            #
#  DESIGN LAWS (doc/design/NNL_REVIEW.md):                                   #
#  - DECOMPOSITION: one word = one method. TheQ() stands ALONE; nouns are    #
#    GENERATED from the semantic lexicon between the markers below --        #
#    particles compose with nouns, they are never fused into TheLengthQ-     #
#    style methods (that road rebuilt the alias explosion).                  #
#  - MARKERLESS frames: no inheritance from stzObject -- the frame is a      #
#    slot-filling machine, not a value; it must not inherit hundreds of      #
#    value methods that would execute instead of record.                     #
#  - ACCOUNTABILITY: aspects resolve through the ONE lexicon (morphology     #
#    included) and refuse with a suggestion; every answer records Why().     #
#---------------------------------------------------------------------------#

# --- the force words (sentence-initial; English subject-aux inversion) ----

func WhatQ()
	return new stzQuestion("what")

func WhatIsQ()
	return new stzQuestion("what")

func HowManyQ()
	return new stzQuestion("howmany")

# the nominal counting frame: "the number of letters in 'ring'"
func NumberOfQ()
	return new stzQuestion("howmany")

	func TheNumberOfQ()
		return new stzQuestion("howmany")

func IsQ()
	return new stzQuestion("is")

func DoesQ()
	return new stzQuestion("is")

class stzQuestion

	@cForce = ""       # what | howmany | is
	@cAspect = ""      # the LEFT constituent's aspect (lexicon stem)
	@cAspect2 = ""     # the RIGHT constituent's aspect ("" = same as left)
	@pLeftHost = ""
	@bLeftSet = 0
	@cComparator = ""  # "" | same | different | more | less
	@nSide = 1
	@bCount1 = 0       # "the number of <noun>" -- count mode per side
	@bCount2 = 0
	@bNegate = 0       # NotQ(): "is X NOT the same as Y"
	@cWhy = ""

	def init(pcForce)
		@cForce = pcForce

	  #--------------------------------------------------------------#
	 #  GRAMMAR PARTICLES -- one word each, written once             #
	#--------------------------------------------------------------#

	def TheQ()
		return This

	def AQ()
		return This

	def AnQ()
		return This

	# the copula slot ("Is the length of Ring IS ... " reads as the
	# mid-sentence 'is' of the comparison) -- position marker only
	def IsQ()
		return This

	# negation of the claim: "Is ... NOT the same as ..."
	def NotQ()
		@bNegate = 1
		return This

	# "the NUMBER OF <noun>" as a constituent: count mode for this side
	def NumberOfQ()
		if @nSide = 1
			@bCount1 = 1
		else
			@bCount2 = 1
		ok
		return This

	  #--------------------------------------------------------------#
	 #  COMPARATORS -- open the RIGHT constituent slot               #
	#--------------------------------------------------------------#

	def TheSameAsQ()
		@cComparator = "same"
		@nSide = 2
		return This

		def SameAsQ()
			return This.TheSameAsQ()

	def DifferentFromQ()
		@cComparator = "different"
		@nSide = 2
		return This

	def MoreThanQ()
		@cComparator = "more"
		@nSide = 2
		return This

	def LessThanQ()
		@cComparator = "less"
		@nSide = 2
		return This

	  #--------------------------------------------------------------#
	 #  CONSTITUENT FILLING                                          #
	#--------------------------------------------------------------#

	# a NOUN fills the current side's aspect slot (nouns are generated
	# below; this is their single landing point)
	def _Noun(pcOp)
		if @nSide = 1
			@cAspect = pcOp
		else
			@cAspect2 = pcOp
		ok
		return This

	# genitive, OPEN form: records the left host, the sentence goes on
	def OfQ(pHost)
		@pLeftHost = pHost
		@bLeftSet = 1
		return This

		# locative flavor: "the number of letters IN ring"
		def InQ(pHost)
			return This.OfQ(pHost)

	  #--------------------------------------------------------------#
	 #  CLOSERS -- plain form: answer as DATA (the Q-convention)     #
	#--------------------------------------------------------------#

	# genitive, CLOSING form: supplies the last missing host and fires
	def Of(pHost)
		if @nSide = 2
			return This._Answer(pHost)
		ok
		@pLeftHost = pHost
		@bLeftSet = 1
		return This._Answer("")

		# locative CLOSING form
		def In(pHost)
			return This.Of(pHost)

	# copula, CLOSING form: "What the first char of Ring IS"
	def Is()
		if NOT @bLeftSet
			StzRaise("NNL question: nothing to answer yet -- no constituent was given.")
		ok
		return This._Answer("")

	def Why()
		return @cWhy

	  #--------------------------------------------------------------#
	 #  THE ANSWERING MACHINERY                                      #
	#--------------------------------------------------------------#

	# compute an aspect of a host THROUGH the accountable dispatcher
	# (morphology + refusal-with-suggestion for free)
	def _Compute(pcAspect, pHost, pbCount)
		_oQh_ = Q(pHost)
		if @cForce = "howmany" or pbCount = 1
			# "how many vowels" counts: prefer the NumberOf twin
			if StzFindFirst(ring_methods(_oQh_), "numberof" + pcAspect) > 0
				return _oQh_._NNLCall("numberof" + pcAspect, [])
			ok
			_vQh_ = _oQh_._NNLCall(pcAspect, [])
			if isList(_vQh_)
				return len(_vQh_)
			ok
			return _vQh_
		ok
		return _oQh_._NNLCall(pcAspect, [])

	def _Answer(pRightHost)
		if @cAspect = ""
			StzRaise("NNL question: no aspect was named (say a noun like FirstCharQ()).")
		ok
		_vLeft_ = This._Compute(@cAspect, @pLeftHost, @bCount1)

		if @cComparator = ""
			# a WH-question: the answer IS the missing constituent
			@cWhy = "answered: " + @@(_vLeft_)
			$cStzLastWhyB = @cWhy
			return _vLeft_
		ok

		# a POLAR comparison: compute the right side, compare, answer 1/0
		_cAsp2_ = @cAspect2
		if _cAsp2_ = ""
			_cAsp2_ = @cAspect
		ok
		_vRight_ = This._Compute(_cAsp2_, pRightHost, @bCount2)

		_bYes_ = FALSE
		_cRel_ = ""
		if @cComparator = "same"
			_bYes_ = Q(_vLeft_).IsEqualTo(_vRight_)
			_cRel_ = "the same as"
		but @cComparator = "different"
			_bYes_ = NOT Q(_vLeft_).IsEqualTo(_vRight_)
			_cRel_ = "different from"
		but @cComparator = "more"
			_bYes_ = ( _vLeft_ > _vRight_ )
			_cRel_ = "more than"
		but @cComparator = "less"
			_bYes_ = ( _vLeft_ < _vRight_ )
			_cRel_ = "less than"
		ok

		if @bNegate = 1
			# the CLAIM is the negated relation; the explanation states
			# the positive fact either way
			_bYes_ = NOT _bYes_
			if _bYes_
				@cWhy = "yes: " + @@(_vLeft_) + " is not " + _cRel_ + " " + @@(_vRight_)
			else
				@cWhy = "no: " + @@(_vLeft_) + " is " + _cRel_ + " " + @@(_vRight_)
			ok
		but _bYes_
			@cWhy = "yes: " + @@(_vLeft_) + " is " + _cRel_ + " " + @@(_vRight_)
		else
			@cWhy = "no: " + @@(_vLeft_) + " is not " + _cRel_ + " " + @@(_vRight_)
		ok
		$cStzLastWhyB = @cWhy
		if _bYes_
			return 1
		ok
		return 0

	  #--------------------------------------------------------------#
	 #  HAND-WRITTEN ASPECT NOUNS (not lexicon op names)             #
	#--------------------------------------------------------------#
	# 'length' is not an operation name (the op is NumberOfChars); the
	# dispatcher resolves it through the lexicon bags, so the noun only
	# needs to exist as a WORD here.

	def LengthQ()
		return This._Noun("length")

	def SizeQ()
		return This._Noun("size")

	# <nnl-question-nouns>
	# GENERATED from the semantic lexicon (scratchpad gen_question_nouns.py):
	# every arity-0 QUERY op and every NumberOf* counter becomes a noun the
	# question frame can name. Each is a recorder -- computing happens at
	# the closer through the accountable dispatcher. Do not edit; regenerate.

	def ACharQ()
		return This._Noun("achar")

	def APositionQ()
		return This._Noun("aposition")

	def ARandomCharQ()
		return This._Noun("arandomchar")

	def ARandomPositionQ()
		return This._Noun("arandomposition")

	def ARandomSectionQ()
		return This._Noun("arandomsection")

	def ASectionQ()
		return This._Noun("asection")

	def AbsQ()
		return This._Noun("abs")

	def AbsoluteQ()
		return This._Noun("absolute")

	def AllAreEqualQ()
		return This._Noun("allareequal")

	def AllCharsAreEvenQ()
		return This._Noun("allcharsareeven")

	def AllCharsAreOddQ()
		return This._Noun("allcharsareodd")

	def AllCharsArePositiveQ()
		return This._Noun("allcharsarepositive")

	def AllDozensQ()
		return This._Noun("alldozens")

	def AllHundredsQ()
		return This._Noun("allhundreds")

	def AllItemsAreEmptyListsQ()
		return This._Noun("allitemsareemptylists")

	def AllItemsAreEqualQ()
		return This._Noun("allitemsareequal")

	def AllItemsAreListsQ()
		return This._Noun("allitemsarelists")

	def AllItemsAreListsOfSameSizeQ()
		return This._Noun("allitemsarelistsofsamesize")

	def AllItemsHaveSameTypeQ()
		return This._Noun("allitemshavesametype")

	def AllPathsQ()
		return This._Noun("allpaths")

	def AllUnitsQ()
		return This._Noun("allunits")

	def AnyCharQ()
		return This._Noun("anychar")

	def AnyPositionQ()
		return This._Noun("anyposition")

	def AnySectionQ()
		return This._Noun("anysection")

	def AreContiguousQ()
		return This._Noun("arecontiguous")

	def AreLanguageAbbreviationsQ()
		return This._Noun("arelanguageabbreviations")

	def AsWellQ()
		return This._Noun("aswell")

	def AttributesQ()
		return This._Noun("attributes")

	def AutoLemmatizedQ()
		return This._Noun("autolemmatized")

	def AutoStemmedQ()
		return This._Noun("autostemmed")

	def AverageQ()
		return This._Noun("average")

	def AverageCharsPerSentenceQ()
		return This._Noun("averagecharspersentence")

	def AverageOfNumbersQ()
		return This._Noun("averageofnumbers")

	def AverageWordsPerSentenceQ()
		return This._Noun("averagewordspersentence")

	def BFormQ()
		return This._Noun("bform")

	def BisectQ()
		return This._Noun("bisect")

	def BothAreListsQ()
		return This._Noun("botharelists")

	def BothAreNumbersQ()
		return This._Noun("botharenumbers")

	def BothAreObjectsQ()
		return This._Noun("bothareobjects")

	def BothAreStringsQ()
		return This._Noun("botharestrings")

	def BoundsQ()
		return This._Noun("bounds")

	def BoundsRemovedQ()
		return This._Noun("boundsremoved")

	def BoxedQ()
		return This._Noun("boxed")

	def BoxedDashedQ()
		return This._Noun("boxeddashed")

	def BoxedRoundQ()
		return This._Noun("boxedround")

	def BoxedRoundDashedQ()
		return This._Noun("boxedrounddashed")

	def BoxedRoundedQ()
		return This._Noun("boxedrounded")

	def BoxedRoundedDashedQ()
		return This._Noun("boxedroundeddashed")

	def BoxifyQ()
		return This._Noun("boxify")

	def BytecodesQ()
		return This._Noun("bytecodes")

	def BytecodesPerCharQ()
		return This._Noun("bytecodesperchar")

	def BytesQ()
		return This._Noun("bytes")

	def BytesPerCharQ()
		return This._Noun("bytesperchar")

	def CapitalCasedQ()
		return This._Noun("capitalcased")

	def CapitalizedQ()
		return This._Noun("capitalized")

	def CaseFoldedQ()
		return This._Noun("casefolded")

	def CentralCharQ()
		return This._Noun("centralchar")

	def CentralItemQ()
		return This._Noun("centralitem")

	def CentralItemPositionQ()
		return This._Noun("centralitemposition")

	def CentralPositionQ()
		return This._Noun("centralposition")

	def CharCaseQ()
		return This._Noun("charcase")

	def CharsQ()
		return This._Noun("chars")

	def CharsAndTheirCountsQ()
		return This._Noun("charsandtheircounts")

	def CharsAndTheirUnicodesQ()
		return This._Noun("charsandtheirunicodes")

	def CharsAndUnicodesQ()
		return This._Noun("charsandunicodes")

	def CharsAndUnicodesUQ()
		return This._Noun("charsandunicodesu")

	def CharsBoxedQ()
		return This._Noun("charsboxed")

	def CharsInvertedQ()
		return This._Noun("charsinverted")

	def CharsNamesQ()
		return This._Noun("charsnames")

	def CharsReversedQ()
		return This._Noun("charsreversed")

	def CharsUQ()
		return This._Noun("charsu")

	def ClassNameQ()
		return This._Noun("classname")

	def ClassifiedQ()
		return This._Noun("classified")

	def CommonLogarithmQ()
		return This._Noun("commonlogarithm")

	def CompactedQ()
		return This._Noun("compacted")

	def ConsecutiveSubStringsQ()
		return This._Noun("consecutivesubstrings")

	def ConsecutiveSubStringsZQ()
		return This._Noun("consecutivesubstringsz")

	def ConsecutiveSubStringsZZQ()
		return This._Noun("consecutivesubstringszz")

	def ContainsADecimalPartQ()
		return This._Noun("containsadecimalpart")

	def ContainsAFinalNumberQ()
		return This._Noun("containsafinalnumber")

	def ContainsAFractionalPartQ()
		return This._Noun("containsafractionalpart")

	def ContainsASignQ()
		return This._Noun("containsasign")

	def ContainsATrailingNumberQ()
		return This._Noun("containsatrailingnumber")

	def ContainsAnEndingNumberQ()
		return This._Noun("containsanendingnumber")

	def ContainsArabicQ()
		return This._Noun("containsarabic")

	def ContainsAtLeastOneNonDuplicatedItemQ()
		return This._Noun("containsatleastonenonduplicateditem")

	def ContainsBillionsQ()
		return This._Noun("containsbillions")

	def ContainsCentralItemQ()
		return This._Noun("containscentralitem")

	def ContainsConsecutiveDuplicatesQ()
		return This._Noun("containsconsecutiveduplicates")

	def ContainsDecimalPartQ()
		return This._Noun("containsdecimalpart")

	def ContainsDiacriticsQ()
		return This._Noun("containsdiacritics")

	def ContainsDigitsQ()
		return This._Noun("containsdigits")

	def ContainsDozensQ()
		return This._Noun("containsdozens")

	def ContainsDupSecutiveItemsQ()
		return This._Noun("containsdupsecutiveitems")

	def ContainsDuplicatedItemsQ()
		return This._Noun("containsduplicateditems")

	def ContainsDuplicatedSubStringsQ()
		return This._Noun("containsduplicatedsubstrings")

	def ContainsDuplicatesQ()
		return This._Noun("containsduplicates")

	def ContainsEmptyStringsQ()
		return This._Noun("containsemptystrings")

	def ContainsFractionalPartQ()
		return This._Noun("containsfractionalpart")

	def ContainsHundredsQ()
		return This._Noun("containshundreds")

	def ContainsHundredsOfBillionsQ()
		return This._Noun("containshundredsofbillions")

	def ContainsHundredsOfMillionsQ()
		return This._Noun("containshundredsofmillions")

	def ContainsHundredsOfThousandsQ()
		return This._Noun("containshundredsofthousands")

	def ContainsHundredsOfTrillionsQ()
		return This._Noun("containshundredsoftrillions")

	def ContainsHybridOrientationQ()
		return This._Noun("containshybridorientation")

	def ContainsInvisibleCharsQ()
		return This._Noun("containsinvisiblechars")

	def ContainsItemsNonDuplicatedQ()
		return This._Noun("containsitemsnonduplicated")

	def ContainsLatinQ()
		return This._Noun("containslatin")

	def ContainsLettersQ()
		return This._Noun("containsletters")

	def ContainsListsQ()
		return This._Noun("containslists")

	def ContainsManyBillionsQ()
		return This._Noun("containsmanybillions")

	def ContainsManyDozensQ()
		return This._Noun("containsmanydozens")

	def ContainsManyHundredsQ()
		return This._Noun("containsmanyhundreds")

	def ContainsManyHundredsOfBillionsQ()
		return This._Noun("containsmanyhundredsofbillions")

	def ContainsManyHundredsOfMillionsQ()
		return This._Noun("containsmanyhundredsofmillions")

	def ContainsManyHundredsOfThousandsQ()
		return This._Noun("containsmanyhundredsofthousands")

	def ContainsManyHundredsOfTrillionsQ()
		return This._Noun("containsmanyhundredsoftrillions")

	def ContainsManyMillionsQ()
		return This._Noun("containsmanymillions")

	def ContainsManyOnesQ()
		return This._Noun("containsmanyones")

	def ContainsManyTensOfBillionsQ()
		return This._Noun("containsmanytensofbillions")

	def ContainsManyTensOfMillionsQ()
		return This._Noun("containsmanytensofmillions")

	def ContainsManyTensOfThousandsQ()
		return This._Noun("containsmanytensofthousands")

	def ContainsManyTensOfTrillionsQ()
		return This._Noun("containsmanytensoftrillions")

	def ContainsManyThousandsQ()
		return This._Noun("containsmanythousands")

	def ContainsManyThousandsOfMillionsQ()
		return This._Noun("containsmanythousandsofmillions")

	def ContainsManyThousandsOfThousandsQ()
		return This._Noun("containsmanythousandsofthousands")

	def ContainsManyTrillionsQ()
		return This._Noun("containsmanytrillions")

	def ContainsManyZerosQ()
		return This._Noun("containsmanyzeros")

	def ContainsMarkersQ()
		return This._Noun("containsmarkers")

	def ContainsMarquersQ()
		return This._Noun("containsmarquers")

	def ContainsMillionsQ()
		return This._Noun("containsmillions")

	def ContainsNoDuplicatesQ()
		return This._Noun("containsnoduplicates")

	def ContainsNoDuplicationsQ()
		return This._Noun("containsnoduplications")

	def ContainsNoNumbersQ()
		return This._Noun("containsnonumbers")

	def ContainsNoObjectsQ()
		return This._Noun("containsnoobjects")

	def ContainsNoStringsQ()
		return This._Noun("containsnostrings")

	def ContainsNonDuplicatedItemsQ()
		return This._Noun("containsnonduplicateditems")

	def ContainsObjectsQ()
		return This._Noun("containsobjects")

	def ContainsOneOrMoreListsQ()
		return This._Noun("containsoneormorelists")

	def ContainsOnesQ()
		return This._Noun("containsones")

	def ContainsOnlyDigitsQ()
		return This._Noun("containsonlydigits")

	def ContainsOnlyEmptyListsQ()
		return This._Noun("containsonlyemptylists")

	def ContainsOnlyLettersQ()
		return This._Noun("containsonlyletters")

	def ContainsOnlyLettersAndNumbersQ()
		return This._Noun("containsonlylettersandnumbers")

	def ContainsOnlyListsQ()
		return This._Noun("containsonlylists")

	def ContainsOnlyListsWithSameNumberOfItemsQ()
		return This._Noun("containsonlylistswithsamenumberofitems")

	def ContainsOnlyNumbersQ()
		return This._Noun("containsonlynumbers")

	def ContainsOnlySpacesQ()
		return This._Noun("containsonlyspaces")

	def ContainsOnlyUniSizeListsQ()
		return This._Noun("containsonlyunisizelists")

	def ContainsPairsQ()
		return This._Noun("containspairs")

	def ContainsSeveralBillionsQ()
		return This._Noun("containsseveralbillions")

	def ContainsSeveralDozensQ()
		return This._Noun("containsseveraldozens")

	def ContainsSeveralHundredsQ()
		return This._Noun("containsseveralhundreds")

	def ContainsSeveralHundredsOfBillionsQ()
		return This._Noun("containsseveralhundredsofbillions")

	def ContainsSeveralHundredsOfMillionsQ()
		return This._Noun("containsseveralhundredsofmillions")

	def ContainsSeveralHundredsOfThousandsQ()
		return This._Noun("containsseveralhundredsofthousands")

	def ContainsSeveralHundredsOfTrillionsQ()
		return This._Noun("containsseveralhundredsoftrillions")

	def ContainsSeveralMillionsQ()
		return This._Noun("containsseveralmillions")

	def ContainsSeveralOnesQ()
		return This._Noun("containsseveralones")

	def ContainsSeveralTensOfBillionsQ()
		return This._Noun("containsseveraltensofbillions")

	def ContainsSeveralTensOfMillionsQ()
		return This._Noun("containsseveraltensofmillions")

	def ContainsSeveralTensOfThousandsQ()
		return This._Noun("containsseveraltensofthousands")

	def ContainsSeveralTensOfTrillionsQ()
		return This._Noun("containsseveraltensoftrillions")

	def ContainsSeveralThousandsQ()
		return This._Noun("containsseveralthousands")

	def ContainsSeveralThousandsOfMillionsQ()
		return This._Noun("containsseveralthousandsofmillions")

	def ContainsSeveralThousandsOfThousandsQ()
		return This._Noun("containsseveralthousandsofthousands")

	def ContainsSeveralTrillionsQ()
		return This._Noun("containsseveraltrillions")

	def ContainsSeveralZerosQ()
		return This._Noun("containsseveralzeros")

	def ContainsSignQ()
		return This._Noun("containssign")

	def ContainsSinglesQ()
		return This._Noun("containssingles")

	def ContainsTensOfBillionsQ()
		return This._Noun("containstensofbillions")

	def ContainsTensOfMillionsQ()
		return This._Noun("containstensofmillions")

	def ContainsTensOfThousandsQ()
		return This._Noun("containstensofthousands")

	def ContainsTensOfTrillionsQ()
		return This._Noun("containstensoftrillions")

	def ContainsThousandsQ()
		return This._Noun("containsthousands")

	def ContainsThousandsOfMillionsQ()
		return This._Noun("containsthousandsofmillions")

	def ContainsThousandsOfThousandsQ()
		return This._Noun("containsthousandsofthousands")

	def ContainsTrillionsQ()
		return This._Noun("containstrillions")

	def ContainsTwoListsQ()
		return This._Noun("containstwolists")

	def ContainsTwoNumbersQ()
		return This._Noun("containstwonumbers")

	def ContainsTwoObjectsQ()
		return This._Noun("containstwoobjects")

	def ContainsTwoStringsQ()
		return This._Noun("containstwostrings")

	def ContainsVowelsQ()
		return This._Noun("containsvowels")

	def ContainsZerosQ()
		return This._Noun("containszeros")

	def ContentQ()
		return This._Noun("content")

	def ContentUQ()
		return This._Noun("contentu")

	def ContentWordsQ()
		return This._Noun("contentwords")

	def CosineQ()
		return This._Noun("cosine")

	def CotangentQ()
		return This._Noun("cotangent")

	def DecimalPartNumericValueQ()
		return This._Noun("decimalpartnumericvalue")

	def DecimalPartValueQ()
		return This._Noun("decimalpartvalue")

	def DecrementedQ()
		return This._Noun("decremented")

	def DeepStringifiedQ()
		return This._Noun("deepstringified")

	def DerivativeSigmoidQ()
		return This._Noun("derivativesigmoid")

	def DetectedLanguageQ()
		return This._Noun("detectedlanguage")

	def DiacriticsRemovedQ()
		return This._Noun("diacriticsremoved")

	def DigitCountQ()
		return This._Noun("digitcount")

	def DigitSumQ()
		return This._Noun("digitsum")

	def DigitsQ()
		return This._Noun("digits")

	def DividorsQ()
		return This._Noun("dividors")

	def DivirdosQ()
		return This._Noun("divirdos")

	def DivisorsQ()
		return This._Noun("divisors")

	def DotlessQ()
		return This._Noun("dotless")

	def DotsOnLettersRemovedQ()
		return This._Noun("dotsonlettersremoved")

	def DotsRemovedQ()
		return This._Noun("dotsremoved")

	def DozensQ()
		return This._Noun("dozens")

	def DozensInBillionsQ()
		return This._Noun("dozensinbillions")

	def DozensInHundredsQ()
		return This._Noun("dozensinhundreds")

	def DozensInMillionsQ()
		return This._Noun("dozensinmillions")

	def DozensInThousandsQ()
		return This._Noun("dozensinthousands")

	def DozensInTrillionsQ()
		return This._Noun("dozensintrillions")

	def DupOriginsQ()
		return This._Noun("duporigins")

	def DupSecutiveSubStringsRemovedQ()
		return This._Noun("dupsecutivesubstringsremoved")

	def DuplicateCharsZQ()
		return This._Noun("duplicatecharsz")

	def DuplicateItemsZQ()
		return This._Noun("duplicateitemsz")

	def DuplicatedCharsRemovedQ()
		return This._Noun("duplicatedcharsremoved")

	def DuplicatedItemsQ()
		return This._Noun("duplicateditems")

	def DuplicatedItemsZQ()
		return This._Noun("duplicateditemsz")

	def DuplicatedStringsQ()
		return This._Noun("duplicatedstrings")

	def DuplicatedSubStringsQ()
		return This._Noun("duplicatedsubstrings")

	def DuplicatesQ()
		return This._Noun("duplicates")

	def DuplicatesRemovedQ()
		return This._Noun("duplicatesremoved")

	def DuplicatesXTZQ()
		return This._Noun("duplicatesxtz")

	def DuplicatesZQ()
		return This._Noun("duplicatesz")

	def DuplicationsQ()
		return This._Noun("duplications")

	def DuplicationsZQ()
		return This._Noun("duplicationsz")

	def EachCharBoxRoundedQ()
		return This._Noun("eachcharboxrounded")

	def EachCharBoxedQ()
		return This._Noun("eachcharboxed")

	def EachCharBoxedDashedQ()
		return This._Noun("eachcharboxeddashed")

	def EachCharBoxedRoundedQ()
		return This._Noun("eachcharboxedrounded")

	def EachCharBoxedRoundedDashedQ()
		return This._Noun("eachcharboxedroundeddashed")

	def EndsWithAFinalNumberQ()
		return This._Noun("endswithafinalnumber")

	def EndsWithANumberQ()
		return This._Noun("endswithanumber")

	def EndsWithATrailingNumberQ()
		return This._Noun("endswithatrailingnumber")

	def EndsWithNumberQ()
		return This._Noun("endswithnumber")

	def EngineQ()
		return This._Noun("engine")

	def EscapedForRegexQ()
		return This._Noun("escapedforregex")

	def EscapedHtmlQ()
		return This._Noun("escapedhtml")

	def ExponentialQ()
		return This._Noun("exponential")

	def FactorialQ()
		return This._Noun("factorial")

	def FactorsQ()
		return This._Noun("factors")

	def FibonacciQ()
		return This._Noun("fibonacci")

	def FirstAndLastItemsQ()
		return This._Noun("firstandlastitems")

	def FirstCharQ()
		return This._Noun("firstchar")

	def FirstCharRemovedQ()
		return This._Noun("firstcharremoved")

	def FirstHalfQ()
		return This._Noun("firsthalf")

	def FirstHalfAndItsPositionQ()
		return This._Noun("firsthalfanditsposition")

	def FirstHalfAndItsSectionQ()
		return This._Noun("firsthalfanditssection")

	def FirstHalfAndPositionQ()
		return This._Noun("firsthalfandposition")

	def FirstHalfAndSectionQ()
		return This._Noun("firsthalfandsection")

	def FirstHalfXTZQ()
		return This._Noun("firsthalfxtz")

	def FirstHalfXTZZQ()
		return This._Noun("firsthalfxtzz")

	def FirstHalfZQ()
		return This._Noun("firsthalfz")

	def FirstHalfZZQ()
		return This._Noun("firsthalfzz")

	def FirstItemQ()
		return This._Noun("firstitem")

	def FirstLineQ()
		return This._Noun("firstline")

	def FirstNonSpaceCharQ()
		return This._Noun("firstnonspacechar")

	def FirstNonSpaceCharPositionQ()
		return This._Noun("firstnonspacecharposition")

	def FirstSentenceQ()
		return This._Noun("firstsentence")

	def FirstWordQ()
		return This._Noun("firstword")

	def FlattenedQ()
		return This._Noun("flattened")

	def FleschKincaidGradeQ()
		return This._Noun("fleschkincaidgrade")

	def FleschReadingEaseQ()
		return This._Noun("fleschreadingease")

	def FractionalPartNumericValueQ()
		return This._Noun("fractionalpartnumericvalue")

	def FractionalPartValueQ()
		return This._Noun("fractionalpartvalue")

	def FrequenciesQ()
		return This._Noun("frequencies")

	def GetRoundQ()
		return This._Noun("getround")

	def GreatestQ()
		return This._Noun("greatest")

	def HTMLEscapeQ()
		return This._Noun("htmlescape")

	def HalvesQ()
		return This._Noun("halves")

	def HalvesAndPositionsQ()
		return This._Noun("halvesandpositions")

	def HalvesAndSectionsQ()
		return This._Noun("halvesandsections")

	def HalvesXTZQ()
		return This._Noun("halvesxtz")

	def HalvesXTZZQ()
		return This._Noun("halvesxtzz")

	def HalvesZQ()
		return This._Noun("halvesz")

	def HalvesZZQ()
		return This._Noun("halveszz")

	def HasADecimalPartQ()
		return This._Noun("hasadecimalpart")

	def HasAFractionalPartQ()
		return This._Noun("hasafractionalpart")

	def HasASignQ()
		return This._Noun("hasasign")

	def HasBillionsQ()
		return This._Noun("hasbillions")

	def HasCentralCharQ()
		return This._Noun("hascentralchar")

	def HasCentralItemQ()
		return This._Noun("hascentralitem")

	def HasDecimalPartQ()
		return This._Noun("hasdecimalpart")

	def HasDiacriticsQ()
		return This._Noun("hasdiacritics")

	def HasDuplicatedCharsQ()
		return This._Noun("hasduplicatedchars")

	def HasDuplicatesQ()
		return This._Noun("hasduplicates")

	def HasFractionalPartQ()
		return This._Noun("hasfractionalpart")

	def HasHundredsQ()
		return This._Noun("hashundreds")

	def HasHundredsOfBillionsQ()
		return This._Noun("hashundredsofbillions")

	def HasHundredsOfMillionsQ()
		return This._Noun("hashundredsofmillions")

	def HasHundredsOfThousandsQ()
		return This._Noun("hashundredsofthousands")

	def HasHundredsOfTrillionsQ()
		return This._Noun("hashundredsoftrillions")

	def HasLeadingAndTrailingCharsQ()
		return This._Noun("hasleadingandtrailingchars")

	def HasLeadingCharsQ()
		return This._Noun("hasleadingchars")

	def HasLeadingItemsQ()
		return This._Noun("hasleadingitems")

	def HasLeadingSubStringQ()
		return This._Noun("hasleadingsubstring")

	def HasManyBillionsQ()
		return This._Noun("hasmanybillions")

	def HasManyHundredsQ()
		return This._Noun("hasmanyhundreds")

	def HasManyHundredsOfBillionsQ()
		return This._Noun("hasmanyhundredsofbillions")

	def HasManyHundredsOfMillionsQ()
		return This._Noun("hasmanyhundredsofmillions")

	def HasManyHundredsOfThousandsQ()
		return This._Noun("hasmanyhundredsofthousands")

	def HasManyHundredsOfTrillionsQ()
		return This._Noun("hasmanyhundredsoftrillions")

	def HasManyOnesQ()
		return This._Noun("hasmanyones")

	def HasManyTensOfBillionsQ()
		return This._Noun("hasmanytensofbillions")

	def HasManyTensOfThousandsQ()
		return This._Noun("hasmanytensofthousands")

	def HasManyTensOfTrillionsQ()
		return This._Noun("hasmanytensoftrillions")

	def HasManyThousandsQ()
		return This._Noun("hasmanythousands")

	def HasManyThousandsOfMillionsQ()
		return This._Noun("hasmanythousandsofmillions")

	def HasManyThousandsOfThousandsQ()
		return This._Noun("hasmanythousandsofthousands")

	def HasManyTrillionsQ()
		return This._Noun("hasmanytrillions")

	def HasManyZerosQ()
		return This._Noun("hasmanyzeros")

	def HasMarkQ()
		return This._Noun("hasmark")

	def HasMayTensOfMillionsQ()
		return This._Noun("hasmaytensofmillions")

	def HasMillionsQ()
		return This._Noun("hasmillions")

	def HasOnesQ()
		return This._Noun("hasones")

	def HasRepeatedLeadingCharsQ()
		return This._Noun("hasrepeatedleadingchars")

	def HasRepeatedLeadingItemsQ()
		return This._Noun("hasrepeatedleadingitems")

	def HasRepeatedTrailingCharsQ()
		return This._Noun("hasrepeatedtrailingchars")

	def HasRepeatedTrailingItemsQ()
		return This._Noun("hasrepeatedtrailingitems")

	def HasSeveralBillionsQ()
		return This._Noun("hasseveralbillions")

	def HasSeveralHundredsQ()
		return This._Noun("hasseveralhundreds")

	def HasSeveralHundredsOfBillionsQ()
		return This._Noun("hasseveralhundredsofbillions")

	def HasSeveralHundredsOfMillionsQ()
		return This._Noun("hasseveralhundredsofmillions")

	def HasSeveralHundredsOfThousandsQ()
		return This._Noun("hasseveralhundredsofthousands")

	def HasSeveralHundredsOfTrillionsQ()
		return This._Noun("hasseveralhundredsoftrillions")

	def HasSeveralMilllionsQ()
		return This._Noun("hasseveralmilllions")

	def HasSeveralOnesQ()
		return This._Noun("hasseveralones")

	def HasSeveralTensOfBillionsQ()
		return This._Noun("hasseveraltensofbillions")

	def HasSeveralTensOfMillionsQ()
		return This._Noun("hasseveraltensofmillions")

	def HasSeveralTensOfThousandsQ()
		return This._Noun("hasseveraltensofthousands")

	def HasSeveralTensOfTrillionsQ()
		return This._Noun("hasseveraltensoftrillions")

	def HasSeveralThousandsQ()
		return This._Noun("hasseveralthousands")

	def HasSeveralThousandsOfMillionsQ()
		return This._Noun("hasseveralthousandsofmillions")

	def HasSeveralThousandsOfThousandsQ()
		return This._Noun("hasseveralthousandsofthousands")

	def HasSeveralTrillionsQ()
		return This._Noun("hasseveraltrillions")

	def HasSeveralZerosQ()
		return This._Noun("hasseveralzeros")

	def HasSignQ()
		return This._Noun("hassign")

	def HasSynonymsQ()
		return This._Noun("hassynonyms")

	def HasTensOfBillionsQ()
		return This._Noun("hastensofbillions")

	def HasTensOfMillionsQ()
		return This._Noun("hastensofmillions")

	def HasTensOfThousandsQ()
		return This._Noun("hastensofthousands")

	def HasTensOfTrillionsQ()
		return This._Noun("hastensoftrillions")

	def HasThousandsQ()
		return This._Noun("hasthousands")

	def HasThousandsOfMillionsQ()
		return This._Noun("hasthousandsofmillions")

	def HasThousandsOfThousandsQ()
		return This._Noun("hasthousandsofthousands")

	def HasTrailingCharsQ()
		return This._Noun("hastrailingchars")

	def HasTrailingItemsQ()
		return This._Noun("hastrailingitems")

	def HasTrailingSubStringQ()
		return This._Noun("hastrailingsubstring")

	def HasTrillionsQ()
		return This._Noun("hastrillions")

	def HasVowelsQ()
		return This._Noun("hasvowels")

	def HasZerosQ()
		return This._Noun("haszeros")

	def HexUnicodeQ()
		return This._Noun("hexunicode")

	def HexUnicodesQ()
		return This._Noun("hexunicodes")

	def HighestQ()
		return This._Noun("highest")

	def HistogramQ()
		return This._Noun("histogram")

	def HowManyDigitsQ()
		return This._Noun("howmanydigits")

	def HowManyDuplicatesQ()
		return This._Noun("howmanyduplicates")

	def HowManyItemsQ()
		return This._Noun("howmanyitems")

	def HowManyLeadingCharQ()
		return This._Noun("howmanyleadingchar")

	def HowManySubStringsQ()
		return This._Noun("howmanysubstrings")

	def HowManyTrailingCharQ()
		return This._Noun("howmanytrailingchar")

	def HowManyWordsQ()
		return This._Noun("howmanywords")

	def HsManyMillionsQ()
		return This._Noun("hsmanymillions")

	def HtmlDecodedQ()
		return This._Noun("htmldecoded")

	def HtmlEncodedQ()
		return This._Noun("htmlencoded")

	def HtmlEscapedQ()
		return This._Noun("htmlescaped")

	def HundredsInBillionsQ()
		return This._Noun("hundredsinbillions")

	def HundredsInHundredsQ()
		return This._Noun("hundredsinhundreds")

	def HundredsInMillionsQ()
		return This._Noun("hundredsinmillions")

	def HundredsInThousandsQ()
		return This._Noun("hundredsinthousands")

	def HundredsInTrillionsQ()
		return This._Noun("hundredsintrillions")

	def HyperbolicCosineQ()
		return This._Noun("hyperboliccosine")

	def HyperbolicSineQ()
		return This._Noun("hyperbolicsine")

	def InPercentageQ()
		return This._Noun("inpercentage")

	def IncrementedQ()
		return This._Noun("incremented")

	def IndexQ()
		return This._Noun("index")

	def InfereTypeQ()
		return This._Noun("inferetype")

	def InitialsQ()
		return This._Noun("initials")

	def IntegerPartQ()
		return This._Noun("integerpart")

	def IntegerPartNumericValueQ()
		return This._Noun("integerpartnumericvalue")

	def IntegerPartStringValueQ()
		return This._Noun("integerpartstringvalue")

	def IntegerPartStringValueWithoutSignQ()
		return This._Noun("integerpartstringvaluewithoutsign")

	def IntegerPartToHexFormQ()
		return This._Noun("integerparttohexform")

	def IntegerPartToOctalFormQ()
		return This._Noun("integerparttooctalform")

	def IntegerPartValueQ()
		return This._Noun("integerpartvalue")

	def IntegerPartWithoutSignQ()
		return This._Noun("integerpartwithoutsign")

	def IntegersQ()
		return This._Noun("integers")

	def IntergerPartQ()
		return This._Noun("intergerpart")

	def IntergerPartStringValueQ()
		return This._Noun("intergerpartstringvalue")

	def IntergersQ()
		return This._Noun("intergers")

	def InverseQ()
		return This._Noun("inverse")

	def InversedQ()
		return This._Noun("inversed")

	def IsACharQ()
		return This._Noun("isachar")

	def IsACharNameQ()
		return This._Noun("isacharname")

	def IsAClassQ()
		return This._Noun("isaclass")

	def IsADigitQ()
		return This._Noun("isadigit")

	def IsADigitInStringQ()
		return This._Noun("isadigitinstring")

	def IsAFunctionQ()
		return This._Noun("isafunction")

	def IsAFunctionNameQ()
		return This._Noun("isafunctionname")

	def IsAHashListQ()
		return This._Noun("isahashlist")

	def IsAHexUnicodeQ()
		return This._Noun("isahexunicode")

	def IsALetterQ()
		return This._Noun("isaletter")

	def IsAListQ()
		return This._Noun("isalist")

	def IsAListOfCharsQ()
		return This._Noun("isalistofchars")

	def IsAListOfListsQ()
		return This._Noun("isalistoflists")

	def IsAListOfListsOfNumbersQ()
		return This._Noun("isalistoflistsofnumbers")

	def IsAListOfNumbersQ()
		return This._Noun("isalistofnumbers")

	def IsAListOfPairsQ()
		return This._Noun("isalistofpairs")

	def IsAListOfPairsOfNumbersQ()
		return This._Noun("isalistofpairsofnumbers")

	def IsAListOfPairsOfStringsQ()
		return This._Noun("isalistofpairsofstrings")

	def IsAListOfStringsQ()
		return This._Noun("isalistofstrings")

	def IsANumberQ()
		return This._Noun("isanumber")

	def IsAObjectQ()
		return This._Noun("isaobject")

	def IsAPairQ()
		return This._Noun("isapair")

	def IsAPairOfNumbersQ()
		return This._Noun("isapairofnumbers")

	def IsAPairQQ()
		return This._Noun("isapairq")

	def IsAPrimeQ()
		return This._Noun("isaprime")

	def IsAPrimeNumberQ()
		return This._Noun("isaprimenumber")

	def IsARealInStringQ()
		return This._Noun("isarealinstring")

	def IsASetQ()
		return This._Noun("isaset")

	def IsAStringQ()
		return This._Noun("isastring")

	def IsAllLettersQ()
		return This._Noun("isallletters")

	def IsAlmostAFunctionCallQ()
		return This._Noun("isalmostafunctioncall")

	def IsAlphaStringQ()
		return This._Noun("isalphastring")

	def IsAnIntegerQ()
		return This._Noun("isaninteger")

	def IsAnObjectQ()
		return This._Noun("isanobject")

	def IsAnRGBColorQ()
		return This._Noun("isanrgbcolor")

	def IsAndColAtNamedParamQ()
		return This._Noun("isandcolatnamedparam")

	def IsAndColAtPositionNamedParamQ()
		return This._Noun("isandcolatpositionnamedparam")

	def IsAndColumnAtNamedParamQ()
		return This._Noun("isandcolumnatnamedparam")

	def IsAndColumnAtPositionNamedParamQ()
		return This._Noun("isandcolumnatpositionnamedparam")

	def IsAndColumnNamedNamedParamQ()
		return This._Noun("isandcolumnnamednamedparam")

	def IsAndColumnNamedParamQ()
		return This._Noun("isandcolumnnamedparam")

	def IsAndNamedParamQ()
		return This._Noun("isandnamedparam")

	def IsAndPositionNamedParamQ()
		return This._Noun("isandpositionnamedparam")

	def IsAndReturnNamedParamQ()
		return This._Noun("isandreturnnamedparam")

	def IsAndReturnNthNamedParamQ()
		return This._Noun("isandreturnnthnamedparam")

	def IsAndReturningNamedParamQ()
		return This._Noun("isandreturningnamedparam")

	def IsAndReturningNthNamedParamQ()
		return This._Noun("isandreturningnthnamedparam")

	def IsAndRowAtNamedParamQ()
		return This._Noun("isandrowatnamedparam")

	def IsAndRowAtPositionNamedParamQ()
		return This._Noun("isandrowatpositionnamedparam")

	def IsAndRowNamedParamQ()
		return This._Noun("isandrownamedparam")

	def IsAndcColNamedNamedParamQ()
		return This._Noun("isandccolnamednamedparam")

	def IsAndcColNamedParamQ()
		return This._Noun("isandccolnamedparam")

	def IsArabicQ()
		return This._Noun("isarabic")

	def IsArabicScriptQ()
		return This._Noun("isarabicscript")

	def IsAtCharsNamedParamQ()
		return This._Noun("isatcharsnamedparam")

	def IsAtNamedParamQ()
		return This._Noun("isatnamedparam")

	def IsAtOrAtPositionNamedParamQ()
		return This._Noun("isatoratpositionnamedparam")

	def IsAtPositionNamedParamQ()
		return This._Noun("isatpositionnamedparam")

	def IsBalancedQ()
		return This._Noun("isbalanced")

	def IsBetweenColAtNamedParamQ()
		return This._Noun("isbetweencolatnamedparam")

	def IsBetweenColAtPositionNamedParamQ()
		return This._Noun("isbetweencolatpositionnamedparam")

	def IsBetweenColumnAtNamedParamQ()
		return This._Noun("isbetweencolumnatnamedparam")

	def IsBetweenColumnAtPositionNamedParamQ()
		return This._Noun("isbetweencolumnatpositionnamedparam")

	def IsBetweenColumnNamedParamQ()
		return This._Noun("isbetweencolumnnamedparam")

	def IsBetweenNamedParamQ()
		return This._Noun("isbetweennamedparam")

	def IsBetweenPositionNamedParamQ()
		return This._Noun("isbetweenpositionnamedparam")

	def IsBetweenPositionsNamedParamQ()
		return This._Noun("isbetweenpositionsnamedparam")

	def IsBetweenRowAtNamedParamQ()
		return This._Noun("isbetweenrowatnamedparam")

	def IsBetweenRowAtPositionNamedParamQ()
		return This._Noun("isbetweenrowatpositionnamedparam")

	def IsBetweenRowNamedParamQ()
		return This._Noun("isbetweenrownamedparam")

	def IsBetweencColNamedParamQ()
		return This._Noun("isbetweenccolnamedparam")

	def IsBigNumberQ()
		return This._Noun("isbignumber")

	def IsBlankQ()
		return This._Noun("isblank")

	def IsBooleanQ()
		return This._Noun("isboolean")

	def IsByColOrByColNumberNamedParamQ()
		return This._Noun("isbycolorbycolnumbernamedparam")

	def IsByNamedParamQ()
		return This._Noun("isbynamedparam")

	def IsByOrUsingOrWithNamedParamQ()
		return This._Noun("isbyorusingorwithnamedparam")

	def IsByOrWithOrUsingNamedParamQ()
		return This._Noun("isbyorwithorusingnamedparam")

	def IsByRowNamedParamQ()
		return This._Noun("isbyrownamedparam")

	def IsCamelCaseQ()
		return This._Noun("iscamelcase")

	def IsCapitalcaseQ()
		return This._Noun("iscapitalcase")

	def IsCaseSensitiveNamedParamQ()
		return This._Noun("iscasesensitivenamedparam")

	def IsCharQ()
		return This._Noun("ischar")

	def IsCharNameQ()
		return This._Noun("ischarname")

	def IsCharsSortedAscQ()
		return This._Noun("ischarssortedasc")

	def IsCharsSortedAscendingQ()
		return This._Noun("ischarssortedascending")

	def IsCharsSortedDescQ()
		return This._Noun("ischarssorteddesc")

	def IsCharsSortedDescendingQ()
		return This._Noun("ischarssorteddescending")

	def IsCircledDigitQ()
		return This._Noun("iscircleddigit")

	def IsCircledNumberQ()
		return This._Noun("iscirclednumber")

	def IsComingNamedParamQ()
		return This._Noun("iscomingnamedparam")

	def IsCommonScriptQ()
		return This._Noun("iscommonscript")

	def IsContiguousQ()
		return This._Noun("iscontiguous")

	def IsContiguousListInNormalFormQ()
		return This._Noun("iscontiguouslistinnormalform")

	def IsContiguousListInShortFormQ()
		return This._Noun("iscontiguouslistinshortform")

	def IsContiguousListInStringQ()
		return This._Noun("iscontiguouslistinstring")

	def IsControlQ()
		return This._Noun("iscontrol")

	def IsCountryAbbreviationQ()
		return This._Noun("iscountryabbreviation")

	def IsCountryCodeQ()
		return This._Noun("iscountrycode")

	def IsCountryIdentifierQ()
		return This._Noun("iscountryidentifier")

	def IsCountryNameQ()
		return This._Noun("iscountryname")

	def IsCountryNumberQ()
		return This._Noun("iscountrynumber")

	def IsCountryPhoneCodeQ()
		return This._Noun("iscountryphonecode")

	def IsCurrencyNameQ()
		return This._Noun("iscurrencyname")

	def IsCurrencySymbolQ()
		return This._Noun("iscurrencysymbol")

	def IsDigitQ()
		return This._Noun("isdigit")

	def IsDigitPalindromeQ()
		return This._Noun("isdigitpalindrome")

	def IsDirectionOrGoingNamedParamQ()
		return This._Noun("isdirectionorgoingnamedparam")

	def IsEmailLikeQ()
		return This._Noun("isemaillike")

	def IsEmptyQ()
		return This._Noun("isempty")

	def IsEqualToNamedParamQ()
		return This._Noun("isequaltonamedparam")

	def IsEvenQ()
		return This._Noun("iseven")

	def IsEvenOrOddQ()
		return This._Noun("isevenorodd")

	def IsFalseQ()
		return This._Noun("isfalse")

	def IsFardiOrZawjiQ()
		return This._Noun("isfardiorzawji")

	def IsFromNamedParamQ()
		return This._Noun("isfromnamedparam")

	def IsFromOrOfNamedParamQ()
		return This._Noun("isfromorofnamedparam")

	def IsFromPositionNamedParamQ()
		return This._Noun("isfrompositionnamedparam")

	def IsFuncQ()
		return This._Noun("isfunc")

	def IsHanScriptQ()
		return This._Noun("ishanscript")

	def IsHashListQ()
		return This._Noun("ishashlist")

	def IsHexUnicodeQ()
		return This._Noun("ishexunicode")

	def IsHexUnicodeInStringQ()
		return This._Noun("ishexunicodeinstring")

	def IsHybridScriptQ()
		return This._Noun("ishybridscript")

	def IsHybridcaseQ()
		return This._Noun("ishybridcase")

	def IsIdentifierQ()
		return This._Noun("isidentifier")

	def IsInANamedParamQ()
		return This._Noun("isinanamedparam")

	def IsInLowercaseQ()
		return This._Noun("isinlowercase")

	def IsInNamedParamQ()
		return This._Noun("isinnamedparam")

	def IsInOrInListNamedParamQ()
		return This._Noun("isinorinlistnamedparam")

	def IsInOrInStringNamedParamQ()
		return This._Noun("isinorinstringnamedparam")

	def IsInheritedScriptQ()
		return This._Noun("isinheritedscript")

	def IsIntegerQ()
		return This._Noun("isinteger")

	def IsIntegerOrRealQ()
		return This._Noun("isintegerorreal")

	def IsIntergerOrRealQ()
		return This._Noun("isintergerorreal")

	def IsIsBoundedByNamedParamQ()
		return This._Noun("isisboundedbynamedparam")

	def IsIsogramQ()
		return This._Noun("isisogram")

	def IsItemQ()
		return This._Noun("isitem")

	def IsKebabCaseQ()
		return This._Noun("iskebabcase")

	def IsLanguageAbbreviationQ()
		return This._Noun("islanguageabbreviation")

	def IsLanguageCodeQ()
		return This._Noun("islanguagecode")

	def IsLanguageIdentifierQ()
		return This._Noun("islanguageidentifier")

	def IsLanguageNameQ()
		return This._Noun("islanguagename")

	def IsLanguageNameOrAbbreviationQ()
		return This._Noun("islanguagenameorabbreviation")

	def IsLanguageNumberQ()
		return This._Noun("islanguagenumber")

	def IsLatinQ()
		return This._Noun("islatin")

	def IsLatinScriptQ()
		return This._Noun("islatinscript")

	def IsLeftToRightQ()
		return This._Noun("islefttoright")

	def IsLetterQ()
		return This._Noun("isletter")

	def IsListInNormalFormQ()
		return This._Noun("islistinnormalform")

	def IsListInShortFormQ()
		return This._Noun("islistinshortform")

	def IsListInStringQ()
		return This._Noun("islistinstring")

	def IsListOfCharsQ()
		return This._Noun("islistofchars")

	def IsListOfEmptyListsQ()
		return This._Noun("islistofemptylists")

	def IsListOfHashListsQ()
		return This._Noun("islistofhashlists")

	def IsListOfListsQ()
		return This._Noun("islistoflists")

	def IsListOfListsOfNumbersQ()
		return This._Noun("islistoflistsofnumbers")

	def IsListOfListsOfSameSizeQ()
		return This._Noun("islistoflistsofsamesize")

	def IsListOfNumbersQ()
		return This._Noun("islistofnumbers")

	def IsListOfNumbersAndPairsOfNumbersQ()
		return This._Noun("islistofnumbersandpairsofnumbers")

	def IsListOfPairsQ()
		return This._Noun("islistofpairs")

	def IsListOfPairsOfNumbersQ()
		return This._Noun("islistofpairsofnumbers")

	def IsListOfPairsOfStringsQ()
		return This._Noun("islistofpairsofstrings")

	def IsListOfStringsQ()
		return This._Noun("islistofstrings")

	def IsLocaleAbbreviationQ()
		return This._Noun("islocaleabbreviation")

	def IsLocaleListQ()
		return This._Noun("islocalelist")

	def IsLongLanguageAbbreviationQ()
		return This._Noun("islonglanguageabbreviation")

	def IsLowercaseQ()
		return This._Noun("islowercase")

	def IsLowercasedQ()
		return This._Noun("islowercased")

	def IsMadeOfDigitsQ()
		return This._Noun("ismadeofdigits")

	def IsMadeOfLettersQ()
		return This._Noun("ismadeofletters")

	def IsMadeOfNumbersQ()
		return This._Noun("ismadeofnumbers")

	def IsMadeOfNumbersAndStringsQ()
		return This._Noun("ismadeofnumbersandstrings")

	def IsMadeOfNumbersOrStringsQ()
		return This._Noun("ismadeofnumbersorstrings")

	def IsMadeOfStringsQ()
		return This._Noun("ismadeofstrings")

	def IsMadeOfUniSizeListsQ()
		return This._Noun("ismadeofunisizelists")

	def IsMadeOfUniformListsQ()
		return This._Noun("ismadeofuniformlists")

	def IsMarkerQ()
		return This._Noun("ismarker")

	def IsMarquerQ()
		return This._Noun("ismarquer")

	def IsMemberQ()
		return This._Noun("ismember")

	def IsMultilingualStringQ()
		return This._Noun("ismultilingualstring")

	def IsNamedObjectQ()
		return This._Noun("isnamedobject")

	def IsNamedParamQ()
		return This._Noun("isnamedparam")

	def IsNegativeQ()
		return This._Noun("isnegative")

	def IsNegativeIntegerQ()
		return This._Noun("isnegativeinteger")

	def IsNestedQ()
		return This._Noun("isnested")

	def IsNorNamedParamQ()
		return This._Noun("isnornamedparam")

	def IsNotAListQ()
		return This._Noun("isnotalist")

	def IsNotANumberQ()
		return This._Noun("isnotanumber")

	def IsNotAStringQ()
		return This._Noun("isnotastring")

	def IsNotAnObjectQ()
		return This._Noun("isnotanobject")

	def IsNotEmptyQ()
		return This._Noun("isnotempty")

	def IsNotEvenQ()
		return This._Noun("isnoteven")

	def IsNotHashListQ()
		return This._Noun("isnothashlist")

	def IsNotInLowercaseQ()
		return This._Noun("isnotinlowercase")

	def IsNotLetterQ()
		return This._Noun("isnotletter")

	def IsNotOddQ()
		return This._Noun("isnotodd")

	def IsNotSignedQ()
		return This._Noun("isnotsigned")

	def IsNumberInStringQ()
		return This._Noun("isnumberinstring")

	def IsNumericStringQ()
		return This._Noun("isnumericstring")

	def IsOddQ()
		return This._Noun("isodd")

	def IsOddOrEvenQ()
		return This._Noun("isoddoreven")

	def IsOfNamedParamQ()
		return This._Noun("isofnamedparam")

	def IsOfOrOfSubStringNamedParamQ()
		return This._Noun("isoforofsubstringnamedparam")

	def IsOfSizeNamedParamQ()
		return This._Noun("isofsizenamedparam")

	def IsOneDigitQ()
		return This._Noun("isonedigit")

	def IsPairQ()
		return This._Noun("ispair")

	def IsPairOfNumbersQ()
		return This._Noun("ispairofnumbers")

	def IsPairOfStringsQ()
		return This._Noun("ispairofstrings")

	def IsPairQQ()
		return This._Noun("ispairq")

	def IsPalindromeQ()
		return This._Noun("ispalindrome")

	def IsPalindromeNumberQ()
		return This._Noun("ispalindromenumber")

	def IsPalindromeWordsQ()
		return This._Noun("ispalindromewords")

	def IsPangramQ()
		return This._Noun("ispangram")

	def IsPerfectQ()
		return This._Noun("isperfect")

	def IsPerfectNumberQ()
		return This._Noun("isperfectnumber")

	def IsPluralOfAStzTypeQ()
		return This._Noun("ispluralofastztype")

	def IsPluralOfStzTypeQ()
		return This._Noun("ispluralofstztype")

	def IsPositionNamedParamQ()
		return This._Noun("ispositionnamedparam")

	def IsPositionOrPositionsNamedParamQ()
		return This._Noun("ispositionorpositionsnamedparam")

	def IsPositiveQ()
		return This._Noun("ispositive")

	def IsPositiveIntegerQ()
		return This._Noun("ispositiveinteger")

	def IsPrimeQ()
		return This._Noun("isprime")

	def IsPrimeNumberQ()
		return This._Noun("isprimenumber")

	def IsRGBColorQ()
		return This._Noun("isrgbcolor")

	def IsRealQ()
		return This._Noun("isreal")

	def IsRealInStringQ()
		return This._Noun("isrealinstring")

	def IsRealNumberQ()
		return This._Noun("isrealnumber")

	def IsReturnNamedParamQ()
		return This._Noun("isreturnnamedparam")

	def IsReturnNthNamedParamQ()
		return This._Noun("isreturnnthnamedparam")

	def IsReturnedAsNamedParamQ()
		return This._Noun("isreturnedasnamedparam")

	def IsReturningNamedParamQ()
		return This._Noun("isreturningnamedparam")

	def IsReturningNthNamedParamQ()
		return This._Noun("isreturningnthnamedparam")

	def IsRightToLeftQ()
		return This._Noun("isrighttoleft")

	def IsScriptQ()
		return This._Noun("isscript")

	def IsScriptAbbreviationQ()
		return This._Noun("isscriptabbreviation")

	def IsScriptCodeQ()
		return This._Noun("isscriptcode")

	def IsScriptIdentifierQ()
		return This._Noun("isscriptidentifier")

	def IsScriptNameQ()
		return This._Noun("isscriptname")

	def IsScriptNumberQ()
		return This._Noun("isscriptnumber")

	def IsSeedNamedParamQ()
		return This._Noun("isseednamedparam")

	def IsSetQ()
		return This._Noun("isset")

	def IsShortLanguageAbbreviationQ()
		return This._Noun("isshortlanguageabbreviation")

	def IsSignedQ()
		return This._Noun("issigned")

	def IsSingleQ()
		return This._Noun("issingle")

	def IsSizeNamedParamQ()
		return This._Noun("issizenamedparam")

	def IsSnakeCaseQ()
		return This._Noun("issnakecase")

	def IsSortedQ()
		return This._Noun("issorted")

	def IsSortedInAscendingQ()
		return This._Noun("issortedinascending")

	def IsSortedInDescendingQ()
		return This._Noun("issortedindescending")

	def IsStartingAtNamedParamQ()
		return This._Noun("isstartingatnamedparam")

	def IsStepNamedParamQ()
		return This._Noun("isstepnamedparam")

	def IsStoppingAtNamedParamQ()
		return This._Noun("isstoppingatnamedparam")

	def IsStopwordQ()
		return This._Noun("isstopword")

	def IsStrictlyNegativeQ()
		return This._Noun("isstrictlynegative")

	def IsStrictlyPositiveQ()
		return This._Noun("isstrictlypositive")

	def IsStzNumberQ()
		return This._Noun("isstznumber")

	def IsTitleCasedQ()
		return This._Noun("istitlecased")

	def IsTitlecaseQ()
		return This._Noun("istitlecase")

	def IsToNamedParamQ()
		return This._Noun("istonamedparam")

	def IsToOrOfNamedParamQ()
		return This._Noun("istoorofnamedparam")

	def IsToOrToPositionQ()
		return This._Noun("istoortoposition")

	def IsToPositionNamedParamQ()
		return This._Noun("istopositionnamedparam")

	def IsToPositionOrToQ()
		return This._Noun("istopositionorto")

	def IsTrueQ()
		return This._Noun("istrue")

	def IsUnsignedQ()
		return This._Noun("isunsigned")

	def IsUppercaseQ()
		return This._Noun("isuppercase")

	def IsUppercasedQ()
		return This._Noun("isuppercased")

	def IsUrlLikeQ()
		return This._Noun("isurllike")

	def IsUsingOrWithOrByNamedParamQ()
		return This._Noun("isusingorwithorbynamedparam")

	def IsVowelQ()
		return This._Noun("isvowel")

	def IsWhereNamedParamQ()
		return This._Noun("iswherenamedparam")

	def IsWithNamedParamQ()
		return This._Noun("iswithnamedparam")

	def IsWithOrByNamedParamQ()
		return This._Noun("iswithorbynamedparam")

	def IsWithOrByOrUsingNamedParamQ()
		return This._Noun("iswithorbyorusingnamedparam")

	def IsWithRowNamedParamQ()
		return This._Noun("iswithrownamedparam")

	def IsWordQ()
		return This._Noun("isword")

	def IsZawjiOrFardiQ()
		return This._Noun("iszawjiorfardi")

	def IsZeroQ()
		return This._Noun("iszero")

	def ItemsQ()
		return This._Noun("items")

	def ItemsAndTheirNumberOfOccurrenceQ()
		return This._Noun("itemsandtheirnumberofoccurrence")

	def ItemsAndTheirPositionsQ()
		return This._Noun("itemsandtheirpositions")

	def ItemsAndTheirTypesQ()
		return This._Noun("itemsandtheirtypes")

	def ItemsAreEmptyListsQ()
		return This._Noun("itemsareemptylists")

	def ItemsAreListsOfSameSizeQ()
		return This._Noun("itemsarelistsofsamesize")

	def ItemsCountQ()
		return This._Noun("itemscount")

	def ItemsHaveSameTypeQ()
		return This._Noun("itemshavesametype")

	def ItemsReversedQ()
		return This._Noun("itemsreversed")

	def ItemsSortedInAscendingQ()
		return This._Noun("itemssortedinascending")

	def ItemsZQ()
		return This._Noun("itemsz")

	def KFormQ()
		return This._Noun("kform")

	def KeywordsQ()
		return This._Noun("keywords")

	def LanguageQ()
		return This._Noun("language")

	def LanguageAbbreviationFormQ()
		return This._Noun("languageabbreviationform")

	def LargestQ()
		return This._Noun("largest")

	def LastAndFirstItemsQ()
		return This._Noun("lastandfirstitems")

	def LastCharQ()
		return This._Noun("lastchar")

	def LastCharRemovedQ()
		return This._Noun("lastcharremoved")

	def LastItemQ()
		return This._Noun("lastitem")

	def LastLineQ()
		return This._Noun("lastline")

	def LastNonSpaceCharQ()
		return This._Noun("lastnonspacechar")

	def LastNonSpaceCharPositionQ()
		return This._Noun("lastnonspacecharposition")

	def LastSentenceQ()
		return This._Noun("lastsentence")

	def LastWordQ()
		return This._Noun("lastword")

	def LastZQ()
		return This._Noun("lastz")

	def LeadingCharsRemovedQ()
		return This._Noun("leadingcharsremoved")

	def LeadingItemsQ()
		return This._Noun("leadingitems")

	def LeadingSpacesRemovedQ()
		return This._Noun("leadingspacesremoved")

	def LeastFrequentQ()
		return This._Noun("leastfrequent")

	def LeftBoundQ()
		return This._Noun("leftbound")

	def LeftCharQ()
		return This._Noun("leftchar")

	def LeftCharRemovedQ()
		return This._Noun("leftcharremoved")

	def LemmaQ()
		return This._Noun("lemma")

	def LemmatizedQ()
		return This._Noun("lemmatized")

	def LemmatizedWordsQ()
		return This._Noun("lemmatizedwords")

	def LettersQ()
		return This._Noun("letters")

	def LexicalDiversityQ()
		return This._Noun("lexicaldiversity")

	def LinesQ()
		return This._Noun("lines")

	def ListQ()
		return This._Noun("list")

	def LongestSentenceInWordsQ()
		return This._Noun("longestsentenceinwords")

	def LowercasedQ()
		return This._Noun("lowercased")

	def LowestQ()
		return This._Noun("lowest")

	def MFormQ()
		return This._Noun("mform")

	def MarkerQ()
		return This._Noun("marker")

	def MarkersAreSortedQ()
		return This._Noun("markersaresorted")

	def MarkersAreSortedAscendingQ()
		return This._Noun("markersaresortedascending")

	def MarkersAreSortedInAscendingQ()
		return This._Noun("markersaresortedinascending")

	def MarkersAreSortedInDescendingQ()
		return This._Noun("markersaresortedindescending")

	def MarkersAreUnsortedQ()
		return This._Noun("markersareunsorted")

	def MarkersSortingOrderQ()
		return This._Noun("markerssortingorder")

	def MarquerQ()
		return This._Noun("marquer")

	def MarquersAreSortedQ()
		return This._Noun("marquersaresorted")

	def MarquersAreSortedInAscendingQ()
		return This._Noun("marquersaresortedinascending")

	def MarquersAreSortedInDescendingQ()
		return This._Noun("marquersaresortedindescending")

	def MarquersAreUnsortedQ()
		return This._Noun("marquersareunsorted")

	def MarquersSortingOrderQ()
		return This._Noun("marquerssortingorder")

	def MaxQ()
		return This._Noun("max")

	def MaxNumberQ()
		return This._Noun("maxnumber")

	def MaxNumberOfDigitsQ()
		return This._Noun("maxnumberofdigits")

	def MaxNumberOfDigitsTheNumberCanContainQ()
		return This._Noun("maxnumberofdigitsthenumbercancontain")

	def MaxRoundQ()
		return This._Noun("maxround")

	def MeanQ()
		return This._Noun("mean")

	def MeanOfNumbersQ()
		return This._Noun("meanofnumbers")

	def MedianQ()
		return This._Noun("median")

	def MergedQ()
		return This._Noun("merged")

	def MetaphoneQ()
		return This._Noun("metaphone")

	def MethodsQ()
		return This._Noun("methods")

	def MiddleQ()
		return This._Noun("middle")

	def MinQ()
		return This._Noun("min")

	def MinNumberQ()
		return This._Noun("minnumber")

	def ModeQ()
		return This._Noun("mode")

	def MostFrequentQ()
		return This._Noun("mostfrequent")

	def MostFrequentCharQ()
		return This._Noun("mostfrequentchar")

	def MostFrequentWordQ()
		return This._Noun("mostfrequentword")

	def MostNegativeSentenceQ()
		return This._Noun("mostnegativesentence")

	def MostPositiveSentenceQ()
		return This._Noun("mostpositivesentence")

	def NamesQ()
		return This._Noun("names")

	def NaturalLogarithmQ()
		return This._Noun("naturallogarithm")

	def NegativeScoreQ()
		return This._Noun("negativescore")

	def NestingDepthQ()
		return This._Noun("nestingdepth")

	def NeutralScoreQ()
		return This._Noun("neutralscore")

	def NoItemsAreDuplicatedQ()
		return This._Noun("noitemsareduplicated")

	def NonDuplicatedItemsQ()
		return This._Noun("nonduplicateditems")

	def NonDuplicatedItemsAndTheirPositionsQ()
		return This._Noun("nonduplicateditemsandtheirpositions")

	def NonDuplicatedItemsZQ()
		return This._Noun("nonduplicateditemsz")

	def NormalizedNFCQ()
		return This._Noun("normalizednfc")

	def NormalizedNFDQ()
		return This._Noun("normalizednfd")

	def NormalizedNFKCQ()
		return This._Noun("normalizednfkc")

	def NormalizedNFKDQ()
		return This._Noun("normalizednfkd")

	def NounsQ()
		return This._Noun("nouns")

	def NullsStrippedQ()
		return This._Noun("nullsstripped")

	def NumberQ()
		return This._Noun("number")

	def NumberFormQ()
		return This._Noun("numberform")

	def NumberOfBytesQ()
		return This._Noun("numberofbytes")

	def NumberOfBytesPerCharQ()
		return This._Noun("numberofbytesperchar")

	def NumberOfCharsQ()
		return This._Noun("numberofchars")

	def NumberOfClassesQ()
		return This._Noun("numberofclasses")

	def NumberOfConsecutiveSubStringsQ()
		return This._Noun("numberofconsecutivesubstrings")

	def NumberOfDecimalsQ()
		return This._Noun("numberofdecimals")

	def NumberOfDigitsQ()
		return This._Noun("numberofdigits")

	def NumberOfDigitsInDecimalPartQ()
		return This._Noun("numberofdigitsindecimalpart")

	def NumberOfDigitsInFractionalPartQ()
		return This._Noun("numberofdigitsinfractionalpart")

	def NumberOfDigitsInIntegerPartQ()
		return This._Noun("numberofdigitsinintegerpart")

	def NumberOfDigitsTheNumberActuallyContainsQ()
		return This._Noun("numberofdigitsthenumberactuallycontains")

	def NumberOfDuplicatedItemsQ()
		return This._Noun("numberofduplicateditems")

	def NumberOfDuplicatedStringsQ()
		return This._Noun("numberofduplicatedstrings")

	def NumberOfDuplicatesQ()
		return This._Noun("numberofduplicates")

	def NumberOfDuplicationsQ()
		return This._Noun("numberofduplications")

	def NumberOfEmptyLinesQ()
		return This._Noun("numberofemptylines")

	def NumberOfIntegersQ()
		return This._Noun("numberofintegers")

	def NumberOfItemsQ()
		return This._Noun("numberofitems")

	def NumberOfItemsBQ()
		return This._Noun("numberofitemsb")

	def NumberOfItemsUQ()
		return This._Noun("numberofitemsu")

	def NumberOfLargestQ()
		return This._Noun("numberoflargest")

	def NumberOfLeadingCharsQ()
		return This._Noun("numberofleadingchars")

	def NumberOfLeadingItemsQ()
		return This._Noun("numberofleadingitems")

	def NumberOfLeadingNumberDigitsQ()
		return This._Noun("numberofleadingnumberdigits")

	def NumberOfLettersQ()
		return This._Noun("numberofletters")

	def NumberOfLevelsQ()
		return This._Noun("numberoflevels")

	def NumberOfLinesQ()
		return This._Noun("numberoflines")

	def NumberOfListsQ()
		return This._Noun("numberoflists")

	def NumberOfMarkersQ()
		return This._Noun("numberofmarkers")

	def NumberOfMarquersQ()
		return This._Noun("numberofmarquers")

	def NumberOfNamedObjectsQ()
		return This._Noun("numberofnamedobjects")

	def NumberOfNonDuplicatedItemsQ()
		return This._Noun("numberofnonduplicateditems")

	def NumberOfNonEmptyLinesQ()
		return This._Noun("numberofnonemptylines")

	def NumberOfNonStzObjectsQ()
		return This._Noun("numberofnonstzobjects")

	def NumberOfNumbersQ()
		return This._Noun("numberofnumbers")

	def NumberOfObjectsQ()
		return This._Noun("numberofobjects")

	def NumberOfOccurrenceOfEachItemQ()
		return This._Noun("numberofoccurrenceofeachitem")

	def NumberOfOccurrenceOfItemsQ()
		return This._Noun("numberofoccurrenceofitems")

	def NumberOfOccurrencesOfLargestItemQ()
		return This._Noun("numberofoccurrencesoflargestitem")

	def NumberOfOccurrencesOfSmallestItemQ()
		return This._Noun("numberofoccurrencesofsmallestitem")

	def NumberOfPairsQ()
		return This._Noun("numberofpairs")

	def NumberOfParagraphsQ()
		return This._Noun("numberofparagraphs")

	def NumberOfQObjectsQ()
		return This._Noun("numberofqobjects")

	def NumberOfRepeatedLeadingCharsQ()
		return This._Noun("numberofrepeatedleadingchars")

	def NumberOfRepeatedLeadingItemsQ()
		return This._Noun("numberofrepeatedleadingitems")

	def NumberOfRepeatedTrailingCharsQ()
		return This._Noun("numberofrepeatedtrailingchars")

	def NumberOfRepeatedTrailingItemsQ()
		return This._Noun("numberofrepeatedtrailingitems")

	def NumberOfRoundsWeCanAddBeforeMaxRoundIsReachedQ()
		return This._Noun("numberofroundswecanaddbeforemaxroundisreached")

	def NumberOfScriptsQ()
		return This._Noun("numberofscripts")

	def NumberOfSentencesQ()
		return This._Noun("numberofsentences")

	def NumberOfSmallestQ()
		return This._Noun("numberofsmallest")

	def NumberOfStringsQ()
		return This._Noun("numberofstrings")

	def NumberOfStzObjectsQ()
		return This._Noun("numberofstzobjects")

	def NumberOfSubStringsQ()
		return This._Noun("numberofsubstrings")

	def NumberOfSubStringsUQ()
		return This._Noun("numberofsubstringsu")

	def NumberOfTrailingCharsQ()
		return This._Noun("numberoftrailingchars")

	def NumberOfTrailingItemsQ()
		return This._Noun("numberoftrailingitems")

	def NumberOfTrailingNumberDigitsQ()
		return This._Noun("numberoftrailingnumberdigits")

	def NumberOfUniqueNamedObjectsQ()
		return This._Noun("numberofuniquenamedobjects")

	def NumberOfUniqueSubStringsQ()
		return This._Noun("numberofuniquesubstrings")

	def NumberOfUnnamedObjectsQ()
		return This._Noun("numberofunnamedobjects")

	def NumberOfVowelsQ()
		return This._Noun("numberofvowels")

	def NumberOfWordsQ()
		return This._Noun("numberofwords")

	def NumberRoundQ()
		return This._Noun("numberround")

	def NumberWithSignQ()
		return This._Noun("numberwithsign")

	def NumbericValueQ()
		return This._Noun("numbericvalue")

	def NumbersAndStringsQ()
		return This._Noun("numbersandstrings")

	def NumbersAndStringsZQ()
		return This._Noun("numbersandstringsz")

	def NumbersAsSectionsQ()
		return This._Noun("numbersassections")

	def ObjectifiedQ()
		return This._Noun("objectified")

	def OnlyLatinLettersQ()
		return This._Noun("onlylatinletters")

	def OrientationQ()
		return This._Noun("orientation")

	def POSTagsQ()
		return This._Noun("postags")

	def PairifiedQ()
		return This._Noun("pairified")

	def PairifyQ()
		return This._Noun("pairify")

	def ParagraphsQ()
		return This._Noun("paragraphs")

	def PartOfSpeechTagsQ()
		return This._Noun("partofspeechtags")

	def PathsQ()
		return This._Noun("paths")

	def PercentQ()
		return This._Noun("percent")

	def PositionOfCentralCharQ()
		return This._Noun("positionofcentralchar")

	def PositiveScoreQ()
		return This._Noun("positivescore")

	def PrimeDividorsQ()
		return This._Noun("primedividors")

	def PrimeDivirdosQ()
		return This._Noun("primedivirdos")

	def PrimeDivisorsQ()
		return This._Noun("primedivisors")

	def PrimeFactorsQ()
		return This._Noun("primefactors")

	def ProductQ()
		return This._Noun("product")

	def ProfileQ()
		return This._Noun("profile")

	def RandomCharQ()
		return This._Noun("randomchar")

	def RandomItemQ()
		return This._Noun("randomitem")

	def RandomItemsQ()
		return This._Noun("randomitems")

	def RandomPositionQ()
		return This._Noun("randomposition")

	def RandomSectionQ()
		return This._Noun("randomsection")

	def RandomizedQ()
		return This._Noun("randomized")

	def RankedQ()
		return This._Noun("ranked")

	def ReadabilityExplainedQ()
		return This._Noun("readabilityexplained")

	def ReadabilityGradeQ()
		return This._Noun("readabilitygrade")

	def ReadingEaseQ()
		return This._Noun("readingease")

	def ReduceQ()
		return This._Noun("reduce")

	def RepresentsAHexUnicodeQ()
		return This._Noun("representsahexunicode")

	def RepresentsAHexUnicodeInStringQ()
		return This._Noun("representsahexunicodeinstring")

	def RepresentsBinaryNumberQ()
		return This._Noun("representsbinarynumber")

	def RepresentsCalculableIntegerQ()
		return This._Noun("representscalculableinteger")

	def RepresentsCalculableNumberQ()
		return This._Noun("representscalculablenumber")

	def RepresentsCalculableRealNumberQ()
		return This._Noun("representscalculablerealnumber")

	def RepresentsDecimalNumberQ()
		return This._Noun("representsdecimalnumber")

	def RepresentsHexNumberQ()
		return This._Noun("representshexnumber")

	def RepresentsIntegerQ()
		return This._Noun("representsinteger")

	def RepresentsNumberQ()
		return This._Noun("representsnumber")

	def RepresentsNumberInBinaryFormQ()
		return This._Noun("representsnumberinbinaryform")

	def RepresentsNumberInDecimalFormQ()
		return This._Noun("representsnumberindecimalform")

	def RepresentsNumberInHexFormQ()
		return This._Noun("representsnumberinhexform")

	def RepresentsNumberInOctalFormQ()
		return This._Noun("representsnumberinoctalform")

	def RepresentsNumberInUnicodeHexFormQ()
		return This._Noun("representsnumberinunicodehexform")

	def RepresentsOctalNumberQ()
		return This._Noun("representsoctalnumber")

	def RepresentsRealInStringQ()
		return This._Noun("representsrealinstring")

	def RepresentsRealNumberQ()
		return This._Noun("representsrealnumber")

	def RepresentsSignedIntegerQ()
		return This._Noun("representssignedinteger")

	def RepresentsSignedNumberQ()
		return This._Noun("representssignednumber")

	def RepresentsSignedRealNumberQ()
		return This._Noun("representssignedrealnumber")

	def RepresentsUnsignedIntegerQ()
		return This._Noun("representsunsignedinteger")

	def RepresentsUnsignedNumberQ()
		return This._Noun("representsunsignednumber")

	def RepresentsUnsignedRealNumberQ()
		return This._Noun("representsunsignedrealnumber")

	def ReturnTypeQ()
		return This._Noun("returntype")

	def ReversedQ()
		return This._Noun("reversed")

	def RightBoundQ()
		return This._Noun("rightbound")

	def RightCharQ()
		return This._Noun("rightchar")

	def RightCharRemovedQ()
		return This._Noun("rightcharremoved")

	def RoundQ()
		return This._Noun("round")

	def RoundedToMaxQ()
		return This._Noun("roundedtomax")

	def ScriptQ()
		return This._Noun("script")

	def ScriptsQ()
		return This._Noun("scripts")

	def SecondHalfQ()
		return This._Noun("secondhalf")

	def SecondHalfAndItsPositionQ()
		return This._Noun("secondhalfanditsposition")

	def SecondHalfAndItsSectionQ()
		return This._Noun("secondhalfanditssection")

	def SecondHalfAndPositionQ()
		return This._Noun("secondhalfandposition")

	def SecondHalfAndSectionQ()
		return This._Noun("secondhalfandsection")

	def SecondHalfXTZQ()
		return This._Noun("secondhalfxtz")

	def SecondHalfXTZZQ()
		return This._Noun("secondhalfxtzz")

	def SecondHalfZQ()
		return This._Noun("secondhalfz")

	def SecondHalfZZQ()
		return This._Noun("secondhalfzz")

	def SectionsOfSameItemsQ()
		return This._Noun("sectionsofsameitems")

	def SentencesQ()
		return This._Noun("sentences")

	def SentimentQ()
		return This._Noun("sentiment")

	def SentimentCompoundQ()
		return This._Noun("sentimentcompound")

	def SentimentExplainedQ()
		return This._Noun("sentimentexplained")

	def SentimentScoreQ()
		return This._Noun("sentimentscore")

	def ShortenedQ()
		return This._Noun("shortened")

	def ShortestSentenceInWordsQ()
		return This._Noun("shortestsentenceinwords")

	def ShowTaggedQ()
		return This._Noun("showtagged")

	def ShuffledQ()
		return This._Noun("shuffled")

	def SigmoidQ()
		return This._Noun("sigmoid")

	def SignRemovedQ()
		return This._Noun("signremoved")

	def SimplifiedQ()
		return This._Noun("simplified")

	def SineQ()
		return This._Noun("sine")

	def SinglifiedQ()
		return This._Noun("singlified")

	def SizeInBytesQ()
		return This._Noun("sizeinbytes")

	def SizeInBytesPerCharQ()
		return This._Noun("sizeinbytesperchar")

	def SmallestQ()
		return This._Noun("smallest")

	def SortedQ()
		return This._Noun("sorted")

	def SoundexQ()
		return This._Noun("soundex")

	def SpacesRemovedQ()
		return This._Noun("spacesremoved")

	def SpacifiedQ()
		return This._Noun("spacified")

	def SquareRootQ()
		return This._Noun("squareroot")

	def SqueezedQ()
		return This._Noun("squeezed")

	def StandardDeviationQ()
		return This._Noun("standarddeviation")

	def StartsWithALeadingNumberQ()
		return This._Noun("startswithaleadingnumber")

	def StartsWithANumberQ()
		return This._Noun("startswithanumber")

	def StartsWithNumberQ()
		return This._Noun("startswithnumber")

	def StddevQ()
		return This._Noun("stddev")

	def StemQ()
		return This._Noun("stem")

	def StemmedQ()
		return This._Noun("stemmed")

	def StemmedWordsQ()
		return This._Noun("stemmedwords")

	def StringQ()
		return This._Noun("string")

	def StringCaseQ()
		return This._Noun("stringcase")

	def StringValueQ()
		return This._Noun("stringvalue")

	def StringifiedQ()
		return This._Noun("stringified")

	def StringsAndNumbersQ()
		return This._Noun("stringsandnumbers")

	def StringsAndNumbersZQ()
		return This._Noun("stringsandnumbersz")

	def StringsLowercasedQ()
		return This._Noun("stringslowercased")

	def StringsUppercasedQ()
		return This._Noun("stringsuppercased")

	def StyleProfileQ()
		return This._Noun("styleprofile")

	def StzClassQ()
		return This._Noun("stzclass")

	def StzClassNameQ()
		return This._Noun("stzclassname")

	def StzTypeQ()
		return This._Noun("stztype")

	def SubStringsQ()
		return This._Noun("substrings")

	def SubStringsUQ()
		return This._Noun("substringsu")

	def SubStringsZQ()
		return This._Noun("substringsz")

	def SubStringsZZQ()
		return This._Noun("substringszz")

	def SubstrinksQ()
		return This._Noun("substrinks")

	def SubstrongsQ()
		return This._Noun("substrongs")

	def SumQ()
		return This._Noun("sum")

	def SumOfDecimalsQ()
		return This._Noun("sumofdecimals")

	def SumOfDigitsQ()
		return This._Noun("sumofdigits")

	def SumOfIntegersQ()
		return This._Noun("sumofintegers")

	def SumOfNumbersQ()
		return This._Noun("sumofnumbers")

	def SupportedLemmaLanguagesQ()
		return This._Noun("supportedlemmalanguages")

	def SupportedStemmerLanguagesQ()
		return This._Noun("supportedstemmerlanguages")

	def TaggedWordsQ()
		return This._Noun("taggedwords")

	def TangentQ()
		return This._Noun("tangent")

	def TextQ()
		return This._Noun("text")

	def TheStringQ()
		return This._Noun("thestring")

	def TitlecasedQ()
		return This._Noun("titlecased")

	def ToBFormQ()
		return This._Noun("tobform")

	def ToBinaryQ()
		return This._Noun("tobinary")

	def ToBinaryFormQ()
		return This._Noun("tobinaryform")

	def ToBinaryFormNoPrefixQ()
		return This._Noun("tobinaryformnoprefix")

	def ToBinaryFormWithoutPrefixQ()
		return This._Noun("tobinaryformwithoutprefix")

	def ToBinaryNoPrefixQ()
		return This._Noun("tobinarynoprefix")

	def ToBinaryWithoutPrefixQ()
		return This._Noun("tobinarywithoutprefix")

	def ToCodeQ()
		return This._Noun("tocode")

	def ToHexQ()
		return This._Noun("tohex")

	def ToHexFormQ()
		return This._Noun("tohexform")

	def ToHexFormWithoutPrefixQ()
		return This._Noun("tohexformwithoutprefix")

	def ToHexUnicodeQ()
		return This._Noun("tohexunicode")

	def ToHexWithoutPrefixQ()
		return This._Noun("tohexwithoutprefix")

	def ToKFormQ()
		return This._Noun("tokform")

	def ToListQ()
		return This._Noun("tolist")

	def ToListInAStringQ()
		return This._Noun("tolistinastring")

	def ToListInAStringInShortFormQ()
		return This._Noun("tolistinastringinshortform")

	def ToListInNormalFormQ()
		return This._Noun("tolistinnormalform")

	def ToListInShortFormQ()
		return This._Noun("tolistinshortform")

	def ToListInStringQ()
		return This._Noun("tolistinstring")

	def ToListInStringInShortFormQ()
		return This._Noun("tolistinstringinshortform")

	def ToListInStringNFQ()
		return This._Noun("tolistinstringnf")

	def ToListInStringSFQ()
		return This._Noun("tolistinstringsf")

	def ToListOfCharsQ()
		return This._Noun("tolistofchars")

	def ToListOfStzCharsQ()
		return This._Noun("tolistofstzchars")

	def ToMFormQ()
		return This._Noun("tomform")

	def ToOctalQ()
		return This._Noun("tooctal")

	def ToOctalFormQ()
		return This._Noun("tooctalform")

	def ToOctalFormWithoutPrefixQ()
		return This._Noun("tooctalformwithoutprefix")

	def ToPairsQ()
		return This._Noun("topairs")

	def ToSetQ()
		return This._Noun("toset")

	def ToSetOfItemsQ()
		return This._Noun("tosetofitems")

	def ToSlugQ()
		return This._Noun("toslug")

	def ToStringQ()
		return This._Noun("tostring")

	def ToUnicodeHexQ()
		return This._Noun("tounicodehex")

	def ToUnicodeHexFormQ()
		return This._Noun("tounicodehexform")

	def TopKeyPhraseQ()
		return This._Noun("topkeyphrase")

	def TrailingCharsRemovedQ()
		return This._Noun("trailingcharsremoved")

	def TrailingItemsQ()
		return This._Noun("trailingitems")

	def TrailingSpacesRemovedQ()
		return This._Noun("trailingspacesremoved")

	def TrimmedQ()
		return This._Noun("trimmed")

	def TrimmedLeftQ()
		return This._Noun("trimmedleft")

	def TrimmedRightQ()
		return This._Noun("trimmedright")

	def TripletsQ()
		return This._Noun("triplets")

	def TypeTokenRatioQ()
		return This._Noun("typetokenratio")

	def TypesQ()
		return This._Noun("types")

	def TypesAndTheirSectionsQ()
		return This._Noun("typesandtheirsections")

	def TypesUQ()
		return This._Noun("typesu")

	def TypesZZQ()
		return This._Noun("typeszz")

	def UnicodeQ()
		return This._Noun("unicode")

	def UnicodePerCharQ()
		return This._Noun("unicodeperchar")

	def UnicodesQ()
		return This._Noun("unicodes")

	def UnicodesPerCharQ()
		return This._Noun("unicodesperchar")

	def UniqueQ()
		return This._Noun("unique")

	def UniqueCharsQ()
		return This._Noun("uniquechars")

	def UniqueCharsAndUnicodesQ()
		return This._Noun("uniquecharsandunicodes")

	def UniqueItemsQ()
		return This._Noun("uniqueitems")

	def UniqueSubStringsQ()
		return This._Noun("uniquesubstrings")

	def UniqueTypesQ()
		return This._Noun("uniquetypes")

	def UniqueWordsQ()
		return This._Noun("uniquewords")

	def UnitsQ()
		return This._Noun("units")

	def UnitsInBillionsQ()
		return This._Noun("unitsinbillions")

	def UnitsInHundredsQ()
		return This._Noun("unitsinhundreds")

	def UnitsInMillionsQ()
		return This._Noun("unitsinmillions")

	def UnitsInThousandsQ()
		return This._Noun("unitsinthousands")

	def UnitsInTrillionsQ()
		return This._Noun("unitsintrillions")

	def UnspacifiedQ()
		return This._Noun("unspacified")

	def UnzipQ()
		return This._Noun("unzip")

	def UnzippedQ()
		return This._Noun("unzipped")

	def UppercasedQ()
		return This._Noun("uppercased")

	def UrlDecodedQ()
		return This._Noun("urldecoded")

	def UrlEncodedQ()
		return This._Noun("urlencoded")

	def ValueQ()
		return This._Noun("value")

	def VarianceQ()
		return This._Noun("variance")

	def VowelQ()
		return This._Noun("vowel")

	def VowelNQ()
		return This._Noun("voweln")

	def VowelNBQ()
		return This._Noun("vowelnb")

	def VowelsQ()
		return This._Noun("vowels")

	def VowelsBQ()
		return This._Noun("vowelsb")

	def WalkBackAndForthQ()
		return This._Noun("walkbackandforth")

	def WalkForthAndBackQ()
		return This._Noun("walkforthandback")

	def WithoutDiacriticsQ()
		return This._Noun("withoutdiacritics")

	def WithoutDotsQ()
		return This._Noun("withoutdots")

	def WithoutDotsOnLettersQ()
		return This._Noun("withoutdotsonletters")

	def WithoutDuplicationQ()
		return This._Noun("withoutduplication")

	def WithoutSapcesQ()
		return This._Noun("withoutsapces")

	def WithoutSpacesQ()
		return This._Noun("withoutspaces")

	def WithoutStopwordsQ()
		return This._Noun("withoutstopwords")

	def WordsQ()
		return This._Noun("words")

	def WordsAndTheirCountsQ()
		return This._Noun("wordsandtheircounts")

	def WordsForSearchQ()
		return This._Noun("wordsforsearch")

	def WordsLemmatizedQ()
		return This._Noun("wordslemmatized")

	def WordsStemmedQ()
		return This._Noun("wordsstemmed")

	def WordsWithPOSQ()
		return This._Noun("wordswithpos")

	def ZerosRemovedQ()
		return This._Noun("zerosremoved")

	def rndItemsQ()
		return This._Noun("rnditems")
	# </nnl-question-nouns>

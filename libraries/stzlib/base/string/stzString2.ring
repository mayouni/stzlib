
# stzString = stzStringView + all updating methods

$bUSE_ALT_FORM 		= 0


  /////////////////
 ///   CLASS   ///
/////////////////

class stzString from stzObject

	@oStringView
	@oQString

	#--

	@oConstraint
	@oLanguage
	@oObjectHistory

	#--

	@oUpdater
	@oAppender
	@oResizer

	#--

	@oChars
	@oCharsCheker
	@oCharsCheckerXT

	@oCharsW
	@oCharsWXT

	#--

	@oContains
	@oContainsXT

	@oCounter
	@oCounterXT
	@oCounterW

	@oCounterInStartEnd
	@oCopare

	#--

	@oSubStrings

	@oSubString
	@oSubStringXT
	@oSubStringChecker

	#--

	@oFinder
	@oFinderW
	@oFinderXT
	@oFinderWXT

	@oAntiFinder

	@oVizFinder
	@oVizFinderXT

	@oBoxer
	@oBoxerXT

	#--

	@oInserter
	@oInserterW
	@oInserterXT
	@oInserterWXT

	#--

	@oReplacer
	@oReplacerXT
	@oReplacerW
	@oReplacerWXT

	#--

	@oRemover
	@oRemoverW
	@oRemoverXT
	@oRemoverWXT

	@oRemoverInStartEnd
	@oRemoverInStartEndXT

	#--

	@Trimmer
	@TrimmerXT

	@oSwapper
	@oMover

	#--

	@oSection
	@oAntiSection

	@oDistance
	@oDistanceXt

	#--

	@oReverser
	@oCharsTurner

	@oSpacifier

	@oSorter

	#--

	@oSpaces
	@oOverSpaces

	@oSpacifier
	@oSpacifierXT
	@oUnSpacifier

	@Simplifier
	@oSimplifierXT

	#--

	@oMarquer

	#--

	@oBounder
	@oBetweener

	#--

	@oSplitter
	@oSplitterXT

	@oSplitsFinder
	@oSplitsFinderXT

	@oLines
	@oLinesW
	@oLinesWXT

	@oEmptyLines

	#--

	@oParts
	@oPartsFinder

	@oPartsXT
	@oPartsFinderXT

	@oPartsClassifier
	@oPartsClassifierXT

	#--

	@oDivider

	@oMultipleChecker
	@oMultiplier

	#--

	@oTypeCast
	@oTypeInfere

	@oImporter
	@oExporter

	@oURL

	#--

	@oRandomizer

	#--

	@oStartsEndsChecker

	#--

	@oOrientation

	#--

	@oOnly
	@oCharCheker

	#--

	@oAlign
	@oAlignXT

	@oJustify
	@oJustifyXT

	#--

	@oLocale
	@oLanguage
	@oCountry
	@oScript
	@oCurrency

	#--

	@oPunctuation
	@oPunctuationFinder
	@oPunctuationRemover

	@oDotsRemover

	#--

	@oNumberInString
	@oBinaryNumberInString
	@oOctalNumberInString
	@oHexNumberInString

	@oListInString
	@oIsShortFormListinsString
	@oContiguousListInString

	#--

	@oDuplicates
	@oDuplicatesFinder
	@oDuplicatesRemover
	@oDuplicatesReplacer

	@oConsecutives
	@oConsecutivesFinder
	@oConsecutivesRemover
	@oConsecutivesReplacer

	@oDupSecutives
	@oDupSecutivesFinder
	@oDupSecutivesRemover
	@oDupSecutivesReplacer

	#--

	@oRingCode
	@oRingFunction
	@oRingClass

	@oInterpolate

	#--

	@oUnicode
	@oHexUnicode

	@oEncoder
	@oHex

	@oFormatNumber

	@oHasher
	@oEncryptor

	#--

	@oRepeater
	@oRepeaterXT

	#--

	@oWalkers
	@oCheckers
	@oYielders
	@oPerformers

	#--

	@oCompressWithBinary

	#--

	@oRepeatedLeadingTrailingChars
	@oStartingTrailingNumber

	#--

	@oNumbers
	@oNumbersExtractor

	#--

	@oHalves
	@oHalvesXT

	#--

	@oOperators
	@oExternalCode
	@oNaturalCode

	#--

	@oStringifier

	#--

	@oShow
	@oShowXT

	@oShortifier
	@oShortifierXT

	#--

	@oSitter

	#--

	@oWords
	@WordsFinders

	@oAnagramChecker

	@oItem


	// Initializes the content of the softanza string object
	def init(pcStr)

		@oStzStringView = new stzStringView(pcStr)

		@oQString = new QString2()
		@oQString.append(pcStr)

		# Adding the first entry in the object history

		StartObjectTime()
		TraceObjectHistory(This)


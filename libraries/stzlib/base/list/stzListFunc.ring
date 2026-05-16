#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTFUNC                #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Q-constructors for stzList modular classes. #
#                  Utility functions (Map, Filter, Reduce,     #
#                  sorting, comparison, etc.) live in           #
#                  stzlist.ring to avoid redefinition errors.   #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///FUNCTIONS  ///
/////////////////

	  #============================================#
	 #  Q-CONSTRUCTORS FOR MODULAR CLASSES        #
	#============================================#

	#-- Core

	func StzListCoreQ(paList)
		return new stzList(paList)

	#-- Extended (with aliases)

	func StzListXTQ(paList)
		return new stzListXT(paList)

	#-- Finder

	func StzListFinderQ(paList)
		return new stzListFinder(paList)

	func StzListFinderXTQ(paList)
		return new stzListFinderXT(paList)

	#-- Replacer

	func StzListReplacerQ(paList)
		return new stzListReplacer(paList)

	func StzListReplacerXTQ(paList)
		return new stzListReplacerXT(paList)

	#-- Remover

	func StzListRemoverQ(paList)
		return new stzListRemover(paList)

	func StzListRemoverXTQ(paList)
		return new stzListRemoverXT(paList)

	#-- Inserter

	func StzListInserterQ(paList)
		return new stzListInserter(paList)

	func StzListInserterXTQ(paList)
		return new stzListInserterXT(paList)

	#-- Sorter

	func StzListSorterQ(paList)
		return new stzListSorter(paList)

	func StzListSorterXTQ(paList)
		return new stzListSorterXT(paList)

	#-- Walker

	func StzListWalkerQ(paList)
		return new stzListWalker(paList)

	func StzListWalkerXTQ(paList)
		return new stzListWalkerXT(paList)

	#-- Checker

	func StzListCheckerQ(paList)
		return new stzListChecker(paList)

	func StzListCheckerXTQ(paList)
		return new stzListCheckerXT(paList)

	#-- Duplicates

	func StzListDuplicatesQ(paList)
		return new stzListDuplicates(paList)

	func StzListDuplicatesXTQ(paList)
		return new stzListDuplicatesXT(paList)

	#-- Bounder

	func StzListBounderQ(paList)
		return new stzListBounder(paList)

	func StzListBounderXTQ(paList)
		return new stzListBounderXT(paList)

	#-- Flattener

	func StzListFlattenerQ(paList)
		return new stzListFlattener(paList)

	func StzListFlattenerXTQ(paList)
		return new stzListFlattenerXT(paList)

	#-- Counter

	func StzListCounterQ(paList)
		return new stzListCounter(paList)

	func StzListCounterXTQ(paList)
		return new stzListCounterXT(paList)

	#-- Sections

	func StzListSectionsQ(paList)
		return new stzListSections(paList)

	func StzListSectionsXTQ(paList)
		return new stzListSectionsXT(paList)

	#-- Random

	func StzListRandomQ(paList)
		return new stzListRandom(paList)

	func StzListRandomXTQ(paList)
		return new stzListRandomXT(paList)

	#-- Splits

	func StzListSplitsQ(paList)
		return new stzListSplits(paList)

	func StzListSplitsXTQ(paList)
		return new stzListSplitsXT(paList)

	#-- Stringify

	func StzListStringifyQ(paList)
		return new stzListStringify(paList)

	func StzListStringifyXTQ(paList)
		return new stzListStringifyXT(paList)

	#-- NamedParams

	func StzListNamedParamsQ(paList)
		return new stzListNamedParams(paList)

	# Phase 3 Q-constructors

	func StzListGetterQ(paList)
		return new stzListGetter(paList)

	func StzListGetterXTQ(paList)
		return new stzListGetterXT(paList)

	func StzListExtractorQ(paList)
		return new stzListExtractor(paList)

	func StzListExtractorXTQ(paList)
		return new stzListExtractorXT(paList)

	func StzListTrimmerQ(paList)
		return new stzListTrimmer(paList)

	func StzListTrimmerXTQ(paList)
		return new stzListTrimmerXT(paList)

	func StzListMoverQ(paList)
		return new stzListMover(paList)

	func StzListMoverXTQ(paList)
		return new stzListMoverXT(paList)

	func StzListClassifierQ(paList)
		return new stzListClassifier(paList)

	func StzListClassifierXTQ(paList)
		return new stzListClassifierXT(paList)

	func StzListComparatorQ(paList)
		return new stzListComparator(paList)

	func StzListComparatorXTQ(paList)
		return new stzListComparatorXT(paList)

	func StzListLeadTrailQ(paList)
		return new stzListLeadTrail(paList)

	func StzListLeadTrailXTQ(paList)
		return new stzListLeadTrailXT(paList)

	func StzListPerformerQ(paList)
		return new stzListPerformer(paList)

	func StzListPerformerXTQ(paList)
		return new stzListPerformerXT(paList)

	func StzListMergerQ(paList)
		return new stzListMerger(paList)

	func StzListMergerXTQ(paList)
		return new stzListMergerXT(paList)

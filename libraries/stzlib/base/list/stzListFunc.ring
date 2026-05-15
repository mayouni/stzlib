#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTFUNC                #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Q-constructors and utility functions        #
#                  for stzList modular classes.                 #
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

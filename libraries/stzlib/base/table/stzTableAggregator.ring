#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZTABLEAGGREGATOR          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Table aggregator subclass -- fill,          #
#                  calculated columns/rows, SUM/PRODUCT/       #
#                  AVERAGE/MAX/MIN, pivot, filter, group by.   #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzTableAggregator from stzTable

	# All methods merged into stzTable (single-class table). This shell
	# preserves `new stzTableAggregator(...)` as an alias inheriting the full API.

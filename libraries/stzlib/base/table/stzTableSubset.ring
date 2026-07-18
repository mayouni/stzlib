#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZTABLESUBSET              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Table subset subclass -- extracting         #
#                  columns, rows, sub-tables, moving and       #
#                  swapping columns and rows.                  #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzTableSubset from stzTable

	# All methods merged into stzTable (single-class table). This shell
	# preserves `new stzTableSubset(...)` as an alias inheriting the full API.

#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZTABLESEARCH              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Table search subclass -- finding cells,     #
#                  counting occurrences, containment checks    #
#                  across cells, rows, columns, and sections.  #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzTableSearch from stzTable

	# All methods merged into stzTable (single-class table). This shell
	# preserves `new stzTableSearch(...)` as an alias inheriting the full API.

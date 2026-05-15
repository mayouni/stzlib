#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGTRIMMER            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String trimmer subclass -- trimming         #
#                  whitespace from strings.                     #
#                  For aliases, use stzStringTrimmerXT.         #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringTrimmer from stzString

	  #======================================================#
	 #   TRIMMING BOTH SIDES                                #
	#======================================================#

	def Trim()
		This.Update(ring_trim(This.Content()))

		def TrimQ()
			This.Trim()
			return This

	def Trimmed()
		return ring_trim(This.Content())

	  #======================================================#
	 #   TRIMMING LEFT / RIGHT                              #
	#======================================================#

	def TrimLeft()
		This.Update(ring_ltrim(This.Content()))

	def TrimmedLeft()
		return ring_ltrim(This.Content())

	def TrimRight()
		This.Update(ring_rtrim(This.Content()))

	def TrimmedRight()
		return ring_rtrim(This.Content())

	  #======================================================#
	 #   TRIMMING START / END                               #
	#======================================================#

	def TrimStart()
		This.TrimLeft()

	def TrimEnd()
		This.TrimRight()

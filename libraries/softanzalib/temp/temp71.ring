	def ReplaceNthOccurrenceCSQ(n, pcSubStr, pcNewSubStr, pCaseSensitive)
		#> @FunctionMetaOptions
			ActivateCache = FALSE
			MonitorExecutionTime = FALSE
			TraceExecutionTree = FALSE
			GenerateAlternativeNames = TRUE
			// Softanza Metacompiler reads a list of alternative english
			// names you want to give to your function, and generates
			// the alternative names section under the function block.

			GenerateMultilingualTranslations = FALSE
			// Softanea Metacompiler reads a translation file of the name
			// of the function, in languages other then english, and
			// generates translated names to it in ring code,
			// ready to be used.
		#>

		This.ReplaceNthOccurrenceCS(n, pcSubStr, pcNewSubStr, pCaseSensitive)
		return This

		#> @FunctionAlternativeForms
	
		def ReplaceNthCSQ(n, pcSubStr, pcNewSubStr, pCaseSensitive)
			return This.ReplaceNthOccurrenceCSQ(n, pcSubStr, pcNewSubStr, pCaseSensitive)
	
		#>

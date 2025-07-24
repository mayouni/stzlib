

	#-- Loading files files related to DATA wings modules (data modeling)

		load "../data/stzDataModelData.ring"
		load "data-wings/dataphore/stzDataModel.ring"

		load "data-wings/dataphore/stzDatabaseModel.ring"
		load "data-wings/dataphore/stzDatabasePerfEngine.ring"

	#-- Loading files files related to INTEGRATION wings modules

		load "integration-wings/excis/stzExtCodeTransFuncs.ring"
		load "integration-wings/excis/stzExtCodeXT.ring"
		load "integration-wings/excis/stzJuliaCode.ring"
		load "integration-wings/excis/stzPrologCode.ring"
		load "integration-wings/excis/stzPythonCode.ring"
		load "integration-wings/excis/stzRCode.ring"

	#-- Loading files files related to TURBO wings modules

		load "turbo-wings/geo/stzGeoMap.ring"

	#-- Loading files files related to INTERNATIONAL wings modules

		load "international-wings/stzCountry.ring"
		load "international-wings/stzCurrency.ring"
		load "international-wings/stzDate.ring"
		load "international-wings/stzLanguage.ring"
		load "international-wings/stzLocale.ring"
		load "international-wings/stzScript.ring"
		load "international-wings/stzStopWords.ring"
		load "international-wings/stzTime.ring"

	#-- Loading files files related to NATURAL wings modules

		load "natural-wings/stzEntity.ring"
		load "natural-wings/stzListOfEntities.ring"

		load "natural-wings/stzAdverb.ring"
		load "natural-wings/stzChainOfTruth.ring"
		load "natural-wings/stzChainOfValue.ring"
		load "natural-wings/stzConstraints.ring"

		load "natural-wings/stzNaturally.ring"
		load "natural-wings/stzNaturalCode.ring"
		load "natural-wings/stzPlural.ring"
		load "natural-wings/stzSingular.ring"
		load "natural-wings/stzText.ring"

	#-- Loading files files related to WEb wings modules

		load "web-wings/stzUrl.ring"

	#-- Loading files related to SECURITY wings modules

		load "security-wings/krypto/stzCrypto.ring"
		load "security-wings/krypto/stzCryptoString.ring"
		load "security-wings/krypto/stzCryptoFile.ring"

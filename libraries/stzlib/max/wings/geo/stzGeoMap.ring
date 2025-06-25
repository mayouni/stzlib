
$cDefaultMapType = :World
$acContinents = [ :Africa, :Asia, :Australia, :America, :Europe ]

$acCountriesByContinent = [
	:Africa = [
		:Tunisia, :Algeria, :Egypt, :Niger
	],

	:Europe = [
		:France, :Belgium
	]
]

@acTownsByCountry = [
	:Tunisia = [ :Tunis, :Sousse, :Nabeul, :Gafsa ]
]

class stzGeoMap
	@cType = $cDefaultMapType  # [ :World, :Continent, :Country ]
	@cName

	@acParts
	@acHilightedParts

	def init(pType)

		# Setting the main object of the map

		if isString(pType)

			if pType = "" or pType = :World
				@cType = :World

			but IsContinent(pType)
				@cType = :Continent
				@cName = pType

			but IsCountry(pType)
				@cType = :Country
				@cName = pType
			ok

		but isList(pType) and len(pType) = 2 and
		   isString(pType[1]) and isString(pType[2])

			if pType[1] = :World
				@cType = :World

			but IsContinent(pType[1])
				@cType = :Continent
				@cName = pType[1]

			but IsCountry(pType[1])
				@cType = :Country
				@cName = pType[1]
			ok
		ok

		# Setting the parts of the map

		if @cType  = :World
			@acParts = $acContinents

		but @cType = :Continent
			@acParts = $acCountriesByContinent[@cName]

		but @cType = :Country
			@acParts = $acTownsByCountry[@cName]
		ok

	# Hilight the given parts

	def Hilight(pacParts)
		
	# Generate the map image

	def Gen()

		def Generate()
			This.Gen()

	# View the map image

	def View()

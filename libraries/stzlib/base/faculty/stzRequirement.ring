#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V1.2) - STZREQUIREMENT                 #
#--------------------------------------------------------------#
#                                                              #
#   Description  : stzRequirement -- WHAT is needed, never      #
#                  WHICH model: the task, its types, a quality, #
#                  a latency and a memory budget, locality,     #
#                  languages, licence policy. The registry      #
#                  resolves it to implementations and explains  #
#                  itself. (Design: SOFTANZA_MODEL_FLOW.md 5.)  #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#

func StzRequirementQ(pcFaculty)
	return new stzRequirement(pcFaculty)

# the numeric meaning of the named qualities; a number may be given instead
func StzQualityLevel(pQuality)
	if isNumber(pQuality) return pQuality ok
	pQuality = lower("" + pQuality)
	if pQuality = "any"  return 0   ok
	if pQuality = "good" return 0.7 ok
	if pQuality = "best" return 0.9 ok
	stzraise("RequireQuality: :any, :good, :best or a number from 0 to 1 -- not '" + pQuality + "'.")

# States what a faculty is needed for, in quality, memory, languages, licence and determinism, and never which model.
#
# The registry resolves a requirement to an implementation and explains its choice. The requirement
# is a plain record read through Data. Quality, memory, languages, licence and determinism filter
# the models; the floor is never filtered. Latency and locality are recorded but the registry does
# not read them yet. A quality bar is checked against the score the registry measured on the golden
# set, a figure computed by the class and not judged by a person.
#
#   receiver   o1 = StzRequirementQ("position")
#   example    o1.RequireQualityQ(:good).RequireMemoryQ(500)
#              ? o1.Data()[:quality]
#              #--> 0.70
#              ? o1.Data()[:memory]
#              #--> 500
#              ? o1.Faculty()
#              #--> position
#   see        stzModelRegistry, stzFaculty
class stzRequirement from stzObject

	@cFaculty = ""
	@nQuality = 0
	@cLatency = "interactive"
	@nMemory = 0               # MB the implementation may hold resident; 0 = no stated budget
	@acLanguages = []
	@cLocality = "local"       # local (default) | allow-service
	@cLicence = "permissive"   # permissive (default) | any
	@bDeterministic = 0
	@bRefuseBelow = 0          # 1 = a plan that could only use the floor is a REFUSAL, not a fallback

	# Builds a requirement for a faculty, with the defaults: no quality bar, interactive, local, permissive licences.
	#
	#   pcFaculty   the name of the faculty the requirement is for, folded to lower case
	#   returns     nothing; the object is built
	#   note        a requirement states what is needed and never which model: the registry resolves
	#               it to an implementation
	#   see         StzRequirementQ, Data
	def init(pcFaculty)
		@cFaculty = lower(pcFaculty)

	# Returns the name of the faculty the requirement is for, in lower case.
	#
	#   returns    a text
	#   see        init, Data
	def Faculty()
		return @cFaculty

	# Returns the whole requirement as data, the form the registry resolves.
	#
	#   returns    a list of [ key, value ] pairs: faculty, quality, latency, memory, languages,
	#              locality, licence, deterministic, refusebelow
	#   note       defaults: quality 0, latency interactive, memory 0 (no budget), no languages,
	#              locality local, licence permissive, deterministic 0, refusebelow 0
	#   see        Resolve, RequireQuality
	def Data()
		return [ :faculty = @cFaculty, :quality = @nQuality, :latency = @cLatency, :memory = @nMemory,
			 :languages = @acLanguages, :locality = @cLocality, :licence = @cLicence,
			 :deterministic = @bDeterministic, :refusebelow = @bRefuseBelow ]

	# Sets the quality an implementation must have measured on the golden set to be chosen.
	#
	#   pQuality   any (0), good (0.7), best (0.9) or a number
	#   returns    nothing; use RequireQualityQ to chain
	#   note       the bar is checked against the measured score, a figure computed by the class
	#              from the goldens, not judged by a person; the floor is never filtered by it
	#   warning    any other word raises an error, but a number is not checked against the range 0
	#              to 1, so 1.5 is stored and no implementation can reach it
	#   see        RefuseBelowQuality, MeasurementOf, RunGoldens
	def RequireQuality(pQuality)
		@nQuality = StzQualityLevel(pQuality)

		def RequireQualityQ(pQuality)
			This.RequireQuality(pQuality)
			return This

	# Records the latency class wanted, interactive by default.
	#
	#   pcClass    the latency class as a word, folded to lower case, such as interactive or batch
	#   returns    nothing; use RequireLatencyQ to chain
	#   note       the word is kept as given and is not checked against a list
	#   warning    it is recorded in Data but the registry does not read it today, so it changes no
	#              choice; the design lists latency as a ranking criterion that is not built
	#   see        Data, RequireMemory
	def RequireLatency(pcClass)
		@cLatency = lower(pcClass)

		def RequireLatencyQ(pcClass)
			This.RequireLatency(pcClass)
			return This

	# Sets the memory budget, in MB, that an implementation may hold resident; 0 means no budget.
	#
	#   pnMB       the budget in megabytes
	#   returns    nothing; use RequireMemoryQ to chain
	#   note       the plan names each implementation rejected for size, with both figures
	#   warning    an implementation declaring more memory than the budget is rejected, and one
	#              declaring none always fits
	#   see        Data, RequireQuality
	def RequireMemory(pnMB)
		@nMemory = pnMB

		def RequireMemoryQ(pnMB)
			This.RequireMemory(pnMB)
			return This

	# Sets the languages the chosen implementation must cover.
	#
	#   pacLanguages   a list of language codes such as fr and ar
	#   returns        nothing; use RequireLanguagesQ to chain
	#   note           an empty list asks for nothing
	#   warning        a text passed instead of a list is stored as given and read letter by letter,
	#                  so give a list
	#   see            Data, RequireLicence
	def RequireLanguages(pacLanguages)
		@acLanguages = pacLanguages

		def RequireLanguagesQ(pacLanguages)
			This.RequireLanguages(pacLanguages)
			return This

	# Records whether a service may be used, local by default.
	#
	#   pcLocality   local or allow-service, folded to lower case
	#   returns      nothing; use RequireLocalityQ to chain
	#   note         the word is kept as given and is not checked against a list
	#   warning      it is recorded in Data but the registry does not read it today: a service is
	#                never chosen implicitly whatever the value, and is reached only by pinning it
	#                by name
	#   see          Data, RequireLicence
	def RequireLocality(pcLocality)
		@cLocality = lower(pcLocality)

		def RequireLocalityQ(pcLocality)
			This.RequireLocality(pcLocality)
			return This

	# Sets the licence policy: permissive keeps only permissive licences, any other word lifts the filter.
	#
	#   pcPolicy   permissive or any, folded to lower case
	#   returns    nothing; use RequireLicenceQ to chain
	#   note       permissive means apache-2.0, mit, bsd-3-clause, bsd-2-clause, isc, n/a and
	#              cc0-1.0
	#   warning    any word other than permissive lifts the filter, spelling mistakes included; an
	#              implementation that never stated its licence counts as not permissive
	#   see        Data, RequireLanguages
	def RequireLicence(pcPolicy)
		@cLicence = lower(pcPolicy)

		def RequireLicenceQ(pcPolicy)
			This.RequireLicence(pcPolicy)
			return This

	# Asks for implementations that reproduce their answer: a non-deterministic one is rejected.
	#
	#   returns    nothing; use RequireDeterminismQ to chain
	#   note       an implementation counts as deterministic unless its specification says
	#              :deterministic = 0
	#   see        RefuseBelowQuality, Data
	def RequireDeterminism()
		@bDeterministic = 1

		def RequireDeterminismQ()
			This.RequireDeterminism()
			return This

	# Makes the resolution a refusal when no model qualifies, instead of letting the floor answer.
	#
	#   returns    nothing; use RefuseBelowQualityQ to chain
	#   note       the refusal carries a below-quality finding naming the faculty
	#   see        RequireQuality, Resolve
	def RefuseBelowQuality()
		@bRefuseBelow = 1

		def RefuseBelowQualityQ()
			This.RefuseBelowQuality()
			return This

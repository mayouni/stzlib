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

	def init(pcFaculty)
		@cFaculty = lower(pcFaculty)

	def Faculty()
		return @cFaculty

	def Data()
		return [ :faculty = @cFaculty, :quality = @nQuality, :latency = @cLatency, :memory = @nMemory,
			 :languages = @acLanguages, :locality = @cLocality, :licence = @cLicence,
			 :deterministic = @bDeterministic, :refusebelow = @bRefuseBelow ]

	def RequireQuality(pQuality)
		@nQuality = StzQualityLevel(pQuality)

		def RequireQualityQ(pQuality)
			This.RequireQuality(pQuality)
			return This

	def RequireLatency(pcClass)
		@cLatency = lower(pcClass)

		def RequireLatencyQ(pcClass)
			This.RequireLatency(pcClass)
			return This

	def RequireMemory(pnMB)
		@nMemory = pnMB

		def RequireMemoryQ(pnMB)
			This.RequireMemory(pnMB)
			return This

	def RequireLanguages(pacLanguages)
		@acLanguages = pacLanguages

		def RequireLanguagesQ(pacLanguages)
			This.RequireLanguages(pacLanguages)
			return This

	def RequireLocality(pcLocality)
		@cLocality = lower(pcLocality)

		def RequireLocalityQ(pcLocality)
			This.RequireLocality(pcLocality)
			return This

	def RequireLicence(pcPolicy)
		@cLicence = lower(pcPolicy)

		def RequireLicenceQ(pcPolicy)
			This.RequireLicence(pcPolicy)
			return This

	def RequireDeterminism()
		@bDeterministic = 1

		def RequireDeterminismQ()
			This.RequireDeterminism()
			return This

	def RefuseBelowQuality()
		@bRefuseBelow = 1

		def RefuseBelowQualityQ()
			This.RefuseBelowQuality()
			return This

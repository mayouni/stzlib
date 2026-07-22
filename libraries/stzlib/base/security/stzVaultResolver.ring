#--------------------------------------------------------------#
#          SOFTANZA LIBRARY (V0.9) - STZVAULTRESOLVER          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#
# The SEAM between a stzSecret's :vault source and an external secret manager
# (HashiCorp Vault, AWS Secrets Manager, a cloud KMS, ...). Softanza does not
# bind to any one backend; it defines the CONTRACT and hands you a reference
# implementation.
#
# THE CONTRACT: a vault resolver is any object exposing
#     Resolve(pcLocator) -> the secret value  (raise if absent)
#   and, ideally, Has(pcLocator) -> bool.
#
# A vault-sourced secret is fetched THROUGH a resolver, passed by reference at
# reveal time (so nothing holds a live backend handle it might leak or stale):
#
#     oKey = new stzSecret("db").FromVaultQ("secret/data/prod/db#password")
#     oKey.RevealVia(oResolver, oActor)     # gated on the actor, fetched via oResolver
#
# stzVaultResolver below is an IN-MEMORY reference resolver: seed it for dev and
# tests, and it satisfies the contract. In production you REPLACE it with your
# own object (subclass this, or supply any object with Resolve/Has) that calls
# your real vault -- the secret, the store, and the actor gate do not change.

  #=============#
 #  FUNCTIONS  #
#=============#

func StzVaultResolverQ(pcName)
	return new stzVaultResolver(pcName)


  #====================#
 #  STZVAULTRESOLVER   #
#====================#

class stzVaultResolver from stzObject

	@cName = ""
	@aEntries = []   # [ [ locator, value ], ... ]  -- in-memory stand-in for a real vault

	def init(pcName)
		@cName = "" + pcName

	def Name()
		return @cName

	# seed a value under a vault locator (dev/test). A real resolver would FETCH
	# from the external manager instead of holding values here.
	def Register(pcLocator, pcValue)
		_l_ = "" + pcLocator
		_i_ = This._Index(_l_)
		if _i_ > 0
			@aEntries[_i_][2] = "" + pcValue
		else
			@aEntries + [ _l_, "" + pcValue ]
		ok
		return This

	def Has(pcLocator)
		return This._Index("" + pcLocator) > 0

	def NumberOfEntries()
		return len(@aEntries)

	# THE CONTRACT METHOD: given a vault locator, return its value; raise if the
	# vault has no such entry. Replace this body with a call to your vault client.
	def Resolve(pcLocator)
		_i_ = This._Index("" + pcLocator)
		if _i_ = 0
			StzRaise("stzVaultResolver '" + @cName + "': no entry for '" + pcLocator + "'.")
		ok
		return @aEntries[_i_][2]

	def Show()
		? "Vault resolver '" + @cName + "': " + len(@aEntries) + " entry/entries"
		_n_ = len(@aEntries)
		for _i_ = 1 to _n_
			? "  " + @aEntries[_i_][1] + " -> ********"   # locators shown, values never
		next

	def _Index(pcLocator)
		_n_ = len(@aEntries)
		for _i_ = 1 to _n_
			if @aEntries[_i_][1] = pcLocator
				return _i_
			ok
		next
		return 0

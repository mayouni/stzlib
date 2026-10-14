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

# Holds an in-memory reference vault resolver, the contract between a vault-sourced secret and an external secret manager.
#
# A vault resolver is any object with Resolve(locator), which returns the value or raises, and
# ideally Has(locator). A secret whose source is a vault is fetched through one, passed at reveal
# time to RevealVia, so nothing holds a live backend handle. This class satisfies the contract for
# development and tests: you seed it with values. In production replace it with an object that calls
# your real vault, such as stzVaultHttpResolver; the secret, the store and the actor gate do not
# change. Locators are written path#field.
#
#   receiver   o1 = new stzVaultResolver("dev-vault")
#   example    o1.Register("secret/data/prod/db#password", "invented-db-pass")
#              ? o1.Has("secret/data/prod/db#password")
#              #--> 1
#              ? o1.Resolve("secret/data/prod/db#password")
#              #--> invented-db-pass
#              ? o1.NumberOfEntries()
#              #--> 1
#   see        stzVaultHttpResolver, stzSecret, stzSecretStore
class stzVaultResolver from stzObject

	@cName = ""
	@aEntries = []   # [ [ locator, value ], ... ]  -- in-memory stand-in for a real vault

	# Builds an empty in-memory vault resolver with a name, the reference stand-in for a real secret manager.
	#
	#   pcName     the resolver's name, quoted in its messages
	#   returns    nothing; the object is built
	#   see        Register, Resolve
	def init(pcName)
		@cName = "" + pcName

	# Returns the name the resolver was built with.
	#
	#   returns    a text
	#   see        init
	def Name()
		return @cName

	# Seeds a value under a vault locator, replacing the value already there.
	#
	#   pcLocator   the locator, a path and a field joined by #, such as
	#               secret/data/prod/db#password
	#   pcValue     the secret value
	#   returns     the resolver itself, so calls chain
	#   note        for development and tests only: the value is held in memory in clear, and a real
	#               resolver fetches it from the vault instead; use invented values
	#   see         Resolve, Has
	#@ aka  seed a value under a vault locator (dev/test). A real resolver would FETCH from the external manager instead of holding values here.
	def Register(pcLocator, pcValue)
		_l_ = "" + pcLocator
		_i_ = This._Index(_l_)
		if _i_ > 0
			@aEntries[_i_][2] = "" + pcValue
		else
			@aEntries + [ _l_, "" + pcValue ]
		ok
		return This

	# TRUE if a value is registered under that exact locator.
	#
	#   pcLocator   the locator to look for
	#   returns     TRUE or FALSE
	#   note        the match is exact, case and field included
	#   see         Register, Resolve
	def Has(pcLocator)
		return This._Index("" + pcLocator) > 0

	# Returns how many locators hold a value.
	#
	#   returns    a number
	#   see        Register
	def NumberOfEntries()
		return len(@aEntries)

	# Returns the value registered under a locator; this is the method the vault contract asks of every resolver.
	#
	#   pcLocator   the locator to read
	#   returns     a text, the secret value
	#   note        the locator is quoted in the error as given, so show the message as text and not
	#               as markup; the reveal itself is gated by the secret that calls RevealVia
	#   warning     raises an error naming the resolver and the locator when nothing is registered
	#               there
	#   see         Has, Register
	#@ aka  THE CONTRACT METHOD: given a vault locator, return its value; raise if the vault has no such entry. Replace this body with a call to your vault client.
	def Resolve(pcLocator)
		_i_ = This._Index("" + pcLocator)
		if _i_ = 0
			StzRaise("stzVaultResolver '" + @cName + "': no entry for '" + pcLocator + "'.")
		ok
		return @aEntries[_i_][2]

	# Prints the resolver's name and entry count, then each locator with its value masked.
	#
	#   returns    nothing; it prints
	#   note       values are never printed
	#   see        NumberOfEntries
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

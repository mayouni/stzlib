#---------------------------------#
#  SOFTANZA CORE GLOBAL SETTINGS  #
#---------------------------------#

# Parameter checking (can be disabled for performance in loops)
_bParamCheck = 1

func CheckingParams()
	return _bParamCheck

func SetParamCheckingTo(bValue)
	_bParamCheck = bValue

# Early checking (preliminary validations before heavy operations)
_bEarlyCheck = 1

func EarlyChecking()
	return _bEarlyCheck

func SetEarlyCheckingTo(bValue)
	_bEarlyCheck = bValue

# Softanza version
$SOFTANZA_VERSION = "0.9"
$SOFTANZALOGO = "Softanza v" + $SOFTANZA_VERSION + " - Programming, by Heart!"

# Ring type constants
_TRUE  = 1
_FALSE = 0

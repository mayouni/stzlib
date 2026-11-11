#---------------------------------#
#  SOFTANZA CORE GLOBAL SETTINGS  #
#---------------------------------#

# Parameter checking (can be disabled for performance in loops)
$bParamCheck = 1

func CheckingParams()
	return $bParamCheck

func SetParamCheckingTo(bValue)
	$bParamCheck = bValue

# Early checking (preliminary validations before heavy operations)
$_bEarlyCheck = 1

func EarlyChecking()
	return $_bEarlyCheck

func SetEarlyCheckingTo(bValue)
	$_bEarlyCheck = bValue

# Softanza version
$SOFTANZA_VERSION = "0.9"
$SOFTANZALOGO = "Softanza v" + $SOFTANZA_VERSION + " - Programming, by Heart!"

# Ring type constants
_TRUE  = 1
_FALSE = 0

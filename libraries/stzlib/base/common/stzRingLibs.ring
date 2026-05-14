
# Loading additional Ring libs required by Softanza Base layer
#NOTE Core layer already has "../../core/common/stkRingLibs.ring"

# Load Base Engine bridges (stz_* DLLs -- superset of Core stk_* DLLs)

$cEnginePath = exefolder() + "/../libraries/stzlib/engine"

chdir($cEnginePath)
load "stz_string.ring"
load "stz_datetime.ring"
load "stz_file.ring"
load "stz_locale.ring"
chdir(exefolder())

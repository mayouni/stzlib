
# Loading additional Ring libs required by Softanza Base layer
#NOTE Core layer already has "../../core/common/stkRingLibs.ring"

# Load Base Engine bridges (stz_* DLLs -- superset of Core stk_* DLLs)

load "../../engine/stz_string.ring"
load "../../engine/stz_datetime.ring"
load "../../engine/stz_file.ring"
load "../../engine/stz_locale.ring"
load "../../engine/stz_unicode.ring"
load "../../engine/stz_regex.ring"
load "../../engine/stz_bytes.ring"
load "../../engine/stz_json.ring"
load "../../engine/stz_url.ring"
load "../../engine/stz_system.ring"
load "../../engine/stzMeta.ring"

# Initialize the meta-engine (named params, error catalog, aliases)
StzMetaInit()

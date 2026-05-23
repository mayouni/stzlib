
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
load "../../engine/stz_value.ring"
load "../../engine/stz_number.ring"
load "../../engine/stz_list.ring"
load "../../engine/stz_hashmap.ring"
load "../../engine/stz_table.ring"
load "../../engine/stz_matrix.ring"
load "../../engine/stz_unidata.ring"
load "../../engine/stz_random.ring"
load "../../engine/stz_csv.ring"
load "../../engine/stz_stats.ring"
load "../../engine/stz_graph.ring"
load "../../engine/stzMeta.ring"

# Initialize the meta-engine (named params, error catalog, aliases)
StzMetaInit()

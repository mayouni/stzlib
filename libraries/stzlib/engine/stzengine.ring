# Softanza Engine -- All-in-One FFI Bridge
#
# Convenience loader: loads all per-domain Engine bridges.
# Use this when you want every Engine module available.
# For selective loading, load individual bridges instead:
#   load "engine/stz_string.ring"     # string + char only
#   load "engine/stz_datetime.ring"   # date + time + datetime only
#   load "engine/stz_file.ring"       # file + dir + path only
#   load "engine/stz_locale.ring"     # locale only
#   load "engine/stz_regex.ring"      # regex only
#   load "engine/stz_bytes.ring"      # byte array only
#   load "engine/stz_json.ring"       # JSON only
#   load "engine/stz_url.ring"        # URL only
#   load "engine/stz_system.ring"     # system/process only
#   load "engine/stz_unicode.ring"    # unicode properties/case/normalize only

load "stz_string.ring"
load "stz_datetime.ring"
load "stz_file.ring"
load "stz_locale.ring"
load "stz_regex.ring"
load "stz_bytes.ring"
load "stz_json.ring"
load "stz_url.ring"
load "stz_system.ring"
load "stz_unicode.ring"

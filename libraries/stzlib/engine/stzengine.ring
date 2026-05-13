# Softanza Engine -- All-in-One FFI Bridge
#
# Convenience loader: loads all per-domain Engine bridges.
# Use this when you want every Engine module available.
# For selective loading, load individual bridges instead:
#   load "engine/stz_string.ring"     # string + char only
#   load "engine/stz_datetime.ring"   # date + time + datetime only
#   load "engine/stz_file.ring"       # file + dir + path only
#   load "engine/stz_locale.ring"     # locale only

load "stz_string.ring"
load "stz_datetime.ring"
load "stz_file.ring"
load "stz_locale.ring"

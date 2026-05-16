# Softanza Library Loader
#
# Usage:
#   load "stzlib.ring"              -> Loads BASE layer (default)
#   $STZ_LAYER = :core  load "..."  -> Loads CORE layer only
#   $STZ_LAYER = :max   load "..."  -> Loads MAX layer (includes Base + Core)
#
# Architecture: Core (stk*) -> Base (stz*) -> Max (stx*)

if NOT isGlobal(:$STZ_LAYER)
    $STZ_LAYER = :base
ok

if $STZ_LAYER = :core
    load "core/stzcore.ring"

but $STZ_LAYER = :max
    load "max/stzmax.ring"

else
    load "base/stzbase.ring"

ok

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

switch $STZ_LAYER

on :core
    load "core/stzcore.ring"

on :base
    load "base/stzbase.ring"

on :max
    load "max/stzmax.ring"

other
    load "base/stzbase.ring"

off

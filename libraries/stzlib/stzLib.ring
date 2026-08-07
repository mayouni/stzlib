# Softanza Library -- BASE layer loader
#
# Usage:
#   load "stzlib.ring"          -> Loads the BASE layer (stz*), and CORE under it
#
# The other two layers have their own entry files, because a layer is chosen
# by WHICH FILE you load, not by a flag:
#
#   load "core/stkLib.ring"     -> CORE only  (stk*) -- lean, portable
#   load "max/stxLib.ring"      -> MAX        (stx*) -- includes BASE and CORE
#
# Architecture: Core (stk*) -> Base (stz*) -> Max (stx*)
#
# WHY THERE IS NO $STZ_LAYER
# ---------------------------
# This file used to read a $STZ_LAYER global and `load` one of three layer
# files from an if/but/else. That could never work, and never did: Ring's
# `load` is a COMPILE-TIME directive, not a runtime statement. The compiler
# pulls in every `load` it sees while parsing the file, whatever branch it
# sits in and whatever the condition would evaluate to at runtime. So all
# three layers were loaded on every `load "stzlib.ring"`, and setting
# $STZ_LAYER = :core changed nothing.
#
# Worse, it made the failure of ONE layer the failure of ALL of them: max/
# did not parse, so `load "stzlib.ring"` did not parse either -- even for a
# caller who only ever wanted BASE.
#
# The global is gone rather than kept as a no-op, because nothing outside
# this file ever read it, and a flag that silently does nothing is the part
# that misleads.
#
# A NOTE ON PATHS
# ---------------
# Ring resolves a relative `load` against the directory of the file that
# contains it, but it keys its already-loaded set on the literal path text.
# Reaching the same file under two different spellings therefore loads it
# TWICE and ends in `C22: Function redefinition`. Load this file by one
# consistent path (see bin/load/stzlib.ring for the installed shim).

    load "base/stzBase.ring"

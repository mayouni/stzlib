# Softanza Engine -- Constraint Validation
#
# Loads stz_constraint.dll for declarative constraints + violation tracking.
#
# Function prefix: StzEngineConstraint*

if isWindows()
    $cStzConstraintLib = $cEngineDir + "/zig-out/bin/stz_constraint.dll"
but isLinux()
    $cStzConstraintLib = $cEngineDir + "/zig-out/lib/libstz_constraint.so"
but isMacOS()
    $cStzConstraintLib = $cEngineDir + "/zig-out/lib/libstz_constraint.dylib"
ok

# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("constraint")
    $pStzConstraintHandle = NULL
but fexists($cStzConstraintLib)
    $pStzConstraintHandle = LoadLib($cStzConstraintLib)
else
    ? "WARNING: stz_constraint not found at: " + $cStzConstraintLib
    $pStzConstraintHandle = NULL
ok

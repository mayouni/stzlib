# Softanza Engine -- Numerical Solver
#
# Loads stz_solver.dll for equation solving, interpolation, integration.
#
# Function prefix: StzEngineSolver*

if isWindows()
    $cStzSolverLib = $cEngineDir + "/zig-out/bin/stz_solver.dll"
but isLinux()
    $cStzSolverLib = $cEngineDir + "/zig-out/lib/libstz_solver.so"
but isMacOS()
    $cStzSolverLib = $cEngineDir + "/zig-out/lib/libstz_solver.dylib"
ok

if fexists($cStzSolverLib)
    $pStzSolverHandle = LoadLib($cStzSolverLib)
else
    ? "WARNING: stz_solver not found at: " + $cStzSolverLib
    $pStzSolverHandle = NULL
ok

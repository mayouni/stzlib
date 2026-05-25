# Softanza Engine -- Skill Engine
#
# Loads stz_skill.dll for skill tracking and assessment.
#
# Function prefix: StzEngineSkill*

if isWindows()
    $cStzSkillLib = $cEngineDir + "/zig-out/bin/stz_skill.dll"
but isLinux()
    $cStzSkillLib = $cEngineDir + "/zig-out/lib/libstz_skill.so"
but isMacOS()
    $cStzSkillLib = $cEngineDir + "/zig-out/lib/libstz_skill.dylib"
ok
if fexists($cStzSkillLib)
    $pStzSkillHandle = LoadLib($cStzSkillLib)
else
    ? "WARNING: stz_skill not found at: " + $cStzSkillLib
    $pStzSkillHandle = NULL
ok

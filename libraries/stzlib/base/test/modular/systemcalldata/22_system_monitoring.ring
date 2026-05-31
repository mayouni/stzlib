# Narrative
# --------
# SYSTEM MONITORING
#
# Extracted from stzsystemcalldatatest.ring, block #22.

load "../../../stzBase.ring"

==========================================

pr()

? "=== SYSTEM INFO ==="
? new stzSystemCall(:SystemInfo).Run()

? NL + "=== DISK SPACE ==="
? new stzSystemCall(:DiskSpace).Run()

? NL + "=== MEMORY ==="
? new stzSystemCall(:MemoryUsage).Run()

? NL + "=== CPU ==="
? new stzSystemCall(:CpuInfo).Run()

pf()

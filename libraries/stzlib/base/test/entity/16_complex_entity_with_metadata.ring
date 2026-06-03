# Narrative
# --------
# Complex entity with metadata
#
# Extracted from stzentitytest.ring, block #16.

load "../../stzBase.ring"

pr()

oComplexEntity = new stzEntity([
    :name = "server01",
    :type = "computer",
    :ip = "192.168.1.100",
    :os = "linux",
    :memory = "32GB",
    :status = "active",
    :owner = "IT Department"
])

? oComplexEntity.Size()
#--> 8

? oComplexEntity.ContainsValue("linux")
#--> 1

oComplexEntity.Show()
#-->
# Entity: server01 (Type: computer)
#   created: 2025-09-26 14:30:15
#   ip: 192.168.1.100
#   os: linux
#   memory: 32GB
#   status: active
#   owner: IT Department

pf()

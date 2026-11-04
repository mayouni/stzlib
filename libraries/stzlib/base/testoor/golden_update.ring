# Rewrites every expected file of the golden logbooks from their committed inputs
# (golden/README.md). Run it from this folder, then READ the diff in git against what
# each case was meant to show: the reference is the oracle and the human is the check.
#
#   rnxc golden_update.ring
#
load "../stzBase.ring"

? "wrote " + TestoorGoldenUpdate(currentdir() + "/golden") + " expected files"

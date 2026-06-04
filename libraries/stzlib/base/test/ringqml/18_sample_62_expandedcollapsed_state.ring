# Narrative
# --------
# (retired) Original test for: Sample 6.2: Expanded/Collapsed State depended on Ring's qApp{} + RingQML Qt
# binding. Softanza is now engine-only and does NOT ship that
# binding. The same end -- 'render this QML markup as a window' --
# is now expressed via the external-runtime pattern, mirroring
# stzDotCode (Graphviz).
#
# Replacement skeleton:
#
#   load "../../stzBase.ring"
#
#   pr()
#
#   oQml = new stzQmlCode()
#   oQml.SetCode("
#       import QtQuick 2.15
#       import QtQuick.Window 2.15
#       Window {
#           visible: true; width: 450; height: 300; title: 'Hello'
#       }
#   ")
#   oQml.Execute()
#   ? oQml.Duration()
#
#   pf()
#
# The standalone Qt `qml` (or `qmlscene`) runtime is invoked as a
# child process. Configure its path via
# $aStzLibConfig[:QmlPath] = "...".
#
# Skip annotation so the runner doesn't flag this as a real error.
#SKIP retired -- depends on Ring's qApp Qt binding; use stzQmlCode

load "../../stzBase.ring"

? "(retired Qt-binding test; see header for the stzQmlCode replacement)"

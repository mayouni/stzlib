# THE GUI PLANE -- the widget, layout and interaction layer.
#
# Plan of record: base/gui/SOFTANZA_GUI_PLAN.md. The survey that chose the
# engine: D:\GitHub\stzzui\doc\GUI-SYSTEM.md.
#
# THIS FILE IS A LOADER, AND THAT IS DELIBERATE. There is no class named
# stzGui and there may not be one -- §2.5 of the plan. `stzGui` and
# `StzZui` differ by one letter and name two adjacent layers of one stack
# that will appear in the same sentence forever; the confusable token is a
# CLASS name, not a directory, so the collision is dissolved at its source
# rather than renamed around. This plane has no god-class to need one.
# Classes here are named for what they are.
#
# WHERE THIS SITS. stzWindow drew the boundary itself: "it is not a widget
# toolkit. There are no buttons, no layout, no menus. It is a rectangle
# that shows what the graphics plane computes and reports what the user
# did -- which is the part a graphics engine owes; the rest is a different
# product." This is that different product.
#
#     the law, the meanings, the refusals ....... StzZui  (not here)
#     the widget tree, layout, interaction ...... HERE
#     canvas, text, textures, windows ........... base/graphics/
#     triangles on a device ..................... the GPU plane
#
# The plane consumes contracts it does not compute. If a class here ever
# grows a :Danger, the layering has collapsed.

load "stzPanel.ring"
load "stzUiProfile.ring"
load "stzUiDocument.ring"
load "stzAccessibilityTree.ring"
load "stzScenePanel.ring"
load "stzScreenReaderBridge.ring"
load "stzUiBindings.ring"

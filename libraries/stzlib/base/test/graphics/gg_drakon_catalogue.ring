load "../../stzBase.ring"
load "gg_drakon_scenes.ring"

/*---------------------------------------------------------------------------
	DN6 -- THE CATALOGUE, drawn against the book's own figures

	The Principal asked for a catalogue covering most of the examples in
	DRAKON: The Human Revolution in Understanding Programs (S. Mitkin,
	2011), so that mastery of the discipline is something SHOWN rather
	than claimed. Each scene below names the figure or the rule it comes
	from, and each is a construct the language has -- not a construct
	this plane found convenient.

	WHAT IS DELIBERATELY ABSENT. Four of the book's figures -- 13, 15,
	20 (left half) and 24 -- exist to show what must NOT be drawn:
	illegal joinings, an arrow pointing at an icon, a Switch with an
	icon between the Select and its Cases. A conformant engine cannot
	produce them, and a catalogue that faked them to look complete would
	be demonstrating the opposite of the thing being demonstrated. They
	are named here instead, and the rules they teach are enforced in
	gg_adversarial's sections 73k through 73v.

	Run:  ring gg_drakon_catalogue.ring
---------------------------------------------------------------------------*/

decimals(2)
FONT = new stzFont("C:/Windows/Fonts/segoeui.ttf")
OPT = [ :Font = FONT, :NodeWidth = 150, :NodeHeight = 56, :FontSize = 20 ]
SIL = [ :Font = FONT, :NodeWidth = 150, :NodeHeight = 56, :FontSize = 20,
        :LayoutMode = :Silhouette ]

? "=============================================================="
? " DN6 -- THE DRAKON CATALOGUE"
? "=============================================================="

#-- 01. Fig 1 -- the simplest diagram ---------------------------------------
#   "The simplest DRAKON diagram." A Title, one Action, an End: entry at
#   the top, exit at the bottom, and one straight skewer between them.
c01 = StzDrakonScene01(OPT)
c01.LastCanvas().ToPNG("cat_01_simplest.png")
? "  01 simplest            " + c01.LastCanvas().Width() + "x" +
  c01.LastCanvas().Height()

#-- 02. Fig 11 -- the If icon ------------------------------------------------
#   "The If icon has one entry, but two exits. The central exit comes out
#   of the bottom of the icon, the right exit comes out of its right
#   side. Placing an exit on the left side is not allowed."
c02 = StzDrakonScene02(OPT)
c02.LastCanvas().ToPNG("cat_02_the_if.png")
? "  02 the If icon         " + c02.LastCanvas().Width() + "x" +
  c02.LastCanvas().Height()

#-- 03. Fig 8 -- the rule of secondary routes -------------------------------
#   "The rule of secondary routes: the further to the right -- the worse
#   it is." Three refusals at three depths, and the outermost is the
#   worst thing that can happen.
c03 = StzDrakonScene03(OPT)
c03.LastCanvas().ToPNG("cat_03_secondary_routes.png")
? "  03 secondary routes    " + c03.LastCanvas().Width() + "x" +
  c03.LastCanvas().Height()

#-- 04. Fig 16 -- the Insertion icon ----------------------------------------
#   "The Insertion icon is the DRAKON notation for calling another
#   DRAKON diagram as a sub-routine."
c04 = StzDrakonScene04(OPT)
c04.LastCanvas().ToPNG("cat_04_insertion.png")
? "  04 the Insertion       " + c04.LastCanvas().Width() + "x" +
  c04.LastCanvas().Height()

#-- 05. Fig 17 -- the For loop ----------------------------------------------
#   "The For icon is actually two icons: Begin For and End For. The code
#   that runs several times is represented by the icons placed between
#   the Begin For and End For icons."
c05 = StzDrakonScene05(OPT)
c05.LastCanvas().ToPNG("cat_05_for_loop.png")
? "  05 the For loop        " + c05.LastCanvas().Width() + "x" +
  c05.LastCanvas().Height()

#-- 06. Fig 18 -- a For loop with an early exit -----------------------------
#   "The Begin For icon is the only single entry into the loop body.
#   There can be several additional, early exits from the loop body.
#   Early exits come from the conditional icons: If and Switch."
c06 = StzDrakonScene06(OPT)
c06.LastCanvas().ToPNG("cat_06_for_early_exit.png")
? "  06 For + early exit    " + c06.LastCanvas().Width() + "x" +
  c06.LastCanvas().Height()

#-- 07. Fig 19a -- the while loop (Question - Action) -----------------------
#   "The If icon can organize a loop in three ways: 1. Question - Action.
#   This is similar to the while loop in programming languages."
c07 = StzDrakonScene07(OPT)
c07.LastCanvas().ToPNG("cat_07_while.png")
? "  07 while loop          " + c07.LastCanvas().Width() + "x" +
  c07.LastCanvas().Height()

#-- 08. Fig 19b -- the do-until loop (Action - Question) --------------------
#   "2. Action - Question. This is similar to the do-until loop."
c08 = StzDrakonScene08(OPT)
c08.LastCanvas().ToPNG("cat_08_do_until.png")
? "  08 do-until loop       " + c08.LastCanvas().Width() + "x" +
  c08.LastCanvas().Height()

#-- 09. Fig 19c -- the hybrid loop (Action - Question - Action) -------------
#   "3. Action - Question - Action. This one is called the hybrid loop."
c09 = StzDrakonScene09(OPT)
c09.LastCanvas().ToPNG("cat_09_hybrid.png")
? "  09 hybrid loop         " + c09.LastCanvas().Width() + "x" +
  c09.LastCanvas().Height()

#-- 10. Fig 23 -- the Switch construct --------------------------------------
#   "The Switch construct consists of: one Select icon that contains a
#   question, and two or more Case icons holding possible answers."
c10 = StzDrakonScene10(OPT)
c10.LastCanvas().ToPNG("cat_10_switch.png")
? "  10 the Switch          " + c10.LastCanvas().Width() + "x" +
  c10.LastCanvas().Height()

#-- 11. Fig 25 -- the Switch loop -------------------------------------------
#   "The rightmost Case icons can lead to some place above the Case icon
#   and form a cycle. This construct is called the Switch loop."
c11 = StzDrakonScene11(OPT)
c11.LastCanvas().ToPNG("cat_11_switch_loop.png")
? "  11 the Switch loop     " + c11.LastCanvas().Width() + "x" +
  c11.LastCanvas().Height()

#-- 12. Fig 27/28 -- visual logic: AND on the skewer ------------------------
#   "Rule: For AND, put the if icons on the skewer. For OR, arrange the
#   if icons as stair steps." Buying only when BOTH hold.
c12 = StzDrakonScene12(OPT)
c12.LastCanvas().ToPNG("cat_12_logic_and.png")
? "  12 visual AND          " + c12.LastCanvas().Width() + "x" +
  c12.LastCanvas().Height()

#-- 13. Fig 28 -- visual logic: OR as stair steps ---------------------------
#   The mirror pattern: any one of the tests is enough, so the ifs step
#   to the right and their affirmative exits gather on one line.
c13 = StzDrakonScene13(OPT)
c13.LastCanvas().ToPNG("cat_13_logic_or.png")
? "  13 visual OR           " + c13.LastCanvas().Width() + "x" +
  c13.LastCanvas().Height()

#-- 14. Fig 2/4 -- branches and the header ----------------------------------
#   "The branch names together with the Begin label are placed in the
#   header of the diagram, which ensures that the summary of the diagram
#   can always be found at the same place." The book's own lunch.
c14 = StzDrakonScene14(SIL)
c14.LastCanvas().ToPNG("cat_14_cook_lunch.png")
? "  14 branches (lunch)    " + c14.LastCanvas().Width() + "x" +
  c14.LastCanvas().Height()

#-- 15. Fig 26 -- the branch loop -------------------------------------------
#   "The next branch can be the same branch or some branch to the left if
#   the intention is to repeat some sequence of actions. The latter case
#   is called the branch loop."
c15 = StzDrakonScene15(SIL)
c15.LastCanvas().ToPNG("cat_15_branch_loop.png")
? "  15 the branch loop     " + c15.LastCanvas().Width() + "x" +
  c15.LastCanvas().Height()

#-- 16. The Principal's own sample: advanceStep -----------------------------
#   A Switch whose cases each carry their own nested Ifs -- the hardest
#   shape in the set, and the one he supplied alongside its JavaScript.
c16 = StzDrakonScene16(OPT)
c16.LastCanvas().ToPNG("cat_16_advance_step.png")
? "  16 advanceStep         " + c16.LastCanvas().Width() + "x" +
  c16.LastCanvas().Height()

#-- 17. The Principal's own sample: NumberToString --------------------------
#   The smallest Switch there is: four answers, four one-line bodies.
c17 = StzDrakonScene17(OPT)
c17.LastCanvas().ToPNG("cat_17_number_to_string.png")
? "  17 NumberToString      " + c17.LastCanvas().Width() + "x" +
  c17.LastCanvas().Height()

#-- 18. The icon set --------------------------------------------------------
#   Every icon this profile draws, on one skewer, so a reader can check
#   the glyphs against the language's own table rather than against a
#   description of it.
c18 = StzDrakonScene18(OPT)
c18.LastCanvas().ToPNG("cat_18_icons.png")
? "  18 the icon set        " + c18.LastCanvas().Width() + "x" +
  c18.LastCanvas().Height()

#-- 19. THE SHELF AND THE INSERTION AT WORK ---------------------------------
#   The last two icons of the table this profile had been approximating.
#
#   The INSERTION is a call to another diagram, and DRAKON rules the box
#   once near each end -- the shape every notation has used for a
#   sub-routine since before flowcharts were printed. This profile had
#   reached for UML's COMPONENT because it was the nearest thing already
#   drawn, and left a comment saying so; a component reads as a
#   deployable part rather than a call, and its tabs sit OUTSIDE the
#   body, so a wire arriving at the left border met a tab.
#
#   The SHELF is a box ruled once across the middle holding two texts:
#   what is produced above the rule, and how it is produced below. That
#   is a two-compartment node and this plane already draws one for a UML
#   class -- so the shelf needed no glyph of its own, only the right to
#   NAME its second compartment. The compartment reader had UML's two
#   property names written into it, which is the same enumerated-list
#   fault as the four layout modes and the one shape called "diamond",
#   met a third time in a week.
c19 = StzDrakonScene19(OPT)
c19.LastCanvas().ToPNG("cat_19_shelf_insertion.png")
? "  19 shelf and insertion " + c19.LastCanvas().Width() + "x" +
  c19.LastCanvas().Height()

#-- 20. THE REAL-TIME ICONS, AND THE LAW THAT MAKES THEM A NOTATION ----------
#   The plan of record named these as the plane's last gap in these
#   words: they "are declared as kinds and draw as sensible shapes; none
#   of them has a LAW yet, which is the difference between a vocabulary
#   and a notation."
#
#   THE LAW IS IN THE MACROICON TABLE, thirteen rows of it. Every row of
#   the form "X by timer" -- action, shelf, fork, switch, input, output,
#   insertion, parallel process -- draws the timer trapezoid ATTACHED TO
#   THE LEFT of the icon it governs, on that icon's own row. Not above
#   it, and not in the flow.
#
#   That is the whole difference between having the icon and having the
#   construct. Drawn in sequence a timer says "wait, then do this",
#   which is a step. Drawn beside, it says "this step is governed by a
#   deadline", which is a property of the step. Those are different
#   algorithms, and the picture has to be able to tell them apart.
#
#   Three of these icons had also been drawn as HEXAGONS -- the
#   question's glyph -- so timer, pause and duration all wore the shape
#   that means "answer yes or no", and par wore the action's box.
c20 = StzDrakonScene20(OPT)
c20.LastCanvas().ToPNG("cat_20_realtime.png")
? "  20 the real-time set  " + c20.LastCanvas().Width() + "x" +
  c20.LastCanvas().Height()

? ""
? "wrote cat_01 .. cat_20"

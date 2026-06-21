# Narrative
# --------
# Are() asks a single yes/no question about ALL items of a list at once.
#
# Given three Arabic words, Are(:Strings) confirms every element is a
# string. The check also accepts a list of conditions that must ALL
# hold: [ :Arabic, :Strings ] verifies both the script and the type,
# and [ :ArabicScript, :RightToLeft, :Texts ] combines a script trait,
# a directionality trait, and a type trait in one collective predicate.
# This is the Softanza idiom for validating the homogeneity of a list
# against several traits without writing an explicit loop.
#
# Extracted from stzlisttest.ring, block #345.

load "../../stzBase.ring"

pr()

? Q([ "واحد", "اثنان", "ثلاثة" ]).Are(:Strings)
#--> TRUE

? Q([ "واحد", "اثنان", "ثلاثة" ]).Are([ :Arabic, :Strings ])
#--> TRUE

? Q([ "واحد", "اثنان", "ثلاثة" ]).Are([ :ArabicScript, :RightToLeft, :Texts ])
#--> TRUE

pf()
# Executed in 0.26 second(s).

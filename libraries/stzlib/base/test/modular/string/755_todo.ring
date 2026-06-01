# Narrative
# --------
# TODO
#
# Extracted from stzStringTest.ring, block #755.

load "../../../stzBase.ring"


pr()

# Boxing work great for latin chars, but for non latin chars,
# it would break:

? StzStringQ("乇乂丅尺卂 丅卄工匚匚").BoxedXT([
	:Line = :Dashed,
	:AllCorners = :Rectangular,

	:TextAdjustedTo = :Center
])
#-->
# ┌╌╌╌╌╌╌╌╌╌╌╌╌╌┐
# ┊ 乇乂丅尺卂 丅卄工匚匚 ┊
# └╌╌╌╌╌╌╌╌╌╌╌╌╌┘

# That is because chars in non-latin script won't have necessarily
# same width. In fact, this is related to the font used to render
# the chars on the screen. Hence, if you use a fixed-width font,
# the boxing will work correclty (TODO: check this!).

# As a configuration option that helps in solving this issue (without
# switching ta a fixed-width font, Softanza provide the width option
# that you can adjust manually and get a nice result like this:

? StzStringQ("乇乂丅尺卂 丅卄工匚匚").BoxedXT([
	:Line = :Dashed,
	:AllCorners = :Rectangular,

	:Width = 30,
	:TextAdjustedTo = :Center
])
#--> TODO: Fix the output to return this
# ┌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┐
# ┊ 乇乂丅尺卂 丅卄工匚匚 ┊
# └╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┘

pf()
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.03 second(s) in Ring 1.20

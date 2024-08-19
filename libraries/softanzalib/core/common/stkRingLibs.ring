
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#  LOADING NECESSARY RING LIBS (INCLUDING EXTENSIONS)  #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

load "StdLib.ring"
load "LightGuiLib.ring"	// #TODO: replace it with "RingQtCoreLib.ring" when ready
load "sqlitelib.ring"
# load "InternetLib.ring"
# load "fastpro.ring"
# load "tracelib.ring"

#NOTE

/*
"LightGuiLib.ring" takes most of the time made by non-Softanza libraries

      Test it with:

      load "../libraries/guilib/classes/ring_qtcore.ring"
      loadlib("ringqt_core.dll")

But don't keep it because programmers will not be able to use load "guilib.ring"
or "lightguilib.ring"
*/

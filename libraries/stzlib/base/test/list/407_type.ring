# Narrative
# --------
# @StzType() reports the canonical Softanza type name of a wrapped value.
#
# Here Q( "X":"Z" ) wraps a single key:value pair, which Softanza treats
# as a one-entry list. Asking @StzType() for it returns the lowercase
# class-style tag "stzlist" -- the runtime identity Softanza assigns to
# list objects. This is the idiomatic way to introspect what kind of
# Softanza object you are holding without inspecting its contents.
#
# Extracted from stzlisttest.ring, block #407.

load "../../stzBase.ring"

pr()

? @StzType( Q( "X":"Z" ) )
#-- stzlist

pf()
# Executed in 0.01 second(s) in Ring 1.22

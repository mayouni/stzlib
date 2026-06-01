# Narrative
# --------
#
# Extracted from stznaturaltest.ring, block #2.

load "../../../stzBase.ring"

pr()

Naturally('
    Create a @{+list:fruits~} with {["banana", "apple", "cherry"]}@ inside.
    {Sort} it then {Uppercase} it.

    @{Box~2} it using these Options: {rounded:true} and {hashed:true}@

    {Show} it

     Create an other {+list} and leave it empty.
     fill it with the content of the {first:list}.

     @{Erase} that {fruits:list}@.
     Show it.

     Show the {second:list}.

')
#-->
# APPLE
# BANANA
# CHERRY

# Softana NML (Natural Markup Language)

{+fruits:list ~1} {~1 ["banana", "apple", "cherry"]}
{?name}
{?count}
{boxXT-0it ~2} {~1 rounded=true} {~2 hashed=true}
{show-0it}

{+list}
{fill-it-with ~1} {~1 first:list..content}

{erase} {fruits:list}
{show-0it}

{^joinXT ~2} {~1 second:list} {~2 " "}
{?0what-0is-0its-type}
{show-0it} 

pf()

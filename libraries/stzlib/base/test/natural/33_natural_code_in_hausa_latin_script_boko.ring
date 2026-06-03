# Narrative
# --------
# NATURAL CODE IN HAUSA LATIN SCRIPT (BOKO)
#
# Extracted from stznaturaltest.ring, block #33.
#ERR Error (R14) : Calling Method without definition: findantisectionszz

load "../../stzBase.ring"



pr()

o1 = NaturallyIn("hausa", "
    Yi rubutu da dauke 'hello niger' a ciki 
    Raba shi kuma maida shi
    @Akwati shi kuma wannan akwati@ dole zagaye
    Nuna shi a kan allo
    Na gode susai

    Yi rubutu da dauke 'hello niger' a ciki.
    Raba shi kuma maida shi!

    @Akwati shi kuma wannan akwati@ dole zagaye ;

    Nuna shi a kan allo...
    Na gode susai ♥

")
#-->
# ╭───────────────────────╮
# │ H E L L O   N I G E R │
# ╰───────────────────────╯

# Vocabulary:
#   Make     --> Yi
#   String   --> Rubuti
#   With     --> Dauke
#   Spacify  --> Raba
#   Uppercase--> Maida
#   Box      --> Akwati
#   Rounded  --> Zagaye

? o1.Code()
#-->
# oStr = StzStringQ("hello niger")
# oStr.Spacify()
# oStr.Uppercase()
# oStr.BoxXT([:Rounded = 1])
# ? oStr.Content()

pf()

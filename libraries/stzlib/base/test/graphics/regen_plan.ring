load "../../stzBase.ring"
b = StzWritePlanCoverage("../../graphics/SOFTANZA_GRAPH_PLANE_PLAN.md",
                         [ "gg_adversarial.ring" ])
? "regenerated = " + b

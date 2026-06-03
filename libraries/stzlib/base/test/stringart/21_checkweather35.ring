# Narrative
# --------
# CheckWeather(35)
#
# Extracted from stzstringarttest.ring, block #21.
#ERR Error (R3) : Calling Function without definition: stringart

load "../../stzBase.ring"

pr()

#-->
# It's hot outside!
#    \   🌞  /
#   \  \│/  /
# ─ ─ ─ ☀ ─ ─ ─
#   /  /│\  \
#     /    \  \

CheckWeather(25)
#-->
# It's cool today.
#          .-~~~-.
#  .- ~ ~-(       )_ _
# /                     ~ -.
# |                           \
#  \                         .'
#    ~- . _____________ . -~

func CheckWeather(temperature)
    if temperature > 30
        ? "It's hot outside!"
        ? StringArt("#{Sun rise}")
    else
        ? "It's cool today."
        ? StringArt("#{Cloud}")
    ok

pf()
# Executed in 0.001 seconds.

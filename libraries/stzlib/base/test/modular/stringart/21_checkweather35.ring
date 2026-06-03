# Narrative
# --------
# CheckWeather(35)
#
# Extracted from stzstringarttest.ring, block #21.

load "../../../stzBase.ring"

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

# Executed in 0.001 seconds.

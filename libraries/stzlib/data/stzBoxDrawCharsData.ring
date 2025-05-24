

# Globals to using in drawing ascii-based boxes
# TODO: use them instead of the hardcoded instances

$LightH = "─"
$HeavyH = "━"
$LightV = "│"
$HeavyV = "┃"

$LightTripleDashH = "┄"
$HeavyTripleDashH = "┅"
$LightTripleDashV = "┆"
$HeavyTripleDashV = "┇"

$LightQuadDashH = "┈"
$HeavyQuadDashH = "┉"
$LightQuadDashV = "┊"
$HeavyQuadDashV = "┋"

$LightDownRight = "┌"
$DownLightRightHeavy = "┍"
$DownHeavyRightLight = "┎"
$HeavyDownRight = "┏"

$LightDownLeft = "┐"
$DownLightLeftHeavy = "┑"
$DownHeavyLeftLight = "┒"
$HeavyDownLeft = "┓"

$LightUpRight = "└"
$UpLightRightHeavy = "┕"
$UpHeavyRightLight = "┖"
$HeavyUpRight = "┗"

$LightUpLeft = "┘"
$UpLightLeftHeavy = "┙"
$UpHeavyLeftLight = "┚"
$HeavyUpLeft = "┛"

$LightVAndRight = "├"
$VLightRightHeavy = "┝"
$UpHeavyRightDownLight = "┞"
$DownHeavyRightUpLight = "┟"
$VHeavyRightLight = "┠"
$DownLightRightUpHeavy = ""
$UpLightRightDownHeavy = "┢"
$HeavyVAndRight = "┣"

$LightVAndLeft = "┤"
$VLightLeftHeavy = "┥"
$UpHeavyLeftDownLight = "┦"
$DownHeavyLeftUpLight = "┧"
$VHeavyLeftLight = "┨"
$DownLightLeftUpHeavy = "┩"
$UpLightLeftDownHeavy = "┪"
$HeavyVAndLeft = "┫"

$LightDownH = "┬"
$LeftHeavyRightDownLight = "┭"
$RightHeavyLeftDownLight = "┮"
$DownLightHHeavy = "┯"
$DownHeavyHLight = "┰"
$RightLightLeftDownHeavy = "┱"
$LeftLightRightDownHeavy = "┲"
$HeavyDownH = "┳"

$LightUpH = "┴"
$LeftHeavyRightUpLight = "┵"
$RightHeavyLeftUpLight = "┶"
$UpLightHHeavy = "┷"
$UpHeavyHLight = "┸"
$RightLightLeftUpHeavy = "┹"
$LeftLightRightUpHeavy = "┺"
$HeavyUpH = "┻"

$LightVAndH = "┼"
$LeftHeavyRightVLight = "┽"
$RightHeavyLeftVLight = "┾"
$VLightHHeavy = "┿"
$UpHeavyDownHLight = "╀"
$DownHeavyUpHLight = "╁"
$VHeavyHLight = "╂"
$LeftUpHeavyRightDownLight = "╃"
$RightUpHeavyLeftDownLight = "╄"
$LeftDownHeavyRightUpLight = "╅"
$RightDownHeavyLeftUpLight = "╆"
$DownLightUpHHeavy = "╇"
$UpLightDownHHeavy = "╈"
$RightLightLeftVHeavy = "╉"
$LeftLightRightVHeavy = "╊"
$HeavyVAndH = "╋"

$LightDoubleDashH = "╌"
$HeavyDoubleDashH = "╍"
$LightDoubleDashV = "╎"
$HeavyDoubleDashV = "╏"

$DoubleH = "═"
$DoubleV = "║"

$DownSingleRightDouble = "╒"
$DownDoubleRightSingle = "╓"
$DoubleDownRight = "╔"
$DownSingleLeftDouble = "╕"
$DownDoubleLeftSingle = "╖"
$DoubleDownLeft = "╗"

$UpSingleRightDouble = "╘"
$UpDoubleRightSingle = "╙"
$DoubleUpRight = "╚"
$UpSingleLeftDouble = "╛"
$UpDoubleLeftSingle = "╜"
$DoubleUpLeft = "╝"

$VSingleRightDouble = "╞"
$VDoubleRightSingle = "╟"
$DoubleVRight = "╠"
$VSingleLeftDouble = "╡"
$VDoubleLeftSingle = "╢"
$DoubleVLeft = "╣"

$DownSingleHDouble = "╤"
$DownDoubleHSingle = "╥"
$DoubleDownH = "╦"
$UpSingleHDouble = "╧"
$UpDoubleHSingle = "╨"
$DoubleUpH = "╩"

$VSingleHDouble = "╪"
$VDoubleHSingle = "╫"
$DoubleVH = "╬"

$ArcDownRight = "╭"
$ArcDownLeft = "╮"
$ArcUpLeft = "╯"
$ArcUpRight = "╰"

$DiagonalUpperRightToLowerLeft = "╱"
$DiagonalUpperLeftToLowerRight = "╲"
$DiagonalCross = "╳"

$LightLeftHalf = "╴"
$LightUpHalf = "╵"
$LightRightHalf = "╶"
$LightDownHalf = "╷"

$HeavyLeftHalf = "╸"
$HeavyUpHalf = "╹"
$HeavyRightHalf = "╺"
$HeavyDownHalf = "╻"

$LightLeftHeavyRight = "╼"
$LightUpHeavyDown = "╽"
$HeavyLeftLightRight = "╾"
$HeavyUpLightDown = "╿"


# Functions
func LightH
    return $LightH


func SetLightH(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $LightH = c


func HeavyH
    return $HeavyH


func SetHeavyH(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $HeavyH = c


func LightV
    return $LightV


func SetLightV(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $LightV = c


func HeavyV
    return $HeavyV


func SetHeavyV(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $HeavyV = c


func LightTripleDashH
    return $LightTripleDashH


func SetLightTripleDashH(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $LightTripleDashH = c


func HeavyTripleDashH
    return $HeavyTripleDashH


func SetHeavyTripleDashH(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $HeavyTripleDashH = c


func LightTripleDashV
    return $LightTripleDashV


func SetLightTripleDashV(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $LightTripleDashV = c


func HeavyTripleDashV
    return $HeavyTripleDashV


func SetHeavyTripleDashV(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $HeavyTripleDashV = c


func LightQuadDashH
    return $LightQuadDashH


func SetLightQuadDashH(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $LightQuadDashH = c


func HeavyQuadDashH
    return $HeavyQuadDashH


func SetHeavyQuadDashH(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $HeavyQuadDashH = c


func LightQuadDashV
    return $LightQuadDashV


func SetLightQuadDashV(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $LightQuadDashV = c


func HeavyQuadDashV
    return $HeavyQuadDashV


func SetHeavyQuadDashV(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $HeavyQuadDashV = c


func LightDownRight
    return $LightDownRight


func SetLightDownRight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $LightDownRight = c


func DownLightRightHeavy
    return $DownLightRightHeavy


func SetDownLightRightHeavy(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $DownLightRightHeavy = c


func DownHeavyRightLight
    return $DownHeavyRightLight


func SetDownHeavyRightLight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $DownHeavyRightLight = c


func HeavyDownRight
    return $HeavyDownRight


func SetHeavyDownRight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $HeavyDownRight = c


func LightDownLeft
    return $LightDownLeft


func SetLightDownLeft(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $LightDownLeft = c


func DownLightLeftHeavy
    return $DownLightLeftHeavy


func SetDownLightLeftHeavy(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $DownLightLeftHeavy = c


func DownHeavyLeftLight
    return $DownHeavyLeftLight


func SetDownHeavyLeftLight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $DownHeavyLeftLight = c


func HeavyDownLeft
    return $HeavyDownLeft


func SetHeavyDownLeft(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $HeavyDownLeft = c


func LightUpRight
    return $LightUpRight


func SetLightUpRight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $LightUpRight = c


func UpLightRightHeavy
    return $UpLightRightHeavy


func SetUpLightRightHeavy(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $UpLightRightHeavy = c


func UpHeavyRightLight
    return $UpHeavyRightLight


func SetUpHeavyRightLight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $UpHeavyRightLight = c


func HeavyUpRight
    return $HeavyUpRight


func SetHeavyUpRight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $HeavyUpRight = c


func LightUpLeft
    return $LightUpLeft


func SetLightUpLeft(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $LightUpLeft = c


func UpLightLeftHeavy
    return $UpLightLeftHeavy


func SetUpLightLeftHeavy(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $UpLightLeftHeavy = c


func UpHeavyLeftLight
    return $UpHeavyLeftLight


func SetUpHeavyLeftLight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $UpHeavyLeftLight = c


func HeavyUpLeft
    return $HeavyUpLeft


func SetHeavyUpLeft(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $HeavyUpLeft = c


func LightVAndRight
    return $LightVAndRight


func SetLightVAndRight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $LightVAndRight = c


func VLightRightHeavy
    return $VLightRightHeavy


func SetVLightRightHeavy(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $VLightRightHeavy = c


func UpHeavyRightDownLight
    return $UpHeavyRightDownLight


func SetUpHeavyRightDownLight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $UpHeavyRightDownLight = c


func DownHeavyRightUpLight
    return $DownHeavyRightUpLight


func SetDownHeavyRightUpLight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $DownHeavyRightUpLight = c


func VHeavyRightLight
    return $VHeavyRightLight


func SetVHeavyRightLight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $VHeavyRightLight = c


func DownLightRightUpHeavy
    return $DownLightRightUpHeavy


func SetDownLightRightUpHeavy(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $DownLightRightUpHeavy = c


func UpLightRightDownHeavy
    return $UpLightRightDownHeavy


func SetUpLightRightDownHeavy(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $UpLightRightDownHeavy = c


func HeavyVAndRight
    return $HeavyVAndRight


func SetHeavyVAndRight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $HeavyVAndRight = c


func LightVAndLeft
    return $LightVAndLeft


func SetLightVAndLeft(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $LightVAndLeft = c


func VLightLeftHeavy
    return $VLightLeftHeavy


func SetVLightLeftHeavy(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $VLightLeftHeavy = c


func UpHeavyLeftDownLight
    return $UpHeavyLeftDownLight


func SetUpHeavyLeftDownLight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $UpHeavyLeftDownLight = c


func DownHeavyLeftUpLight
    return $DownHeavyLeftUpLight


func SetDownHeavyLeftUpLight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $DownHeavyLeftUpLight = c


func VHeavyLeftLight
    return $VHeavyLeftLight


func SetVHeavyLeftLight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $VHeavyLeftLight = c


func DownLightLeftUpHeavy
    return $DownLightLeftUpHeavy


func SetDownLightLeftUpHeavy(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $DownLightLeftUpHeavy = c


func UpLightLeftDownHeavy
    return $UpLightLeftDownHeavy


func SetUpLightLeftDownHeavy(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $UpLightLeftDownHeavy = c


func HeavyVAndLeft
    return $HeavyVAndLeft


func SetHeavyVAndLeft(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $HeavyVAndLeft = c


func LightDownH
    return $LightDownH


func SetLightDownH(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $LightDownH = c


func LeftHeavyRightDownLight
    return $LeftHeavyRightDownLight


func SetLeftHeavyRightDownLight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $LeftHeavyRightDownLight = c


func RightHeavyLeftDownLight
    return $RightHeavyLeftDownLight


func SetRightHeavyLeftDownLight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $RightHeavyLeftDownLight = c


func DownLightHHeavy
    return $DownLightHHeavy


func SetDownLightHHeavy(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $DownLightHHeavy = c


func DownHeavyHLight
    return $DownHeavyHLight


func SetDownHeavyHLight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $DownHeavyHLight = c


func RightLightLeftDownHeavy
    return $RightLightLeftDownHeavy


func SetRightLightLeftDownHeavy(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $RightLightLeftDownHeavy = c


func LeftLightRightDownHeavy
    return $LeftLightRightDownHeavy


func SetLeftLightRightDownHeavy(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $LeftLightRightDownHeavy = c


func HeavyDownH
    return $HeavyDownH


func SetHeavyDownH(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $HeavyDownH = c


func LightUpH
    return $LightUpH


func SetLightUpH(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $LightUpH = c


func LeftHeavyRightUpLight
    return $LeftHeavyRightUpLight


func SetLeftHeavyRightUpLight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $LeftHeavyRightUpLight = c


func RightHeavyLeftUpLight
    return $RightHeavyLeftUpLight


func SetRightHeavyLeftUpLight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $RightHeavyLeftUpLight = c


func UpLightHHeavy
    return $UpLightHHeavy


func SetUpLightHHeavy(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $UpLightHHeavy = c


func UpHeavyHLight
    return $UpHeavyHLight


func SetUpHeavyHLight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $UpHeavyHLight = c


func RightLightLeftUpHeavy
    return $RightLightLeftUpHeavy


func SetRightLightLeftUpHeavy(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $RightLightLeftUpHeavy = c


func LeftLightRightUpHeavy
    return $LeftLightRightUpHeavy


func SetLeftLightRightUpHeavy(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $LeftLightRightUpHeavy = c


func HeavyUpH
    return $HeavyUpH


func SetHeavyUpH(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $HeavyUpH = c


func LightVAndH
    return $LightVAndH


func SetLightVAndH(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $LightVAndH = c


func LeftHeavyRightVLight
    return $LeftHeavyRightVLight


func SetLeftHeavyRightVLight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $LeftHeavyRightVLight = c


func RightHeavyLeftVLight
    return $RightHeavyLeftVLight


func SetRightHeavyLeftVLight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $RightHeavyLeftVLight = c


func VLightHHeavy
    return $VLightHHeavy


func SetVLightHHeavy(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $VLightHHeavy = c


func UpHeavyDownHLight
    return $UpHeavyDownHLight


func SetUpHeavyDownHLight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $UpHeavyDownHLight = c


func DownHeavyUpHLight
    return $DownHeavyUpHLight


func SetDownHeavyUpHLight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $DownHeavyUpHLight = c


func VHeavyHLight
    return $VHeavyHLight


func SetVHeavyHLight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $VHeavyHLight = c


func LeftUpHeavyRightDownLight
    return $LeftUpHeavyRightDownLight


func SetLeftUpHeavyRightDownLight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $LeftUpHeavyRightDownLight = c


func RightUpHeavyLeftDownLight
    return $RightUpHeavyLeftDownLight


func SetRightUpHeavyLeftDownLight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $RightUpHeavyLeftDownLight = c


func LeftDownHeavyRightUpLight
    return $LeftDownHeavyRightUpLight


func SetLeftDownHeavyRightUpLight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $LeftDownHeavyRightUpLight = c


func RightDownHeavyLeftUpLight
    return $RightDownHeavyLeftUpLight


func SetRightDownHeavyLeftUpLight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $RightDownHeavyLeftUpLight = c


func DownLightUpHHeavy
    return $DownLightUpHHeavy


func SetDownLightUpHHeavy(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $DownLightUpHHeavy = c


func UpLightDownHHeavy
    return $UpLightDownHHeavy


func SetUpLightDownHHeavy(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $UpLightDownHHeavy = c


func RightLightLeftVHeavy
    return $RightLightLeftVHeavy


func SetRightLightLeftVHeavy(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $RightLightLeftVHeavy = c


func LeftLightRightVHeavy
    return $LeftLightRightVHeavy


func SetLeftLightRightVHeavy(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $LeftLightRightVHeavy = c


func HeavyVAndH
    return $HeavyVAndH


func SetHeavyVAndH(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $HeavyVAndH = c


func LightDoubleDashH
    return $LightDoubleDashH


func SetLightDoubleDashH(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $LightDoubleDashH = c


func HeavyDoubleDashH
    return $HeavyDoubleDashH


func SetHeavyDoubleDashH(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $HeavyDoubleDashH = c


func LightDoubleDashV
    return $LightDoubleDashV


func SetLightDoubleDashV(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $LightDoubleDashV = c


func HeavyDoubleDashV
    return $HeavyDoubleDashV


func SetHeavyDoubleDashV(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $HeavyDoubleDashV = c


func DoubleH
    return $DoubleH


func SetDoubleH(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $DoubleH = c


func DoubleV
    return $DoubleV


func SetDoubleV(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $DoubleV = c


func DownSingleRightDouble
    return $DownSingleRightDouble


func SetDownSingleRightDouble(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $DownSingleRightDouble = c


func DownDoubleRightSingle
    return $DownDoubleRightSingle


func SetDownDoubleRightSingle(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $DownDoubleRightSingle = c


func DoubleDownRight
    return $DoubleDownRight


func SetDoubleDownRight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $DoubleDownRight = c


func DownSingleLeftDouble
    return $DownSingleLeftDouble


func SetDownSingleLeftDouble(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $DownSingleLeftDouble = c


func DownDoubleLeftSingle
    return $DownDoubleLeftSingle


func SetDownDoubleLeftSingle(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $DownDoubleLeftSingle = c


func DoubleDownLeft
    return $DoubleDownLeft


func SetDoubleDownLeft(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $DoubleDownLeft = c


func UpSingleRightDouble
    return $UpSingleRightDouble


func SetUpSingleRightDouble(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $UpSingleRightDouble = c


func UpDoubleRightSingle
    return $UpDoubleRightSingle


func SetUpDoubleRightSingle(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $UpDoubleRightSingle = c


func DoubleUpRight
    return $DoubleUpRight


func SetDoubleUpRight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $DoubleUpRight = c


func UpSingleLeftDouble
    return $UpSingleLeftDouble


func SetUpSingleLeftDouble(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $UpSingleLeftDouble = c


func UpDoubleLeftSingle
    return $UpDoubleLeftSingle


func SetUpDoubleLeftSingle(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $UpDoubleLeftSingle = c


func DoubleUpLeft
    return $DoubleUpLeft


func SetDoubleUpLeft(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $DoubleUpLeft = c


func VSingleRightDouble
    return $VSingleRightDouble


func SetVSingleRightDouble(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $VSingleRightDouble = c


func VDoubleRightSingle
    return $VDoubleRightSingle


func SetVDoubleRightSingle(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $VDoubleRightSingle = c


func DoubleVRight
    return $DoubleVRight


func SetDoubleVRight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $DoubleVRight = c


func VSingleLeftDouble
    return $VSingleLeftDouble


func SetVSingleLeftDouble(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $VSingleLeftDouble = c


func VDoubleLeftSingle
    return $VDoubleLeftSingle


func SetVDoubleLeftSingle(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $VDoubleLeftSingle = c


func DoubleVLeft
    return $DoubleVLeft


func SetDoubleVLeft(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $DoubleVLeft = c


func DownSingleHDouble
    return $DownSingleHDouble


func SetDownSingleHDouble(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $DownSingleHDouble = c


func DownDoubleHSingle
    return $DownDoubleHSingle


func SetDownDoubleHSingle(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $DownDoubleHSingle = c


func DoubleDownH
    return $DoubleDownH


func SetDoubleDownH(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $DoubleDownH = c


func UpSingleHDouble
    return $UpSingleHDouble


func SetUpSingleHDouble(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $UpSingleHDouble = c


func UpDoubleHSingle
    return $UpDoubleHSingle


func SetUpDoubleHSingle(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $UpDoubleHSingle = c


func DoubleUpH
    return $DoubleUpH


func SetDoubleUpH(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $DoubleUpH = c


func VSingleHDouble
    return $VSingleHDouble


func SetVSingleHDouble(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $VSingleHDouble = c


func VDoubleHSingle
    return $VDoubleHSingle


func SetVDoubleHSingle(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $VDoubleHSingle = c


func DoubleVH
    return $DoubleVH


func SetDoubleVH(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $DoubleVH = c


func ArcDownRight
    return $ArcDownRight


func SetArcDownRight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $ArcDownRight = c


func ArcDownLeft
    return $ArcDownLeft


func SetArcDownLeft(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $ArcDownLeft = c


func ArcUpLeft
    return $ArcUpLeft


func SetArcUpLeft(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $ArcUpLeft = c


func ArcUpRight
    return $ArcUpRight


func SetArcUpRight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $ArcUpRight = c


func DiagonalUpperRightToLowerLeft
    return $DiagonalUpperRightToLowerLeft


func SetDiagonalUpperRightToLowerLeft(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $DiagonalUpperRightToLowerLeft = c


func DiagonalUpperLeftToLowerRight
    return $DiagonalUpperLeftToLowerRight


func SetDiagonalUpperLeftToLowerRight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $DiagonalUpperLeftToLowerRight = c


func DiagonalCross
    return $DiagonalCross


func SetDiagonalCross(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $DiagonalCross = c


func LightLeftHalf
    return $LightLeftHalf


func SetLightLeftHalf(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $LightLeftHalf = c


func LightUpHalf
    return $LightUpHalf


func SetLightUpHalf(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $LightUpHalf = c


func LightRightHalf
    return $LightRightHalf


func SetLightRightHalf(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $LightRightHalf = c


func LightDownHalf
    return $LightDownHalf


func SetLightDownHalf(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $LightDownHalf = c


func HeavyLeftHalf
    return $HeavyLeftHalf


func SetHeavyLeftHalf(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $HeavyLeftHalf = c


func HeavyUpHalf
    return $HeavyUpHalf


func SetHeavyUpHalf(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $HeavyUpHalf = c


func HeavyRightHalf
    return $HeavyRightHalf


func SetHeavyRightHalf(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $HeavyRightHalf = c


func HeavyDownHalf
    return $HeavyDownHalf


func SetHeavyDownHalf(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $HeavyDownHalf = c


func LightLeftHeavyRight
    return $LightLeftHeavyRight


func SetLightLeftHeavyRight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $LightLeftHeavyRight = c


func LightUpHeavyDown
    return $LightUpHeavyDown


func SetLightUpHeavyDown(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $LightUpHeavyDown = c


func HeavyLeftLightRight
    return $HeavyLeftLightRight


func SetHeavyLeftLightRight(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $HeavyLeftLightRight = c


func HeavyUpLightDown
    return $HeavyUpLightDown


func SetHeavyUpLightDown(c)
    if not (isstring(c) and len(c) = 1)
        error("Incorrect param type! c must be a char.")
    ok
    $HeavyUpLightDown = c

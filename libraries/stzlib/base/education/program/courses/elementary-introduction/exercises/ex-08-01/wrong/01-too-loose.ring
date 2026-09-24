# Any digits anywhere: both dates pass.
? rx("[0-9]+").MatchFirst("2026-09-24")
? rx("[0-9]+").MatchFirst("24/09/2026")

# _measure_chunk.ring -- score ONE implementation on a SLICE of a faculty's golden set.
#
#     ring _measure_chunk.ring <faculty> <implementation id> <from> <to>
#
# For models too slow to finish a whole golden set inside one process run (a 3B model on CPU takes longer than the
# ten minutes a foreground run is given). Each golden item scores 1 or 0, so the slices add up exactly: sum the
# "ok" and "n" columns of every slice, then record the total with _measure_record.ring.
# Prints one line:  CHUNK <faculty> <impl> <from>-<to> ok=<right> valid=<answered> n=<items> sec=<wall>

load "../../stzBase.ring"
load "_ticket_app.ring"

cFac = lower(sysargv[3])
cImpl = sysargv[4]
nFrom = 0 + sysargv[5]
nTo = 0 + sysargv[6]
StzTicketAppDeclare()

nRow = _StzFacultyRow(cFac)
aG = $aStzFaculties[nRow][:golden]
if nTo > len(aG) nTo = len(aG) ok
aSlice = []
for i = nFrom to nTo
	add(aSlice, aG[i])
next
$aStzFaculties[nRow][:golden] = aSlice

t0 = clock()
aS = StzScoreImplementation(cFac, cImpl, [])
nSec = (clock() - t0) / clockspersecond()
? "CHUNK " + cFac + " " + cImpl + " " + nFrom + "-" + nTo + " ok=" + (aS[:score] * aS[:n]) + " valid=" + (aS[:conformance] * aS[:n]) +
  " n=" + aS[:n] + " sec=" + nSec

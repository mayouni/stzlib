# _measure_record.ring -- record the SUM of _measure_chunk.ring slices as one measurement row.
#
#     ring _measure_record.ring <faculty> <implementation id> <right> <valid> <n> [note]
#
# The row goes to results/measurements.zmdl.txt against the faculty's CURRENT golden version, exactly as
# _measure_flows.ring would have written it had the whole set run in one process.

load "../../stzBase.ring"
load "_ticket_app.ring"

cStore = "results/measurements.zmdl.txt"
StzLoadMeasurements(cStore)
StzTicketAppDeclare()

cFac = lower(sysargv[3])
cImpl = sysargv[4]
nRight = 0 + sysargv[5]
nValid = 0 + sysargv[6]
nItems = 0 + sysargv[7]
cNote = ""
if len(sysargv) >= 8 cNote = sysargv[8] ok

nRow = _StzFacultyRow(cFac)
StzRecordMeasurement(cFac, cImpl, $aStzFaculties[nRow][:goldenversion], nRight / nItems, nItems, nValid / nItems, cNote)
StzSaveMeasurements(cStore)
? "RECORDED " + cFac + " / " + cImpl + "  score=" + (nRight / nItems) + "  n=" + nItems

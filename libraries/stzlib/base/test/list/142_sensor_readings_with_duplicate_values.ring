# Narrative
# --------
# # Sensor readings with duplicate values
#
# Extracted from stzlisttest.ring, block #142.
#ERR Error (R14) : Calling Method without definition: findduplicates

load "../../stzBase.ring"

pr()

aSensorReadings = [
    ["timestamp", "temperature"],
    ["10:00:00", 22.5],
    ["10:00:00", 22.5],    # Duplicate reading
    ["10:00:00", 22.5],    # Duplicate reading
    ["10:00:01", 22.6],
    ["10:00:01", 22.6],    # Duplicate reading
    ["10:00:02", 22.7]
]

oSensorData = new stzList(aSensorReadings)

? @@( oSensorData.FindDuplicates() ) + NL

# Get unique readings while preserving order

oSensorData.RemoveDuplicates()
? @@NL( oSensorData.Content() )
#--> [
#	[ "timestamp", "temperature" ],
#	[ "10:00:00", 22.50 ],
#	[ "10:00:01", 22.60 ],
#	[ "10:00:02", 22.70 ]
# ]

pf()

# Synthetic boundary fixtures

`two_countries.geojson` and `two_countries.topojson` describe THE SAME two
invented countries, so a reader can be held to giving identical geometry
from either. Nothing here is a real place and no real border is asserted:
the whole point of the geo plane's kill line is that this repository
vendors no boundary data.

Between them they carry every shape GE1 promises to keep:

  * a HOLE -- Arda has a lake, which a reader that keeps only the largest
    ring would fill in as land
  * an ISLAND -- Berea is a MultiPolygon, and its island is the part a
    largest-ring reader drops
  * a SHARED BORDER -- Arda and Berea meet along one line, written ONCE in
    the topology (arc 0) and twice in the GeoJSON. That is the whole reason
    TopoJSON exists, and it is why the two files cannot disagree about
    where the border runs.

Generated, not hand-typed; the generator is in the commit that added them.

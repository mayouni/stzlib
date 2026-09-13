# The atlas is NOT vendored, and this folder is not committed

The geo plane's kill line, written when DN24b refused to ship boundary
data and unchanged since: **a boundary dataset carries a POSITION on every
disputed border**, restated in every picture drawn from it, in a plane
whose doctrine is that a picture must not assert what it cannot check. It
also carries a VINTAGE (right the day it lands, silently wrong after) and
a LICENCE the consumer would owe. None of that applies to a font subset,
which is why one is committed and this is not.

So the examples that need land read it from HERE, and this folder is in
`.gitignore`. Fetch it yourself, once:

    curl -sSL -o countries-110m.json \
      https://cdn.jsdelivr.net/npm/world-atlas@2.0.2/countries-110m.json
    curl -sSL -o land-110m.json \
      https://cdn.jsdelivr.net/npm/world-atlas@2.0.2/land-110m.json

`world-atlas` is Natural Earth's public-domain data as TopoJSON: 108 KB
for 177 countries at 1:110m, which is the scale a screen can show. Natural
Earth states no rights over it (naturalearthdata.com/about/terms-of-use);
the packaging is Mike Bostock's, ISC.

**Every example and every guard that uses it says what it skipped when the
folder is empty.** Nothing here is required to run the geo guards -- those
stand on the invented fixtures in `../fixtures`, which assert no border.

## Inside a country: the admin-1 units

The same refusal, the same source. Natural Earth's admin-1 file is the
provinces, governorates, regions and departments inside every country --
4,596 of them, **40 MB**, 121 properties each. Nobody wants that in memory
to draw the eight regions of Niger, so it is fetched once, CUT, and thrown
away:

    curl -sSL -o _ne10_admin1.json       https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/ne_10m_admin_1_states_provinces.geojson

then, from `base/test/graphics`:

    ring atlas/cut_admin1.ring        # writes admin1_<country>.geojson here
    rm atlas/_ne10_admin1.json

The cutting is `StzEngineJsonFilterFeatures`, which matches **in the
engine** so the other 4,588 features never cross into Ring. Niger comes to
60 KB, Tunisia to 131 KB, France to 719 KB, in about half a second each.

`nvkelso/natural-earth-vector` is Natural Earth's own repository; the data
is public domain, the packaging CC0. Same licence envelope as the country
file above, which is why this source and not one of the CC-BY atlases.

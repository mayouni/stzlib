# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #13.

load "../../../stzBase.ring"


aData = [
	[
		"product",
		[ "Apple", "Orange", "Banana" ]
	],
	[
		"price",
		[ "$1.50", "$1.20", "$0.80" ]
	],
	[
		"stock",
		[ "100", "150", "200" ]
	]
]

o1 = new stzTable(aData)
? o1.ToHtmlXT() # Without XT you get a compact versio of the html string
#-->
'
<table class="data" id="products">
<thead>

<tr>
            <th scope="col">product</th>
            <th scope="col">price</th>
            <th scope="col">stock</th>
</tr>

</thead>

<tbody>

<tr class="row">
        <td>Apple</td>
        <td>$1.50</td>
        <td>100</td>

</tr>

<tr class="row">
        <td>Orange</td>
        <td>$1.20</td>
        <td>150</td>

</tr>

<tr class="row">
        <td>Banana</td>
        <td>$0.80</td>
        <td>200</td>

</tr>

</tbody>
</table>
'

pf()
# Executed in 0.01 second(s) in Ring 1.22

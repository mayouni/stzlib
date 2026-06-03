# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #7.

load "../../stzBase.ring"

pr()

str = '
    <table class="data" id="products">
        <thead>
            <tr>
                <th scope="col">Product</th>
                <th scope="col">Price</th>
                <th scope="col">Stock</th>
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
            <tr class="row">
                <td>Grape</td>
                <td>$2.00</td>
                <td>80</td>
            </tr>
            <tr class="row">
                <td>Mango</td>
                <td>$3.00</td>
                <td>50</td>
            </tr>
        </tbody>
    </table>
'

o1 = new stzString(str)

? o1.IsHtmlTable()
#--> TRUE

o1.HtmlToDataTableQRT(:stzTable).Show()
#-->
# ╭─────────┬───────┬───────╮
# │ Product │ Price │ Stock │
# ├─────────┼───────┼───────┤
# │ Apple   │ $1.50 │   100 │
# │ Orange  │ $1.20 │   150 │
# │ Banana  │ $0.80 │   200 │
# ╰─────────┴───────┴───────╯

pf()
# Executed in 0.10 second(s) in Ring 1.22

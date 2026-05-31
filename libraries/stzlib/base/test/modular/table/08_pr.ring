# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #8.

load "../../../stzBase.ring"


cHtml = '
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Product Overview</title>
</head>
<body>

    <h1>Product Overview</h1>

<h2>Current Inventory</h2>
<p>Below is the list of products currently available in our store. It includes prices and the quantity in stock:</p>

<table class="data" id="products-inventory">
    <thead>
        <tr>
            <th scope="col">Product</th>
            <th scope="col">Price</th>
            <th scope="col">Stock</th>
        </tr>
    </thead>
    <tbody>
        <tr class="row"><td>Apple</td><td>$1.50</td><td>100</td></tr>
        <tr class="row"><td>Orange</td><td>$1.20</td><td>150</td></tr>
        <tr class="row"><td>Banana</td><td>$0.80</td><td>200</td></tr>
        <tr class="row"><td>Grape</td><td>$2.00</td><td>80</td></tr>
        <tr class="row"><td>Mango</td><td>$3.00</td><td>50</td></tr>
    </tbody>
</table>

<p>As you can see, bananas are our top-stocked item, but mangoes are running low. Restocking will be necessary soon, especially for high-demand fruits.</p>

<h2>Incoming Shipments</h2>
<p>This next table shows the expected quantities from our upcoming delivery. These items will be added to inventory once received:</p>

<table class="data" id="products-incoming">
    <thead>
        <tr>
            <th scope="col">Product</th>
            <th scope="col">Incoming Quantity</th>
            <th scope="col">Expected Arrival</th>
        </tr>
    </thead>
    <tbody>
        <tr class="row"><td>Pineapple</td><td>60</td><td>2025-05-20</td></tr>
        <tr class="row"><td>Kiwi</td><td>120</td><td>2025-05-21</td></tr>
        <tr class="row"><td>Strawberry</td><td>90</td><td>2025-05-22</td></tr>
    </tbody>
</table>

<p>These fresh items will broaden our offering for the week ahead. Special promotions are planned once the shipment is confirmed.</p>

<h2>Top-Selling Products (Last 7 Days)</h2>
<p>Here is an overview of our best-sellers over the past week. These trends help guide procurement decisions:</p>

<table class="data" id="products-top-sellers">
    <thead>
        <tr>
            <th scope="col">Product</th>
            <th scope="col">Units Sold</th>
            <th scope="col">Revenue</th>
        </tr>
    </thead>
    <tbody>
        <tr class="row"><td>Banana</td><td>180</td><td>$144.00</td></tr>
        <tr class="row"><td>Apple</td><td>160</td><td>$240.00</td></tr>
        <tr class="row"><td>Orange</td><td>140</td><td>$168.00</td></tr>
    </tbody>
</table>

<p>Bananas continue to dominate sales, followed closely by apples. Increasing their stock could yield higher revenue next week.</p>

</body>
</html>
'

o1 = new stzString(cHtml)
? o1.ContainsHtmlTable()
#--> TRUE

? o1.NumberOfHtmlTables()
#--> 3

o1.HtmlToDataTablesQRT(:stzListOfTables).Show()
#-->
# ╭─────────┬───────┬───────╮
# │ Product │ Price │ Stock │
# ├─────────┼───────┼───────┤
# │ Apple   │ $1.50 │   100 │
# │ Orange  │ $1.20 │   150 │
# │ Banana  │ $0.80 │   200 │
# ╰─────────┴───────┴───────╯
# ╭────────────┬───────────────────┬──────────────────╮
# │  Product   │ Incoming Quantity │ Expected Arrival │
# ├────────────┼───────────────────┼──────────────────┤
# │ Pineapple  │                60 │ 2025-05-20       │
# │ Kiwi       │               120 │ 2025-05-21       │
# │ Strawberry │                90 │ 2025-05-22       │
# ╰────────────┴───────────────────┴──────────────────╯
# ╭─────────┬────────────┬─────────╮
# │ Product │ Units Sold │ Revenue │
# ├─────────┼────────────┼─────────┤
# │ Banana  │        180 │ $144.00 │
# │ Apple   │        160 │ $240.00 │
# │ Orange  │        140 │ $168.00 │
# ╰─────────┴────────────┴─────────╯

pf()
# Executed in 0.42 second(s) in Ring 1.22

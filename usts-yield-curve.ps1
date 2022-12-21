
# function get-rrp-award-rate ()
# {
#     $result = Invoke-RestMethod 'https://fred.stlouisfed.org/graph/fredgraph.csv?id=RRPONTSYAWARD'
# 
#     $result | ConvertFrom-Csv
# }
# 
# $result_rrp_award_rate = get-rrp-award-rate | Where-Object RRPONTSYAWARD -NE '.'

# $result = Invoke-RestMethod 'https://home.treasury.gov/resource-center/data-chart-center/interest-rates/daily-treasury-rates.csv/2022/all?type=daily_treasury_yield_curve&field_tdr_date_value=2022&page&_format=csv'


# $result_effr = Invoke-RestMethod 'https://markets.newyorkfed.org/api/rates/unsecured/effr/last/10.json'

# $result_effr.refRates[0].targetRateFrom
# 
# $result_effr.refRates[0].targetRateTo

# ----------------------------------------------------------------------

function get-fed-funds-upper ()
{
    $result = Invoke-RestMethod 'https://fred.stlouisfed.org/graph/fredgraph.csv?id=DFEDTARU'

    $result | ConvertFrom-Csv
}

function get-fed-funds-lower ()
{
    $result = Invoke-RestMethod 'https://fred.stlouisfed.org/graph/fredgraph.csv?id=DFEDTARL'

    $result | ConvertFrom-Csv
}

$fed_funds_upper = get-fed-funds-upper
$fed_funds_lower = get-fed-funds-lower

# ----------------------------------------------------------------------

$year = Get-Date -Format 'yyyy'

# $year = 2020

$result = Invoke-RestMethod ('https://home.treasury.gov/resource-center/data-chart-center/interest-rates/daily-treasury-rates.csv/{0}/all?type=daily_treasury_yield_curve&field_tdr_date_value={0}&page&_format=csv' -f $year)

$table = $result | ConvertFrom-Csv | Sort-Object Date

foreach ($row in $table)
{
    $row.Date = Get-Date $row.Date -Format 'yyyy-MM-dd'
}

# foreach ($row in $table)
# {
#     '{0} {1}' -f $row.Date, $result_rrp_award_rate.Where({ $_.DATE -le $row.Date }, 'Last')[0].DATE
# }

foreach ($row in $table)
{
    $rrp = $result_rrp_award_rate.Where({ $_.DATE -le $row.Date }, 'Last')[0].RRPONTSYAWARD
        
    $row | Add-Member -MemberType NoteProperty -Name RRP -Value ([decimal] $rrp).ToString('F')
}

function color ($a, $b)
{
    if     ($b -gt $a) { 'Green' }
    elseif ($b -lt $a) { 'Red' }
    else               { 'White' }
}

#          2022-12-09   3.80  3.81  4.13  4.31  4.54  4.72  4.72  4.33  4.07  3.75  3.69  3.57  3.82  3.56
$header = 'Date         RRP   1 Mo  2 Mo  3 Mo  4 Mo  6 Mo  1 Yr  2 Yr  3 Yr  5 Yr  7 Yr  10 Yr 20 Yr 30 Yr'

Write-Host $header

foreach ($row in $table | Sort-Object Date)
{
    Write-Host ('{0} '  -f $row.Date)                                                        -NoNewline
    Write-Host ('{0,6}'  -f ([decimal] $row.'RRP').ToString('F'))                            -NoNewline
    Write-Host ('{0,6}'  -f $row.'1 Mo')  -ForegroundColor (color $row.'RRP'  $row.'1 Mo')   -NoNewline
    Write-Host ('{0,6}'  -f $row.'2 Mo')  -ForegroundColor (color $row.'1 Mo'  $row.'2 Mo')  -NoNewline
    Write-Host ('{0,6}'  -f $row.'3 Mo')  -ForegroundColor (color $row.'2 Mo'  $row.'3 Mo')  -NoNewline
    Write-Host ('{0,6}'  -f $row.'4 Mo')  -ForegroundColor (color $row.'3 Mo'  $row.'4 Mo')  -NoNewline
    Write-Host ('{0,6}'  -f $row.'6 Mo')  -ForegroundColor (color $row.'4 Mo'  $row.'6 Mo')  -NoNewline
    Write-Host ('{0,6}'  -f $row.'1 Yr')  -ForegroundColor (color $row.'6 Mo'  $row.'1 Yr')  -NoNewline
    Write-Host ('{0,6}'  -f $row.'2 Yr')  -ForegroundColor (color $row.'1 Yr'  $row.'2 Yr')  -NoNewline
    Write-Host ('{0,6}'  -f $row.'3 Yr')  -ForegroundColor (color $row.'2 Yr'  $row.'3 Yr')  -NoNewline
    Write-Host ('{0,6}'  -f $row.'5 Yr')  -ForegroundColor (color $row.'3 Yr'  $row.'5 Yr')  -NoNewline
    Write-Host ('{0,6}'  -f $row.'7 Yr')  -ForegroundColor (color $row.'5 Yr'  $row.'7 Yr')  -NoNewline
    Write-Host ('{0,6}'  -f $row.'10 Yr') -ForegroundColor (color $row.'7 Yr'  $row.'10 Yr') -NoNewline
    Write-Host ('{0,6}'  -f $row.'20 Yr') -ForegroundColor (color $row.'10 Yr' $row.'20 Yr') -NoNewline
    Write-Host ('{0,6}'  -f $row.'30 Yr') -ForegroundColor (color $row.'20 Yr' $row.'30 Yr') -NoNewline

    Write-Host
}

Write-Host $header

# --------------------------------------------------------------------------------

$json = @{
    chart = @{
        type = 'line'
        data = @{
            labels = 'RRP', '1 Mo', '2 Mo',  '3 Mo',  '4 Mo',  '6 Mo',  '1 Yr',  '2 Yr',  '3 Yr',  '5 Yr',  '7 Yr',  '10 Yr', '20 Yr', '30 Yr'
            datasets = @(
                @{
                    label = ('US Treasury Security Yield Curve : ' + $table[-1].Date)
                    data = $table[-1].'RRP', $table[-1].'1 Mo', $table[-1].'2 Mo', $table[-1].'3 Mo',  $table[-1].'4 Mo',  $table[-1].'6 Mo',  $table[-1].'1 Yr',  $table[-1].'2 Yr',  $table[-1].'3 Yr',  $table[-1].'5 Yr',  $table[-1].'7 Yr',  $table[-1].'10 Yr', $table[-1].'20 Yr', $table[-1].'30 Yr'
                    fill = $false
                }
            )
        }
        options = @{

            scales = @{ yAxes = @(@{ id = 'Y1' }) }

            annotation = @{

                annotations = @(

                    @{
                        type = 'line'; mode = 'horizontal'; value = $fed_funds_lower[-1].DFEDTARL; scaleID = 'Y1'; borderColor = 'red'; borderWidth = 1
                        label = @{
                            # enabled = $true
                            # content = 'Fed Funds Lower'
                            # position = 'end'
                        }
                    }

                    @{
                        type = 'line'; mode = 'horizontal'; value = $fed_funds_upper[-1].DFEDTARU; scaleID = 'Y1'; borderColor = 'red'; borderWidth = 1
                        label = @{
                            # enabled = $true
                            # content = 'Fed Funds Upper'
                        }
                    }
                )
            }

            plugins = @{ datalabels = @{ display = $true } }
        }
    }
} | ConvertTo-Json -Depth 100

$result_chart = Invoke-RestMethod -Method Post -Uri 'https://quickchart.io/chart/create' -Body $json -ContentType 'application/json'

# Start-Process $result_chart.url

$id = ([System.Uri] $result_chart.url).Segments[-1]

Start-Process ('https://quickchart.io/chart-maker/view/{0}' -f $id)
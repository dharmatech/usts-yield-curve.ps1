
Param([string[]] $years)

if ($years -eq $null)
{
    $years = @(Get-Date -Format 'yyyy')
}

# ----------------------------------------------------------------------

function get-rrp-award-rate ()
{
    $result = Invoke-RestMethod 'https://fred.stlouisfed.org/graph/fredgraph.csv?id=RRPONTSYAWARD'

    $result | ConvertFrom-Csv
}

$result_rrp_award_rate = get-rrp-award-rate | Where-Object RRPONTSYAWARD -NE '.'
# ----------------------------------------------------------------------

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

$table = @()

foreach ($year in $years)
{
    Write-Host "Retrieving year $year..." -ForegroundColor Yellow -NoNewline

    $result = Invoke-RestMethod ('https://home.treasury.gov/resource-center/data-chart-center/interest-rates/daily-treasury-rates.csv/{0}/all?type=daily_treasury_yield_curve&field_tdr_date_value={0}&page&_format=csv' -f $year)    

    Write-Host 'done'

    $table = $table + ($result | ConvertFrom-Csv)
}

foreach ($row in $table)
{
    $row.Date = Get-Date $row.Date -Format 'yyyy-MM-dd'
}

$table = $table | Sort-Object Date

foreach ($row in $table)
{
    $rrp = $result_rrp_award_rate.Where({ $_.DATE -le $row.Date }, 'Last')[0].RRPONTSYAWARD
        
    $row | Add-Member -MemberType NoteProperty -Name RRP -Value ([decimal] $rrp).ToString('F')
}
# ----------------------------------------------------------------------

# $table | Sort-Object Date | Select-Object -First 10 | ft *


# # $year = Get-Date -Format 'yyyy'

# # $year = Get-Date (Get-Date).AddDays(-365) -Format 'yyyy'

# # $year = 2020

# $year = 2023

# $result = Invoke-RestMethod ('https://home.treasury.gov/resource-center/data-chart-center/interest-rates/daily-treasury-rates.csv/{0}/all?type=daily_treasury_yield_curve&field_tdr_date_value={0}&page&_format=csv' -f $year)

# $table = $result | ConvertFrom-Csv | Sort-Object Date

# foreach ($row in $table)
# {
#     $row.Date = Get-Date $row.Date -Format 'yyyy-MM-dd'
# }

# # foreach ($row in $table)
# # {
# #     '{0} {1}' -f $row.Date, $result_rrp_award_rate.Where({ $_.DATE -le $row.Date }, 'Last')[0].DATE
# # }

# foreach ($row in $table)
# {
#     $rrp = $result_rrp_award_rate.Where({ $_.DATE -le $row.Date }, 'Last')[0].RRPONTSYAWARD
        
#     $row | Add-Member -MemberType NoteProperty -Name RRP -Value ([decimal] $rrp).ToString('F')
# }
# ----------------------------------------------------------------------
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

$prev = $table[-21]

$prev_day = $table[-2]

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
                    lineTension = 0
                }

                @{
                    label = ($prev_day.Date)
                    data = $prev_day.'RRP', $prev_day.'1 Mo', $prev_day.'2 Mo', $prev_day.'3 Mo',  $prev_day.'4 Mo',  $prev_day.'6 Mo',  $prev_day.'1 Yr',  $prev_day.'2 Yr',  $prev_day.'3 Yr',  $prev_day.'5 Yr',  $prev_day.'7 Yr',  $prev_day.'10 Yr', $prev_day.'20 Yr', $prev_day.'30 Yr'
                    fill = $false
                    lineTension = 0
                    hidden = $true
                }                                

                @{
                    label = ($prev.Date)
                    data = $prev.'RRP', $prev.'1 Mo', $prev.'2 Mo', $prev.'3 Mo',  $prev.'4 Mo',  $prev.'6 Mo',  $prev.'1 Yr',  $prev.'2 Yr',  $prev.'3 Yr',  $prev.'5 Yr',  $prev.'7 Yr',  $prev.'10 Yr', $prev.'20 Yr', $prev.'30 Yr'
                    fill = $false
                    lineTension = 0
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

# --------------------------------------------------------------------------------

# $table | Select-Object -First 10 | ft *

# $table.ForEach(
#     { 
#         foreach ($i in 0..13)
#         {
#             Get-Date (Get-Date $_.Date).AddMinutes(24 / 14 * 60 * $i) -Format 'yyyy-MM-dd HH:mm'
#         }
#     }
# )

# # $table.ForEach({ $_.RRP; $_.'1 Mo' })

# $table.ForEach({ $_.'RRP'; $_.'1 Mo'; $_.'2 Mo'; $_.'3 Mo'; $_.'4 Mo'; $_.'6 Mo'; $_.'1 Yr'; $_.'2 Yr'; $_.'3 Yr'; $_.'5 Yr'; $_.'7 Yr'; $_.'10 Yr'; $_.'20 Yr'; $_.'30 Yr'  })





# $json = @{
#     chart = @{
#         type = 'line'
#         data = @{
#             labels = $table.ForEach(
#                 { 
#                     foreach ($i in 0..13)
#                     {
#                         Get-Date (Get-Date $_.Date).AddMinutes(24 / 14 * 60 * $i) -Format 'yyyy-MM-dd HH:mm'
#                     }
#                 }
#             )

#             datasets = @(
#                 @{
#                     label = ('US Treasury Security Yield Curve : ' + $table[-1].Date)
#                     data = $table.ForEach({ $_.'RRP'; $_.'1 Mo'; $_.'2 Mo'; $_.'3 Mo'; $_.'4 Mo'; $_.'6 Mo'; $_.'1 Yr'; $_.'2 Yr'; $_.'3 Yr'; $_.'5 Yr'; $_.'7 Yr'; $_.'10 Yr'; $_.'20 Yr'; $_.'30 Yr'  })
#                     # fill = $false
#                     # lineTension = 0
#                 }
#             )
#         }
#         options = @{

#             scales = @{ yAxes = @(@{ id = 'Y1' }) }

#             annotation = @{

#                 annotations = @(

#                     @{
#                         type = 'line'; mode = 'horizontal'; value = $fed_funds_lower[-1].DFEDTARL; scaleID = 'Y1'; borderColor = 'red'; borderWidth = 1
#                         label = @{
#                             # enabled = $true
#                             # content = 'Fed Funds Lower'
#                             # position = 'end'
#                         }
#                     }

#                     @{
#                         type = 'line'; mode = 'horizontal'; value = $fed_funds_upper[-1].DFEDTARU; scaleID = 'Y1'; borderColor = 'red'; borderWidth = 1
#                         label = @{
#                             # enabled = $true
#                             # content = 'Fed Funds Upper'
#                         }
#                     }
#                 )
#             }

#             plugins = @{ datalabels = @{ display = $true } }
#         }
#     }
# } | ConvertTo-Json -Depth 100

# $result_chart = Invoke-RestMethod -Method Post -Uri 'https://quickchart.io/chart/create' -Body $json -ContentType 'application/json'

# # Start-Process $result_chart.url

# $id = ([System.Uri] $result_chart.url).Segments[-1]

# Start-Process ('https://quickchart.io/chart-maker/view/{0}' -f $id)

# --------------------------------------------------------------------------------

# $table | Select-Object -First 10 | ft *

$json = @{
    chart = @{
        # type = 'bar'
        type = 'line'
        data = @{
            labels = $table.ForEach({ $_.Date })

            datasets = @(
                @{ label = 'RRP';  data = $table.ForEach({ $_.RRP  });                              borderWidth = 2; fill = $false; pointRadius = 0; }
                @{ label = '1 Mo'; data = $table.ForEach({ $_.'1 Mo' })  ; borderColor = '#ff0000'; borderWidth = 2; fill = $true ; pointRadius = 0; borderDash = @(5, 5) }
                @{ label = '2 Mo'; data = $table.ForEach({ $_.'2 Mo' })  ; borderColor = '#ffaa00'; borderWidth = 2; fill = $false; pointRadius = 0; borderDash = @(5, 5) }
                @{ label = '3 Mo'; data = $table.ForEach({ $_.'3 Mo' })  ; borderColor = '#a1a106'; borderWidth = 2; fill = $false; pointRadius = 0; borderDash = @(5, 5) }
                @{ label = '4 Mo'; data = $table.ForEach({ $_.'4 Mo' })  ; borderColor = '#fac97a'; borderWidth = 2; fill = $false; pointRadius = 0; borderDash = @(5, 5) }
                @{ label = '6 Mo'; data = $table.ForEach({ $_.'6 Mo' })  ; borderColor = '#00ff00'; borderWidth = 2; fill = $false; pointRadius = 0; borderDash = @(5, 5) }
                @{ label = '1 Yr'; data = $table.ForEach({ $_.'1 Yr' })  ; borderColor = '#ff0000'; borderWidth = 2; fill = $false; pointRadius = 0; }
                @{ label = '2 Yr'; data = $table.ForEach({ $_.'2 Yr' })  ; borderColor = '#ffaa00'; borderWidth = 2; fill = $false; pointRadius = 0; }
                @{ label = '3 Yr'; data = $table.ForEach({ $_.'3 Yr' })  ; borderColor = '#a1a106'; borderWidth = 2; fill = $false; pointRadius = 0; }
                @{ label = '5 Yr'; data = $table.ForEach({ $_.'5 Yr' })  ; borderColor = '#00ff00'; borderWidth = 2; fill = $false; pointRadius = 0; }
                @{ label = '7 Yr'; data = $table.ForEach({ $_.'7 Yr' })  ; borderColor = '#00ffff'; borderWidth = 2; fill = $false; pointRadius = 0; }
                @{ label = '10 Yr'; data = $table.ForEach({ $_.'10 Yr' }); borderColor = '#0000ff'; borderWidth = 2; fill = $false; pointRadius = 0; }
                @{ label = '20 Yr'; data = $table.ForEach({ $_.'20 Yr' }); borderColor = '#aa00ff'; borderWidth = 2; fill = $false; pointRadius = 0; }
                @{ label = '30 Yr'; data = $table.ForEach({ $_.'30 Yr' }); borderColor = '#000000'; borderWidth = 2; fill = $false; pointRadius = 0; }
            )                        

        }
        options = @{ 

            title = @{ display = $true; text = 'Daily U.S. Treasury Par Yield Curve Rates: ' + ($years -join ', ') }

            # scales = @{
            #     xAxes = @(@{ stacked = $true })
            #     yAxes = @(@{ stacked = $true })
            # }

        }
    }
} | ConvertTo-Json -Depth 100

$result_chart = Invoke-RestMethod -Method Post -Uri 'https://quickchart.io/chart/create' -Body $json -ContentType 'application/json'

# Start-Process $result_chart.url

$id = ([System.Uri] $result_chart.url).Segments[-1]

Start-Process ('https://quickchart.io/chart-maker/view/{0}' -f $id)

exit
# --------------------------------------------------------------------------------

.\usts-yield-curve.ps1 -years 2021, 2022, 2023
.\usts-yield-curve.ps1 -years 2022, 2023
.\usts-yield-curve.ps1 -years 2023

# --------------------------------------------------------------------------------
$table = @()

foreach ($year in $years)
{
    Write-Host "Retrieving year $year..." -ForegroundColor Yellow -NoNewline

    $result = Invoke-RestMethod ('https://home.treasury.gov/resource-center/data-chart-center/interest-rates/daily-treasury-rates.csv/{0}/all?type=daily_treasury_yield_curve&field_tdr_date_value={0}&page&_format=csv' -f $year)    

    Write-Host 'done'

    $table = $table + ($result | ConvertFrom-Csv)
}

foreach ($row in $table)
{
    $row.Date = Get-Date $row.Date -Format 'yyyy-MM-dd'
}

$table = $table | Sort-Object Date

# $table_alt | Sort-Object Date | Select-Object -First 10 | ft *

foreach ($row in $table)
{
    $rrp = $result_rrp_award_rate.Where({ $_.DATE -le $row.Date }, 'Last')[0].RRPONTSYAWARD
        
    $row | Add-Member -MemberType NoteProperty -Name RRP -Value ([decimal] $rrp).ToString('F')
}

$table | Select-Object -First 10 | ft *





$result_2021 = Invoke-RestMethod ('https://home.treasury.gov/resource-center/data-chart-center/interest-rates/daily-treasury-rates.csv/{0}/all?type=daily_treasury_yield_curve&field_tdr_date_value={0}&page&_format=csv' -f 2021)
$result_2022 = Invoke-RestMethod ('https://home.treasury.gov/resource-center/data-chart-center/interest-rates/daily-treasury-rates.csv/{0}/all?type=daily_treasury_yield_curve&field_tdr_date_value={0}&page&_format=csv' -f 2022)
$result_2023 = Invoke-RestMethod ('https://home.treasury.gov/resource-center/data-chart-center/interest-rates/daily-treasury-rates.csv/{0}/all?type=daily_treasury_yield_curve&field_tdr_date_value={0}&page&_format=csv' -f 2023)

# $result_2022 | ConvertFrom-Csv | Select-Object -First 20 | ft *

# $table_alt = $result_2022 + $result_2023 | ConvertFrom-Csv

$table_alt = ($result_2021 | ConvertFrom-Csv) + ($result_2022 | ConvertFrom-Csv) + ($result_2023 | ConvertFrom-Csv)

foreach ($row in $table_alt)
{
    $row.Date = Get-Date $row.Date -Format 'yyyy-MM-dd'
}

$table_alt = $table_alt | Sort-Object Date

# $table_alt | Sort-Object Date | Select-Object -First 10 | ft *

foreach ($row in $table_alt)
{
    $rrp = $result_rrp_award_rate.Where({ $_.DATE -le $row.Date }, 'Last')[0].RRPONTSYAWARD
        
    $row | Add-Member -MemberType NoteProperty -Name RRP -Value ([decimal] $rrp).ToString('F')
}

$table_alt | Select-Object -First 10 | ft *

$table = $table_alt
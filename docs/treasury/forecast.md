# Cash Forecasting

Forecasts project future cash positions from scheduled inflows and outflows.

## Entities

- `CashForecast` — persisted forecast snapshot per period

## Services

- `ForecastService.generate` — builds `ForecastPoint` series via engine
- `ForecastService.liquiditySnapshot` — aggregates cash, bank, and petty cash

## Permissions

- `forecast.view` — access forecast page and reports

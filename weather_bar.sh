#!/bin/bash

source weather.sh


# Get weather glyph and temperature for status bar (e.g. waybar)
print_weather_bar() {
	get_weather
	weather_data=$(cat "$WEATHER_DATA_FILE")
	temperature=$(echo "$weather_data" | jq -r '.properties.timeseries[0].data.instant.details."air_temperature"')
	temperature=$(printf "%.0f" "$temperature")
	weather_code=$(echo "$weather_data" | jq -r '.properties.timeseries[0].data.next_1_hours.summary.symbol_code' | cut -d'_' -f1)
	echo "🌡️${temperature}°C $(get_weather_glyph "$weather_code")"
}

print_weather_bar

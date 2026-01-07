#!/bin/bash

# Get the directory of the current script
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

source "$SCRIPT_DIR"/weather.sh

# Get weather glyph and temperature for status bar (e.g. waybar)
print_weather_bar() {
	get_weather
	TODAY=$(date +%Y-%m-%d)
	weather_data=$(cat "$WEATHER_DATA_FILE")
	sun_data=$(cat "$SUN_DATA_FILE")
	temperature=$(echo "$weather_data" | jq -r '.properties.timeseries[0].data.instant.details."air_temperature"')
	humidity=$(echo "$weather_data" | jq -r '.properties.timeseries[0].data.instant.details."relative_humidity"')
	weather_code=$(echo "$weather_data" | jq -r '.properties.timeseries[0].data.next_1_hours.summary.symbol_code' | cut -d'_' -f1)
	wind_speed=$(echo "$weather_data" | jq -r '.properties.timeseries[0].data.instant.details."wind_speed"')
	precipitation=$(echo "$weather_data" | jq -r '.properties.timeseries[0].data.next_1_hours.details."precipitation_amount"')
	precipitation_6=$(echo "$weather_data" | jq -r '.properties.timeseries[0].data.next_6_hours.details."precipitation_amount"')
	sunrise=$(echo "$sun_data" | jq -r '.properties.sunrise.time' | cut -d'+' -f1 | cut -d'T' -f2)
	sunset=$(echo "$sun_data" | jq -r '.properties.sunset.time' | cut -d'+' -f1 | cut -d'T' -f2)
	max_temp=$(echo "$weather_data" | jq -r --arg today "$TODAY" '[.properties.timeseries[] | select((.time | fromdateiso8601 | strftime("%Y-%m-%d")) == $today) | .data.instant.details.air_temperature] | max // 0')
	min_temp=$(echo "$weather_data" | jq -r --arg today "$TODAY" '[.properties.timeseries[] | select((.time | fromdateiso8601 | strftime("%Y-%m-%d")) == $today) | .data.instant.details.air_temperature] | min // 0')
	max_wind=$(echo "$weather_data" | jq -r --arg today "$TODAY" '[.properties.timeseries[] | select((.time | fromdateiso8601 | strftime("%Y-%m-%d")) == $today) | .data.instant.details.wind_speed] | max // 0')

	# echo "📅 ${TODAY} $(get_weather_glyph "$weather_code")"
  # echo "🌡️ ${temperature}°C (H: ${max_temp}°C L: ${min_temp}°C)"
	# echo "🌬️ ${wind_speed} m/s (H: ${max_wind} m/s)"
	# echo "☀️ $(date -d "$sunrise" +%H:%M) 🌙 $(date -d "$sunset" +%H:%M)"
	# echo "🌧️ ${precipitation}mm (next 6 hours ${precipitation_6}mm)"
	# echo "💧 humidity ${humidity}%"
	temperature=$(printf "%.0f" "$temperature")
	echo "{\"text\": \"🌡️${temperature}°C $(get_weather_glyph "$weather_code")\", \"tooltip\": \"🌡️Temperature 🔥 ${max_temp}°C ❄️ ${min_temp}°C\n☀️ $(date -d "$sunrise" +%H:%M) 🌙 $(date -d "$sunset" +%H:%M)\n🌧️ ${precipitation}mm (next 6 hours ${precipitation_6}mm)\"}"
}

print_weather_bar

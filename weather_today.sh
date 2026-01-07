#!/bin/bash

source weather.sh


# Print detailed weather for today
print_weather_today() {
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

  declare -n code_array=$(get_weather_code "$weather_code")
	echo "📅 ${TODAY} |"
	echo "--------------┼--------------------------------"
	echo "${code_array[0]} | 🌡️ ${temperature}°C (H: ${max_temp}°C L: ${min_temp}°C)"
	echo "${code_array[1]} | 🌬️ ${wind_speed} m/s (H: ${max_wind} m/s)"
	echo "${code_array[2]} | ☀️ $(date -d "$sunrise" +%H:%M) 🌙 $(date -d "$sunset" +%H:%M)"
	echo "${code_array[3]} | 🌧️ ${precipitation}mm (next 6 hours ${precipitation_6}mm)"
	echo "${code_array[4]} | 💧 humidity ${humidity}%"
}

print_weather_today

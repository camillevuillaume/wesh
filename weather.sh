#!/bin/bash

source ascii-art.sh
CONFIG_FILE=$HOME/.config/wesh/wesh.conf
CONFIG_DIR=$HOME/.config/wesh/
WEATHER_DATA_FILE="$CONFIG_DIR/weather_data.json"
SUN_DATA_FILE="$CONFIG_DIR/sun_data.json"

#load config file
load_config() {
	CONFIG_FILE="$HOME/.config/wesh/wesh.conf"
	if [[ -f "$CONFIG_FILE" ]]; then
		source "$CONFIG_FILE"
	else
		echo "Config file not found!"
	fi
}

# get location from ip address and write it to config file
get_location() {
	if [ ! -d $CONFIG_DIR ]; then
		mkdir -p $CONFIG_DIR
	fi
	if [ ! -f $CONFIG_FILE ]; then
		touch $CONFIG_FILE
	fi

	data=$(curl -s "https://ipapi.co/json")
	lat=$(echo "$data" | jq -r '.latitude')
	lon=$(echo "$data" | jq -r '.longitude')
	echo "Detected location: Latitude=$lat, Longitude=$lon"
	# Update or append LATITUDE
	grep -q "^LATITUDE=" "$CONFIG_FILE" && sed -i "s/^LATITUDE=.*/LATITUDE=$lat/" "$CONFIG_FILE" || echo "LATITUDE=$lat" >>"$CONFIG_FILE"
	# Update or append LONGITUDE
	grep -q "^LONGITUDE=" "$CONFIG_FILE" && sed -i "s/^LONGITUDE=.*/LONGITUDE=$lon/" "$CONFIG_FILE" || echo "LONGITUDE=$lon" >>"$CONFIG_FILE"
	source "$CONFIG_FILE"
}

# get weather and sun data from met.no API and store them in files
get_weather() {
	load_config
	# get location if not set
	if [[ -z "$LATITUDE" || -z "$LONGITUDE" ]]; then
		get_location
	fi

	# check if data is older than 1 hour or files do not exist
	timestamp=$(date +%s)
	if [[ -z "$TIMESTAMP" || $((timestamp - TIMESTAMP)) -gt 3600 || ! -f $WEATHER_DATA_FILE || ! -f $SUN_DATA_FILE ]]; then
		# Update or append TIMESTAMP
		grep -q "^TIMESTAMP=" "$CONFIG_FILE" && sed -i "s/^TIMESTAMP=.*/TIMESTAMP=$timestamp/" "$CONFIG_FILE" || echo "TIMESTAMP=$timestamp" >>"$CONFIG_FILE"
		#get weather data
		weather=$(curl -A "wesh (https://github.com/camillevuillaume)" -X GET --header "Accept: application.json" "https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=$LATITUDE&lon=$LONGITUDE")

		#get sun data with timezone offset
		offset_encoded=$(date +%:z | sed 's/+/%2B/g; s/:/%3A/g')
		sun_data=$(curl -A "wesh (https://github.com/camillevuillaume)" -X GET --header "Accept: application.json" "https://api.met.no/weatherapi/sunrise/3.0/sun?lat=$LATITUDE&lon=$LONGITUDE&offset=$offset_encoded")

		# Write weather data to file
		echo "$weather" >"$WEATHER_DATA_FILE"
		echo "$sun_data" >"$SUN_DATA_FILE"
	fi
}

print_weather_bar() {
	get_weather
	weather_data=$(cat "$WEATHER_DATA_FILE")
	temperature=$(echo "$weather_data" | jq -r '.properties.timeseries[0].data.instant.details."air_temperature"')
	temperature=$(printf "%.0f" "$temperature")
	weather_code=$(echo "$weather_data" | jq -r '.properties.timeseries[0].data.next_1_hours.summary.symbol_code' | cut -d'_' -f1)
	echo "🌡️${temperature}°C $(get_weather_glyph $weather_code)"
}

print_weather_short() {
	get_weather
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
	TODAY=$(date +%Y-%m-%d)
	max_temp=$(echo "$weather_data" | jq -r --arg today "$TODAY" '[.properties.timeseries[] | select((.time | fromdateiso8601 | strftime("%Y-%m-%d")) == $today) | .data.instant.details.air_temperature] | max // 0')
	min_temp=$(echo "$weather_data" | jq -r --arg today "$TODAY" '[.properties.timeseries[] | select((.time | fromdateiso8601 | strftime("%Y-%m-%d")) == $today) | .data.instant.details.air_temperature] | min // 0')
  max_wind=$(echo "$weather_data" | jq -r --arg today "$TODAY" '[.properties.timeseries[] | select((.time | fromdateiso8601 | strftime("%Y-%m-%d")) == $today) | .data.instant.details.wind_speed] | max // 0')

  code_name=$(get_weather_code "$weather_code")
  declare -n code_array="$code_name"
  echo "📅 $TODAY |"
  echo "--------------┼--------------------------------"
  echo "${code_array[0]} | 🌡️ ${temperature}°C (H: ${max_temp}°C L: ${min_temp}°C)"
  echo "${code_array[1]} | 🌬️ ${wind_speed} m/s (H: ${max_wind} m/s)"
  echo "${code_array[2]} | ☀️ $(date -d $sunrise +%H:%M) 🌙 $(date -d $sunset +%H:%M)"
  echo "${code_array[3]} | 🌧️ ${precipitation}mm (next 6 hours ${precipitation_6}mm)"
  echo "${code_array[4]} | 💧 humidity ${humidity}%"
}

print_weather_bar
print_weather_short

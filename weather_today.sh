#!/bin/bash

PRECIPITATION_HOURS=6

# Get the directory of the current script
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

source "$SCRIPT_DIR"/weather.sh

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

	declare -n code_array="$(get_weather_code "$weather_code")"
	echo "    TODAY     |      📅 ${TODAY} "
	echo "--------------┼-------------------------------"
	echo "${code_array[0]} | 🌡️ ${temperature}°C (🔥 ${max_temp}°C ❄️ ${min_temp}°C)"
	echo "${code_array[1]} | 🌬️ ${wind_speed} m/s (H: ${max_wind} m/s)"
	echo "${code_array[2]} | ☀️ $(date -d "$sunrise" +%H:%M) 🌙 $(date -d "$sunset" +%H:%M)"
	echo "${code_array[3]} | 🌧️ ${precipitation}mm (next 6h ${precipitation_6}mm)"
	echo "${code_array[4]} | 💧 humidity ${humidity}%"
}

# Display a bar representing precipitation intensity
print_precipitation_intensity() {
  local intensity=$1
  if (( $(echo "$intensity < 0.1" | bc -l) )); then
    echo -e "\033[90m-\033[0m"
  elif (( $(echo "$intensity < 2.5" | bc -l) )); then
    echo -e "\033[34m█\033[0m"
  elif (( $(echo "$intensity < 7.6" | bc -l) )); then
    echo -e "\033[34m██\033[0m"
  elif (( $(echo "$intensity < 50" | bc -l) )); then
    echo -e "\033[34m███\033[0m"
  else
    echo -e "\033[34m████\033[0m"
  fi
}

# Print precipitation forecast for the next N hours
# Arguments:
# 1: number of hours
print_precipitations() {
  get_weather
  TODAY=$(date +%Y-%m-%d)
  hour_start=$(date +%H)
  hour_start=$((10#$hour_start))
  hour_end=$((hour_start + $1))
  if [ "$hour_end" -gt 23 ]; then
    hour_end=23
  fi
  weather_data=$(cat "$WEATHER_DATA_FILE")
  echo "   🕐 Time    |   🌧️ Precipitation (mm)"
  echo "--------------┼-------------------------------"
  for hour in $(seq "$hour_start" "$hour_end"); do
    time_slot=$(date -d "${TODAY} ${hour}:00" +%Y-%m-%dT%H:%M:%SZ)
    precipitation=$(echo "$weather_data" | jq -r --arg time_slot "$time_slot" '.properties.timeseries[] | select(.time == $time_slot) | .data.next_1_hours.details."precipitation_amount" // 0')
    # printf "%s | %.2f\n" "$(date -d "$time_slot" +%H:%M)" "$precipitation"
    precipitation=$(printf "%.1f" "$precipitation")
    intensity_bar=$(print_precipitation_intensity "$precipitation")
    printf "   %02d:00      | %smm %s\n" "$hour" "$precipitation" "$intensity_bar"
    # echo "DEBUG: time_slot=$time_slot" >&2
    # echo "DEBUG: precipitation=$precipitation" >&2
  done
}

print_weather_next() {
	get_weather
  if [ "$1" == "tomorrow" ]; then
    DAY_OFFSET=1
  elif [ "$1" == "day_after_tomorrow" ]; then
    DAY_OFFSET=2
  else
    DAY_OFFSET=0
  fi
  TODAY=$(date -d "+$DAY_OFFSET day" +%Y-%m-%d)

  if [ "$DAY_OFFSET" -eq 0 ]; then
    label="TODAY"
  elif [ "$DAY_OFFSET" -eq 1 ]; then
    label="TOMORROW"
  else
    label=$(date -d "+$DAY_OFFSET day" +%A | tr '[:lower:]' '[:upper:]')
  fi
	
  weather_data=$(cat "$WEATHER_DATA_FILE")
  # find time series index for 06:00 tomorrow
  time_slot=$(date -d "${TODAY} 01:00" +%Y-%m-%dT%H:%M:%SZ)
  morning_symbol_code=$(echo "$weather_data" | jq -r --arg time_slot "$time_slot" '.properties.timeseries[] | select(.time == $time_slot) | .data.next_6_hours.summary.symbol_code' | cut -d'_' -f1)
  # find time series index for 12:00 tomorrow
  time_slot=$(date -d "${TODAY} 12:00" +%Y-%m-%dT%H:%M:%SZ)
  noon_symbol_code=$(echo "$weather_data" | jq -r --arg time_slot "$time_slot" '.properties.timeseries[] | select(.time == $time_slot) | .data.next_6_hours.summary.symbol_code' | cut -d'_' -f1)
  # find time series index for 18:00 tomorrow
  time_slot=$(date -d "${TODAY} 18:00" +%Y-%m-%dT%H:%M:%SZ)
  evening_symbol_code=$(echo "$weather_data" | jq -r --arg time_slot "$time_slot" '.properties.timeseries[] | select(.time == $time_slot) | .data.next_6_hours.summary.symbol_code' | cut -d'_' -f1)

	max_temp=$(echo "$weather_data" | jq -r --arg today "$TODAY" '[.properties.timeseries[] | select((.time | fromdateiso8601 | strftime("%Y-%m-%d")) == $today) | .data.instant.details.air_temperature] | max // 0')
  max_temp=$(printf "%.0f" "$max_temp")
	min_temp=$(echo "$weather_data" | jq -r --arg today "$TODAY" '[.properties.timeseries[] | select((.time | fromdateiso8601 | strftime("%Y-%m-%d")) == $today) | .data.instant.details.air_temperature] | min // 0')
  min_temp=$(printf "%.0f" "$min_temp")

  declare -n code_array_m="$(get_weather_code "$morning_symbol_code")"
  declare -n code_array_n="$(get_weather_code "$noon_symbol_code")"
  declare -n code_array_e="$(get_weather_code "$evening_symbol_code")"
	printf " %-12s | 📅 %s  🔥%s°C ❄️%s°C\n" "$label" "$TODAY" "$max_temp" "$min_temp"
	# echo "   TOMORROW   | 📅 ${TODAY} | 🔥${max_temp}°C ❄️${min_temp}°C"
  echo "   Morning    |      Noon     |    Evening    "
	echo "--------------┼---------------┼---------------"
	echo "${code_array_m[0]} | ${code_array_n[0]} | ${code_array_e[0]}"
	echo "${code_array_m[1]} | ${code_array_n[1]} | ${code_array_e[1]}"
	echo "${code_array_m[2]} | ${code_array_n[2]} | ${code_array_e[2]}"
	echo "${code_array_m[3]} | ${code_array_n[3]} | ${code_array_e[3]}"
	echo "${code_array_m[4]} | ${code_array_n[4]} | ${code_array_e[4]}"
}

print_weather_today
echo 
print_precipitations $PRECIPITATION_HOURS
echo
print_weather_next tomorrow
echo
print_weather_next day_after_tomorrow
read -s -n 1

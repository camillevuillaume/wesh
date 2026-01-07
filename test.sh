#!/bin/bash

source weather.sh

test_codes() {
	# 	print_weather_short "$weather_code" "$temperature" "$max_temp" "$min_temp" "$wind_speed" "$max_wind" "$sunrise" "$sunset" "$precipitation" "$precipitation_6" "$humidity"
	print_weather_short "code_cloudy" "15" "20" "10" "5" "10" "06:00" "18:00" "2" "5" "80" "2024-03-15"
	print_weather_short "code_fog" "10" "15" "5" "3" "8" "07:00" "19:00" "0" "1" "90" "2024-07-22"
	print_weather_short "code_heavy_rain" "12" "18" "8" "6" "12" "05:30" "17:30" "10" "20" "85" "2024-11-08"
	print_weather_short "code_heavy_showers" "14" "19" "9" "4" "11" "06:15" "18:15" "8" "15" "75" "2024-02-14"
	print_weather_short "code_heavy_snow" "-2" "0" "-5" "2" "6" "04:45" "16:45" "15" "25" "70" "2024-12-30"
	print_weather_short "code_heavy_snow_showers" "-1" "1" "-4" "3" "7" "05:15" "17:15" "12" "22" "65" "2024-01-18"
	print_weather_short "code_light_rain" "16" "21" "11" "5" "9" "06:30" "18:30" "3" "7" "80" "2024-09-05"
	print_weather_short "code_light_showers" "18" "23" "13" "4" "8" "07:30" "19:30" "4" "9" "75" "2024-06-11"
	print_weather_short "code_light_sleet" "2" "6" "-1" "3" "5" "05:00" "17:00" "6" "12" "70" "2024-10-27"
	print_weather_short "code_light_sleet_showers" "3" "7" "0" "4" "6" "05:30" "17:30" "5" "10" "65" "2024-04-19"
	print_weather_short "code_light_snow" "0" "4" "-3" "2" "4" "04:30" "16:30" "8" "15" "60" "2024-01-09"
  print_weather_short "code_light_snow_showers" "1" "5" "-2" "3" "5" "05:00" "17:00" "7" "13" "55" "2024-12-03"
  print_weather_short "code_partly_cloudy" "20" "25" "15" "4" "7" "06:45" "18:45" "1" "3" "50" "2024-08-16"
  print_weather_short "code_sunny" "22" "27" "17" "3" "6" "07:00" "19:00" "0" "1" "40" "2024-05-28"
  print_weather_short "code_thundery_heavy_rain" "14" "19" "9" "7" "13" "05:15" "17:15" "12" "22" "85" "2024-07-04"
  print_weather_short "code_thundery_showers" "16" "21" "11" "5" "6" "06:00" "18:00" "8" "15" "80" "2024-03-21"
  print_weather_short "code_thundery_snow_showers" "0" "3" "-2" "4" "7" "05:45" "17:45" "10" "18" "75" "2024-11-14"




}

test_codes

#!/bin/bash

source weather.sh

test_codes() {
	print_weather "code_cloudy" "20" "10" "10" "5" "06:00" "18:00" "2" "80" "2024-03-15"
	print_weather "code_fog" "15" "5" "8" "3" "07:00" "19:00" "0" "90" "2024-07-22"
	print_weather "code_heavy_rain" "18" "8" "12" "6" "05:30" "17:30" "10" "85" "2024-11-08"
	print_weather "code_heavy_showers" "19" "9" "11" "4" "06:15" "18:15" "8" "75" "2024-02-14"
	print_weather "code_heavy_snow" "0" "-5" "6" "2" "04:45" "16:45" "15" "70" "2024-12-30"
	print_weather "code_heavy_snow_showers" "1" "-4" "7" "3" "05:15" "17:15" "12" "65" "2024-01-18"
	print_weather "code_light_rain" "21" "11" "9" "5" "06:30" "18:30" "3" "80" "2024-09-05"
	print_weather "code_light_showers" "23" "13" "8" "4" "07:30" "19:30" "4" "75" "2024-06-11"
	print_weather "code_light_sleet" "6" "-1" "5" "3" "05:00" "17:00" "6" "70" "2024-10-27"
	print_weather "code_light_sleet_showers" "7" "0" "6" "4" "05:30" "17:30" "5" "65" "2024-04-19"
	print_weather "code_light_snow" "4" "-3" "4" "2" "04:30" "16:30" "8" "60" "2024-01-09"
	print_weather "code_light_snow_showers" "5" "-2" "5" "3" "05:00" "17:00" "7" "55" "2024-12-03"
	print_weather "code_partly_cloudy" "25" "15" "7" "4" "06:45" "18:45" "1" "50" "2024-08-16"
	print_weather "code_sunny" "27" "17" "6" "3" "07:00" "19:00" "0" "40" "2024-05-28"
	print_weather "code_thundery_heavy_rain" "19" "9" "13" "7" "05:15" "17:15" "12" "85" "2024-07-04"
	print_weather "code_thundery_showers" "21" "11" "6" "5" "06:00" "18:00" "8" "80" "2024-03-21"
	print_weather "code_thundery_snow_showers" "3" "-2" "7" "4" "05:45" "17:45" "10" "75" "2024-11-14"
}

test_codes

# wesh

Weather forecast from the Linux terminal.

## Dependencies

This has only been tested on Linux. You will need the following dependencies:
- A nerd font for glyphs.
- curl
- jq

The scripts are using the following free APIs:
- [met.no](https://api.met.no/weatherapi/locationforecast/2.0/documentation) for weather data.
- Optionally [ipapi.co](https://ipapi.co/) for geolocation data.

Note that these APIs have usage policies and rate limits. Please refer to their respective documentation for more details. In particular, met.no is one of the few weather APIs that allow free access without registration, but they ask users not to exceed 1 request per hour. The scripts implement basic caching to help with this, so do not modify their behavior in a way that would increase the request frequency.

## Usage

For a status bar like waybar, you can use the following scripts:
- `weather_bar.sh`: Displays current temperature and a glyph for the current weather.
- `weather_today.sh`: Displays more informations about the weather forecast for the current day. This can be associated with a tooltip showing more details or a popup when clicked.

The scripts write a config and cache files to `~/.config/wesh/`. It is recommended to edit the location information manually for better precision, instead of relying on IP based geolocation. 

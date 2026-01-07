# wesh

Weather forecast from the Linux terminal, providing weather information in the status bar, tooltip and detailed forecast over three days.

<img width="1110" height="1073" alt="image" src="https://github.com/user-attachments/assets/04a102a5-3a98-4808-97bc-3e8605ff90cf" />

!NOTE All units are in metric system (Celsius, meters per second, etc.).

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

## Waybar configuration examples

### Waybar

Here is an example of a custom module in `modules.jsonc` for waybar and Kitty. It is assumed that the scripts are located in `~/.config/waybar/wesh/`. The module displays the weather glyph and temperature, gives mroe details on hover, and opens a floating Kitty window with a more detailed forecast over 3 days when clicked.

```json
   "custom/weather": {
    "exec-if": "test -f ~/.config/waybar/wesh/weather_bar.sh",
    "exec": "~/.config/waybar/wesh/weather_bar.sh",
    "return-type": "json",
    "interval": 3600,
    "on-click": "kitty --title FloatingKitty -o remember_window_size=no -o initial_window_width=46c -o initial_window_height=36c ~/.config/waybar/wesh/weather_today.sh"
  },
```
### Niri and Hyprland window rule

To open Kitty as a floating window when clicking on the weather module, you can add the following rule to Niri's configuration file (`~/.config/niri/config.toml`):

```ini
window-rule {
    match title="FloatingKitty"
    open-floating true
}
```
This rule matches any window with the title "floatingkitty" and opens it as a floating window.

Here is the corresponding rule for Hyprland (`~/.config/hypr/hyprland.conf`):

```ini
# match by title
windowrule {
  name = floatingkitty
  match:title = FloatingKitty

  float = true
}
```



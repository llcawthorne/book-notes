#!/usr/bin/env python
import json

import requests

city_name = "San Francisco"
state_code = "CA"
country_code = "US"
API_key = "dummy_API_key"

response = requests.get(
    f"https://api.openweathermap.org/geo/1.0/direct?q={city_name},{state_code},{country_code}&appid={API_key}"
)
response.raise_for_status()

# json.loads returns Python data structures
response_data = json.loads(response.text)

# We need the lat and lon from this response to make a weather request
# You could play with this at a repl to find the response structure
# At index 0 is a map that includes many keys including 'lat' and 'lon'
# There is only index 0 if your request matched one city/state/country
lat = response_data[0]["lat"]
lon = response_data[0]["lon"]

response = requests.get(
    f"https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API_key}"
)

# If you entered an invalid lat/lon, your response.text would look like:
# {"cod":"400", "message":"wrong lattitude"}
response_data = json.loads(response.text)

# This response body is documented in the API docs and can be seen by manually
# fetching the API URL in a browser
weather_summary = response_data["weather"][0]["main"]
weather_detail = response_data["weather"][0]["description"]
temp_kelvin = response_data["main"]["temp"]
feels_like_kelvin = response_data["main"]["feels_like"]
temp_celsius = round(temp_kelvin - 273.15, 1)
temp_farenheit = round(temp_kelvin * (9 / 5) - 459.67, 1)
humidity_percentage = response_data["main"]["humidity"]

print(
    f"The temperature in {city_name}, {state_code}, {country_code} is {temp_celsius} C/{temp_farenheit} F"
)

# You could make a request against:
# https://api.openweathermap.org/data/2.5/forecast?lat=%7Blat%7D&lon=%7Blon%7D%26appid=%7BAPI_key%7D
# for a five day forecast. Notably response_data['list'][0]['dt'] holds a
# timestamp that can be passed to `datetime.datetime.fromtimestamp()` to get
# the date, response_data['list'][0]['main'] Holds the temperature and
# humidity like an current forecast, and response_data['list'][0]['weather']
# holds a dictionary with 'main', 'description' and other keys like the
# "weather" element of an immediate forecast
# In total, response_data['list'] holds 40 dictionaries with forecasts
# at three-hour increments for the next five days, although this could change

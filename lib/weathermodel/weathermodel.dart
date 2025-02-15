class Weather {

  final String cityName;
  final double temperature;
  final String mainCondition;
  final String maindesc;
  final double windspeed;
  final int cloudiness;
  final double tempmin;
  final double tempmax;
  final int humidity;
  final int pressure;
  final int degrees;
  final double windgust;
  final int visible;
  final double feelslike;
  final int sunriseTimestamp;
  final int sunsetTimestamp;
  final int timezone;
  final int lastUpdate;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
    required this.maindesc,
    required this.windspeed,
    required this.cloudiness,
    required this.tempmin,
    required this.tempmax,
    required this.humidity,
    required this.pressure,
    required this.degrees,
    required this.windgust,
    required this.visible,
    required this.feelslike,
    required this.sunriseTimestamp,
    required this.sunsetTimestamp,
    required this.timezone,
     required this.lastUpdate,
  
  });
  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      mainCondition: json['weather'][0]['main'],
      maindesc: json['weather'][0]['description'],
      windspeed: json['wind']['speed'].toDouble(),
      cloudiness: json['clouds']['all'],
      tempmin: json['main']['temp_min'].toDouble(), 
      tempmax: json['main']['temp_max'].toDouble(), // Convert to double
      humidity: json['main']['humidity'],
      pressure: json['main']['pressure'],
      degrees: json['wind']['deg'],
      windgust:  json['wind']['gust'] != null ? json['wind']['gust'].toDouble() : 0.00,
      visible: json['visibility'],
      feelslike: json['main']['feels_like'] !=null ? json['main']['feels_like'].toDouble() : 0.00,
      sunriseTimestamp: json['sys']['sunrise'],
      sunsetTimestamp: json['sys']['sunset'],
      timezone: json['timezone'],
      lastUpdate: json['dt'],
    );

    
  }

    Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'temperature': temperature,
      'mainCondition': mainCondition,
      'maindesc': maindesc,
      'windspeed': windspeed,
      'cloudiness': cloudiness,
      'tempmin': tempmin,
      'tempmax': tempmax,
      'humidity': humidity,
      'pressure': pressure,
      'degrees': degrees,
      'windgust': windgust,
      'visible': visible,
      'feelslike': feelslike,
      'sunriseTimestamp': sunriseTimestamp,
      'sunsetTimestamp': sunsetTimestamp,
      'timezone': timezone,
      'lastUpdate': lastUpdate,
    };
  }

   DateTime get sunriseDateTime =>
      DateTime.fromMillisecondsSinceEpoch(sunriseTimestamp * 1000, isUtc: true).toLocal();

  DateTime get sunsetDateTime =>
      DateTime.fromMillisecondsSinceEpoch(sunsetTimestamp * 1000, isUtc: true).toLocal();

  DateTime get datacalc=>
      DateTime.fromMillisecondsSinceEpoch(lastUpdate * 1000, isUtc: true).toLocal();

}


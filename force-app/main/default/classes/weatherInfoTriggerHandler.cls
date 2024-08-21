public class weatherInfoTriggerHandler{

    @future(callout=true)
    public static void getWeatherForLocation(Set<Id> weatherIds) {
        // Query the Weather Info records based on the passed IDs
        List<WeatherInfo__c> weatherUpdateLst = new List<WeatherInfo__c>();
        List<WeatherInfo__c> weathers = [SELECT Id, Location__r.Name, Location__r.Country__c FROM WeatherInfo__c WHERE Id IN :weatherIds];

        // OpenWeatherMap API Key
        String apiKey = System.Label.OpenWeather_API;

        // Prepare an HTTP instance
        Http http = new Http();

        // Loop through the weather info records and make the API call for each
        for (WeatherInfo__c weatherInfo : weathers) {
            String city = weatherInfo.Location__r.Name != null ? weatherInfo.Location__r.Name : 'London';
            String country = weatherInfo.Location__r.Country__c != null ? weatherInfo.Location__r.Country__c : 'UK';

            String url = System.Label.OpenWeather_Base_URL + 'data/2.5/weather?q=' +
                         EncodingUtil.urlEncode(city + ',' + country, 'UTF-8') +
                         '&appid=' + apiKey;

            HttpRequest request = new HttpRequest();
            request.setEndpoint(url);
            request.setMethod('GET');

            try {
                HttpResponse response = http.send(request);
                if (response.getStatusCode() == 200) {
                    Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

                    if (jsonResponse!=null) {
                        Map<String, Object> mainData = (Map<String, Object>) jsonResponse.get('main');
                        List<Object> weatherList = (List<Object>) jsonResponse.get('weather');
                        Map<String, Object> weatherDescription = (Map<String, Object>) weatherList[0];


                        Decimal temp = (Decimal) mainData.get('temp');
                        Decimal minTemp = (Decimal) mainData.get('temp_min');
                        Decimal maxTemp = (Decimal) mainData.get('temp_max');
                        Decimal humidity = (Decimal) mainData.get('humidity');
                        String icon = (String) weatherDescription.get('icon');
                        String iconUrl = System.Label.OpenWeather_Base_URL+'img/wn/' + icon + '@2x.png';

                        weatherInfo.Temprature__c = temp - 273.15; // Convert from Kelvin to Celsius 
                        weatherInfo.Min_Temprature__c = minTemp - 273.15; // Convert from Kelvin to Celsius
                        weatherInfo.Max_Temprature__c = maxTemp - 273.15; // Convert from Kelvin to Celsius
                        weatherInfo.Humidity__c = humidity;
                        weatherInfo.Description__c = (String)weatherDescription.get('description');
                        weatherInfo.Icon__c = iconUrl;
                        weatherUpdateLst.add(weatherInfo);
                    }

                } else {
                    System.debug('Error: ' + response.getStatus());
                }
            } catch (Exception e) {
                System.debug('Exception: ' + e.getMessage());
            }
        }
        
        if(weatherUpdateLst.size()>0) {
        update weatherUpdateLst;
        }
    }
}
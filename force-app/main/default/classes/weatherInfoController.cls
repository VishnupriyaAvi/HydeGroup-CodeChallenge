public class weatherInfoController{

    @AuraEnabled(cacheable=true)
    public static List<WeatherInfo__c> getWeatherData(Id locationId) {
        return [SELECT Id, Max_Temprature__c, Min_Temprature__c, Temprature__c, Humidity__c, LastModifiedDate, Location__r.Name, Location__r.Country__c , Description__c, Icon__c FROM WeatherInfo__c WHERE Location__c =: locationId LIMIT 10];
    }
}
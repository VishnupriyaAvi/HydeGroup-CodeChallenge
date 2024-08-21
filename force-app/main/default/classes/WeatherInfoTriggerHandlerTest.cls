@isTest
public class WeatherInfoTriggerHandlerTest {

    @isTest
    static void testGetWeatherForLocation() {
        // Set up test data
        Location__c testLocation = new Location__c(Name = 'Test City', Country__c = 'TC');
        insert testLocation;

        WeatherInfo__c testWeatherInfo = new WeatherInfo__c(Location__c = testLocation.Id);
        insert testWeatherInfo;

        Set<Id> weatherIds = new Set<Id>{testWeatherInfo.Id};

        // Set up the mock response
        System.Test.setMock(HttpCalloutMock.class, new WeatherInfoCalloutMock());

        // Call the future method
        Test.startTest();
        WeatherInfoTriggerHandler.getWeatherForLocation(weatherIds);
        Test.stopTest();

        // Query the updated WeatherInfo record
        WeatherInfo__c updatedWeatherInfo = [SELECT Id, Temprature__c, Min_Temprature__c, Max_Temprature__c, 
                                             Humidity__c, Description__c, Icon__c 
                                             FROM WeatherInfo__c WHERE Id = :testWeatherInfo.Id];

        // Assertions
        System.assertNotEquals(null, updatedWeatherInfo.Temprature__c);
        System.assertNotEquals(null, updatedWeatherInfo.Min_Temprature__c);
        System.assertNotEquals(null, updatedWeatherInfo.Max_Temprature__c);
        System.assertNotEquals(null, updatedWeatherInfo.Humidity__c);
        System.assertEquals('clear sky', updatedWeatherInfo.Description__c); // Matching with mock data
        System.assertEquals(System.Label.OpenWeather_Base_URL + 'img/wn/01d@2x.png', updatedWeatherInfo.Icon__c); // Matching with mock data
    }
}
@IsTest
public class WeatherInfoControllerTest {

    @TestSetup
    static void setupTestData() {
        // Create a mock location
        Location__c location = new Location__c(
            Name = 'Test Location',
            Country__c = 'Test Country'
        );
        insert location;
        
        // Create mock WeatherInfo__c records
        List<WeatherInfo__c> weatherRecords = new List<WeatherInfo__c>();
        for (Integer i = 1; i <= 10; i++) {
            weatherRecords.add(new WeatherInfo__c(
                Location__c = location.Id,
                Max_Temprature__c = 30 + i,
                Min_Temprature__c = 15 + i,
                Temprature__c = 22 + i,
                Humidity__c = 60 + i,
                Description__c = 'Clear skies',
                Icon__c = 'clear_sky_icon'
            ));
        }
        insert weatherRecords;
    }
    
    @IsTest
    static void testGetWeatherData() {
        // Get the location Id from the setup data
        Id locationId = [SELECT Id FROM Location__c WHERE Name = 'Test Location' LIMIT 1].Id;
        
        // Call the method to test
        List<WeatherInfo__c> weatherData = WeatherInfoController.getWeatherData(locationId);
        
        // Assert that the method returns 10 records
        System.assertEquals(10, weatherData.size(), 'Expected 10 weather records to be returned');
        
        // Assert that the first record contains the expected data
        WeatherInfo__c firstRecord = weatherData[0];
        System.assertEquals(31, firstRecord.Max_Temprature__c, 'Max temperature does not match expected value');
        System.assertEquals(16, firstRecord.Min_Temprature__c, 'Min temperature does not match expected value');
        System.assertEquals(23, firstRecord.Temprature__c, 'Temperature does not match expected value');
        System.assertEquals(61, firstRecord.Humidity__c, 'Humidity does not match expected value');
        System.assertEquals('Clear skies', firstRecord.Description__c, 'Description does not match expected value');
        System.assertEquals('clear_sky_icon', firstRecord.Icon__c, 'Icon does not match expected value');
    }
}

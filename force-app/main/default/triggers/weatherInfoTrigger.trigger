trigger weatherInfoTrigger on WeatherInfo__c (after insert, after update) {
    Set<Id> weatherIds = new Set<Id>();
    for (WeatherInfo__c weather : Trigger.New) {
        if(weather.Location__c!=null){
        weatherIds.add(weather.Id);
        }
    }

    if(!System.isFuture() && !System.isBatch()){
    if(weatherIds.size()>0){
        weatherInfoTriggerHandler.getWeatherForLocation(weatherIds);
        }
    }
    
    
}
// Mock class to simulate the HTTP response
@isTest
public class WeatherInfoCalloutMock implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"main": {"temp": 298.15, "temp_min": 293.15, "temp_max": 303.15, "humidity": 65}, "weather": [{"description": "clear sky", "icon": "01d"}]}');
        return res;
    }
}
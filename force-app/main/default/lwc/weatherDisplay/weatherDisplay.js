import { LightningElement, wire, api } from 'lwc';
import getWeatherData from '@salesforce/apex/weatherInfoController.getWeatherData';

export default class WeatherDisplay extends LightningElement {
    @api recordId;
    weatherData;

    @wire(getWeatherData, { locationId: '$recordId' })
    wiredWeatherData({ error, data }) {
        if (data) {
            this.weatherData = data.map(weather => ({
                id: weather.Id,
                name: weather.Location__r.Name,
                updatedDate: this.formatDate(weather.LastModifiedDate),
                updatedTime: this.formatTime(weather.LastModifiedDate),
                temperature: weather.Temprature__c,
                humidity : weather.Humidity__c,
                icon : weather.Icon__c,
                description : weather.Description__c
            }));
        } else if (error) {
            console.error('Error fetching weather data:', error);
        }
    }

    formatDate(dateTimeString) {
        // Create a new Date object from the Salesforce datetime string
        const date = new Date(dateTimeString);

        // Extract the year, month, and day
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0'); // Months are zero-based in JS
        const day = String(date.getDate()).padStart(2, '0');

        // Return the date in YYYY-MM-DD format
        return `${day}/${month}/${year}`;
    }

    formatTime(dateTimeString) {
        // Create a new Date object from the Salesforce datetime string
        const date = new Date(dateTimeString);

        // Extract the hours and minutes
        const hours = String(date.getHours()).padStart(2, '0');
        const minutes = String(date.getMinutes()).padStart(2, '0');

        // Return the time in HH:MM format
        return `${hours}:${minutes}`;
    }
}
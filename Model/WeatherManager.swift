//
//  WeatherManager.swift
//  Clima
//
//  Created by Gilang Aditya R on 23/03/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
	func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
	func didFailWithError(error: Error)
}

struct WeatherManager {
	let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?appid=0af7282ec5e2073d73db4c4d0d60d44d&units=metric"
	
	var delegate: WeatherManagerDelegate?
	
	func fetchWeather(cityName: String){
		let urlString = "\(weatherUrl)&q=\(cityName)"
		performRequest(url: urlString)
	}
	
	func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
		let urlString = "\(weatherUrl)&lat=\(latitude)&lon=\(longitude)"
		performRequest(url: urlString)
	}
	
	func performRequest(url: String){
		if let url = URL(string: url){
			let session = URLSession(configuration: .default)
			//closure object
			let task = session.dataTask(with: url){ (data, response, error) in
				if error != nil{
					print(error!)
					delegate?.didFailWithError(error: error!)
					return
				}
				
				if let safeData = data {
					if let weather = self.parseJSON(weatherData: safeData){
						self.delegate?.didUpdateWeather(self, weather: weather)
					}
				}
			}
			task.resume()
		}
	}
	
	func parseJSON(weatherData: Data)-> WeatherModel? {
		let decoder = JSONDecoder()
		do{
			let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
			let id = decodedData.weather[0].id
			let temp = decodedData.main.temp
			let name = decodedData.name
			
			let weather =  WeatherModel(conditionId: id, cityName: name, temperature: temp)
			return weather
		}catch{
			print(error)
			delegate?.didFailWithError(error: error)
			return nil
		}
		
	}
}

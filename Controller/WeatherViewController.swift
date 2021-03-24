//
//  WeatherModel.swift
//  Clima
//
//  Created by Gilang Aditya R on 23/03/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
	
	
	@IBOutlet weak var conditionImageView: UIImageView!
	@IBOutlet weak var temperatureLabel: UILabel!
	@IBOutlet weak var cityLabel: UILabel!
	@IBOutlet weak var searchTextField: UITextField!
	
	var weatherManager = WeatherManager()
	let locationManager = CLLocationManager()
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		locationManager.delegate = self
		locationManager.requestWhenInUseAuthorization()
		locationManager.requestLocation()
		
		weatherManager.delegate = self
		searchTextField.delegate = self
		
	}
	
	@IBAction func searchButtonPressed(_ sender: UIButton) {
		weatherManager.fetchWeather(cityName: searchTextField.text!)
	}
	@IBAction func locationButtonPressed(_ sender: UIButton) {
		locationManager.requestLocation()
	}
}

//MARK: - WeatherManagerDelegate

extension WeatherViewController: WeatherManagerDelegate{
	func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel){
		print(weather.temperature)
		DispatchQueue.main.async {
			self.temperatureLabel.text = weather.temperatureString
			self.conditionImageView.image = UIImage(systemName: weather.conditionName)
			self.cityLabel.text = weather.cityName
		}
	}
	
	func didFailWithError(error: Error) {
		print(error)
	}
}

//MARK: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate{
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		searchTextField.endEditing(true)
		weatherManager.fetchWeather(cityName: searchTextField.text!)
		print(searchTextField.text!)
		
		return true
	}
	
	func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
		if textField.text != "" {
			weatherManager.fetchWeather(cityName: searchTextField.text!)
			return true
		}else{
			textField.placeholder = "Type something"
			return false
		}
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		searchTextField.text = ""
	}
}

//MARK: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if let location = locations.last {
			locationManager.stopUpdatingLocation()
			let lat = location.coordinate.latitude
			let lon = location.coordinate.longitude
			weatherManager.fetchWeather(latitude: lat, longitude: lon)
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print(error)
	}
}

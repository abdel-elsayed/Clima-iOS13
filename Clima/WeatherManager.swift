//
//  WeatherManager.swift
//  Clima
//
//  Created by Abdelrahman Elsayed on 10/13/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate{
    func didUpdateWeather(weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=" + ProcessInfo.processInfo.environment["API-KEY"]! + "&units=metric"
    let cityName = ""
    let temp = 0.0
    var delegate: WeatherManagerDelegate?
    
    func fetchWather(cityName: String ) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        //print(urlString)
        print(weatherURL)
        performRequest(URLString: urlString)
    }
    
    func fetchWather(lat: CLLocationDegrees, lon: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(lat)&lon=\(lon)"
        
        //api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API key}
        
        //print(urlString)
        print(weatherURL)
        performRequest(URLString: urlString)
    }

    
    //performing data request to the API to
    func performRequest(URLString: String) {
        
        //steps to create a successful URL session
        //1- Create a URL
        if let URL = URL(string: URLString){
            //2- Create a URLSession
            let URLSession = URLSession(configuration: .default)
            //3- Give ther session a task
            let task = URLSession.dataTask(with: URL) { data, response, error in
                if error != nil{
                    delegate?.didFailWithError(error: error!)
                    return
                }
                
                //if there is data returned
                if let safeData = data {
                    //let dataString = String(data: safeData, encoding: .utf8)
                    //print(dataString!)
                    if let weather = self.parseJSON(safeData: safeData){
                        delegate?.didUpdateWeather(weather: weather)
                    }
                   
                }
            }
            //4- Start the task
            task.resume()
            
        }
    }
    
    func parseJSON(safeData: Data) -> WeatherModel? {
        //parsing the JSON and decoding it into WeatherData Object
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: safeData)
            let weatherModel = WeatherModel(conditionId: decodedData.weather[0].id, name: decodedData.name, temp: decodedData.main.temp)
            return weatherModel
        } catch {
            print(error)
            return nil
        }
    }
}

//
//  F1Data_Model.swift
//  F1App
//
//  Created by Arman Husic on 3/23/22.
//

import Foundation
import UIKit
import SwiftyJSON
import Formula1API


struct F1ApiRoutes  {
    
  
    /**
        Here we will  set up some routes to the ergast api
        Set up a struct that can decode the json return by ergast
     */
    
    let myData = Data()

    static func allDrivers(seasonYear:String){
        let url = "https://ergast.com/api/f1/\(seasonYear)/drivers.json"

        guard let unwrappedURL = URL(string: url) else {return}
        
        URLSession.shared.dataTask(with: unwrappedURL) { (data, response, err) in
                    
            guard let data = data else {return}
            print(response)

            do {
                let f1Data = try JSONDecoder().decode(Drivers.self, from: data)
                let driversTableArray = f1Data.data.driverTable.drivers
                print(driversTableArray)
                for i in Range(0...driversTableArray.count - 1) {
                    Data.driverNames.append(driversTableArray[i].familyName)
                    Data.driverNationality.append(driversTableArray[i].nationality)
                    Data.driverURL.append(driversTableArray[i].url)
                    Data.driverNumber.append(driversTableArray[i].permanentNumber)
                    Data.driverFirstNames.append(driversTableArray[i].givenName)
                    Data.driverDOB.append(driversTableArray[i].dateOfBirth)
                    Data.driverCode.append(driversTableArray[i].code)
                }
                
            } catch  {
                print(data.debugDescription)
                print("Error decoding DRIVERS json data ")
            }
        }.resume()
    }
    
    
    
    
    
    static func allConstructors(seasonYear:String) {
        let url = "https://ergast.com/api/f1/\(seasonYear)/constructors.json"
        
        guard let unwrappedURL = URL(string: url) else {return}
        
        URLSession.shared.dataTask(with: unwrappedURL) { (data, response, err) in
                    
            guard let data = data else {return}
            
            do {
                let f1Data = try JSONDecoder().decode(Constructors.self, from: data)
                let thisArray = f1Data.data.constructorTable.constructors
                print(thisArray)
                for i in Range(0...thisArray.count - 1){
                    Data.teamNames.append(thisArray[i].name)
                    Data.teamNationality.append(thisArray[i].nationality)
                    Data.teamURL.append(thisArray[i].url)
                    Data.constructorID.append(thisArray[i].constructorID)
                }
            } catch  {
                print("Error decoding CONSTRUCTOR json data ")
            }
        }.resume()
    }
    
    
    
    static func allCircuits(seasonYear:String){
        let url = "https://ergast.com/api/f1/\(seasonYear)/circuits.json"
        
        guard let unwrappedURL = URL(string: url) else {return}
        
        URLSession.shared.dataTask(with: unwrappedURL) { (data, response, err) in
                    
            guard let data = data else {return}
            
            do {
                let f1Data = try JSONDecoder().decode(Circuits.self, from: data)
                let thisArray = f1Data.data.circuitTable.circuits
                
                print("PRINTING CIRCUIT URL")
                print(f1Data.data.url)
                for i in Range(0...thisArray.count - 1){
                    
                    Data.circuitName.append(thisArray[i].circuitName)
                    Data.circuitID.append(thisArray[i].circuitID)
                    Data.circuitLocation.append(thisArray[i].location.country)
//                    Data.circuitURL.append(secondArray[i].)
                }
                
            
                
                
                
            } catch  {
                print("Error decoding CONSTRUCTOR json data ")
            }
        }.resume()
    
    }
    
    
    
    
}

//
//  F1Data_Model.swift
//  F1App
//
//  Created by Arman Husic on 3/23/22.
//

import Foundation
import UIKit
import Formula1API


/**
    Here we will  set up some routes to the ergast api
    Set up a struct that can decode the json return by ergast

 */


struct F1ApiRoutes  {
            
    
    typealias FoundationData = Foundation.Data
    static var cache = [String: FoundationData]()


    static func allConstructors(seasonYear: String, completion: @escaping (Bool) -> Void) {
        // Check if data is in UserDefaults
        if let cachedData = retrieveCachedData(for: seasonYear, queryKey: "allConstructors") {
            do {
                let f1Data = try JSONDecoder().decode(Constructors.self, from: cachedData)
                handleFetchedData(f1Data, seasonYear: seasonYear, completion: completion)
                print("SUCCESSFULLY GATHERED SAVED DATA")
                return
            } catch let error {
                print("Error decoding cached data: \(error.localizedDescription)")
            }
        }

        let urlString = "https://ergast.com/api/f1/\(seasonYear)/constructors.json"
        guard let url = URL(string: urlString) else { return }

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10
        let session = URLSession(configuration: sessionConfig)
        let task = session.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print("Error: No data received")
                completion(false)
                return
            }

            do {
                let f1Data = try JSONDecoder().decode(Constructors.self, from: data)

                // Cache the data
                cache[seasonYear] = data

                handleFetchedData(f1Data, seasonYear: seasonYear, completion: completion)

                // Save to UserDefaults
                UserDefaults.standard.set(data, forKey: "cache_allConstructors_\(seasonYear)")

            } catch let error {
                print("Error decoding CONSTRUCTORS json data: \(error.localizedDescription)")
                completion(false)
            }
        }

        task.resume()
    }
            
    static func retrieveCachedData(for seasonYear: String, queryKey: String) -> FoundationData? {
        if let cachedData = UserDefaults.standard.data(forKey: "cache_\(queryKey)_\(seasonYear)") {
            return cachedData
        }
        return nil
    }

    static func handleFetchedData(_ f1Data: Constructors, seasonYear: String, completion: @escaping (Bool) -> Void) {
        let constructorTable = f1Data.data.constructorTable
        let constructorsArray = constructorTable.constructors
        let season = constructorTable.season?.capitalized

        for constructor in constructorsArray {
            if let encodedConstructorName = constructor.name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
                let constructorPageTitle = encodedConstructorName
                let constructorPageURLString = "https://en.wikipedia.org/w/api.php?action=query&titles=\(constructorPageTitle)&prop=pageimages&format=json&pithumbsize=250"
                guard let constructorPageURL = URL(string: constructorPageURLString) else { continue }

                URLSession.shared.dataTask(with: constructorPageURL) { (data, response, error) in
                    guard let data = data else { return }

                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let query = json["query"] as? [String: Any],
                           let pages = query["pages"] as? [String: Any],
                           let pageID = pages.keys.first,
                           let page = pages[pageID] as? [String: Any],
                           let thumbnail = page["thumbnail"] as? [String: Any],
                           let thumbnailURLString = thumbnail["source"] as? String {
                            
                            print(thumbnailURLString)
                            
                            DispatchQueue.main.async {
                                if !F1DataStore.constructorID.contains(constructor.constructorID) {
                                    let tuple = (constructor.constructorID, thumbnailURLString)
                                    let string = "\(tuple.0),\(tuple.1)"
                                    print(constructor.url)
                                    F1DataStore.teamImgURL.append(tuple.1)
                                    F1DataStore.teamNames.append(constructor.name)
                                    F1DataStore.teamNationality.append(constructor.nationality)
                                    F1DataStore.teamURL.append(constructor.url)
                                    F1DataStore.constructorID.append(constructor.constructorID)
                                    F1DataStore.f1Season.append(season)
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                if !F1DataStore.constructorID.contains(constructor.constructorID) {
                                    F1DataStore.teamImgURL.append("\(constructor.constructorID),default")
                                    F1DataStore.teamNames.append(constructor.name)
                                    F1DataStore.teamNationality.append(constructor.nationality)
                                    F1DataStore.teamURL.append(constructor.url)
                                    F1DataStore.constructorID.append(constructor.constructorID)
                                    F1DataStore.f1Season.append(season)
                                    print(F1DataStore.teamURL)
                                }
                            }
                            completion(true)
                        }

                        
                    } catch let error {
                        print("Error decoding Wikipedia JSON data: \(error.localizedDescription)")
                        // Handle error
                    }
                }.resume()
            }
        } // end for loop
    }

    
    static func allRaceResults(seasonYear: String, round: String, completion: @escaping (Bool) -> Void) {
        print(seasonYear, round)
        let urlString = "https://ergast.com/api/f1/\(seasonYear)/\(round)/results.json"
        guard let url = URL(string: urlString) else { return }
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10 // set timeout to 10 seconds
        let session = URLSession(configuration: sessionConfig)
        let task = session.dataTask(with: url) { (data, response, error) in

            guard let data = data else {
                print("Error: No data received")
                completion(false)
                return
            }
            do {
                let raceResults = try JSONDecoder().decode(RaceResults.self, from: data)
                for race in raceResults.mrData.raceTable.races {
                    F1DataStore.singleRaceName = "\(seasonYear)\n\(race.raceName) \nRound \(round)"
                    for result in race.results {
                        F1DataStore.constructorID.append(result.constructor.name)
                        F1DataStore.driverNames.append("\(result.driver.givenName) \(result.driver.familyName)")
                        F1DataStore.driverLastName.append(result.driver.familyName)
                        F1DataStore.racePosition.append(result.position)
                        F1DataStore.racePoints.append(result.points)
                        F1DataStore.fastestLap.append("Fastest Lap: \(result.fastestLap?.time.time ?? "")")
                        F1DataStore.raceTime.append("Starting Grid Position: \(result.grid)\nLaps Completed: \(result.laps)\nRace Pace: \(result.time?.time ?? "Way Off")")
                        F1DataStore.qualiResults.append(result.grid)
                     
                    }
                    completion(true)
                }
            } catch let error {
                completion(false)
                print("Error decoding race results: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    
    

    static func getDriverResults(driverId: String, limit: Int, completion: @escaping (Bool, [Race]) -> Void) {
        let urlString = "https://ergast.com/api/f1/drivers/\(driverId)/results.json?limit=\(limit)"
        guard let url = URL(string: urlString) else {
            completion(false, [])
            return
        }
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10 // set timeout to 10 seconds
        let session = URLSession(configuration: sessionConfig)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print("Error: No data received")
                completion(false, [])
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let mrData = json["MRData"] as? [String: Any],
                   let raceTable = mrData["RaceTable"] as? [String: Any],
                   let racesArray = raceTable["Races"] as? [[String: Any]] {
                    
                    var races = [Race]()
                    
                    for (index, raceData) in racesArray.enumerated() {
                        if let race = createRace(from: raceData) {
                            print("Processing race \(index + 1) of \(racesArray.count)")
                            races.append(race)
                        } else {
                            print("Error processing race \(index + 1)")
                            // Print the raceData or other relevant information to identify the issue
                        }
                    }
                    completion(true, races)
                    
                } else {
                    completion(false, [])
                    print("Error: Invalid JSON format driver results")
                }
            } catch let error {
                completion(false, [])
                print("Error decoding driver results: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }

    
    private static func createRace(from data: [String: Any]) -> Race? {
        guard let raceName = data["raceName"] as? String,
              let circuitData = data["Circuit"] as? [String: Any],
              let circuitName = circuitData["circuitName"] as? String,
              let locationData = circuitData["Location"] as? [String: Any],
              let locality = locationData["locality"] as? String,
              let country = locationData["country"] as? String,
              let date = data["date"] as? String,
              let resultsArray = data["Results"] as? [[String: Any]] else {
            return nil
        }
        
        var results = [Result]()
        for resultData in resultsArray {
            if let result = createResult(from: resultData) {
                results.append(result)
            }
        }
        
        let circuit = Circuit(circuitName: circuitName, location: Location(locality: locality, country: country))
        return Race(raceName: raceName, circuit: circuit, date: date, results: results)
    }

    private static func createResult(from data: [String: Any]) -> Result? {
        // Extract commonly used values for improved readability
        let driverData = data["Driver"] as? [String: Any] ?? [:]
        let constructorData = data["Constructor"] as? [String: Any] ?? [:]
        let timeData = data["Time"] as? [String: Any] ?? [:]

        // Extract values using computed properties
        guard let number = data["number"] as? String,
              let position = data["position"] as? String,
              let positionText = data["positionText"] as? String,
              let points = data["points"] as? String,
              let driverId = driverData["driverId"] as? String,
              let driverUrl = driverData["url"] as? String,
              let givenName = driverData["givenName"] as? String,
              let familyName = driverData["familyName"] as? String,
              let dateOfBirth = driverData["dateOfBirth"] as? String,
              let nationality = driverData["nationality"] as? String,
              let constructorId = constructorData["constructorId"] as? String,
              let constructorUrl = constructorData["url"] as? String,
              let constructorName = constructorData["name"] as? String,
              let constructorNationality = constructorData["nationality"] as? String,
              let grid = data["grid"] as? String,
              let laps = data["laps"] as? String,
              let status = data["status"] as? String,
              let time = timeData["time"] as? String?
        else {
            print("CANT PROCESS? -\(data["grid"]!)")
            return nil
        }
        print("\(driverId)-\(grid) ")
        
        let driver = Driver(driverId: driverId, permanentNumber: nil, code: nil, url: driverUrl, givenName: givenName, familyName: familyName, dateOfBirth: dateOfBirth, nationality: nationality)
        let constructor = Constructor(constructorId: constructorId, url: constructorUrl, name: constructorName, nationality: constructorNationality)
       
        
        let timeValue = time ?? "N/A"
        let raceTime = Time(millis: "", time: timeValue)
        return Result(number: number, position: position, positionText: positionText, points: points, driver: driver, constructor: constructor, grid: grid, laps: laps, status: status, time: raceTime, fastestLap: nil)
    }
    


    
    static func allRaceSchedule(seasonYear: String, completion: @escaping (Bool) -> Void) {
        let url = "https://ergast.com/api/f1/\(seasonYear).json"

        guard let unwrappedURL = URL(string: url) else { return }

        // Check if data is cached
        if let cachedData = retrieveCachedData(for: seasonYear, queryKey: "raceSchedule") {
            do {
                let f1Data = try JSONSerialization.jsonObject(with: cachedData, options: []) as? [String: Any]

                if let mrData = f1Data?["MRData"] as? [String: Any],
                    let raceTable = mrData["RaceTable"] as? [String: Any],
                    let races = raceTable["Races"] as? [[String: Any]] {

                    for race in races {
                        if let raceName = race["raceName"] as? String,
                            let circuit = race["Circuit"] as? [String: Any],
                            let circuitName = circuit["circuitName"] as? String,
                            let location = circuit["Location"] as? [String: Any],
                            let country = location["country"] as? String,
                            let locality = location["locality"] as? String,
                            let date = race["date"] as? String,
                            let lat = location["lat"] as? String,
                            let long = location["long"] as? String {
                            
                            F1DataStore.circuitRaceDate.append(date)
                            F1DataStore.raceName.append(raceName)
                            F1DataStore.circuitID.append(circuit["circuitId"] as? String ?? "")
                            F1DataStore.circuitName.append(circuitName)
                            F1DataStore.circuitLocation.append(country)
                            F1DataStore.circuitCity.append(locality)
                            F1DataStore.circuitURL.append("https://en.wikipedia.org/wiki/\(circuitName.replacingOccurrences(of: " ", with: "_"))")
                            F1DataStore.circuitLatitude.append(lat)
                            F1DataStore.circuitLongitude.append(long)
                        }
                    }
                    print("RACE DATA LOADED FROM CACHE")
                    F1DataStore.cellCount = races.count - 1
                    completion(true)
                    return // Data is loaded from cache, so we're done
                }
            } catch {
                print("Error decoding cached JSON: \(error.localizedDescription)")
            }
        }

        // Data is not cached or cache is invalid, fetch from API
        URLSession.shared.dataTask(with: unwrappedURL) { (data, response, err) in
            guard let data = data else {
                completion(false)
                return
            }

            do {
                let f1Data = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

                if let mrData = f1Data?["MRData"] as? [String: Any],
                    let raceTable = mrData["RaceTable"] as? [String: Any],
                    let races = raceTable["Races"] as? [[String: Any]] {

                    for race in races {
                        if let raceName = race["raceName"] as? String,
                            let circuit = race["Circuit"] as? [String: Any],
                            let circuitName = circuit["circuitName"] as? String,
                            let location = circuit["Location"] as? [String: Any],
                            let country = location["country"] as? String,
                            let locality = location["locality"] as? String,
                            let date = race["date"] as? String,
                            let lat = location["lat"] as? String,
                            let long = location["long"] as? String {
                            
                            F1DataStore.circuitRaceDate.append(date)
                            F1DataStore.raceName.append(raceName)
                            F1DataStore.circuitID.append(circuit["circuitId"] as? String ?? "")
                            F1DataStore.circuitName.append(circuitName)
                            F1DataStore.circuitLocation.append(country)
                            F1DataStore.circuitCity.append(locality)
                            F1DataStore.circuitURL.append("https://en.wikipedia.org/wiki/\(circuitName.replacingOccurrences(of: " ", with: "_"))")
                            F1DataStore.circuitLatitude.append(lat)
                            F1DataStore.circuitLongitude.append(long)
                            
                        }
                    }
                    F1DataStore.cellCount = races.count - 1

                    // Cache the data to UserDefaults
                    if let jsonData = try? JSONSerialization.data(withJSONObject: f1Data ?? [:], options: []) {
                        UserDefaults.standard.set(jsonData, forKey: "cache_raceSchedule_\(seasonYear)")
                    }

                    completion(true)
                } else {
                    print("Error: Invalid JSON structure")
                    completion(false)
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
                completion(false)
            }
        }.resume()
    }




    
    static func worldDriversChampionshipStandings(seasonYear: String, completion: @escaping (Bool) -> Void) {

        // Check if data is in UserDefaults
        if let cachedData = retrieveCachedData(for: seasonYear, queryKey: "worldDriversChampionshipStandings")  {
            do {
                if let json = try JSONSerialization.jsonObject(with: cachedData, options: []) as? [String: Any] {
                    processDriverStandings(json, seasonYear: seasonYear, completion: completion)
                    print("RETRIEVED DRIVER DATA FROM USER DEFAULTS")
                    return
                }
            } catch let error {
                print("Error decoding cached data: \(error.localizedDescription)")
                completion(false)
                return
            }
        }

        let urlString = "https://ergast.com/api/f1/\(seasonYear)/driverStandings.json"

        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                guard let data = data else {
                    print("Error: No data received")
                    completion(false)
                    return
                }

                // Data received successfully
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {

                        // Cache the data
                        cache["worldDriversChampionshipStandings_\(seasonYear)"] = data

                        processDriverStandings(json, seasonYear: seasonYear, completion: completion)

                        // Save to UserDefaults
                        if seasonYear != "2023" {
                            UserDefaults.standard.set(data, forKey: "cache_worldDriversChampionshipStandings_\(seasonYear)")
                        }

                    } else {
                        print("Error: Invalid JSON structure")
                        completion(false)
                    }
                } catch let error {
                    print("Error decoding JSON: \(error.localizedDescription)")
                    completion(false)
                }
            }
            task.resume()
        } else {
            print("Error: Invalid URL")
            completion(false)
        }
    }
    
    
    static func processDriverStandings(_ json: [String: Any], seasonYear: String, completion: @escaping (Bool) -> Void) {
        if let mrData = json["MRData"] as? [String: Any],
            let standingsTable = mrData["StandingsTable"] as? [String: Any],
            let standingsLists = standingsTable["StandingsLists"] as? [[String: Any]] {
            
            F1DataStore.f1Season.append(seasonYear) // Assuming Data.f1Season is a global variable or property
            
            for standingsList in standingsLists {
                let driverStandings = standingsList["DriverStandings"] as? [[String: Any]] ?? []
                
                for driverStanding in driverStandings {
                    if let driver = driverStanding["Driver"] as? [String: Any],
                       let givenName = driver["givenName"] as? String,
                       let familyName = driver["familyName"] as? String,
                       let position = driverStanding["position"] as? String,
                       let points = driverStanding["points"] as? String,
                       let constructors = driverStanding["Constructors"] as? [[String: Any]] {
                        
                        var teamNames: [String] = []
                        
                        for constructor in constructors {
                            if let teamName = constructor["name"] as? String {
                                teamNames.append(teamName)
                            }
                        }
                        
                        let teamNamesString = teamNames.joined(separator: ", ")
                        
                        fetchDriverInfoFromWikipedia(givenName: givenName, familyName: familyName) { success in
                            if success {
                                F1DataStore.racePosition.append(position)
                                F1DataStore.racePoints.append(points)
                                F1DataStore.driverNames.append("\(givenName) \(familyName)")
                                F1DataStore.driverLastName.append(familyName)
                                F1DataStore.teamNames.append(teamNamesString)
                                // Add other driver information...
                                completion(true)
                            } else {
                                print("Error fetching driver info")
                                completion(false)
                            }
                        }
                    }
                }
            }
        } else {
            print("Error: Invalid JSON structure")
            completion(false)
        }
    }


    
    
    static func fetchDriverInfoFromWikipedia(givenName: String, familyName: String, completion: @escaping (Bool) -> Void) {
        let encodedGivenName = givenName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        let encodedFamilyName = familyName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        let driverPageTitle = "\(encodedGivenName)_\(encodedFamilyName)"
        let driverPageURLString = "https://en.wikipedia.org/w/api.php?action=query&titles=\(driverPageTitle)&prop=pageimages&format=json&pithumbsize=500"
        
        guard let driverPageURL = URL(string: driverPageURLString) else {
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: driverPageURL) { (data, response, error) in
            guard let data = data else {
                print("Error: No data received for \(givenName) \(familyName)")
                completion(false)
                return
            }
            
            do {
                let wikipediaData = try JSONDecoder().decode(WikipediaData.self, from: data)
                
                guard let pageID = wikipediaData.query.pages.keys.first,
                    let page = wikipediaData.query.pages[pageID] else {
                        print("Error: Invalid response for \(givenName) \(familyName)")
                        completion(false)
                        return
                }
                
                let thumbnailURLString = page.thumbnail?.source
                
                DispatchQueue.main.async {
                    F1DataStore.driverImgURL.append(thumbnailURLString ?? "lewis")
                    // Append other driver information...
                    completion(true)
                }
            } catch let error {
                print("Error decoding Wikipedia JSON data for \(givenName) \(familyName): \(error.localizedDescription)")
                completion(false)
            }
        }.resume()
    }


    ////
    ///
    ///
    ///
    ///
    // This is not used yet, but will be added in some capacity soon
    static func allTimeDriverChampionships(completion: @escaping (Bool) -> Void) {
        let urlString = "https://ergast.com/api/f1/driverstandings/1.json?limit=100"

        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("Error: No data received")
                    return
                }

                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])

                    if let json = json as? [String: Any],
                       let mrData = json["MRData"] as? [String: Any],
                       let standingsTable = mrData["StandingsTable"] as? [String: Any],
                       let standingsLists = standingsTable["StandingsLists"] as? [[String: Any]] {

                        var driverChampionships: [String: Int] = [:]
                        
                        for standingsList in standingsLists {
                            let driverStandings = standingsList["DriverStandings"] as? [[String: Any]] ?? []
                            for driverStanding in driverStandings {
                                let driver = driverStanding["Driver"] as? [String: Any] ?? [:]
                                let driverId = driver["driverId"] as? String ?? ""
                                
                                if let championships = driverChampionships[driverId] {
                                    driverChampionships[driverId] = championships + 1
                                } else {
                                    driverChampionships[driverId] = 1
                                }
                                
                            }
                        }

                        F1DataStore.driverChampionships.append(contentsOf: driverChampionships.sorted { $0.value > $1.value })
                        for (driverId, championships) in  F1DataStore.driverChampionships {
                            print("Driver: \(driverId), Championships: \(championships)")
                        }
                        completion(true)
                    } else {
                        print("Error: Invalid JSON structure")
                        completion(false)
                    }
                } catch {
                    print("Error decoding JSON: \(error.localizedDescription)")
                    completion(false)

                }
            }

            task.resume()
        } else {
            print("Error: Invalid URL")
            completion(false)

        }
    }

    
    

}

struct WikipediaData: Codable {
    struct Query: Codable {
        struct Page: Codable {
            struct Thumbnail: Codable {
                let source: String
            }
            let thumbnail: Thumbnail?
        }
        let pages: [String: Page]
    }
    let query: Query
}


struct WikipediaImage: Decodable {
    let source: String
}

struct WikipediaQuery: Decodable {
    let pages: [String: WikipediaPage]
}

struct WikipediaPage: Decodable {
    let thumbnail: WikipediaThumbnail?
    let originalimage: WikipediaImage?
}

struct WikipediaThumbnail: Decodable {
    let source: String
}

/**
 
 https://ergast.com/api/f1/2008/results/1
 working on adding results that show up for drivers or teams or as a standalone not sure yet

 */

struct Time: Decodable {
    let millis: String
    let time: String
    
    private enum CodingKeys: String, CodingKey {
        case millis, time
    }
}

struct RaceResults: Decodable {
    let mrData: MRData
    
    private enum CodingKeys: String, CodingKey {
        case mrData = "MRData"
    }
}

struct MRData: Decodable {
    let raceTable: RaceTable
    
    private enum CodingKeys: String, CodingKey {
        case raceTable = "RaceTable"
    }
}

struct RaceTable: Decodable {
    let races: [Race]
    let season: String
    
    private enum CodingKeys: String, CodingKey {
        case races = "Races"
        case season = "season"
    }
}

struct Race: Decodable {
    let raceName: String
    let circuit: Circuit
    let date: String
    let results: [Result]
    
    private enum CodingKeys: String, CodingKey {
        case raceName = "raceName"
        case circuit = "Circuit"
        case date = "date"
        case results = "Results"
    }
}

struct Circuit: Decodable {
    let circuitName: String
    let location: Location
    
    private enum CodingKeys: String, CodingKey {
        case circuitName = "circuitName"
        case location = "Location"
    }
}

struct Location: Decodable {
    let locality: String
    let country: String
    
    private enum CodingKeys: String, CodingKey {
        case locality = "locality"
        case country = "country"
    }
}

struct Result: Decodable {
    let number: String
    let position: String
    let positionText: String
    let points: String
    let driver: Driver
    let constructor: Constructor
    let grid: String
    let laps: String
    let status: String
    let time: Time?
    let fastestLap: FastestLap?
    
    private enum CodingKeys: String, CodingKey {
        case number = "number"
        case position = "position"
        case positionText = "positionText"
        case points = "points"
        case driver = "Driver"
        case constructor = "Constructor"
        case grid = "grid"
        case laps = "laps"
        case status = "status"
        case time = "Time"
        case fastestLap = "FastestLap"
    }
}

struct Driver: Decodable {
    let driverId: String
    let permanentNumber: String?
    let code: String?
    let url: String
    let givenName: String
    let familyName: String
    let dateOfBirth: String
    let nationality: String
    
    private enum CodingKeys: String, CodingKey {
        case driverId = "driverId"
        case permanentNumber = "permanentNumber"
        case code = "code"
        case url = "url"
        case givenName = "givenName"
        case familyName = "familyName"
        case dateOfBirth = "dateOfBirth"
        case nationality = "nationality"
    }
}

struct Constructor: Decodable {
    let constructorId: String
    let url: String
    let name: String
    let nationality: String
    
    private enum CodingKeys: String, CodingKey {
        case constructorId = "constructorId"
        case url = "url"
        case name = "name"
        case nationality = "nationality"
    }
}

struct ConstructorStandings: Codable {
    let data: StandingsData

    struct StandingsData: Codable {
        let season: String?
        let standingsTable: StandingsTable

        struct StandingsTable: Codable {
            let standingsLists: [StandingsList]

            struct StandingsList: Codable {
                let season: String
                let constructorStandings: [ConstructorStanding]

                struct ConstructorStanding: Codable {
                    let position: String
                    let points: String
                    let wins: String
                    let constructor: Constructor

                    struct Constructor: Codable {
                        let constructorID: String
                        let url: String
                        let name: String
                        let nationality: String
                    }
                }
            }
        }
    }
}

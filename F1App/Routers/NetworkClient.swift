//
//  NetworkClient.swift
//  F1App
//
//  Created by Arman Husic on 10/18/24.
//

import Foundation
import Get

class NetworkClient {
    private let baseURL: URL
    private let apiClient: APIClient

    enum Endpoints: String {
        case baseURL = "https://ergast.com/api/f1/"
    }

    init() {
        self.baseURL = URL(string: Endpoints.baseURL.rawValue)!
        self.apiClient = APIClient(baseURL: baseURL)
    }

    private func getCachedData(for seasonYear: String, queryKey: String) -> Data? {
        let key = "cache_\(queryKey)_\(seasonYear)"
        return UserDefaults.standard.data(forKey: key)
    }
    
    private func saveCachedData(_ data: Data, for seasonYear: String, queryKey: String) {
        let key = "cache_\(queryKey)_\(seasonYear)"
        UserDefaults.standard.set(data, forKey: key)
    }
    
    func retrieveCachedData(for seasonYear: String, queryKey: String) -> Data? {
        let key = "cache_\(queryKey)_\(seasonYear)"
        if let cachedData = UserDefaults.standard.data(forKey: key) {
            return cachedData
        } else {
            // Log an error or handle the absence of data gracefully
            print("No cached data available for key: \(key)")
            return nil
        }
    }
    
    func getConstructorStandings(seasonYear: String) async throws -> [ConstructorStanding] {
        // Check the cache first
        if let cachedData = retrieveCachedData(for: seasonYear, queryKey: "constructorStandings") {
            do {
                let root = try JSONDecoder().decode(Root.self, from: cachedData)
                print("Successfully gathered data from cache")
                return processConstructorStandings(root: root)
            } catch {
                print("Error decoding cached data: \(error)")
                // Continue to fetch fresh data if cache is corrupted
            }
        }

        // Proceed with network call
        let urlString = "\(baseURL)\(seasonYear)/constructorStandings.json?limit=100"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let root = try JSONDecoder().decode(Root.self, from: data)
        
        if seasonYear != "\(Calendar.current.component(.year, from: Date()))" {
            UserDefaults.standard.set(data, forKey: "cache_constructorStandings_\(seasonYear)")
        }

        return processConstructorStandings(root: root)
    }

    func processConstructorStandings(root: Root) -> [ConstructorStanding] {
        guard let standingsList = root.mrData?.standingsTable?.standingsLists?.first else {
            print("Standings table not found")
            return []
        }
        
        return standingsList.constructorStandings ?? []
    }
    
    func fetchRaceResults(season: String, round: String) async throws -> Root {
        let cacheKey = "raceResults_\(season)_\(round)"

        if let cachedData = getCachedData(for: season, queryKey: cacheKey) {
            do {
                let cachedRoot = try JSONDecoder().decode(Root.self, from: cachedData)
                print("Returnng cached race results for season: \(season), round: \(round)")
                return cachedRoot
            } catch {
                print("Error decoding cached data: \(error)")
                throw error
            }
        }

        let request = Request<Root>(path: "\(season)/\(round)/results.json", method: .get)
        let root = try await apiClient.send(request).value
        
        if let data = try? JSONEncoder().encode(root) {
            if season != "2024" {
                saveCachedData(data, for: season, queryKey: cacheKey)
            }
        }

        return root
    }

    func fetchRaceSchedule(forYear year: String) async throws -> Root {
        let cacheKey = "raceSchedule_\(year)"
        
        if let cachedData = getCachedData(for: year, queryKey: cacheKey) {
            do {
                let cachedRoot = try JSONDecoder().decode(Root.self, from: cachedData)
                print("Returnng cached race schedule for year: \(year)")
                return cachedRoot
            } catch {
                print("Error decoding cached data: \(error)")
            }
        }

        let request = Request<Root>(path: "\(year).json", method: .get)
        do {
            let root = try await apiClient.send(request).value
            if year != "2024" {
                let data = try JSONEncoder().encode(root)
                saveCachedData(data, for: year, queryKey: cacheKey)
            }
            return root
        } catch {
            print("Error fetching race scedule: \(error)")
            throw error
        }
    }
}

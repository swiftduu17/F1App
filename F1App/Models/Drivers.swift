//
//  Drivers.swift
//  F1App
//
//  Created by Arman Husic on 4/11/22.
//
//
//  DriverInfo.swift
////

import Foundation

/// Codable struct, used for serializing JSON from the Drivers endpoint.
public struct Drivers: Codable {
    public let data: DriversData

    private enum CodingKeys: String, CodingKey {
        case data = "MRData"
    }
}

public struct DriversData: Codable {
    public let series: String
    public let url: String
    public let limit: String
    public let offset: String
    public let total: String
    public let driverTable: DriverTable

    private enum CodingKeys: String, CodingKey {
        case series
        case url
        case limit
        case offset
        case total
        case driverTable = "DriverTable"
    }
}

public struct DriverTable: Codable {
    public let season: String?
    public let drivers: [Drivers]

    private enum CodingKeys: String, CodingKey {
        case season
        case drivers = "Drivers"
    }
}

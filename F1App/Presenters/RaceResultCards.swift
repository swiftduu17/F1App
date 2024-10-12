//
//  RaceResultCards.swift
//  F1App
//
//  Created by Arman Husic on 10/11/24.
//

import SwiftUI

struct RaceResultCards: View {
    
    var body: some View {
        titleCard(title: "Race Results")
        raceResultsList(
            result: ["Hamilton", "Vettel", "Leclerc", "Bottas", "Sainz", "Piastri", "Norris", "Perez", "Verstappen", "Alonso"],
            rowIcon: "person.circle.fill"
        )
    }
    
    @MainActor func titleCard(title: String) -> some View {
        HStack {
            VStack {
                ZStack {
                    Circle()
                        .foregroundStyle(.black)
                        .frame(width: 100, height: 100)
                        .padding()
                    Image(systemName: "car.fill") // or app logo, something nicer
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.red)
                        .frame(width: 75, height: 75)

                }
                Text(title)
                    .font(.headline)
                    .padding([.bottom], 20)
            }
            .frame(width: .infinity, height: .infinity, alignment: .center)

            ZStack {
                Rectangle()
                    .frame(width: .infinity, height: 100)
                    .ignoresSafeArea()
                    .foregroundStyle(.clear)
                
            }
        }
        .background(
            LinearGradient(colors: [.red, .black.opacity(0.9), .black], startPoint: .bottomLeading, endPoint: .topTrailing)
        )
        .cornerRadius(12)
        .padding([.top, .bottom, .horizontal], 2)
    }
    
    @MainActor func raceResultsList(result: [String], rowIcon: String) -> some View {
        List {
            ForEach(0..<10) { index in
                HStack {
                    Image(systemName: rowIcon)
                        .resizable()
                        .frame(width: 50, height: 50, alignment: .leading)
                        .scaledToFill()
                        .padding(.trailing, 16)

                    HStack {
                        Text("P\(index + 1)")
                            .bold()
                            .font(.caption)
                        Text("\(result[index])")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(
                LinearGradient(colors: [.blue, .red], startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    RaceResultCards()
}

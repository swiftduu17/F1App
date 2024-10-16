//
//  RaceResultCards.swift
//  F1App
//
//  Created by Arman Husic on 10/11/24.
//

import SwiftUI

struct RaceResultCards: View {
    enum Constants {
        static let titleImg: String = "flag.pattern.checkered.circle"
        static let rowIcon: String = "person.circle"
        static let fallbackTitle: String = "Grand Prix Results"
    }
    
    @ObservedObject var viewModel: HomeViewModel
    let race: Race
    
    private var customGrandient: LinearGradient {
        LinearGradient(colors: [
            .black.opacity(0.9),
                .red.opacity(0.5),
                .black.opacity(0.75)
        ],
           startPoint: .bottomLeading,
           endPoint: .topTrailing
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            titleCard(
                title: race.raceName ?? Constants.fallbackTitle,
                titleImg: Constants.titleImg
            )
            raceResultsList(
                results: viewModel.raceResults2,
                rowIcon: Constants.rowIcon
            )
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    }
    
    @MainActor func titleCard(title: String, titleImg: String) -> some View {
        HStack {
            VStack {
                HStack {
                    Spacer()
                    ZStack {
                        Circle()
                            .foregroundStyle(.black.opacity(0.4))
                            .frame(width: 75, height: 75)
                        Image(systemName: titleImg)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .padding()
                }

                Text(title.uppercased())
                    .frame(width: UIScreen.main.bounds.width, alignment: .center)
                    .font(.title2)
                    .bold()
                    .padding([.bottom], 0)
                    .padding(.horizontal, 8)

                Text("\(race.date ?? ""), \(race.time ?? "")")
                    .font(.callout)
                    .padding(.bottom)
                    .frame(width: UIScreen.main.bounds.width, alignment: .center)
            }
            .foregroundStyle(.white)
        }
        .background(customGrandient)
        .padding([.top, .bottom, .horizontal], 2)
    }
    
    @MainActor func raceResultsList(results: [Result], rowIcon: String) -> some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            List {
                ForEach(results.indices, id: \.self) { index in
                    let result = results[index]
                    
                    let driverStanding = viewModel.driverStandings.first { standing in
                        standing.givenName == result.driver?.givenName &&
                        standing.familyName == result.driver?.familyName
                    }
                    
                    VStack {
                        HStack {
                            HStack {
                                if let imageURL = driverStanding?.imageUrl, !imageURL.isEmpty {
                                    AsyncImage(url: URL(string: imageURL)) { image in
                                        image.resizable()
                                            .frame(width: 40, height: 40)
                                            .scaledToFit()
                                            .padding(.trailing, 10)
                                            .padding([.leading, .top], 8)
                                    } placeholder: {
                                        Image(systemName: rowIcon)
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                            .scaledToFit()
                                            .padding(.trailing, 10)
                                            .padding([.leading, .top], 8)
                                    }
                                } else {
                                    Image(systemName: rowIcon)
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .scaledToFit()
                                        .padding(.trailing, 10)
                                        .padding([.leading, .top], 8)
                                }

                                Text("\(result.driver?.givenName ?? "") \(result.driver?.familyName ?? "")")
                                    .bold()
                            }
                            .font(.title2)
                            .foregroundStyle(.white)
                        }
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Group {
                            Text("\(result.constructor?.name ?? "") \(result.status?.lowercased() ?? "") P\(result.position ?? "\(index + 1)")")
                            Text("Qualified P\(result.grid ?? "")")
                            Text("Points :\(result.points ?? "")")
                        }
                        .padding([.horizontal, .top], 12)
                        .padding([.bottom], 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.white)
                        .font(.subheadline)
                        .bold()
                    }
                }
                .background(.black)
                .cornerRadius(8)
            }
            .scrollContentBackground(.hidden)
        }
    }
}

#Preview {
    HomeScreen()
}

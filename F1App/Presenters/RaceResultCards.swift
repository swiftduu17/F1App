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
            raceResultsList
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    }

    @MainActor func titleCard(title: String, titleImg: String) -> some View {
        HStack {
            VStack {
                HStack {
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

    @MainActor private var raceResultsList: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            resultsScrollView(
                results: viewModel.raceResults2,
                rowIcon: Constants.rowIcon
            )
        }
    }

    @ViewBuilder private func resultsScrollView(results: [Result], rowIcon: String) -> some View {
        ScrollView {
            LazyVStack {
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
                                        asyncImage(image: image)
                                    } placeholder: {
                                        placeHolderImage(rowIcon: rowIcon)
                                    }
                                } else {
                                    placeHolderImage(rowIcon: rowIcon)
                                }

                                Text("\(result.driver?.givenName ?? "") \(result.driver?.familyName ?? "")")
                                    .bold()
                            }
                            .font(.title2)
                            .foregroundStyle(.white)
                        }
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                        raceInfo(
                            result: result,
                            index: index
                        )
                    }
                }
                .background(.black)
                .cornerRadius(8)
            }
        }
        .scrollContentBackground(.hidden)
    }

    @ViewBuilder private func asyncImage(image: Image) -> some View {
        ZStack {
            image
                .resizable()
                .scaledToFit()
                .padding(.trailing, 10)
                .padding([.leading, .top], 8)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(LinearGradient(colors: [.red, .black, .black, .black], startPoint: .bottomLeading, endPoint: .topTrailing), lineWidth: 12)
                )
        }
    }

    @ViewBuilder private func raceInfo(result: Result, index: Int) -> some View {
        Group {
            Text("\(result.constructor?.name ?? "") \(result.status?.lowercased() ?? ""): P\(result.position ?? "\(index + 1)")")
            Text("Qualified: P\(result.grid ?? "")")
            Text("Points: \(result.points ?? "")")
        }
        .padding([.horizontal, .top], 12)
        .padding([.bottom], 8)
        .frame(maxWidth: .infinity, alignment: .center)
        .foregroundStyle(.white)
        .font(.subheadline)
        .bold()
    }
    
    @ViewBuilder private func placeHolderImage(rowIcon: String) -> some View {
        Image(systemName: rowIcon)
            .resizable()
            .frame(width: 40, height: 40)
            .scaledToFit()
            .padding(.trailing, 10)
            .padding([.leading, .top], 8)
    }
}

#Preview {
    HomeScreen()
}

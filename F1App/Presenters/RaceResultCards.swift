//
//  RaceResultCards.swift
//  F1App
//
//  Created by Arman Husic on 10/11/24.
//

import SwiftUI

struct RaceResultCards: View {
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var resultsViewModel: RaceResultViewModel
    let race: Race

    var body: some View {
        VStack(spacing: 0) {
            titleCard(
                title: race.raceName ?? RaceResultViewModel.Constants.fallbackTitle,
                titleImg: RaceResultViewModel.Constants.titleImg
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
        .background(resultsViewModel.customGrandient)
        .padding([.top, .bottom, .horizontal], 2)
    }

    @MainActor private var raceResultsList: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)

            resultsScrollView(results: viewModel.raceResults2)
        }
    }

    @ViewBuilder private func resultsScrollView(results: [Result]) -> some View {
        ScrollView {
            LazyVStack {
                ForEach(results.indices, id: \.self) { index in
                    let result = results[index]

                    driverInfo(
                        result: result,
                        driverStanding: resultsViewModel.matchDriver(
                            viewModel: viewModel,
                            result: result
                        ),
                        rowIcon: RaceResultViewModel.Constants.rowIcon,
                        index: index
                    )
                }
                .background(.black)
                .cornerRadius(8)
            }
        }
        .scrollContentBackground(.hidden)
    }
    
    @ViewBuilder private func driverInfo(
        result: Result,
        driverStanding: DriverStanding?,
        rowIcon: String,
        index: Int
    ) -> some View {
        VStack {
            HStack {
                VStack {
                    if let imageURL = driverStanding?.imageUrl, !imageURL.isEmpty {
                        AsyncImage(url: URL(string: imageURL)) { image in
                            asyncImage(image: image)
                        }
                        placeholder: {
                            placeHolderImage(rowIcon: rowIcon)
                        }
                    } else {
                        placeHolderImage(rowIcon: rowIcon)
                    }

                    Text("\(result.driver?.givenName ?? "") \(result.driver?.familyName ?? "")")
                        .bold()
                }
                .font(.title)
                .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            raceInfo(
                result: result,
                index: index
            )
        }
    }

    @ViewBuilder private func asyncImage(image: Image) -> some View {
        ZStack {
            image
                .resizable()
                .scaledToFit()
                .aspectRatio(contentMode: .fill)
                .padding(.trailing, 10)
                .padding([.leading, .top], 8)
                .clipShape(Rectangle())
                .overlay(
                    Rectangle()
                        .stroke(
                            LinearGradient(colors: [.black.opacity(0.9), .black.opacity(0.9), .red.opacity(0.7), .red.opacity(0.75)], startPoint: .bottomLeading, endPoint: .topTrailing),
                            lineWidth: 24
                        )
                )
        }
    }

    @ViewBuilder private func raceInfo(result: Result, index: Int) -> some View {
        Text("\(result.constructor?.name ?? "")")
            .font(.title2)
            .bold()
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 24)
            .padding(.top, 0)
            .padding(.bottom, 0)

        Group {
            HStack {
                Image(systemName: RaceResultViewModel.Constants.titleImg)
                Text("\(result.status ?? ""): P\(result.position ?? "\(index + 1)")")
            }
            HStack {
                Image(systemName: RaceResultViewModel.Constants.gridPositionIcon)
                Text("Qualified: P\(result.grid ?? "")")
            }
            HStack {
                Image(systemName: RaceResultViewModel.Constants.fastestLapIcon)
                Text("Fastest Lap: \(result.fastestLap?.time?.time ?? ""), Lap: \(result.fastestLap?.lap ?? "")")
            }
            HStack {
                Image(systemName: RaceResultViewModel.Constants.pointsIcon)
                Text("Points: \(result.points ?? "")")
            }
            Divider()
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding([.bottom], 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.white)
        .font(.headline)
        .bold()
    }
    
    @ViewBuilder private func placeHolderImage(rowIcon: String) -> some View {
        Image(systemName: rowIcon)
            .resizable()
            .frame(width: UIScreen.main.bounds.width/1.5, height: UIScreen.main.bounds.height/3.5)
            .scaledToFit()
            .padding(.trailing, 10)
            .padding([.leading, .top], 8)
    }
}

#Preview {
    HomeScreen()
}

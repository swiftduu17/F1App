//
//  HomeScreen.swift
//  F1App
//
//  Created by Arman Husic on 2/19/24.
//

import SwiftUI
import UIKit

struct HomeScreen: View {
    @ObservedObject var viewModel = HomeViewModel()
    @State var text: String
    let homeModel = HomeModel()

    var body: some View {
        ZStack {
            backgroundGradient
            content
        }
    }

    @ViewBuilder
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                .black.opacity(0.75),
                .blue.opacity(0.95),
                .cyan.opacity(0.75),
                .black
            ],
            startPoint: .bottomTrailing,
            endPoint: .topTrailing
        )
            .ignoresSafeArea()
    }

    @ViewBuilder
    private var content: some View {
        VStack {
            HomeTopBar
            QueriesScrollView
        }
    }

    @ViewBuilder
    private var HomeTopBar: some View {
        VStack {
            Text("Box Box F1")
                .font(.title)
                .bold()
                .foregroundStyle(.white)
                .padding([.bottom, .top], 32)
            SeasonSelector(currentSeason: viewModel.seasonYear) { season in
                viewModel.seasonYear = season
                print(season)
            }
        }
    }

    @ViewBuilder
    private var QueriesScrollView: some View {
        ScrollView {
            QueriesCollection
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private var QueriesCollection: some View {
        VStack {
            LazyVGrid(
                columns: [GridItem(.fixed(UIScreen.main.bounds.width / 2))],
                spacing: 24) {
                    ForEach(viewModel.queriesArray().indices, id: \.self) { index in
                        QueryButton(ErgastQuery: viewModel.queriesArray()[index])
                            .sheet(isPresented: $viewModel.shouldNavigateToFirstResults) {
                                MyViewControllerWrapper()
                            }
                    }
                }
                .padding(20)
        }
    }

    struct QueryButton: View {
        var ErgastQuery: ErgastQueryButton
        
        var body: some View {
            Button(action: ErgastQuery.action) {
                VStack {
                    ErgastQuery.icon?
                        .resizable()
                        .font(.title2)
                        .scaledToFit()
                        .foregroundStyle(
                            LinearGradient(colors: [
                                .white.opacity(0.75),
                                .gray.opacity(0.25),
                                .yellow.opacity(0.25)
                            ], 
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing
                            )
                        )
                        .padding(24)
                    Text(ErgastQuery.label)
                        .font(.title)
                        .bold()
                        .foregroundStyle(.white)
                        .padding([.bottom, .top], 16)
                }
                .frame(
                    minWidth: UIScreen.main.bounds.width - 16,
                    minHeight: UIScreen.main.bounds.height/2 - 75
                )
                .ignoresSafeArea()
                .background(
                    LinearGradient(colors: [
                        .indigo.opacity(0.25),
                        .black,
                        .black
                    ], 
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(24)
                .padding(8)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    HomeScreen(text: "2024")
}
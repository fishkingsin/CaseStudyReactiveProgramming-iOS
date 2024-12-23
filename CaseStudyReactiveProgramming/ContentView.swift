//
//  ContentView.swift
//  CaseStudyReactiveProgramming
//
//  Created by James Kong on 23/12/2024.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var viewModel = MainViewModel()
    var body: some View {
        VStack {
            TextField("Search...", text: $viewModel.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            List(viewModel.articles) { article in
                VStack(alignment: .leading) {
                    Text(article.title)
                        .font(.headline)
                    Text(article.subtitle)
                        .font(.subheadline)
                }
            }
        }
        .onAppear {
            viewModel.fetchArticles()
        }
    }
}

#Preview {
    ContentView()
}

//
//  MainViewModel.swift
//  CaseStudyReactiveProgramming
//
//  Created by James Kong on 23/12/2024.
//
import SwiftUI
import Combine

struct Article: Identifiable, Hashable, Equatable {
    var id: UUID = UUID()
    var title: String
    var subtitle: String
}

class MainViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var articles: [Article] = []
    
    private var serahPublisher: AnyPublisher<[Article], Never> {
        $searchText
            .combineLatest(fetchArticlesPublisher())
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .map { searchText, articles in
                // Filter articles based on the search text
                articles.filter { article in
                    searchText.isEmpty || article.title.contains(searchText)
                }
            }
            .map { filteredArticles in
                // Transform filtered articles into DisplayArticleViewModels
                filteredArticles.map { article in
                    Article(
                        title: article.title,
                        subtitle: "By \(article.subtitle)"
                    )
                }
            }.eraseToAnyPublisher()
    }
    var cancellables: Set<AnyCancellable> = []
    func fetchArticles() {
        articles = [
            Article(title: "SwiftUI", subtitle: "A SwiftUI framework"),
            Article(title: "Combine", subtitle: "A SwiftUI framework"),
            Article(title: "SwiftUI", subtitle: "A SwiftUI framework"),
            Article(title: "Combine", subtitle: "A SwiftUI framework"),
        ]
        
    }
    
    func fetchArticlesPublisher() -> AnyPublisher<[Article], Never> {
        Just([
            Article(title: "SwiftUI", subtitle: "A SwiftUI framework"),
            Article(title: "Combine", subtitle: "A SwiftUI framework"),
            Article(title: "SwiftUI", subtitle: "A SwiftUI framework"),
            Article(title: "Combine", subtitle: "A SwiftUI framework"),
        ])
        .delay(for: .milliseconds(100), scheduler: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    init() {
        searchArticles()
    }
    
    private func searchArticles() {
        serahPublisher
            .receive(on: DispatchQueue.main) // Ensure UI updates happen on the main thread
            .sink(receiveCompletion: { completion in
                // Handle errors in the pipeline
                if case let .failure(error) = completion {
                    print("Error: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] displayArticles in
                // Update the published property for UI binding
                self?.articles = displayArticles
            })
            .store(in: &cancellables)
    }
}

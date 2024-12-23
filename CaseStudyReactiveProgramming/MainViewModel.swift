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

class ArticlesRepository {
    func fetchArticles() -> AnyPublisher<[Article], Never> {
        Just([
            Article(title: "SwiftUI", subtitle: "A SwiftUI framework"),
            Article(title: "Combine", subtitle: "A SwiftUI framework"),
            Article(title: "SwiftUI", subtitle: "A SwiftUI framework"),
            Article(title: "Combine", subtitle: "A SwiftUI framework"),
        ])
        .delay(for: .milliseconds(100), scheduler: RunLoop.main)
        .eraseToAnyPublisher()
    }
}

class MainViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var articles: [Article] = []
    let repository = ArticlesRepository()
    private var searchPublisher: AnyPublisher<[Article], Never> {
        $searchText
            .combineLatest(repository.fetchArticles())
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
    
    init() {
        searchArticles()
    }
    
    private func searchArticles() {
        searchPublisher
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

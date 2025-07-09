//
//  TriviaQuestionService.swift
//  Trivia
//
//  Created by Daniel Woldetsadik on 7/8/25.
//

import Foundation
import Foundation

class TriviaQuestionService {
    static func fetchQuestions(amount: Int = 5,
                               completion: (([TriviaQuestion]) -> Void)? = nil) {
        
        let parameters = "amount=\(amount)"
        
        guard let url = URL(string: "https://opentdb.com/api.php?\(parameters)") else {
            print(" Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print(" Invalid HTTP response")
                return
            }
    guard let data = data else {
                print(" No data received")
                return}
    do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(TriviaResponse.self, from: data)
                DispatchQueue.main.async {
                    completion?(response.results)
                }} catch {
                print("Decoding error: \(error.localizedDescription)")}}
        
        task.resume()
    }
}


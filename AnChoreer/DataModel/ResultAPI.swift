//
//  ResultAPI.swift
//  AnChoreer
//
//  Created by Kim dohyun on 2021/12/02.
//

import Foundation
import Alamofire


let headers:HTTPHeaders = [
    "X-Naver-Client-Id":"RTgXQh8hFHdXPpo1MVBZ",
    "X-Naver-Client-Secret":"uyXcs5fMjJ"
]

struct ResultAPI {
    static func getMovieList(Paramter: Parameters, completionHandler: @escaping([SearchModelInfo]) -> ()) {
        guard let urlString = URL(string: "https://openapi.naver.com/v1/search/movie.json") else {
            return
        }
        AF.request(urlString, method: .get, parameters: Paramter, encoding: URLEncoding.queryString, headers: headers)
            .validate(statusCode: 200...500)
            .responseData { response in
                switch response.result {
                case let .success(response):
                    do {
                        let jsonDecoder = try JSONDecoder().decode(SearchModel.self, from: response)
                        completionHandler(jsonDecoder.items)
                    } catch {
                        print(error.localizedDescription)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        
    }
}

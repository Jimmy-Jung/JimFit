//
//  FireStorage.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/15.
//

import Foundation
import Alamofire
import RealmSwift

enum FireStoreError: Error {
    case url
}

enum FireStoreRouter: URLRequestConvertible {
    case checkETag
    case fetchData
    
    var baseURL: URL? {
        return URL(string: APIKEY.ExerciseDataURL)
    }
    
    var method: HTTPMethod {
        switch self {
        case .checkETag:
            return .get
        case .fetchData:
            return .get
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .checkETag:
            return ["If-None-Match": UM.ETag]
        case .fetchData:
            return nil
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        guard let url = baseURL else { throw FireStoreError.url}
        var urlRequest = try URLRequest(url: url, method: method, headers: headers)
        urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
        return urlRequest
    }
}

final class FireStorageService {
    
    let realmManager = RealmManager.shared
    
    func checkETagFromFireStore() {

        AF.request(FireStoreRouter.checkETag).response { response in
            switch response.result {
            case .success(_):
                if response.response?.statusCode != 304 {
                    self.fetchDataFromFireStore()
                } else {
                    UM.finishedLaunch = true
                }
            case .failure(let error):
                print("Error: checking ETag - \(error)")
                UM.finishedLaunch = true
            }
        }
    }
    
    func fetchDataFromFireStore()  {
        AF.request(FireStoreRouter.fetchData).response { response in
            switch response.result {
            case .success(let data):
                guard let data else { return }
                self.parseExerciseData(jsonData: data)
                UM.ETag = response.response?.allHeaderFields["Etag"] as? String ?? ""
            case .failure(let error):
                print("Error: fetching FireStore Data - \(error)")
                UM.finishedLaunch = true
            }
        }
    }
    
    private func parseExerciseData(jsonData: Data) {
        do {
            let jsonDecoder = JSONDecoder()
            let exercises = try jsonDecoder.decode([Exercise].self, from: jsonData)
            // Realm에 저장
            realmManager.saveNewRealm(exercises: exercises)
            realmManager.copyLikeAndRemoveOldRealm()
        } catch {
            print("Error: Parsing exercise data")
            UM.finishedLaunch = true
        }
    }
}

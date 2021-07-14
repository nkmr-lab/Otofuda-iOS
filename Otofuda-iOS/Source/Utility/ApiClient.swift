//
//  ApiClient.swift
//  Otofuda-iOS
//
//  Created by 新納真次郎 on 2019/10/24.
//  Copyright © 2019 nkmr-lab. All rights reserved.
//

import SwiftyJSON
import Alamofire
import RxSwift

protocol ApiClientProtocol {
    var baseUrl: String { get }

    init(_ baseUrl: String)

    func get<T: ResponseEntity>(path: String?,
                                request: RequestEntity?) -> Single<T>
}

class ApiClient: ApiClientProtocol {

    var baseUrl: String

    required init(_ baseUrl: String = BASE_API_URL) {
        self.baseUrl = baseUrl
    }

    func get<T: ResponseEntity>(path: String?,
                                request: RequestEntity?) -> Single<T> {

        var requestUrl = baseUrl
        if let path = path {
            requestUrl = baseUrl + path
        }

        var params = Parameters()
        if let request = request {
            params = request.parameterize()
        }

        return Single<T>.create { single in
//            let manager = SessionManager.default
            let request = AF.request(requestUrl,
                                          method: .get,
                                          parameters: params,
                                          encoding: URLEncoding.default,
                                          headers: nil)
                .responseJSON(completionHandler: { response in
                    switch response.result {
                    case .success(_):
                        guard let data = response.data else {
                            return single(.failure(response.error!))
                        }
                        let json = JSON(data)
                        return single(.success(T(json)))

                    case .failure(let error):
                        print( error )
                        return single(.failure(response.error!))
                    }
                })
            return Disposables.create {
                request.cancel()
            }
        }
    }
}

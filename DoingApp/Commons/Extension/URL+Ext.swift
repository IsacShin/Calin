//
//  URL+Ext.swift
//  DoingApp
//
//  Created by 신이삭 on 5/22/25.
//

import Foundation

extension URL {
    func appendingQueryParameters(_ parameters: [String: String]) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return self
        }
        components.queryItems = (components.queryItems ?? []) + parameters.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        return components.url ?? self
    }
}

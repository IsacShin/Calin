//
//  APIError.swift
//  DoingApp
//
//  Created by 신이삭 on 5/22/25.
//
import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingFailed
    case serverError(statusCode: Int)
    case custom(message: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "잘못된 URL입니다."
        case .invalidResponse:
            return "서버 응답이 유효하지 않습니다."
        case .decodingFailed:
            return "응답을 디코딩하는 데 실패했습니다."
        case .serverError(let code):
            return "서버 오류 (\(code))"
        case .custom(let message):
            return message
        }
    }
}

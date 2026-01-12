//
//  RandomUserAPI.swift
//  RandomUserApp
//
//  Created by JooYoung Kim on 1/12/26.
//

import Foundation

struct RandomUserAPI {
    struct ResponseDTO: Decodable {
        let results: [UserDTO]
        let info: InfoDTO
    }
    
    struct InfoDTO: Decodable {
        let seed: String
        let results: Int
        let page: Int
        let version: String
    }
    
    struct UserDTO: Decodable {
        let gender: String
        let name: NameDTO
        let location: LocationDTO
        let email: String
        let login: LoginDTO
        let dob: DobDTO
        let picture: PictureDTO
    }
    
    struct NameDTO: Decodable {
        let title: String
        let first: String
        let last: String
    }
    
    struct LocationDTO: Decodable {
        let state: String
        let country: String
    }
    
    struct LoginDTO: Decodable {
        let uuid: String
    }
    
    struct DobDTO: Decodable {
        let age: Int
    }
    
    struct PictureDTO: Decodable {
        let large: String
        let medium: String
        let thumbnail: String
    }
    
    enum APIError: Error {
        case invalidURL
        case invalidResponce
        case httpStatus(Int)
        case decodingFailed
    }
    
    static func fetchUsers(
        gender: Gender,
        page: Int,
        results: Int
    ) async throws -> (items: [UserListItem], returnSeed: String) {
       
        var comps = URLComponents(string: "https://randomuser.me/api/")
        let query: [URLQueryItem] = [
            .init(name: "gender", value: gender == .male ? "male" : "female"),
            .init(name: "page", value: String(page)),
            .init(name: "results", value: String(results))
        ]
        
        comps?.queryItems = query
        
        guard let url = comps?.url else {
            throw APIError.invalidURL
        }
        print("url \(url)")
        
        let (data, resp) = try await URLSession.shared.data(from: url)
        guard let http = resp as? HTTPURLResponse else {
            throw APIError.invalidResponce
        }
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.httpStatus(http.statusCode)
        }
        
        let decode: ResponseDTO
        do {
            decode = try JSONDecoder().decode(ResponseDTO.self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
        
        let mapped: [UserListItem] = decode.results.map { u in
            let fullName = "[\(u.name.title)]\(u.name.first) \(u.name.last)"
            let subtitle = "\(u.location.state) \(u.location.country)"
            
            return UserListItem(
                uuid: u.login.uuid,
                name: fullName,
                subtitle: subtitle,
                email: u.email,
                thumbnailURL: URL(string: u.picture.thumbnail),
                largeURL: URL(string: u.picture.large),
                mediumURL: URL(string: u.picture.medium)
            )
        }
        
        return (mapped, decode.info.seed)
    }
}

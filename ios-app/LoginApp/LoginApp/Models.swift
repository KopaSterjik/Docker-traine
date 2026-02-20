import Foundation

struct TokenResponse: Codable {
    let access_token: String
    let token_type: String
    let username: String
}

struct ProfileResponse: Codable {
    let id: Int
    let email: String
    let username: String
    let created_at: String
}

struct ErrorResponse: Codable {
    let detail: String
}

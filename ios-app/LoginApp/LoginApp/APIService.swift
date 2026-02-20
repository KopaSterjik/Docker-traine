import Foundation

@MainActor
class APIService: ObservableObject {
    // ⚠️ Симулятор: localhost. Реальное устройство: IP вашего Mac.
    static let baseURL = "http://localhost:8000"

    @Published var token: String?
    @Published var username: String?
    @Published var isLoading = false
    @Published var errorMessage: String?

    var isLoggedIn: Bool { token != nil }

    func register(email: String, username: String, password: String) async {
        await request(
            endpoint: "/register",
            body: ["email": email, "username": username, "password": password]
        )
    }

    func login(email: String, password: String) async {
        await request(
            endpoint: "/login",
            body: ["email": email, "password": password]
        )
    }

    func logout() {
        token = nil
        username = nil
    }

    func fetchProfile() async -> ProfileResponse? {
        guard let token else { return nil }
        guard let url = URL(string: Self.baseURL + "/profile") else { return nil }

        var req = URLRequest(url: url)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            return try JSONDecoder().decode(ProfileResponse.self, from: data)
        } catch {
            return nil
        }
    }

    private func request(endpoint: String, body: [String: String]) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        guard let url = URL(string: Self.baseURL + endpoint) else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONEncoder().encode(body)

        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            let http = response as! HTTPURLResponse

            if http.statusCode == 200 {
                let result = try JSONDecoder().decode(TokenResponse.self, from: data)
                self.token = result.access_token
                self.username = result.username
            } else {
                let err = try? JSONDecoder().decode(ErrorResponse.self, from: data)
                self.errorMessage = err?.detail ?? "Error \(http.statusCode)"
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}

import SwiftUI

@main
struct LoginApp: App {
    @StateObject private var api = APIService()

    var body: some Scene {
        WindowGroup {
            if api.isLoggedIn {
                HomeView()
                    .environmentObject(api)
            } else {
                AuthView()
                    .environmentObject(api)
            }
        }
    }
}

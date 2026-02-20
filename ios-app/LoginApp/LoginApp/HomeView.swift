import SwiftUI

struct HomeView: View {
    @EnvironmentObject var api: APIService
    @State private var profile: ProfileResponse?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                if let p = profile {
                    // Аватар
                    ZStack {
                        Circle()
                            .fill(.blue.gradient)
                            .frame(width: 100, height: 100)
                        Text(String(p.username.prefix(1)).uppercased())
                            .font(.system(size: 44, weight: .bold))
                            .foregroundStyle(.white)
                    }

                    Text(p.username)
                        .font(.title.bold())

                    // Карточка с инфо
                    VStack(spacing: 16) {
                        InfoRow(icon: "envelope.fill", label: "Email", value: p.email)
                        Divider()
                        InfoRow(icon: "number", label: "ID", value: "\(p.id)")
                        Divider()
                        InfoRow(icon: "calendar", label: "Создан", value: String(p.created_at.prefix(10)))
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                } else {
                    ProgressView("Загрузка профиля...")
                }

                Spacer()

                Button(role: .destructive) {
                    api.logout()
                } label: {
                    Label("Выйти", systemImage: "rectangle.portrait.and.arrow.right")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.bordered)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(30)
            .navigationTitle("Профиль")
            .task {
                profile = await api.fetchProfile()
            }
        }
    }
}

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject({
            let api = APIService()
            api.token = "mock-token"
            api.username = "kopa"
            return api
        }())
}

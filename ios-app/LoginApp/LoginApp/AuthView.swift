import SwiftUI

struct AuthView: View {
    @EnvironmentObject var api: APIService
    @State private var isRegister = false
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // Иконка
                Image(systemName: isRegister ? "person.badge.plus" : "person.circle")
                    .font(.system(size: 64))
                    .foregroundStyle(.blue)
                    .symbolEffect(.bounce, value: isRegister)

                Text(isRegister ? "Регистрация" : "Вход")
                    .font(.largeTitle.bold())

                // Поля ввода
                VStack(spacing: 14) {
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundStyle(.secondary)
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    if isRegister {
                        HStack {
                            Image(systemName: "person")
                                .foregroundStyle(.secondary)
                            TextField("Имя пользователя", text: $username)
                                .autocapitalization(.none)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    HStack {
                        Image(systemName: "lock")
                            .foregroundStyle(.secondary)
                        SecureField("Пароль", text: $password)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .animation(.easeInOut(duration: 0.3), value: isRegister)

                // Ошибка
                if let err = api.errorMessage {
                    Label(err, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                        .font(.caption)
                        .transition(.opacity)
                }

                // Кнопка отправки
                Button {
                    Task {
                        if isRegister {
                            await api.register(email: email, username: username, password: password)
                        } else {
                            await api.login(email: email, password: password)
                        }
                    }
                } label: {
                    Group {
                        if api.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(isRegister ? "Создать аккаунт" : "Войти")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .disabled(api.isLoading || email.isEmpty || password.isEmpty)

                // Переключатель
                Button {
                    withAnimation {
                        isRegister.toggle()
                        api.errorMessage = nil
                    }
                } label: {
                    Text(isRegister ? "Уже есть аккаунт? **Войти**" : "Нет аккаунта? **Регистрация**")
                        .font(.subheadline)
                }

                Spacer()
            }
            .padding(.horizontal, 30)
        }
    }
}

#Preview("Login") {
    AuthView()
        .environmentObject(APIService())
}

#Preview("Register") {
    AuthView()
        .environmentObject({
            let api = APIService()
            return api
        }())
}

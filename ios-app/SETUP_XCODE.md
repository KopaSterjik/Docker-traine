# Настройка в Xcode

## Вариант 1 — Новый проект (рекомендуется)
1. Xcode → File → New → Project → iOS → App
2. Product Name: **LoginApp**
3. Interface: **SwiftUI**, Language: **Swift**
4. Удали сгенерированные файлы (`ContentView.swift`, `LoginAppApp.swift`)
5. Перетащи все `.swift` файлы из `LoginApp/` в проект
6. Build & Run (⌘R)

## Вариант 2 — Скрипт автосоздания
Запусти `create_xcode_project.sh` (ниже).

## Для Preview
- Каждый View-файл содержит `#Preview` макрос
- Preview работает без запущенного бэкенда
- Canvas: Editor → Canvas (⌥⌘Enter)

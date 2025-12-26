# Deadline Countdown

Приложение "Deadline Countdown" — простое iOS-приложение на SwiftUI с хранением данных в Core Data для отслеживания дедлайнов и связанных задач (todo).

**Ключевые возможности**
- Создание, редактирование и удаление дедлайнов.
- Добавление/удаление todo-позиций внутри дедлайна.
- Архивация дедлайнов по наступлению срока.
- Уведомления о приближении дедлайна (через `NotificationService`).

**Технологии**
- Swift, SwiftUI
- Core Data (NSPersistentContainer)
- Combine

**Требования**
- Xcode 15 или новее
- iOS 26.2

**Структура проекта (важные файлы и каталоги)**
- [DeadlineCountdownApp.swift](DeadlineCountdownApp.swift) — точка входа приложения
- [ViewModels/DeadlineListViewModel.swift](ViewModels/DeadlineListViewModel.swift) — логика работы с дедлайнами и todo
- [Services/PersistenceController.swift](Services/PersistenceController.swift) — конфигурация Core Data (поддержка in-memory для тестов)
- [Models/DeadlineModel.xcdatamodeld](Models/DeadlineModel.xcdatamodeld) — модель данных Core Data
- [Views/AddDeadlineView.swift](Views/AddDeadlineView.swift) — UI для добавления/редактирования дедлайна
- [DeadlineCountdownTests/DeadlineCountdownTests.swift](DeadlineCountdownTests/DeadlineCountdownTests.swift) — unit-тесты

**Как запустить проект**
1. Откройте `DeadlineCountdown.xcodeproj` в Xcode:

```bash
open DeadlineCountdown.xcodeproj
```

2. Выберите подходующую схему и запустите на симуляторе или устройстве.

**Тестирование**
- Проект содержит модульные тесты в `DeadlineCountdownTests`. Тесты используют in-memory `NSPersistentContainer`, поэтому они не затрагивают реальное хранилище.
- Запуск тестов в Xcode: меню Product → Test (или Cmd+U).

**Архитектура и примечания по коду**
- `DeadlineListViewModel` содержит основную бизнес-логику: CRUD для `DeadlineEntity`, работу с todo (`TodoItemEntity`) и архивацию просроченных дедлайнов.
- `PersistenceController` поддерживает режим `inMemory`, который применяется в тестах.
- `TimerService` обновляет текущую дату каждую секунду; в тестах таймер останавливается для детерминированности.
- `NotificationService` отвечает за планирование локальных уведомлений.

**Контакты и вклад**
Сиротин Артём - почта: aisirotin@edu.hse.ru

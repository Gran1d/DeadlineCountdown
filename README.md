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

**Соответствие критериям оценки (Self-Check)**

Приложение спроектировано с учётом ключевых метрик качества и готовности к оцениванию:

1. Архитектура

	- Используется паттерн MVVM. Слой данных (Core Data) полностью отделён от UI.
	- Бизнес-логика сосредоточена в `DeadlineListViewModel`.

2. Структурированное тестирование

	- В проекте реализованы модульные тесты в `DeadlineCountdownTests/DeadlineCountdownTests.swift`, проверяющие CRUD-операции с дедлайнами и логику работы с todo-позициями.

3. Количественные метрики

	- Есть вкладка `Metrics` (`Views/MetricsView.swift`), которая может показывать в реальном времени ключевые показатели:
	  - Performance: время запуска и задержки UI.
	  - Stability: показатели отказов (crash-free rate) и ошибки Core Data.
	  - Memory: использование heap-памяти.

4. Сбор фидбека

	- Реализован экран/оверлей обратной связи через `Views/FeedbackView.swift`, который позволяет пользователю оставить отзыв и редактировать его позже в статистике.
    - Так же пока пользователь не оставил обратную связь экран обратной связи появляется после создания первого дедлайна.

5. Продуктивность

	- Приложение готово к использованию: состояние сохраняется в Core Data и сохраняется после перезагрузки.
	- Приложение запускается на iOS-устройствах.

**Контакты и вклад**

Сиротин Артём - почта: aisirotin@edu.hse.ru

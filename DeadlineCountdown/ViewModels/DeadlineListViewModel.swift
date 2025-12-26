import Foundation
import CoreData
import Combine

final class DeadlineListViewModel: ObservableObject {

    @Published var deadlines: [DeadlineEntity] = []
    @Published var currentDate: Date = Date()
    
    private var cancellables = Set<AnyCancellable>()
    private let context: NSManagedObjectContext

    // Замыкание для уведомления о добавлении дедлайна (для FeedbackView)
    var onDeadlineAdded: (() -> Void)?
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        fetchDeadlines()
        
        // Подписка на TimerService для обновления currentDate
        // Заменить на:
        TimerService.shared.$currentDate
            .receive(on: RunLoop.main)
            .sink { [weak self] date in
                guard let self = self else { return }
                self.currentDate = date
                
                // Проверяем только если действительно нужно
                let needsArchiving = self.deadlines.contains { deadline in
                    guard let due = deadline.dueDate else { return false }
                    return due <= date && !deadline.isArchived
                }
                
                if needsArchiving {
                    self.archivePastDeadlines()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Fetch
    func fetchDeadlines() {
        let request: NSFetchRequest<DeadlineEntity> = DeadlineEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DeadlineEntity.dueDate, ascending: true)]
        do {
            deadlines = try context.fetch(request)
        } catch {
            AppMetrics.logError(error)
        }
    }
    
    // MARK: - Add
    func addDeadline(title: String, dueDate: Date, remindBefore: Int16) {
        let newDeadline = DeadlineEntity(context: context)
        newDeadline.id = UUID()
        newDeadline.title = title
        newDeadline.dueDate = dueDate
        newDeadline.createdAt = Date()
        newDeadline.isArchived = false
        newDeadline.remindBefore = remindBefore
        
        saveContext()
    
        onDeadlineAdded?()
        
        scheduleNotification(for: newDeadline)
    }
    
    // MARK: - Update
    func updateDeadline(_ deadline: DeadlineEntity, title: String, dueDate: Date, remindBefore: Int16) {
        deadline.title = title
        deadline.dueDate = dueDate
        deadline.remindBefore = remindBefore
        deadline.isArchived = false
        
        saveContext()
        scheduleNotification(for: deadline)
    }
    
    // MARK: - Delete
    func removeDeadline(_ deadline: DeadlineEntity) {
        context.performAndWait {
            context.delete(deadline)
            saveContext()
        }
    }
    
    // MARK: - Archive past
    func archivePastDeadlines() {
        var hasChanges = false

        for deadline in deadlines where !deadline.isArchived {
            if let due = deadline.dueDate, due <= currentDate {
                deadline.isArchived = true
                hasChanges = true
            }
        }

        if hasChanges {
            saveContext()
        }
    }

    
    // MARK: - Helpers
    func activeDeadlines() -> [DeadlineEntity] {
        deadlines.filter { !$0.isArchived && ($0.dueDate ?? Date()) > currentDate }
    }
    
    func archivedDeadlines() -> [DeadlineEntity] {
        deadlines.filter { $0.isArchived || ($0.dueDate ?? Date()) <= currentDate }
    }
    
    func timeRemaining(for deadline: DeadlineEntity) -> TimeInterval {
        guard let dueDate = deadline.dueDate else { return 0 }
        return max(dueDate.timeIntervalSince(currentDate), 0)
    }
    
    // MARK: - Todo logic

    func todos(for deadline: DeadlineEntity) -> [TodoItemEntity] {
        let set = deadline.todos as? Set<TodoItemEntity> ?? []
        return set.sorted {
            ($0.createdAt ?? Date()) < ($1.createdAt ?? Date())
        }
    }

    func addTodo(to deadline: DeadlineEntity, title: String) {
        let todo = TodoItemEntity(context: context)
        todo.id = UUID()
        todo.title = title
        todo.isCompleted = false
        todo.createdAt = Date()
        todo.deadline = deadline

        saveContext()
    }

    func toggleTodo(_ todo: TodoItemEntity) {
        todo.isCompleted.toggle()
        saveContext()
    }

    func removeTodo(_ todo: TodoItemEntity) {
        context.delete(todo)
        saveContext()
    }
    
    // MARK: - Todo metrics

    func totalTodoCount() -> Int {
        deadlines.reduce(0) {
            $0 + ( ($1.todos as? Set<TodoItemEntity>)?.count ?? 0 )
        }
    }

    func completedTodoCount() -> Int {
        deadlines.reduce(0) {
            let todos = ($1.todos as? Set<TodoItemEntity>) ?? []
            return $0 + todos.filter { $0.isCompleted }.count
        }
    }

    func deadlinesWithAllTasksCompleted() -> Int {
        deadlines.filter { deadline in
            let todos = (deadline.todos as? Set<TodoItemEntity>) ?? []
            return !todos.isEmpty && todos.allSatisfy { $0.isCompleted }
        }.count
    }


    
    // MARK: - Save context
    private func saveContext() {
        do {
            try context.save()
            fetchDeadlines() // обновляем массив для UI
        } catch {
            AppMetrics.logError(error)
        }
    }
    
    // MARK: - Notifications
    private func scheduleNotification(for deadline: DeadlineEntity) {
        guard let dueDate = deadline.dueDate else { return }
        let notifyDate = Calendar.current.date(byAdding: .minute, value: -Int(deadline.remindBefore), to: dueDate) ?? dueDate
        if notifyDate > Date() {
            NotificationService.shared.scheduleNotification(
                title: "Срок дедлайна",
                body: deadline.title ?? "",
                date: notifyDate
            )
        }
    }
}

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
        context.delete(deadline)
        saveContext()
    }
    
    // MARK: - Archive past
    func archivePastDeadlines() {
        for deadline in deadlines {
            if let due = deadline.dueDate, due <= currentDate, !deadline.isArchived {
                deadline.isArchived = true
            }
        }
        saveContext()
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

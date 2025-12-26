import XCTest
import CoreData
@testable import DeadlineCountdown

final class DeadlineCountdownTests: XCTestCase {
    var persistence: PersistenceController!
	var viewModel: DeadlineListViewModel!

	override func setUp() {
		super.setUp()
		persistence = PersistenceController(inMemory: true)
		// Остановим таймер, чтобы тесты были детерминированными
		TimerService.shared.stop()
		viewModel = DeadlineListViewModel(context: persistence.container.viewContext)
	}

	override func tearDown() {
		viewModel = nil
		persistence = nil
		super.tearDown()
	}

	// Вспомогательный помощник для ожидания условия с таймаутом
	private func waitFor(_ condition: @escaping () -> Bool, timeout: TimeInterval = 1.0) {
		let start = Date()
		while Date().timeIntervalSince(start) < timeout {
			if condition() { return }
			RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.01))
		}
		// если не выполнено — тест продолжит и вызовет XCTAssert
	}

	func testAddDeadline_createsDeadline() {
		XCTAssertEqual(viewModel.deadlines.count, 0)

		let due = Date().addingTimeInterval(3600)
		viewModel.addDeadline(title: "Test Deadline", dueDate: due, remindBefore: 10)

		// fetchDeadlines вызывается внутри addDeadline — подождём коротко
		waitFor({ self.viewModel.deadlines.count == 1 })

		XCTAssertEqual(viewModel.deadlines.count, 1)
		let created = viewModel.deadlines.first
		XCTAssertEqual(created?.title, "Test Deadline")
		XCTAssertEqual(created?.remindBefore, 10)
		XCTAssertNotNil(created?.id)
		XCTAssertNotNil(created?.dueDate)
	}

	func testRemoveDeadline_deletesDeadline() {
		let due = Date().addingTimeInterval(3600)
		viewModel.addDeadline(title: "ToDelete", dueDate: due, remindBefore: 5)
		waitFor({ self.viewModel.deadlines.count == 1 })

		guard let deadline = viewModel.deadlines.first else {
			XCTFail("Дедлайн не создан")
			return
		}

		viewModel.removeDeadline(deadline)

		// removeDeadline использует context.perform и асинхронно обновляет массив
		waitFor({ self.viewModel.deadlines.isEmpty }, timeout: 2.0)

		XCTAssertTrue(viewModel.deadlines.isEmpty)
	}

	func testAddTodo_addsTodoToDeadline() {
		let due = Date().addingTimeInterval(3600)
		viewModel.addDeadline(title: "WithTodos", dueDate: due, remindBefore: 5)
		waitFor({ self.viewModel.deadlines.count == 1 })

		guard let deadline = viewModel.deadlines.first else {
			XCTFail("Дедлайн не создан")
			return
		}

		XCTAssertEqual(viewModel.todos(for: deadline).count, 0)

		viewModel.addTodo(to: deadline, title: "First Task")

		// добавление синхронно сохраняет контекст и обновляет массив
		waitFor({ self.viewModel.todos(for: deadline).count == 1 })

		let todos = viewModel.todos(for: deadline)
		XCTAssertEqual(todos.count, 1)
		XCTAssertEqual(todos.first?.title, "First Task")
		XCTAssertFalse(todos.first?.isCompleted ?? true)
	}
    
}

import XCTest

final class DeadlineCountdownUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    // MARK: - Add / Delete Deadline with Date
    @MainActor
    func testAddAndDeleteDeadline() throws {

        // Открываем вкладку Active
        app.tabBars.buttons["Active"].tap()

        // Нажимаем "+"
        app.buttons["plus"].firstMatch.tap()

        // Вводим название
        let titleField = app.textFields["Title"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("UI Deadline")

        // Закрываем клавиатуру, чтобы можно было работать с DatePicker
        if app.keyboards.buttons["Return"].exists {
            app.keyboards.buttons["Return"].tap()
        }

        // Дату для теста устанавливаем через launchArgument в самой вью (см. AddDeadlineView.onAppear)
        // Дожидаемся, что поле сохранения доступно
        XCTAssertTrue(app.buttons["Save"].waitForExistence(timeout: 2))

        // Сохраняем
        app.buttons["Save"].tap()

        // Проверяем, что дедлайн появился
        let cell = app.staticTexts["UI Deadline"]
        XCTAssertTrue(cell.waitForExistence(timeout: 2))

        // Удаляем дедлайн
        let firstCell = app.cells.firstMatch
        firstCell.swipeLeft()
        if firstCell.buttons["Delete"].exists {
            firstCell.buttons["Delete"].tap()
        } else if app.buttons["Delete"].exists {
            app.buttons["Delete"].tap()
        }

        // Проверяем, что исчез
        XCTAssertFalse(cell.exists)
    }

    // MARK: - Add Todo and Toggle
    @MainActor
    func testAddTodoAndToggle() throws {

        app.tabBars.buttons["Active"].tap()

        // Добавляем дедлайн
        app.buttons["plus"].firstMatch.tap()

        let titleField = app.textFields["Title"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("Deadline with Todo")

        // Закрываем клавиатуру
        if app.keyboards.buttons["Return"].exists {
            app.keyboards.buttons["Return"].tap()
        }

        app.buttons["Save"].tap()

        let deadlineCell = app.staticTexts["Deadline with Todo"]
        XCTAssertTrue(deadlineCell.waitForExistence(timeout: 2))
        deadlineCell.tap()

        // Добавляем задачу
        let taskField = app.textFields["New task"]
        XCTAssertTrue(taskField.waitForExistence(timeout: 2))
        taskField.tap()
        taskField.typeText("UITask 1")
        app.keyboards.buttons["Return"].tap() // закрываем клавиатуру

        app.buttons["Add"].tap()

        let taskCell = app.staticTexts["UITask 1"]
        XCTAssertTrue(taskCell.waitForExistence(timeout: 2))

        // Отмечаем задачу (по иконке)
        let checkbox = app.images["circle"].firstMatch
        if checkbox.exists {
            checkbox.tap()
        }
    }
}

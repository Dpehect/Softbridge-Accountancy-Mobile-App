import XCTest

final class MuhasebeUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testWalkthrough() throws {
        let app = XCUIApplication()
        app.launch()
        
        let unlockButton = app.buttons["unlockButton"]
        if unlockButton.waitForExistence(timeout: 5) {
            unlockButton.tap()
        }
        
        sleep(4)
        
        let tabLedger = app.tabBars.buttons["Ledger"]
        if tabLedger.waitForExistence(timeout: 5) {
            tabLedger.tap()
        }
        
        sleep(2)
        
        let googleRow = app.staticTexts["Google Workspace"]
        if googleRow.waitForExistence(timeout: 5) {
            googleRow.tap()
        }
        
        sleep(3)
        
        let closeButton = app.buttons["closeButton"]
        if closeButton.waitForExistence(timeout: 5) {
            closeButton.tap()
        }
        
        sleep(2)
        
        let tabInsights = app.tabBars.buttons["Insights"]
        if tabInsights.waitForExistence(timeout: 5) {
            tabInsights.tap()
        }
        
        sleep(3)
        
        let tabVault = app.tabBars.buttons["The Vault"]
        if tabVault.waitForExistence(timeout: 5) {
            tabVault.tap()
        }
        
        sleep(2)
        
        let invoicesFolder = app.buttons["folder_Invoices"]
        if invoicesFolder.waitForExistence(timeout: 5) {
            invoicesFolder.tap()
        }
        
        sleep(2)
        
        let uploadButton = app.buttons["uploadButton"]
        if uploadButton.waitForExistence(timeout: 5) {
            uploadButton.tap()
        }
        
        sleep(5)
    }
}

import UIKit
import CocoaLumberjackSwift
import SQLite

class RootViewController: UINavigationController {

    let fileCache = FileCache()
    let networkingService = DefaultNetworkingService()
    var dataBase: Connection?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCocoaLumberjack()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        fileCache.managedObjectContext = appDelegate.persistentContainer.viewContext

        let myViewController = MainViewController()

        loadDB()

        setupMainViewController(myViewController: myViewController)

        viewControllers = [myViewController]
    }

    func setupCocoaLumberjack() {
        DDLog.add(DDOSLogger.sharedInstance) // Uses os_log
        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
    }

    func setupMainViewController(myViewController: MainViewController) {
        myViewController.fileCache = fileCache
        myViewController.networkingService = networkingService
        myViewController.loadToDoItemsFromServer()
        myViewController.dataBase = dataBase
    }

    func loadDB() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!

        let dbPath = "\(path)/db.sqlite3"
        let dbExists = FileManager.default.fileExists(atPath: dbPath)

        do {
            dataBase = try Connection(dbPath)

            if !dbExists {
                let todoItemsTable = Table("todoItems")
                let id = Expression<String>(Keys.id.rawValue)
                let text = Expression<String>(Keys.text.rawValue)
                let importance = Expression<String>(Keys.importance.rawValue)
                let isCompleted = Expression<Bool>(Keys.isCompleted.rawValue)
                let creationDate = Expression<Int>(Keys.creationDate.rawValue)
                let lastUpdatedBy = Expression<String>(Keys.lastUpdatedBy.rawValue)
                let deadlineDate = Expression<Int?>(Keys.deadlineDate.rawValue)
                let modificationDate = Expression<Int>(Keys.modificationDate.rawValue)

                try dataBase!.run(todoItemsTable.create { table in
                    table.column(id, primaryKey: true)
                    table.column(text)
                    table.column(importance)
                    table.column(isCompleted)
                    table.column(creationDate)
                    table.column(lastUpdatedBy)
                    table.column(deadlineDate)
                    table.column(modificationDate)

                DDLogInfo("Create SQL DB")
                })
            } else {
                DDLogInfo("Load SQL DB")
            }
            guard let dataBaseForFC = dataBase else { return }
            fileCache.load(dataBase: dataBaseForFC)
        } catch {
            print("Error: try Connection(dbPath)")
        }
    }

}

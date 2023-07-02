import UIKit
import CocoaLumberjackSwift

class RootViewController: UINavigationController {

    let fileCache = FileCache()

    override func viewDidLoad() {
        super.viewDidLoad()

        DDLog.add(DDOSLogger.sharedInstance) // Uses os_log
        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)

        let myViewController = MainViewController()
        myViewController.fileCache = fileCache
        viewControllers = [myViewController]
    }
}

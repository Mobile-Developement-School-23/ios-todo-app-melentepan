import UIKit

class RootViewController: UIViewController {
    
    let fileCache = FileCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1)
        
        let button = UIButton(type: .system)
        button.setTitle("Перейти", for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc func buttonTapped() {
        let todoVC = TodoItemViewController()
//        fileCache.loadJSON(from: <#T##URL#>)
        todoVC.fileCache = fileCache
        let newViewController = UINavigationController(rootViewController: todoVC)
        newViewController.modalPresentationStyle = .fullScreen
        present(newViewController, animated: true, completion: nil)
    }
}

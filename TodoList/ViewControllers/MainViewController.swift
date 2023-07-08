import UIKit

class MainViewController: UIViewController {

    let tableView = UITableView()
    let labelCountOfComplete = UILabel()
    let buttonShow = UIButton()
    let plusButton = UIButton()

    var completeIsShow = true
    var isDirty = false

    var fileCache = FileCache()
    var networkingService = DefaultNetworkingService()

    override func viewDidLoad() {
        super.viewDidLoad()
        createTableView()
        createPlusButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "Мои дела"
        view.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1)
    }

    func createTableView() {
        view.addSubview(tableView)

        tableView.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = TableViewCell.cellHeight

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")

        tableView.dataSource = self
        tableView.delegate = self

        createHeaderView()
        createFooterView()
    }

    func createHeaderView() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        headerView.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1)

        labelCountOfComplete.text = "Выполнено — \(fileCache.todoItems.filter({$0.isCompleted == true}).count)"
        labelCountOfComplete.layer.opacity = 0.3
        labelCountOfComplete.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(labelCountOfComplete)

        buttonShow.setTitle("Скрыть", for: .normal)
        buttonShow.setTitleColor(.systemBlue, for: .normal)
        buttonShow.translatesAutoresizingMaskIntoConstraints = false
        buttonShow.addTarget(self, action: #selector(showButtonTap), for: .touchUpInside)
        headerView.addSubview(buttonShow)

        NSLayoutConstraint.activate([
            labelCountOfComplete.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            labelCountOfComplete.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            buttonShow.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            buttonShow.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])

        tableView.tableHeaderView = headerView
    }

    func createFooterView() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: (56 + 76)))
        footerView.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1)

        let firstView = UIButton()
        let label = UILabel()
        let secondView = UIView()

        footerView.addSubview(firstView)
        firstView.addSubview(label)
        footerView.addSubview(secondView)

        firstView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        secondView.translatesAutoresizingMaskIntoConstraints = false

        firstView.backgroundColor = .white
        firstView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        firstView.layer.cornerRadius = 16
        firstView.addTarget(self, action: #selector(newButtonTap), for: .touchUpInside)

        label.text = "Новое"
        label.textAlignment = .center
        label.textColor = .gray

        NSLayoutConstraint.activate([

            firstView.leadingAnchor.constraint(equalTo: footerView.leadingAnchor),
            firstView.trailingAnchor.constraint(equalTo: footerView.trailingAnchor),
            firstView.topAnchor.constraint(equalTo: footerView.topAnchor),
            firstView.heightAnchor.constraint(equalToConstant: 56),

            secondView.leadingAnchor.constraint(equalTo: footerView.leadingAnchor),
            secondView.trailingAnchor.constraint(equalTo: footerView.trailingAnchor),
            secondView.topAnchor.constraint(equalTo: firstView.bottomAnchor),
            secondView.heightAnchor.constraint(equalToConstant: 76),

            label.centerXAnchor.constraint(equalTo: firstView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: firstView.centerYAnchor)
        ])

        tableView.tableFooterView = footerView
    }

    func createPlusButton() {
        view.addSubview(plusButton)

        let imageView = UIImageView(image: UIImage(named: "plusButton"))

        plusButton.addSubview(imageView)

        plusButton.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            plusButton.heightAnchor.constraint(equalToConstant: 44),
            plusButton.widthAnchor.constraint(equalToConstant: 44),
            plusButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plusButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -54),

            imageView.topAnchor.constraint(equalTo: plusButton.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: plusButton.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: plusButton.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: plusButton.trailingAnchor)
            ])

        plusButton.addTarget(self, action: #selector(newButtonTap), for: .touchUpInside)
    }

    @objc func newButtonTap() {
        let newTodoItemVC = TodoItemViewController(mainVC: self, statusOfVC: .creation)
        let newTodoItemNavVC = UINavigationController(rootViewController: newTodoItemVC)
        present(newTodoItemNavVC, animated: true)
    }

    @objc func showButtonTap() {
        completeIsShow.toggle()

        if completeIsShow {
            buttonShow.setTitle("Скрыть", for: .normal)
        } else {
            buttonShow.setTitle("Показать", for: .normal)
        }

        labelCountOfComplete.text = "Выполнено — \(fileCache.todoItems.filter({$0.isCompleted == true}).count)"

        tableView.reloadData()
    }

    func addToDoItemOnServer(todoItem: TodoItem) {
        Task {
            do {
                _ = try await networkingService.postTodoItemElement(todoItemLocal: todoItem)
                isDirty = false
            } catch {
                isDirty = true
            }
        }
    }

    func loadToDoItemsFromServer() {
        Task {
            do {
                let newTodoItems = try await networkingService.getTodoItemList()
                for item in newTodoItems {
                    fileCache.add(item: item)
                }
                tableView.reloadData()
                labelCountOfComplete.text = "Выполнено — \(self.fileCache.todoItems.filter({$0.isCompleted == true}).count)"
                isDirty = false
            } catch {
                isDirty = true
            }
        }
    }

    func deleteToDoItemFromServer(todoItem: TodoItem) {
        Task {
            do {
                _ = try await networkingService.deleteTodoItemElement(id: todoItem.id)
                isDirty = false
            } catch {
                isDirty = true
            }
        }
    }

    func changeToDoItemsOnServer() {
        Task {
            do {
                _ = try await networkingService.patchTodoItemsList(todoItemsLocal: fileCache.todoItems)
                isDirty = false
            } catch {
                isDirty = true
            }
        }
    }

    func loadOneToDoItemFromServer(todoItem: TodoItem) {
        Task {
            do {
                _ = try await networkingService.getTodoItemElement(id: todoItem.id)
                isDirty = false
            } catch {
                isDirty = true
            }
        }
    }

    func changeOneToDoItemOnServer(todoItem: TodoItem) {
        Task {
            do {
                _ = try await networkingService.putTodoItemElement(todoItemLocal: todoItem)
                isDirty = false
            } catch {
                isDirty = true
            }
        }
    }
}

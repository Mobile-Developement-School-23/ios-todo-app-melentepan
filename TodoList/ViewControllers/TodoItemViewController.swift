import UIKit
import CocoaLumberjackSwift

class TodoItemViewController: UIViewController {

    var mainVC = MainViewController()

    let mainView = UIStackView()

    let textView = UITextView()
    let scrollView = UIScrollView()

    let stackView = UIStackView()

    let importanceView = ImportanceView()
    let deadlineView = DeadlineView()
    let calendarView = CalendarView()

    let cancelButton = UIButton(type: .system)
    let saveButton = UIButton(type: .system)
    let deleteButton = UIButton(type: .system)

    var isCalendarCellVisible = false
    var date: Date?

    let statusOfVC: StatusVC

    var todoItem: TodoItem?

    init(mainVC: MainViewController, statusOfVC: StatusVC, todoItem: TodoItem? = nil) {
        self.mainVC = mainVC
        self.statusOfVC = statusOfVC
        self.todoItem = todoItem
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1)
        navigationController?.navigationBar.prefersLargeTitles = false
        setupNavigationBar()
        createScrollView()
        createMainView()
        createTextView()
        createStackView()
        createDeleteButton()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        if let todoItem = todoItem {
            textView.text = todoItem.text
            textView.textColor = .black

            var importanceIndex = 1
            if todoItem.importance == .unimportant {
                importanceIndex = 0
            } else if todoItem.importance == .usual {
                importanceIndex = 1
            } else if todoItem.importance == .important {
                importanceIndex = 2
            }

            importanceView.importanceControl.selectedSegmentIndex = importanceIndex

            if let deadlineDate = todoItem.deadlineDate {
                deadlineView.switchControl.isOn = true
                deadlineView.switchChanged()
                calendarView.calendarView.date = deadlineDate
                calendarView.datePickerChanged(calendarView.calendarView)
            }

            if statusOfVC == .change {
                saveButton.isEnabled = true
                deleteButton.isEnabled = true
                calendarView.isHidden = true
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = mainView.frame.size
    }

    func setupNavigationBar() {
        title = "Дело"

        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.addTarget(self, action: #selector(tapCancel), for: .touchUpInside)

        saveButton.setTitle("Сохранить", for: .normal)
        saveButton.addTarget(self, action: #selector(tapSave), for: .touchUpInside)

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)

        saveButton.isEnabled = false
    }

    func createScrollView() {
        view.addSubview(scrollView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            scrollView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1)
        ])

    }

    func createMainView() {
        scrollView.addSubview(mainView)

        mainView.axis = .vertical
        mainView.distribution = .fill
        mainView.alignment = .center
        mainView.spacing = 16

        mainView.translatesAutoresizingMaskIntoConstraints = false
        mainView.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1)
        NSLayoutConstraint.activate([
            mainView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            mainView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            mainView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1)
        ])
    }

    func createTextView() {
        textView.text = "Что надо сделать?"
        textView.textColor = .lightGray
        textView.delegate = self
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.layer.cornerRadius = 16
        mainView.addArrangedSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120)
        ])
    }

    func createStackView() {
        mainView.addArrangedSubview(stackView)

        stackView.clipsToBounds = true
        stackView.layer.cornerRadius = 16
        stackView.backgroundColor = .white
        stackView.axis = .vertical
        stackView.distribution = .fill

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -16)
        ])

        importanceView.translatesAutoresizingMaskIntoConstraints = false
        importanceView.heightAnchor.constraint(equalToConstant: 56).isActive = true
        stackView.addArrangedSubview(importanceView)

        stackView.addArrangedSubview(SeparatorView())

        deadlineView.scrollView = scrollView
        deadlineView.translatesAutoresizingMaskIntoConstraints = false
        deadlineView.heightAnchor.constraint(equalToConstant: 56).isActive = true
        stackView.addArrangedSubview(deadlineView)

        let separatorView = SeparatorView()
        separatorView.isHidden = true
        deadlineView.separatorView = separatorView
        stackView.addArrangedSubview(separatorView)

        calendarView.isHidden = true
        deadlineView.calendarView = calendarView
        calendarView.deadlineView = deadlineView
        stackView.addArrangedSubview(calendarView)
    }

    func createDeleteButton() {
        deleteButton.setTitle("Удалить", for: .normal)
        deleteButton.setTitleColor(.red, for: .normal)
        deleteButton.setTitleColor(.gray, for: .disabled)

        deleteButton.backgroundColor = .white
        deleteButton.layer.cornerRadius = 16
        deleteButton.isEnabled = false
        deleteButton.addTarget(self, action: #selector(tapDelete), for: .touchUpInside)

        mainView.addArrangedSubview(deleteButton)

        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deleteButton.heightAnchor.constraint(equalToConstant: 56),
            deleteButton.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 16),
            deleteButton.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -16)
        ])

    }

    @objc func tapCancel() {
        dismiss(animated: true)
    }

    @objc func tapSave() {
        let text = textView.text
        let importance = importanceView.items[importanceView.importanceControl.selectedSegmentIndex]
        let deadlineDate = deadlineView.switchControl.isOn ? calendarView.calendarView.date : nil
        let modificationDate = Date()

        if statusOfVC == .change {
            DDLogDebug("Обновление todoItem")
            if let todoItem = todoItem {
                let updatedTodoItem = TodoItem(id: todoItem.id, text: text!, importance: importance, deadlineDate: deadlineDate, isCompleted: todoItem.isCompleted, modificationDate: modificationDate)
                mainVC.fileCache.add(item: updatedTodoItem)
            }
        } else {
            DDLogDebug("Создание todoItem")
            let isCompleted = false
            let todoItem = TodoItem(text: text!, importance: importance, deadlineDate: deadlineDate, isCompleted: isCompleted, modificationDate: modificationDate)
            mainVC.fileCache.add(item: todoItem)
        }

        mainVC.fileCache.saveJSON()
        mainVC.tableView.reloadData()
        dismiss(animated: true)
    }

    @objc func tapDelete() {
        mainVC.fileCache.remove(id: todoItem!.id)
        DDLogDebug("Удаление \(todoItem!.id)")
        mainVC.tableView.reloadData()
        dismiss(animated: true)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardSize.cgRectValue
        var contentInset = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInset = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
}

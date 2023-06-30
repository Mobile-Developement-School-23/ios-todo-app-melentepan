import UIKit

class DeadlineView: UIView {
    let dueDateLabel = UILabel()
    let stackView = UIStackView()
    let dueDateButton = UIButton(type: .system)
    let switchControl = UISwitch()

    var scrollView = UIScrollView()
    var calendarView = UIView()
    var separatorView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    func setupViews() {
        dueDateLabel.text = "Сделать до"

        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("d MMMM yyyy")
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let tomorrowString = dateFormatter.string(from: tomorrow)

        dueDateButton.setTitle(tomorrowString, for: .normal)
        dueDateButton.isHidden = true

        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill

        addSubview(switchControl)
        addSubview(stackView)

        stackView.addArrangedSubview(dueDateLabel)
        stackView.addArrangedSubview(dueDateButton)
        stackView.sendSubviewToBack(dueDateButton)

        dueDateLabel.translatesAutoresizingMaskIntoConstraints = false
        dueDateButton.translatesAutoresizingMaskIntoConstraints = false
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        switchControl.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        dueDateButton.addTarget(self, action: #selector(changeCalendar), for: .touchUpInside)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            switchControl.topAnchor.constraint(equalTo: topAnchor, constant: 12.5),
            switchControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12.5),
            switchControl.leadingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 16),
            switchControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])

    }

    @objc func switchChanged() {
        dueDateButton.isHidden = !switchControl.isOn
        if !switchControl.isOn && !calendarView.isHidden {
            changeCalendar()
        }
    }

    @objc func changeCalendar() {
        UIView.animate(withDuration: 0.3) {
            self.calendarView.isHidden.toggle()
            self.separatorView.isHidden.toggle()
            self.calendarView.alpha = self.calendarView.isHidden ? 0 : 1
            self.separatorView.alpha = self.separatorView.isHidden ? 0 : 1
        }
        if !calendarView.isHidden { scrollView.contentSize.height += calendarView.frame.height }
    }
}

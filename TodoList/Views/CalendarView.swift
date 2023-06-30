import UIKit

class CalendarView: UIView {
    let calendarView = UIDatePicker()

    var deadlineView = DeadlineView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(calendarView)

        calendarView.datePickerMode = .date
        calendarView.preferredDatePickerStyle = .inline
        calendarView.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        calendarView.date = calendarView.minimumDate!

        calendarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            calendarView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            calendarView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            calendarView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])

        calendarView.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func datePickerChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("d MMMM yyyy")
        let dateString = dateFormatter.string(from: sender.date)
        deadlineView.dueDateButton.setTitle(dateString, for: .normal)
        deadlineView.changeCalendar()
    }

}

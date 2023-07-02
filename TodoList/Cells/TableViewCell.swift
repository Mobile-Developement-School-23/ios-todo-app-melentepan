import UIKit

class TableViewCell: UITableViewCell {

    static let cellHeight: CGFloat = 56

    var todoItem: TodoItem!

    var fileCache = FileCache()

    var bottomStackView = UIStackView()

    let cellImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let topLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.font = label.font.withSize(17)
        return label
    }()

    let bottomImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "calendar")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let bottomLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = label.font.withSize(15)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.text = nil
        detailTextLabel?.text = nil
        imageView?.image = nil
        accessoryType = .none
        isUserInteractionEnabled = true
        topLabel.attributedText = nil
    }

    func setupViews() {
        addSubview(cellImageView)

        bottomStackView = UIStackView(arrangedSubviews: [bottomImageView, bottomLabel])
        bottomStackView.axis = .horizontal
        bottomStackView.isHidden = true
        bottomStackView.layer.opacity = 0.3

        let stackView = UIStackView(arrangedSubviews: [topLabel, bottomStackView])
        stackView.axis = .vertical
        stackView.spacing = 1
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            cellImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            cellImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            cellImageView.widthAnchor.constraint(equalTo: cellImageView.heightAnchor, multiplier: 1),

            stackView.leadingAnchor.constraint(equalTo: cellImageView.trailingAnchor, constant: 12),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -39),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),

            bottomLabel.centerYAnchor.constraint(equalTo: bottomStackView.centerYAnchor),

            bottomImageView.heightAnchor.constraint(equalToConstant: 12),
            bottomImageView.widthAnchor.constraint(equalToConstant: 13),
            bottomImageView.centerYAnchor.constraint(equalTo: bottomStackView.centerYAnchor),
            bottomImageView.leadingAnchor.constraint(equalTo: cellImageView.trailingAnchor, constant: 12),
            bottomImageView.trailingAnchor.constraint(equalTo: bottomLabel.leadingAnchor, constant: -2)
        ])
    }
    func setText() {
        var importanceSym = ""
        if todoItem.importance == .important {
            importanceSym = "‼️ "
        } else if todoItem.importance == .unimportant {
            importanceSym = "↓ "
        }

        topLabel.text = "\(importanceSym)\(todoItem.text)"
    }

    func setCompleteImage() {
        if todoItem.isCompleted {
            cellImageView.image = UIImage(named: "done")
            return
        }
        if todoItem.importance == .important {
            cellImageView.image = UIImage(named: "important")
        } else {
            cellImageView.image = UIImage(named: "none")
        }
    }

    func setComplete() {
        todoItem.isCompleted = !todoItem.isCompleted
        fileCache.add(item: todoItem)
        setCompleteImage()
        setTextEffects()
    }

    func setTextEffects() {
        if todoItem.isCompleted {
            topLabel.layer.opacity = 0.3
            topLabel.attributedText = NSAttributedString(string: topLabel.text ?? "", attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue])
        } else {
            topLabel.layer.opacity = 1
            topLabel.attributedText = NSAttributedString(string: topLabel.text ?? "", attributes: [:])
        }
    }

    func setDeadline() {
        guard let date = todoItem.deadlineDate else {
            bottomStackView.isHidden = true
            return
        }
        bottomStackView.isHidden = false

        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("d MMMM")
        bottomLabel.text = dateFormatter.string(from: date)

    }

}

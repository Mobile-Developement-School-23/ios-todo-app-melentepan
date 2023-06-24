import UIKit

class ImportanceView: UIView {
    let importanceLabel = UILabel()
    let importanceControl = UISegmentedControl(items: ["↓", "нет", "‼️"])
    
    let items = [Importance.unimportant, Importance.usual, Importance.important]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {

        importanceLabel.text = "Важность"
        importanceLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(importanceLabel)
        

        importanceControl.translatesAutoresizingMaskIntoConstraints = false
        importanceControl.selectedSegmentIndex = 1
        addSubview(importanceControl)
        
        

        NSLayoutConstraint.activate([
            importanceLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            importanceLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            importanceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            importanceControl.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            importanceControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            importanceControl.leadingAnchor.constraint(equalTo: importanceLabel.trailingAnchor, constant: 16),
            importanceControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])
    }
}

import UIKit

final class ScheduleTableViewCell: UITableViewCell {
    static let reuseIdentifier = "ScheduleTableViewCellReuseIdentifier"
    private lazy var nameLabel = UILabel()
    lazy var toggle = UISwitch()
    private lazy var stackView = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(nameLabel: String) {
        self.nameLabel.text = nameLabel
    }
}

//MARK: Configure UI
private extension ScheduleTableViewCell {
    func configureUI() {
        configureNameLabelAndToggle()
        self.backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
    }
    
    func configureNameLabelAndToggle() {
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.onTintColor = UIColor(red: 55/255, green: 114/255, blue: 231/255, alpha: 1)
        
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        nameLabel.textColor = .black
        
        stackView = UIStackView(arrangedSubviews: [nameLabel, toggle])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
}

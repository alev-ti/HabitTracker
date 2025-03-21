import UIKit

final class ScheduleTableViewCell: UITableViewCell {
    let theme = Theme()
    static let reuseIdentifier = "ScheduleTableViewCellReuseIdentifier"
    private lazy var nameLabel = UILabel()
    private lazy var toggle = UISwitch()
    private lazy var stackView = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    func configureCell(nameLabel: String) {
        self.nameLabel.text = nameLabel
    }
    
    func toggleOn() {
        toggle.isOn = true
    }
    
    func configureToggle(target: Any?, action: Selector, tag: Int) {
        toggle.addTarget(target, action: action, for: .valueChanged)
        toggle.tag = tag
    }
    
    func isToggleOn() -> Bool {
        toggle.isOn
    }
}


private extension ScheduleTableViewCell {
    func configureUI() {
        configureNameLabelAndToggle()
        self.backgroundColor = theme.tableCellColor
    }
    
    func configureNameLabelAndToggle() {
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.onTintColor = Color.blue
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        nameLabel.textColor = theme.textColor
        
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

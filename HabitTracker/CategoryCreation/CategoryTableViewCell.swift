import UIKit

final class CategoryTableViewCell: UITableViewCell {
    static let reuseIdentifier = String(describing: CategoryTableViewCell.self)
    
    private let nameLabel = UILabel()
    private let checkMarkImage = UIImageView()
    private let stackView = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    func configureCell(with cell: CategoryCellModel) {
        nameLabel.text = cell.title
        checkMarkImage.image = cell.isSelected == true ? UIImage(systemName: "checkmark") : nil
    }
    
    func didTapCell(_ isSelected: Bool) {
        checkMarkImage.image = isSelected ? UIImage(systemName: "checkmark") : nil
    }
}

private extension CategoryTableViewCell {
    func setupUI() {
        backgroundColor = Color.lightGray
        configureStackView()
    }
    
    func configureStackView() {
        nameLabel.textColor = .black
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        checkMarkImage.contentMode = .scaleAspectFit
        checkMarkImage.tintColor = Color.blue
        
        let spacer = UIView()
        
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(spacer)
        stackView.addArrangedSubview(checkMarkImage)
        
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            spacer.widthAnchor.constraint(greaterThanOrEqualToConstant: 10)
        ])
    }
}

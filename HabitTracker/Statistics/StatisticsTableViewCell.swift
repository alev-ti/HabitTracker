import UIKit

final class StatisticsTableViewCell: UITableViewCell {
    static let reuseIdentifier = "StatisticsTableViewCell"

    private lazy var containerView = GradientBorderView()
    private lazy var countLabel: UILabel = createLabel(fontSize: 34, weight: .bold)
    private lazy var infoLabel: UILabel = createLabel(fontSize: 12, weight: .regular)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }

    func configure(with count: String, info: String) {
        countLabel.text = count
        infoLabel.text = info
    }
}

// MARK: - UI Setup

private extension StatisticsTableViewCell {
    func setupUI() {
        backgroundColor = .white
        setupContainerView()
        setupLabels()
    }

    func setupContainerView() {
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 16
        containerView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            containerView.heightAnchor.constraint(equalToConstant: 90)
        ])
    }

    func setupLabels() {
        containerView.addSubview(countLabel)
        containerView.addSubview(infoLabel)

        NSLayoutConstraint.activate([
            countLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            countLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            countLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),

            infoLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            infoLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            infoLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
        ])
    }

    func createLabel(fontSize: CGFloat, weight: UIFont.Weight) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        label.textColor = Color.lightBlack
        return label
    }
}

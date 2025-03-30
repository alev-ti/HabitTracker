import UIKit

protocol TrackerCellDelegate: AnyObject {
    func cellButtonDidTapped(_ cell: TrackerCell)
}

final class TrackerCell: UICollectionViewCell {
    
    static let identifier: String = "TrackerCell"
    
    weak var delegate: TrackerCellDelegate?
    
    private let theme = Theme()
    
    private lazy var cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emojiBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var completionButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 16
        button.backgroundColor = .white
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var daysCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = theme.textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var pinSquare: UIImageView = {
        let pinSquare = UIImageView()
        pinSquare.contentMode = .center
        pinSquare.image = UIImage(named: "pin")
        pinSquare.translatesAutoresizingMaskIntoConstraints = false
        return pinSquare
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    private func setupUI() {
        self.layer.cornerRadius = 16
        contentView.addSubview(cardView)
        contentView.addSubview(completionButton)
        contentView.addSubview(daysCountLabel)
        cardView.addSubview(emojiBackgroundView)
        emojiBackgroundView.addSubview(emojiLabel)
        cardView.addSubview(nameLabel)
        contentView.addSubview(pinSquare)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 98),
            
            // Настройка круглого фона для эмоджи
            emojiBackgroundView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 32),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 32),

            // Центрируем эмоджи внутри фона
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),

            nameLabel.topAnchor.constraint(equalTo: emojiBackgroundView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            
            completionButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            completionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            completionButton.widthAnchor.constraint(equalToConstant: 34),
            completionButton.heightAnchor.constraint(equalToConstant: 34),
            
            daysCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysCountLabel.centerYAnchor.constraint(equalTo: completionButton.centerYAnchor),
            
            pinSquare.heightAnchor.constraint(equalToConstant: 24),
            pinSquare.widthAnchor.constraint(equalToConstant: 24),
            pinSquare.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            pinSquare.centerYAnchor.constraint(equalTo: emojiLabel.centerYAnchor)
        ])
        
        // Делаем фон круглым после установки констрейнтов
        emojiBackgroundView.layer.cornerRadius = 16
        emojiBackgroundView.clipsToBounds = true

        completionButton.addTarget(self, action: #selector(completionButtonTapped), for: .touchUpInside)
    }
    
    func configure(name: String, emoji: String, color: UIColor, delegate: TrackerCellDelegate, isPinned: Bool) {
        self.nameLabel.text = name
        self.emojiLabel.text = emoji
        self.cardView.backgroundColor = color
        self.emojiBackgroundView.backgroundColor = .white.withAlphaComponent(0.3)
        self.completionButton.backgroundColor = color
        self.delegate = delegate
        self.pinSquare.image = isPinned ? UIImage(named: "pin") : nil
    }
    
    func changeCompletionStatus(days: Int, isCompleted: Bool, trackerType: TrackerType) {
        switch trackerType {
            
        case .habit:
            let daysString = String.localizedStringWithFormat(
                NSLocalizedString("days_count", comment: "quantity of days"),
                days)
            
            if isCompleted {
                daysCountLabel.text = daysString
                completionButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
                completionButton.backgroundColor = completionButton.backgroundColor?.withAlphaComponent(0.3)
            } else {
                daysCountLabel.text = daysString
                completionButton.setImage(UIImage(systemName: "plus"), for: .normal)
                completionButton.backgroundColor = completionButton.backgroundColor?.withAlphaComponent(1)
            }
            case .irregularEvent:
            if isCompleted || days > 0 {
                daysCountLabel.text = NSLocalizedString("tracker_cell.completed", comment: "completed event")
                completionButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
                completionButton.backgroundColor = completionButton.backgroundColor?.withAlphaComponent(0.3)
            } else {
                daysCountLabel.text = NSLocalizedString("tracker_cell.not_completed", comment: "not completed event")
                completionButton.setImage(UIImage(systemName: "plus"), for: .normal)
                completionButton.backgroundColor = completionButton.backgroundColor?.withAlphaComponent(1)
            }
        }
    }
    
    @objc func completionButtonTapped() {
        delegate?.cellButtonDidTapped(self)
    }
}

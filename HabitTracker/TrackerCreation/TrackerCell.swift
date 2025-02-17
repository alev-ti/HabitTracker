import UIKit

final class TrackerCell: UICollectionViewCell {
    
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
        label.textColor = .black
        label.text = "0 дней"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var completionHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(cardView)
        contentView.addSubview(completionButton)
        contentView.addSubview(daysCountLabel)
        
        cardView.addSubview(emojiBackgroundView)
        emojiBackgroundView.addSubview(emojiLabel)
        cardView.addSubview(nameLabel)
        
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
            daysCountLabel.centerYAnchor.constraint(equalTo: completionButton.centerYAnchor)
        ])
        
        // Делаем фон круглым после установки констрейнтов
        emojiBackgroundView.layer.cornerRadius = 16
        emojiBackgroundView.clipsToBounds = true

        completionButton.addTarget(self, action: #selector(completionButtonTapped), for: .touchUpInside)
    }

    
    func configure(with tracker: Tracker, isCompleted: Bool, daysCount: Int, completionHandler: @escaping () -> Void) {
        emojiLabel.text = tracker.emoji
        nameLabel.text = tracker.name
        cardView.backgroundColor = tracker.color
        self.completionHandler = completionHandler
        
        let image = isCompleted ? UIImage(systemName: "checkmark") : UIImage(systemName: "plus")
        completionButton.setImage(image, for: .normal)
        completionButton.backgroundColor = isCompleted ? tracker.color.withAlphaComponent(0.4) : tracker.color
        
        let isIrregularEvent = tracker.schedule.isEmpty
        if isIrregularEvent {
            daysCountLabel.text = isCompleted ? "Выполнено" : "Не выполнено"
        } else {
            daysCountLabel.text = "\(daysCount) \(dayString(for: daysCount))"
        }
    }
    
    private func dayString(for count: Int) -> String {
        let remainder = count % 10
        switch remainder {
        case 1:
            return "день"
        case 2...4:
            return "дня"
        default:
            return "дней"
        }
    }
    
    @objc private func completionButtonTapped() {
        completionHandler?()
    }
}

import UIKit

final class EmojiCell: UICollectionViewCell {
    static let identifier: String = "emojiCell"
    
    private lazy var emojiLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    override func prepareForReuse() {}
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(emoji: String) {
        self.emojiLabel.text = emoji
        
    }
    
    func selectCell(select: Bool) {
        self.backgroundColor = select ? Color.lightGray : .clear
    }
}


private extension EmojiCell {
    func setupUI() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 16
        configureEmoji()
    }
    
    func configureEmoji() {
        contentView.addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
        ])
    }
}

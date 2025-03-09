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
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    func configureCell(emoji: String) {
        emojiLabel.text = emoji
        
    }
    
    func selectCell(select: Bool) {
        backgroundColor = select ? Color.lightGray : .clear
    }
}


private extension EmojiCell {
    func setupUI() {
        layer.masksToBounds = true
        layer.cornerRadius = 16
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

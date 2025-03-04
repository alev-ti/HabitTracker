import UIKit

final class ColorCell: UICollectionViewCell {
    static let identifier: String = "colorCell"
    
    private lazy var colorView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    override func prepareForReuse() {}
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(_ color: UIColor) {
        colorView.backgroundColor = color
        
    }
    
    func selectCell(select: Bool) {
        layer.borderColor = select ? colorView.backgroundColor?.withAlphaComponent(0.5).cgColor : UIColor.clear.cgColor
        layer.borderWidth = select ? 3 : 0
    }
}


private extension ColorCell {
    func setupUI() {
        layer.masksToBounds = true
        layer.cornerRadius = 8
        configureColorView()
    }
    
    func configureColorView() {
        colorView.translatesAutoresizingMaskIntoConstraints = false
        colorView.layer.masksToBounds = true
        colorView.layer.cornerRadius = 8
        contentView.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6)
        ])
    }
}


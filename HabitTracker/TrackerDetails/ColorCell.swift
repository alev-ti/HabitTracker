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
        self.colorView.backgroundColor = color
        
    }
    
    func selectCell(select: Bool) {
        self.layer.borderColor = select ? self.colorView.backgroundColor?.withAlphaComponent(0.5).cgColor : UIColor.clear.cgColor
        self.layer.borderWidth = select ? 3 : 0
    }
}


private extension ColorCell {
    func setupUI() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 8
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


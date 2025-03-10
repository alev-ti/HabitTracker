import UIKit

final class OnboardingScreenViewController: UIViewController {
    
    private let textLabel = UILabel()
    private let continueButton = UIButton(type: .custom)
    private let backgroundImage = UIImageView()
    
    private weak var delegate: OnboardingScreenDelegate?
    private let image: UIImage
    private let text: String
    
    init(image: UIImage, text: String, delegate: OnboardingScreenDelegate) {
        self.image = image
        self.text = text
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        configureBackgroundImage()
        configureTextLabel()
        configureContinueButton()
        setupConstraints()
    }
    
    private func configureBackgroundImage() {
        backgroundImage.image = image
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.frame = view.bounds
        view.addSubview(backgroundImage)
    }
    
    private func configureTextLabel() {
        textLabel.text = text
        textLabel.font = .boldSystemFont(ofSize: 32)
        textLabel.textColor = .black
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textLabel)
    }
    
    private func configureContinueButton() {
        continueButton.setTitle("Вот это технологии!", for: .normal)
        continueButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.backgroundColor = Color.lightBlack
        continueButton.layer.cornerRadius = 16
        continueButton.clipsToBounds = true
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        view.addSubview(continueButton)
    }
    
    private func setupConstraints() {
        let screenHeight = UIScreen.main.bounds.height
        
        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: screenHeight / 1.9),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func continueButtonTapped() {
        delegate?.hideOnboarding()
    }
}

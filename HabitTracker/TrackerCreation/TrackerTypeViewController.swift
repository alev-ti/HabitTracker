import UIKit

// Экран выбора типа трекера
final class TrackerTypeViewController: UIViewController {
    
    enum TrackerType {
        case habit
        case irregularEvent
    }
    
    var onTrackerTypeSelected: ((TrackerType) -> Void)?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Создание трекера"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let habitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Привычка", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let irregularEventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Нерегулярное событие", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        view.addSubview(habitButton)
        view.addSubview(irregularEventButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            habitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            habitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20), // Отступ слева
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20), // Отступ справа
            habitButton.heightAnchor.constraint(equalToConstant: 50), // Высота кнопки
            
            irregularEventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16), // Расстояние между кнопками
            irregularEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20), // Отступ слева
            irregularEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20), // Отступ справа
            irregularEventButton.heightAnchor.constraint(equalToConstant: 50) // Высота кнопки
        ])
        
        habitButton.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        irregularEventButton.addTarget(self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
    }
    
    @objc private func habitButtonTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onTrackerTypeSelected?(.habit)
        }
    }
    
    @objc private func irregularEventButtonTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onTrackerTypeSelected?(.irregularEvent)
        }
    }
}

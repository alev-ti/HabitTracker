import UIKit

// Моки данных
let mockCategories: [TrackerCategory] = [
    TrackerCategory(
        title: "Домашний уют",
        trackers: [
            Tracker(id: UUID(), name: "Поливать растения", color: .systemGreen, emoji: "🌱", schedule: [.Monday, .Wednesday, .Friday])
        ]
    ),
    TrackerCategory(
        title: "Радостные мелочи",
        trackers: [
            Tracker(id: UUID(), name: "Кошка заслонила камеру на созвоне", color: .systemYellow, emoji: "🐱", schedule: [.Tuesday, .Thursday]),
            Tracker(id: UUID(), name: "Бабушка прислала открытку в вотсап", color: .systemOrange, emoji: "💌", schedule: [.Saturday, .Sunday])
        ]
    )
]

// Главный экран
final class TrackersViewController: UIViewController {
    
    private let stubImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "stub_no_trackers"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let stubLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "Трекеры"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 34)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    private let searchBar: UISearchBar = {
       let searchBar = UISearchBar()
       searchBar.placeholder = "Поиск"
       searchBar.backgroundImage = UIImage()
       searchBar.translatesAutoresizingMaskIntoConstraints = false
       return searchBar
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private var categories: [TrackerCategory] = mockCategories
    private var completedTrackers: Set<UUID> = [] // Храним ID выполненных трекеров
    private var currentDate: Date = Date() // Текущая дата
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDatePicker()
        updateStubVisibility()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Кнопка "+" слева
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
            style: .plain,
            target: self,
            action: #selector(addTracker)
        )
        navigationItem.leftBarButtonItem?.tintColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1)
        
        // DatePicker справа
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        // Добавляем элементы на экран
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(stubImageView)
        view.addSubview(stubLabel)
        
        // Констрейнты
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            stubImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            stubImageView.widthAnchor.constraint(equalToConstant: 100),
            stubImageView.heightAnchor.constraint(equalToConstant: 100),
            
            stubLabel.topAnchor.constraint(equalTo: stubImageView.bottomAnchor, constant: 10),
            stubLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // Регистрация заголовка секции
        collectionView.register(
            TrackerHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "Header"
        )
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setupDatePicker() {
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
    }
    
    @objc private func datePickerValueChanged() {
        currentDate = datePicker.date
        collectionView.reloadData()
    }
    
    private func updateStubVisibility() {
        let isEmpty = categories.isEmpty
        stubImageView.isHidden = !isEmpty
        stubLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }
    
    @objc private func addTracker() {
        let trackerTypeVC = TrackerTypeViewController()
        trackerTypeVC.modalPresentationStyle = .pageSheet
        trackerTypeVC.onTrackerTypeSelected = { [weak self] trackerType in
            if trackerType == .habit {
                self?.showHabitCreationScreen()
            } else {
                // Реализация для нерегулярного события
            }
        }
        present(trackerTypeVC, animated: true)
    }
    
    private func showHabitCreationScreen() {
        let habitVC = HabitCreationViewController()
        habitVC.modalPresentationStyle = .pageSheet
        habitVC.onCancel = { [weak self] in
            self?.dismiss(animated: true)
        }
        habitVC.onCreate = { [weak self] tracker in
            let newCategory = TrackerCategory(title: "Привычки", trackers: [tracker])
            self?.categories.append(newCategory)
            self?.updateStubVisibility()
            self?.dismiss(animated: true)
        }
        present(habitVC, animated: true)
    }
    
    // Логика отметки трекера как выполненного
    private func toggleTrackerCompletion(for trackerId: UUID) {
        if completedTrackers.contains(trackerId) {
            completedTrackers.remove(trackerId)
        } else {
            completedTrackers.insert(trackerId)
        }
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as! TrackerCell
        let tracker = categories[indexPath.section].trackers[indexPath.row]
        let isCompleted = completedTrackers.contains(tracker.id)
        cell.configure(with: tracker, isCompleted: isCompleted, daysCount: 5, completionHandler: { [weak self] in
            self?.toggleTrackerCompletion(for: tracker.id)
        })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 10) / 2
        return CGSize(width: width, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! TrackerHeaderView
        header.titleLabel.text = categories[indexPath.section].title
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 40)
    }
}

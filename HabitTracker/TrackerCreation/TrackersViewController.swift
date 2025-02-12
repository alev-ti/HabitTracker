import UIKit

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
    
    // Список категорий и вложенных в них трекеров
    private var categories: [TrackerCategory] = mockCategories
    // Трекеры, которые были «выполнены» в выбранную дату
    private var completedTrackers: [UUID: Set<Date>] = [:]
    // Текущая дата
    private var currentDate: Date = Date()
    
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
        
        // Регистрация заголовка категории
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
        let isEmpty = getVisibleCategories().isEmpty
        stubImageView.isHidden = !isEmpty
        stubLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }
    
    // Подсчет количества выполнений
    private func completedDays(for trackerId: UUID) -> Int {
        return completedTrackers[trackerId]?.count ?? 0
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
    
    // Отметка трекера как выполненного
    private func toggleTrackerCompletion(for trackerId: UUID) {
        let today = Calendar.current.startOfDay(for: currentDate)
        // нельзя отметить карточку для будущей даты
        guard today <= Calendar.current.startOfDay(for: Date()) else { return }
        
        if completedTrackers[trackerId]?.contains(today) == true {
            completedTrackers[trackerId]?.remove(today)
            if completedTrackers[trackerId]?.isEmpty == true {
                completedTrackers.removeValue(forKey: trackerId)
            }
        } else {
            if completedTrackers[trackerId] == nil {
                completedTrackers[trackerId] = []
            }
            completedTrackers[trackerId]?.insert(today)
        }
        collectionView.reloadData()
    }
    
    private func getVisibleCategories() -> [TrackerCategory] {
        let calendar = Calendar.current
        var weekdayIndex = calendar.component(.weekday, from: currentDate) - 1

        // Сдвиг воскресенья в конец недели
        if weekdayIndex == 0 {
            weekdayIndex = 6
        } else {
            weekdayIndex -= 1
        }

        let weekDay = WeekDays.allCases[weekdayIndex]

        let filteredCategories = categories.compactMap { category -> TrackerCategory? in
            let filteredTrackers = category.trackers.filter { tracker in
                tracker.schedule.contains(weekDay)
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        return filteredCategories
    }


}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return getVisibleCategories().count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getVisibleCategories()[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as! TrackerCell
        let tracker = getVisibleCategories()[indexPath.section].trackers[indexPath.row]
        
        let isCompletedToday = completedTrackers[tracker.id]?.contains(Calendar.current.startOfDay(for: currentDate)) ?? false
        let daysCount = completedDays(for: tracker.id)
        
        cell.configure(with: tracker, isCompleted: isCompletedToday, daysCount: daysCount, completionHandler: { [weak self] in
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

import UIKit

final class TrackersViewController: UIViewController {
    
    private let theme = Theme()
    
    private lazy var stubView: StubView = {
        let imageView = UIImageView(image: UIImage(named: "stub_no_trackers"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = NSLocalizedString("trackers_view_controller.stub_text", comment: "stub text empty trackers")
        label.textColor = theme.textColor
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return StubView(imageView: imageView, label: label)
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("trackers_view_controller.title_trackers", comment: "title Trackers")
        titleLabel.font = UIFont.boldSystemFont(ofSize: 34)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    private lazy var searchBar: UISearchBar = {
       let searchBar = UISearchBar()
       searchBar.placeholder = NSLocalizedString("trackers_view_controller.search_input_placeholder", comment: "search placeholder")
       searchBar.backgroundImage = UIImage()
       searchBar.translatesAutoresizingMaskIntoConstraints = false
       return searchBar
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.backgroundColor = theme.backgroundColor
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -2)
        return collectionView
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let statisticsService: StatisticsProviding = StatisticsProvider()
    private var categories: [TrackerCategory] = [] {
        didSet {
            statisticsService.store(allTrackerCategories: categories, allTrackerRecords: completedTrackers)
        }
    }

    private var completedTrackers: [TrackerRecord] = [] {
        didSet {
            statisticsService.store(allTrackerCategories: categories, allTrackerRecords: completedTrackers)
        }
    }
    private var currentDate: Date = Date()
    private var filteredCategories: [TrackerCategory] = []
    private var isSearching = false
    private lazy var dataProvider: DataProviderProtocol = {
        DataProvider(delegate: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let trackerCategories = dataProvider.getAllTrackerCategory()

        self.completedTrackers = dataProvider.getAllRecords()
        
        self.categories = trackerCategories ?? []
        searchBar.delegate = self
        setupUI()
        setupDatePicker()
        updateStubVisibility()
    }
    
    private func setupUI() {
        view.backgroundColor = theme.backgroundColor
        
        // Кнопка "+" слева
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
            style: .plain,
            target: self,
            action: #selector(addTracker)
        )
        navigationItem.leftBarButtonItem?.tintColor = theme.textColor
        
        // DatePicker справа
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        // Добавляем элементы на экран
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(stubView.imageView)
        view.addSubview(stubView.label)
        
        // Констрейнты
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            stubView.imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubView.imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            stubView.imageView.widthAnchor.constraint(equalToConstant: 100),
            stubView.imageView.heightAnchor.constraint(equalToConstant: 100),
            
            stubView.label.topAnchor.constraint(equalTo: stubView.imageView.bottomAnchor, constant: 10),
            stubView.label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
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
        updateStubVisibility()
    }
    
    private func updateStubVisibility() {
        let isEmpty = getVisibleCategories().isEmpty
        stubView.setVisibility(isVisible: isEmpty)
        collectionView.isHidden = isEmpty
    }

    private func completedDays(for trackerId: UUID) -> Int {
        completedTrackers.filter { $0.id == trackerId }.count
    }
    
    @objc private func addTracker() {
        let trackerTypeVC = TrackerTypeViewController()
        trackerTypeVC.modalPresentationStyle = .pageSheet
        trackerTypeVC.onTrackerTypeSelected = { [weak self] trackerType in
            if trackerType == .habit {
                self?.showHabitCreationScreen()
            } else {
                self?.showIrregularEventCreationScreen()
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
        habitVC.onCreate = { [weak self] trackerCategory in
            self?.dismiss(animated: true)
            guard let tracker = trackerCategory.trackers.first else { return }
            self?.dataProvider.addTracker(categoryTitle: trackerCategory.title, tracker: tracker)
            self?.collectionView.reloadData()
            self?.updateStubVisibility()
        }
        present(habitVC, animated: true)
    }
    
    private func showIrregularEventCreationScreen() {
        let irregularEventVC = IrregularEventCreationViewController()
        irregularEventVC.modalPresentationStyle = .pageSheet
        irregularEventVC.onCancel = { [weak self] in
            self?.dismiss(animated: true)
        }
        irregularEventVC.onCreate = { [weak self] trackerCategory in
            self?.dismiss(animated: true)
            trackerCategory.trackers.forEach { tracker in
                self?.dataProvider.addTracker(categoryTitle: trackerCategory.title, tracker: tracker)
            }
            self?.collectionView.reloadData()
            self?.updateStubVisibility()
        }
        present(irregularEventVC, animated: true)
    }
    
    private func toggleTrackerCompletion(for tracker: Tracker) {
        let today = Calendar.current.startOfDay(for: currentDate)
        let now = Calendar.current.startOfDay(for: Date())

        guard today <= now else { return }
        
        let record = TrackerRecord(id: tracker.id, date: today)
        
        if let existingIndex = completedTrackers.firstIndex(where: {
            $0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: today)
        }) {
            completedTrackers.remove(at: existingIndex)
        } else {
            do {
                try dataProvider.addNewRecord(tracker: tracker, trackerRecord: record)
                completedTrackers.append(record)
            } catch {
                print("Failed to add new record: \(error)")
            }
        }
        collectionView.reloadData()
    }

    
    func getVisibleCategories() -> [TrackerCategory] {
        if isSearching {
            return filteredCategories
        }

        let today = Calendar.current.startOfDay(for: currentDate)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "EEEE"
        let weekdayName = dateFormatter.string(from: today)

        guard let weekDay = WeekDay(from: weekdayName) else {
            return categories
        }

        return categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                if tracker.schedule.isEmpty {
                    // Нерегулярные события: показываем только если оно не выполнено ИЛИ выполнено в соответствующую дату
                    return !completedTrackers.contains { $0.id == tracker.id } || completedTrackers.contains(TrackerRecord(id: tracker.id, date: today))
                }
                return tracker.schedule.contains(weekDay)
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
    }
    
    func reloadData() {
        collectionView.reloadData()
    }

}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        getVisibleCategories().count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        getVisibleCategories()[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as! TrackerCell
        let tracker = getVisibleCategories()[indexPath.section].trackers[indexPath.row]
        
        let today = Calendar.current.startOfDay(for: currentDate)
        let isCompletedToday = completedTrackers.contains(TrackerRecord(id: tracker.id, date: today))
        let daysCount = completedDays(for: tracker.id)
        
        cell.configure(with: tracker, isCompleted: isCompletedToday, daysCount: daysCount, completionHandler: { [weak self] in
            self?.toggleTrackerCompletion(for: tracker)
        })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - CollectionViewParam.itemSpacing) / CollectionViewParam.numberOfItemsPerRow
        return CGSize(width: width, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as? TrackerHeaderView
        header?.changeTitleLabel(with: getVisibleCategories()[indexPath.section].title)
        return header ?? UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 40)
    }
}

extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredCategories = []
        } else {
            isSearching = true
            filteredCategories = categories.compactMap { category in
                let filteredTrackers = category.trackers.filter { tracker in
                    tracker.name.lowercased().contains(searchText.lowercased())
                }
                return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
            }
        }
        collectionView.reloadData()
        updateStubVisibility()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        isSearching = false
        filteredCategories = []
        searchBar.resignFirstResponder()
        collectionView.reloadData()
        updateStubVisibility()
    }
}

extension TrackersViewController: DataProviderDelegate {
    func didUpdate() {
        let trackerCategories = dataProvider.getAllTrackerCategory()
        self.categories = trackerCategories ?? []
    }
}

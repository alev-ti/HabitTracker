import UIKit

protocol HabitCreationDelegate: AnyObject {
    func didCreateTracker(_ trackerCategory: TrackerCategory)
}

final class TrackersViewController: UIViewController, TrackerCellDelegate {
    
    private let theme = Theme.shared
    
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
    
    private lazy var stubNoResultsView: StubView = {
        let imageView = UIImageView(image: UIImage(named: "stub_no_results"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = NSLocalizedString("trackers_view_controller.stub_text_no_results", comment: "stub text nothing found")
        label.textColor = theme.textColor
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return StubView(imageView: imageView, label: label)
    }()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        return searchController
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.backgroundColor = theme.backgroundColor
        collectionView.alwaysBounceVertical = true
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(TrackerHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        
        let currentDate = Date()
        let calendar = Calendar.current
        let minDate = calendar.date(byAdding: .year, value: -1, to: currentDate)
        let maxDate = calendar.date(byAdding: .year, value: 1, to: currentDate)
        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var filterButton: UIButton = {
        let filterButton = UIButton()
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.setTitle(NSLocalizedString("trackers_view_controller.button_filters", comment: "button Filters"), for: .normal)
        filterButton.backgroundColor = Color.blue
        filterButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        filterButton.layer.cornerRadius = 16
        filterButton.clipsToBounds = true
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return filterButton
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
    private let filterStateSavingService: FilterStateStorage = UserDefaultsFilterStateStorage()
    private var filteredCategories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = [] {
        didSet {
            filteredCategories = visibleCategories
        }
    }
    private lazy var dataProvider: DataProviderProtocol = {
        DataProvider(delegate: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let trackerCategories = dataProvider.getAllTrackerCategory()
        self.completedTrackers = dataProvider.getAllRecords()
        self.categories = trackerCategories ?? []
        updateVisibleCategories(from: Date())
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.reportEvent(
            name: "open_main_screen",
            params: [
                "event": "open",
                "screen": "Main"
            ]
        )
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.reportEvent(
            name: "close_main_screen",
            params: [
                "event": "close",
                "screen": "Main"
            ]
        )
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
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Добавляем элементы на экран
        view.addSubview(collectionView)
        view.addSubview(filterButton)
        view.addSubview(stubView.imageView)
        view.addSubview(stubView.label)
        view.addSubview(stubNoResultsView.imageView)
        view.addSubview(stubNoResultsView.label)
        
        // Констрейнты
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stubView.imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubView.imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            stubView.imageView.widthAnchor.constraint(equalToConstant: 100),
            stubView.imageView.heightAnchor.constraint(equalToConstant: 100),
            
            stubView.label.topAnchor.constraint(equalTo: stubView.imageView.bottomAnchor, constant: 10),
            stubView.label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stubNoResultsView.imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubNoResultsView.imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            stubNoResultsView.imageView.widthAnchor.constraint(equalToConstant: 100),
            stubNoResultsView.imageView.heightAnchor.constraint(equalToConstant: 100),
            
            stubNoResultsView.label.topAnchor.constraint(equalTo: stubNoResultsView.imageView.bottomAnchor, constant: 10),
            stubNoResultsView.label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        self.currentDate = sender.date
        updateVisibleCategories(from: currentDate)
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
        AnalyticsService.reportEvent(
            name: "click_add_tracker",
            params: [
                "event": "click",
                "screen": "Main",
                "item": "add_track"
            ]
        )
    }
    
    private func showHabitCreationScreen() {
        let habitVC = HabitCreationViewController()
        habitVC.delegate = self
        let navVC = UINavigationController(rootViewController: habitVC)
        navVC.modalPresentationStyle = .pageSheet
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: theme.textColor,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        navVC.navigationBar.titleTextAttributes = textAttributes
        navVC.navigationBar.barTintColor = theme.backgroundColor
        navVC.navigationBar.backgroundColor = theme.backgroundColor
        habitVC.navigationItem.title = NSLocalizedString("habit_creation_view_controller.title", comment: "title New habit")
        
        present(navVC, animated: true)
    }
    
    private func showIrregularEventCreationScreen() {
        let irregularEventVC = IrregularEventCreationViewController()
        irregularEventVC.delegate = self
        let navVC = UINavigationController(rootViewController: irregularEventVC)
        navVC.modalPresentationStyle = .pageSheet
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: theme.textColor,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        navVC.navigationBar.titleTextAttributes = textAttributes
        navVC.navigationBar.barTintColor = theme.backgroundColor
        navVC.navigationBar.backgroundColor = theme.backgroundColor
        irregularEventVC.navigationItem.title = NSLocalizedString("irregular_event_creation_view_controller.title", comment: "title New irregular event")
        
        present(navVC, animated: true)
    }
    
    private func updateVisibleCategories(from date: Date) {
        let filterState = filterStateSavingService.filterValue
        let weekDay = WeekDay(from: getDayOfWeek(from: date))
        var pinnedTrackers: [Tracker] = []
        
        updateFilterButtonVisibility(for: date)
        
        var filteredCategories: [TrackerCategory] = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                
                if tracker.isPinned {
                    pinnedTrackers.append(tracker)
                    return false
                }
                
                let isScheduledToday = tracker.schedule.contains { $0 == weekDay }
                let isOneTimeTracker = tracker.schedule.isEmpty
                let currentDayStart = Calendar.current.startOfDay(for: currentDate)
                
                let isCompletedToday: Bool = {
                    guard let completion = completedTrackers.first(where: { $0.id == tracker.id }) else {
                        return false
                    }
                    return Calendar.current.startOfDay(for: completion.date) == currentDayStart
                }()
                
                switch filterState {
                    case 2:
                        return (isScheduledToday || isOneTimeTracker) && isCompletedToday
                        
                    case 3:
                        if isScheduledToday {
                            return !isCompletedToday
                        } else if isOneTimeTracker {
                            return !completedTrackers.contains(where: { $0.id == tracker.id })
                        }
                        return false
                        
                    default:
                        if isScheduledToday {
                            return true
                        } else if isOneTimeTracker {
                            if let completionDate = completedTrackers.first(where: { $0.id == tracker.id })?.date {
                                return Calendar.current.startOfDay(for: completionDate) == currentDayStart
                            }
                            return true
                        }
                        return false
                }
            }
            
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        
        if !pinnedTrackers.isEmpty {
            let pinnedCategory = TrackerCategory(title: "Закреплённые", trackers: pinnedTrackers)
            filteredCategories.insert(pinnedCategory, at: 0)
        }
        
        visibleCategories = filteredCategories
        updateStubVisibility()
        collectionView.reloadData()
    }
    
    private func updateStubVisibility() {
        let noTrackersInDB = dataProvider.getAllTrackers().isEmpty
        if noTrackersInDB {
            stubView.setVisibility(isVisible: true)
            stubNoResultsView.setVisibility(isVisible: false)
        } else {
            let noSearchResults = visibleCategories.isEmpty
            stubView.setVisibility(isVisible: false)
            stubNoResultsView.setVisibility(isVisible: noSearchResults)
        }
    }
    
    private func filtersDidUpdate(value: Int) {
        if value == 1 {
            currentDate = Date()
            datePicker.date = currentDate
        }
        updateVisibleCategories(from: currentDate)
    }
    
    @objc private func filterButtonTapped() {
        let filterViewController = FilterViewController { [weak self] value in
            self?.filtersDidUpdate(value: value)
        }
        let navigationController = UINavigationController(rootViewController: filterViewController)
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: theme.textColor,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        navigationController.navigationBar.titleTextAttributes = textAttributes
        present(navigationController, animated: true)
        AnalyticsService.reportEvent(
            name: "click_filter_btn",
            params: [
                "event": "click",
                "screen": "Main",
                "item": "filter"
            ]
        )
    }
    
    private func updateFilterButtonVisibility(for currentDate: Date) {
        let currentFilterState = filterStateSavingService.filterValue
        filterButton.backgroundColor = (1...3).contains(currentFilterState) ? .systemRed : Color.blue
        
        guard let weekDay = WeekDay(from: getDayOfWeek(from: currentDate)) else {
            filterButton.isHidden = true
            return
        }
        
        let startOfDay = Calendar.current.startOfDay(for: currentDate)
        
        let trackers = categories.flatMap { $0.trackers }.filter { tracker in
            tracker.schedule.contains(weekDay) ||
            (tracker.schedule.isEmpty && (
                completedTrackers.contains { $0.id == tracker.id && Calendar.current.startOfDay(for: $0.date) == startOfDay } ||
                !completedTrackers.contains { $0.id == tracker.id }
            ))
        }
        
        filterButton.isHidden = trackers.isEmpty
    }
    
    private func getDayOfWeek(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_En")
        dateFormatter.dateFormat = "EEEE"
        
        let dayOfWeek = dateFormatter.string(from: date)
        return dayOfWeek
    }
    
    func cellButtonDidTapped(_ cell: TrackerCell) {
        completedTrackers = dataProvider.getAllRecords()
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        let isIrregularEvent = filteredCategories[indexPath.section].trackers[indexPath.row].schedule.isEmpty
        if isIrregularEvent, getTrackerCompletionsQuantity(for: filteredCategories[indexPath.section].trackers[indexPath.row].id) > 0 {
            removeCompletedTracker(cell)
            updateVisibleCategories(from: currentDate)
            return
        }
        
        if !checkCompletionCurrentTrackerToday(id: filteredCategories[indexPath.section].trackers[indexPath.row].id) {
            completeTracker(cell)
        } else {
            removeCompletedTracker(cell)
        }
        updateVisibleCategories(from: currentDate)
    }
    
    private func completeTracker(_ cell: TrackerCell) {
        let currentDateIsNotFuture = Calendar.current.compare(Date(), to: currentDate, toGranularity: .day) != .orderedAscending
        guard let indexPath = collectionView.indexPath(for: cell),
              currentDateIsNotFuture else { return }
        
        AnalyticsService.reportEvent(
            name: "click_complete_tracker",
            params: [
                "event": "click",
                "screen": "Main",
                "item": "track"
            ]
        )
        
        let currentTracker = filteredCategories[indexPath.section].trackers[indexPath.row]
        let currentTrackerID = filteredCategories[indexPath.section].trackers[indexPath.row].id
        
        do {
            try dataProvider.addNewRecord(tracker: currentTracker, trackerRecord: TrackerRecord(id: currentTrackerID, date: currentDate))
            completedTrackers = dataProvider.getAllRecords()
            
            let completionsCount = getTrackerCompletionsQuantity(for: filteredCategories[indexPath.section].trackers[indexPath.row].id)
            let trackerCompletedToday = checkCompletionCurrentTrackerToday(id: filteredCategories[indexPath.section].trackers[indexPath.row].id)
            let trackerType = filteredCategories[indexPath.section].trackers[indexPath.row].schedule.isEmpty ? TrackerType.irregularEvent : TrackerType.habit
            
            cell.changeCompletionStatus(days: completionsCount, isCompleted: trackerCompletedToday, trackerType: trackerType)
        }
        catch {
            print("[completeTracker]: Не удалось сохранить TrackerRecord")
        }
    }
    
    
    private func removeCompletedTracker(_ cell: TrackerCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]
        let trackerId = filteredCategories[indexPath.section].trackers[indexPath.row].id
        
        do {
            try dataProvider.removeRecord(tracker: tracker, trackerRecord: TrackerRecord(id: trackerId, date: currentDate))
            completedTrackers = dataProvider.getAllRecords()
            
            let completionsCount = getTrackerCompletionsQuantity(for: trackerId)
            let trackerCompletedToday = checkCompletionCurrentTrackerToday(id: trackerId)
            let trackerType = filteredCategories[indexPath.section].trackers[indexPath.row].schedule.isEmpty ? TrackerType.irregularEvent : TrackerType.habit
            
            cell.changeCompletionStatus(days: completionsCount, isCompleted: trackerCompletedToday, trackerType: trackerType)
        }
        catch {
            print("[removeCompletedTracker]: Не удалось удалить TrackerRecord")
        }
    }
    
    private func getTrackerCompletionsQuantity(for trackerId: UUID) -> Int {
        completedTrackers.filter { $0.id == trackerId }.count
    }
    
    private func checkCompletionCurrentTrackerToday(id: UUID) -> Bool {
        completedTrackers.contains {
            $0.id == id && Calendar.current.isDate(currentDate, inSameDayAs: $0.date)
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell
        cell?.prepareForReuse()
        
        let name = filteredCategories[indexPath.section].trackers[indexPath.row].name
        let emoji = filteredCategories[indexPath.section].trackers[indexPath.row].emoji
        let color = filteredCategories[indexPath.section].trackers[indexPath.row].color
        let isPinned = filteredCategories[indexPath.section].trackers[indexPath.row].isPinned
        cell?.configure(name: name, emoji: emoji, color: color, delegate: self, isPinned: isPinned)
        
        if checkCompletionCurrentTrackerToday(id: filteredCategories[indexPath.section].trackers[indexPath.row].id) {
            let completionsCount = getTrackerCompletionsQuantity(for: filteredCategories[indexPath.section].trackers[indexPath.row].id)
            let isTrackerCompletedToday = checkCompletionCurrentTrackerToday(id: filteredCategories[indexPath.section].trackers[indexPath.row].id)
            let trackerType = filteredCategories[indexPath.section].trackers[indexPath.row].schedule.isEmpty ? TrackerType.irregularEvent : TrackerType.habit
            
            cell?.changeCompletionStatus(days: completionsCount, isCompleted: isTrackerCompletedToday, trackerType: trackerType)
        } else {
            let completionsCount = getTrackerCompletionsQuantity(for: filteredCategories[indexPath.section].trackers[indexPath.row].id)
            let isTrackerCompletedToday = checkCompletionCurrentTrackerToday(id: filteredCategories[indexPath.section].trackers[indexPath.row].id)
            let trackerType = filteredCategories[indexPath.section].trackers[indexPath.row].schedule.isEmpty ? TrackerType.irregularEvent : TrackerType.habit
            
            cell?.changeCompletionStatus(days: completionsCount, isCompleted: isTrackerCompletedToday, trackerType: trackerType)
        }
        
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - CollectionViewParam.itemSpacing) / CollectionViewParam.numberOfItemsPerRow
        return CGSize(width: width, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPaths.count > 0 else { return nil }
        
        let indexPath = indexPaths[0]
        let isPinned = filteredCategories[indexPath.section].trackers[indexPath.row].isPinned
        
        let pinButtonText = NSLocalizedString("trackers_view_controller.tracker_menu_pin", comment: "pin tracker")
        let unpinButtonText = NSLocalizedString("trackers_view_controller.tracker_menu_unpin", comment: "unpin tracker")
        let editButtonText = NSLocalizedString("trackers_view_controller.tracker_menu_edit", comment: "edit tracker")
        let deleteButtonText = NSLocalizedString("trackers_view_controller.tracker_menu_delete", comment: "delete tracker")
        
        return UIContextMenuConfiguration(actionProvider:  { action in
            return UIMenu(children: [
                
                UIAction(title: isPinned ? unpinButtonText : pinButtonText) { [weak self] _ in
                    guard let self = self else { return }
                    let id = self.filteredCategories[indexPath.section].trackers[indexPath.row].id
                    
                    self.dataProvider.pinnedTracker(id: id)
                    self.categories = self.dataProvider.getAllTrackerCategory() ?? []
                    updateVisibleCategories(from: currentDate)
                },
                
                UIAction(title: editButtonText) { [weak self] _ in
                    guard let self = self else { return }
                    
                    let currentTracker = filteredCategories[indexPath.section].trackers[indexPath.row]
                    let currentTrackerArray: [Tracker] = [currentTracker]
                    let isHabitEditing = !currentTracker.schedule.isEmpty
                    guard let categoryTitle = dataProvider.getCategoryTitleForTrackerId(id: currentTracker.id) else { return }
                    
                    let currentTrackerCategory = TrackerCategory(title: categoryTitle, trackers: currentTrackerArray)
                    let vc = isHabitEditing ?
                    EditHabitViewController(delegate: self, trackerCategory: currentTrackerCategory, daysCompleted: getTrackerCompletionsQuantity(for: currentTracker.id)) : EditIrregularEventViewController(delegate: self, trackerCategory: currentTrackerCategory, isTrackerCompletedToday: checkCompletionCurrentTrackerToday(id: currentTracker.id))
                    let navigationController = UINavigationController(rootViewController: vc)
                    present(navigationController, animated: true)
                    
                    AnalyticsService.reportEvent(
                        name: "click_edit_tracker_btn",
                        params: [
                            "event": "click",
                            "screen": "Main",
                            "item": "edit"
                        ]
                    )
                },
                
                UIAction(title: deleteButtonText, attributes: .destructive) { [weak self] _ in
                    guard let self = self else { return }
                    let alert = UIAlertController(title: nil, message: "Уверены что хотите удалить трекер?", preferredStyle: .actionSheet)
                    let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { action in
                        let currentTrackerId = self.filteredCategories[indexPath.section].trackers[indexPath.row].id
                        self.dataProvider.removeTracker(id: currentTrackerId)
                    }
                    let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                    alert.addAction(deleteAction)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                    AnalyticsService.reportEvent(
                        name: "click_delete_tracker_btn",
                        params: [
                            "event": "click",
                            "screen": "Main",
                            "item": "delete"
                        ]
                    )
                }
            ])
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as? TrackerHeaderView
        header?.changeTitleLabel(with: filteredCategories[indexPath.section].title)
        return header ?? UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 40)
    }
}

extension TrackersViewController: DataProviderDelegate {
    func didUpdate() {
        guard  let categoryIsExists = dataProvider.getAllTrackerCategory() else { return }
        self.completedTrackers = dataProvider.getAllRecords()
        self.categories = categoryIsExists
        updateVisibleCategories(from: currentDate)
    }
}

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            let filteredCategories = visibleCategories.compactMap { category in
                let filteredTrackers = category.trackers.filter { tracker in
                    tracker.name.lowercased().contains(searchText.lowercased())
                }
                return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
            }
            let oldVisibleCategories = self.filteredCategories
            self.filteredCategories = filteredCategories
            stubNoResultsView.setVisibility(isVisible: filteredCategories.count == 0)
            collectionView.performBatchUpdates({
                for (sectionIndex, oldCategory) in oldVisibleCategories.enumerated() {
                    if !filteredCategories.contains(where: {$0.title == oldCategory.title}) {
                        collectionView.deleteSections(IndexSet(integer: sectionIndex))
                    } else {
                        let oldTrackers = oldCategory.trackers
                        let newTrackers = filteredCategories.first(where: {$0.title == oldCategory.title})?.trackers ?? []
                        let trackersToDelete = oldTrackers.enumerated().compactMap{(index, tracker) in
                            return !newTrackers.contains(where: { $0.name == tracker.name }) ? IndexPath(item: index, section: sectionIndex) : nil
                        }
                        
                        if !trackersToDelete.isEmpty {
                            collectionView.deleteItems(at: trackersToDelete)
                        }
                    }
                }
                
                for (sectionIndex, newCategory) in filteredCategories.enumerated() {
                    if !oldVisibleCategories.contains(where: { $0.title == newCategory.title }) {
                        collectionView.insertSections(IndexSet(integer: sectionIndex))
                    } else {
                        let oldTrackers = oldVisibleCategories.first(where: { $0.title == newCategory.title })?.trackers ?? []
                        let newTrackers = newCategory.trackers
                        
                        let trackersToInsert = newTrackers.enumerated().compactMap { (index, tracker) in
                            return !oldTrackers.contains(where: { $0.name == tracker.name }) ? IndexPath(item: index, section: sectionIndex) : nil
                        }
                        
                        if !trackersToInsert.isEmpty {
                            collectionView.insertItems(at: trackersToInsert)
                        }
                    }
                }
            })
        } else {
            updateVisibleCategories(from: currentDate)
        }
    }
}

extension TrackersViewController: HabitCreationDelegate {
    func didCreateTracker(_ trackerCategory: TrackerCategory) {
        print("[didCreateTracker]: TrackersViewController получил трекер", trackerCategory)
        guard let tracker = trackerCategory.trackers.first else { return }
        dataProvider.addTracker(categoryTitle: trackerCategory.title, tracker: tracker)
        collectionView.reloadData()
    }
}

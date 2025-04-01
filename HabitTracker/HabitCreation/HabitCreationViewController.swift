import UIKit

protocol ScheduleSelectionDelegate: AnyObject {
    func didSelectSchedule(days: [WeekDay])
}

// Экран создания привычки
class HabitCreationViewController: UIViewController {
    init() {
        self.tracker = nil
        self.daysCompleted = nil
        super.init(nibName: nil, bundle: nil)
    }
    
    init(delegate: HabitCreationDelegate, trackerCategory: TrackerCategory, daysCompleted: Int) {
        self.delegate = delegate
        self.tracker = trackerCategory
        self.daysCompleted = daysCompleted
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    private let tracker: TrackerCategory?
    private let daysCompleted: Int?
    private lazy var completedDaysLabel = UILabel()
    
    weak var delegate: HabitCreationDelegate?
    
    private let theme = Theme.shared
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("habit_creation_view_controller.tracker_name_input_placeholder", comment: "placeholder Tracker's title")
        textField.backgroundColor = theme.tableCellColor
        textField.layer.cornerRadius = 16
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
        textField.leftViewMode = .always
        return textField
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(
            NSLocalizedString("habit_creation_view_controller.button_cancel", comment: "button cancel"),
            for: .normal
        )
        button.setTitleColor(Color.lightRed, for: .normal)
        button.layer.borderColor = Color.lightRed.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(
            NSLocalizedString("habit_creation_view_controller.button_create", comment: "button create"),
            for: .normal
        )
        button.backgroundColor = Color.gray
        button.setTitleColor(theme.buttonTitleColor, for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var scheduleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let viewModel = CategoryViewModel()
    
    private var tableViewData: [CellData] = [
        CellData(title: NSLocalizedString("habit_creation_view_controller.category", comment: "category title")),
        CellData(title: NSLocalizedString("habit_creation_view_controller.schedule", comment: "schedule title"))
    ]
    
    private lazy var trackerDetailCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.headerReferenceSize = CGSize(width: view.frame.width, height: 20)
        layout.sectionInset = UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)

        let numberOfItemsInRow: CGFloat = 6
        let itemWidth = (view.frame.width - layout.sectionInset.left - layout.sectionInset.right - (numberOfItemsInRow - 1) * 8) / numberOfItemsInRow
        let itemHeight = itemWidth

        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = theme.backgroundColor
        collectionView.alwaysBounceVertical = true
        collectionView.allowsMultipleSelection = true
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
        collectionView.register(TrackerDetailHeaderSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "trackerDetailHeader")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    var selectedDays: [WeekDay] = [] {
        didSet {
            updateScheduleLabel()
            validateForm()
        }
    }
    
    private var selectedEmoji: String?
    private var selectedEmojiIndexPath: IndexPath?
    private var selectedColor: UIColor?
    private var selectedColorIndexPath: IndexPath?
    private var selectedCategoryTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let tracker = tracker,
           tracker.trackers.count > 0 {
            selectedDays = tracker.trackers[0].schedule
            selectedCategoryTitle = tracker.title
            selectedEmoji = tracker.trackers[0].emoji
            selectedColor = tracker.trackers[0].color
            
            nameTextField.text = tracker.trackers[0].name
            tableViewData[0].text = tracker.title
            tableViewData[1].text = getScheduleCellString(daysWeek: tracker.trackers[0].schedule)
        }
        hideKeyboardWhenTapped()
        setupUI()
    }
    
    private func getScheduleCellString(daysWeek: [WeekDay]) -> String {
        let sortedDaysWeek = daysWeek.sorted()
        let selectedDaysString = sortedDaysWeek.map {$0.getShortName()}.joined(separator: ", ")
        return selectedDaysString
    }
    
    private var trackerDetailCollectionViewData: [TrackerDetailCell] = [
        TrackerDetailCell(header: "Emoji", type: .emoji(TrackerDetails.emojis)),
        TrackerDetailCell(header: NSLocalizedString("habit_creation_view_controller.color", comment: "color title"), type: .color(TrackerDetails.colors))
    ]
    
    private func validateForm() {
        let isValid = !nameTextField.text!.isEmpty && !selectedDays.isEmpty && selectedEmoji != nil && selectedColor != nil && selectedCategoryTitle != nil
        createButton.isEnabled = isValid
        createButton.backgroundColor = isValid
            ? Color.lightBlack
            : Color.gray
    }
    
    private func updateScheduleLabel() {
        scheduleLabel.text = selectedDays.isEmpty ? nil : selectedDays.map { $0.getShortName() }.joined(separator: ", ")
        tableView.reloadData()
    }
    
    private func configureCompletedDaysLabel() {
        guard let _ = tracker, let daysCompleted = daysCompleted else { return }
        completedDaysLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(completedDaysLabel)
        let daysString = String.localizedStringWithFormat(
            NSLocalizedString("days_count", comment: "quantity of days"),
            daysCompleted)
        completedDaysLabel.text = daysString
        completedDaysLabel.textAlignment = .center
        completedDaysLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        
        NSLayoutConstraint.activate([
            completedDaysLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 64),
            completedDaysLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            completedDaysLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    private func setupUI() {
        view.backgroundColor = theme.backgroundColor
        
        view.addSubview(nameTextField)
        view.addSubview(tableView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        view.addSubview(categoryLabel)
        view.addSubview(scheduleLabel)
        view.addSubview(trackerDetailCollectionView)
        
        let trackerInitialized = tracker != nil && daysCompleted != nil
        
        configureCompletedDaysLabel()
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: trackerInitialized ? completedDaysLabel.bottomAnchor : view.topAnchor, constant: trackerInitialized ? 40 : 54),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150), // 2 строки по 75
            
            trackerDetailCollectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            trackerDetailCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackerDetailCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trackerDetailCollectionView.bottomAnchor.constraint(equalTo: createButton.topAnchor, constant: -16),
            
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -8),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor)
        ])
        
        // Настройка таблицы
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        trackerDetailCollectionView.dataSource = self
        trackerDetailCollectionView.delegate = self
        
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange() {
        validateForm()
    }
    
    @objc private func cancelButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        self.dismiss(animated: true)
        if let tracker = tracker,
           tracker.trackers.count > 0 {
            let id = tracker.trackers[0].id
            let schedule = selectedDays
            guard let name = nameTextField.text,
                  let color = selectedColor,
                  let emoji = selectedEmoji,
                  let title = selectedCategoryTitle
            else { return }
            
            let trackerCategory = TrackerCategory(title: title, trackers: [Tracker(id: id, name: name, color: color, emoji: emoji, isPinned: tracker.trackers[0].isPinned, schedule: schedule)])
            delegate?.didCreateTracker(trackerCategory)
        } else {
            let id = UUID()
            let schedule = selectedDays
            guard let name = nameTextField.text,
                  let color = selectedColor,
                  let emoji = selectedEmoji,
                  let title = selectedCategoryTitle
            else { return }
            
            let trackerCategory = TrackerCategory(title: title, trackers: [Tracker(id: id, name: name, color: color, emoji: emoji, isPinned: false, schedule: schedule)])
            delegate?.didCreateTracker(trackerCategory)
        }
    }
}


extension HabitCreationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = tableViewData[indexPath.row].title
        cell.accessoryType = .disclosureIndicator // Шеврон вправо
        cell.backgroundColor = theme.tableCellColor
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        cell.textLabel?.text = nil
        let titleLabel = UILabel()
        titleLabel.text = tableViewData[indexPath.row].title
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = theme.textColor
        
        stackView.addArrangedSubview(titleLabel)
        
        if indexPath.row == 0 {
            if selectedCategoryTitle != nil {
                categoryLabel.text = selectedCategoryTitle
                stackView.addArrangedSubview(categoryLabel)
            }
        }
        
        if indexPath.row == 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 1000)
            if !selectedDays.isEmpty {
                scheduleLabel.text = selectedDays.map { $0.getShortName() }.joined(separator: ", ")
                stackView.addArrangedSubview(scheduleLabel)
            }
        }
        
        cell.contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -32),
            stackView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
                let categoriesScreenViewController = CategoryScreenViewController(viewModel: viewModel, selectedCategory: selectedCategoryTitle)
                categoriesScreenViewController.completionHandler = { [weak self] categoryTitle in
                    self?.selectedCategoryTitle = categoryTitle
                    self?.tableViewData[0].text = categoryTitle
                    self?.tableView.reloadData()
                    self?.validateForm()
                }
                let navigationController = UINavigationController(rootViewController: categoriesScreenViewController)
                
                let textAttributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.black,
                    .font: UIFont.systemFont(ofSize: 16, weight: .medium)
                ]
                navigationController.navigationBar.titleTextAttributes = textAttributes
                present(navigationController, animated: true)
        case 1:
                let scheduleScreenViewController = ScheduleCreationViewController(selectedDays: [])
            scheduleScreenViewController.completionHandler = { [weak self] data in
                self?.selectedDays = data
                self?.tableView.reloadData()
                self?.validateForm()
            }
            
            let navigationController = UINavigationController(rootViewController: scheduleScreenViewController)
            
            let textAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 16, weight: .medium)
            ]
            navigationController.navigationBar.titleTextAttributes = textAttributes
            present(navigationController, animated: true)
        default:
            break
        }
    }
}

extension HabitCreationViewController: ScheduleSelectionDelegate {
    func didSelectSchedule(days: [WeekDay]) {
        self.selectedDays = days
    }
}

extension HabitCreationViewController: UICollectionViewDelegate,UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        trackerDetailCollectionViewData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch trackerDetailCollectionViewData[section].type {
        case .emoji(let emojis):
            return emojis.count
        case .color(let colors):
            return colors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch trackerDetailCollectionViewData[indexPath.section].type {
        case .emoji(let emojis):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.identifier, for: indexPath) as? EmojiCell else {
                    return UICollectionViewCell()
                }
            cell.prepareForReuse()
            cell.configureCell(emoji: emojis[indexPath.item])
            if let tracker = tracker,
               tracker.trackers.count > 0,
               emojis[indexPath.row] == tracker.trackers[0].emoji {
                cell.selectCell(select: true)
                self.selectedEmojiIndexPath = indexPath
            }
            return cell
        case .color(let colors):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.identifier, for: indexPath) as? ColorCell else {
                    return UICollectionViewCell()
                }
            cell.prepareForReuse()
            cell.configureCell(colors[indexPath.row])
            if let tracker = tracker,
               tracker.trackers.count > 0,
               colors[indexPath.row] == tracker.trackers[0].color {
                cell.selectCell(select: true)
                self.selectedColorIndexPath = indexPath
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "trackerDetailHeader", for: indexPath) as? TrackerDetailHeaderSupplementaryView
        view?.titleLabel.text = trackerDetailCollectionViewData[indexPath.section].header
        view?.titleLabel.textColor = theme.textColor
        return view ?? UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch trackerDetailCollectionViewData[indexPath.section].type {
        case .emoji(let emoji):
            guard let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell else { return }
            if let selectedEmojiIndexPath,
               let previousCell = collectionView.cellForItem(at: selectedEmojiIndexPath) as? EmojiCell {
                self.selectedEmojiIndexPath = indexPath
                previousCell.selectCell(select: false)
                collectionView.deselectItem(at: selectedEmojiIndexPath, animated: true)
                
                cell.selectCell(select: true)
                self.selectedEmoji = emoji[indexPath.row]
                return
            }
            self.selectedEmojiIndexPath = indexPath
            cell.selectCell(select: true)
            self.selectedEmoji = emoji[indexPath.row]
            
        case .color(let color):
            guard let cell = collectionView.cellForItem(at: indexPath) as? ColorCell else { return }
            if let selectedColorIndexPath,
               let previousCell = collectionView.cellForItem(at: selectedColorIndexPath) as? ColorCell {
                self.selectedColorIndexPath = indexPath
                previousCell.selectCell(select: false)
                collectionView.deselectItem(at: selectedColorIndexPath, animated: true)
                
                cell.selectCell(select: true)
                self.selectedColor = color[indexPath.row]
                return
            }
            self.selectedColorIndexPath = indexPath
            cell.selectCell(select: true)
            self.selectedColor = color[indexPath.row]
        }
        validateForm()
    }
}


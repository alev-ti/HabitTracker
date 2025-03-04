import UIKit

// Экран создания нерегулярного события
final class IrregularEventCreationViewController: UIViewController {
    
    var onCancel: (() -> Void)?
    var onCreate: ((TrackerCategory) -> Void)?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новое нерегулярное событие"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = Color.lightGray
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
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(Color.lightRed, for: .normal)
        button.layer.borderColor = Color.lightRed.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.backgroundColor = Color.gray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let tableData = ["Категория"]
    
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
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.allowsMultipleSelection = true
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
        collectionView.register(TrackerDetailHeaderSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "trackerDetailHeader")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private var selectedEmoji: String?
    private var selectedEmojiIndexPath: IndexPath?
    private var selectedColor: UIColor?
    private var selectedColorIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.hideKeyboardWhenTapped()
    }
    
    private var trackerDetailCollectionViewData: [TrackerDetailCell] = [
        TrackerDetailCell(header: "Emoji", type: .emoji(TrackerDetails.emojis)),
        TrackerDetailCell(header: "Цвет", type: .color(TrackerDetails.colors))
    ]
    
    private func validateForm() {
        let isValid = !nameTextField.text!.isEmpty && selectedEmoji != nil && selectedColor != nil
        createButton.isEnabled = isValid
        createButton.backgroundColor = isValid
            ? Color.lightBlack
            : Color.gray
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        view.addSubview(nameTextField)
        view.addSubview(tableView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        view.addSubview(trackerDetailCollectionView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 75),
            
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
        onCancel?()
    }
    
    @objc private func createButtonTapped() {
        guard let name = nameTextField.text,
              !name.isEmpty,
              let color = selectedColor,
              let emoji = selectedEmoji
        else { return }
        let tracker = Tracker(id: UUID(), name: name, color: color, emoji: emoji, schedule: [])
        let today = Calendar.current.startOfDay(for: Date())
        let record = TrackerRecord(id: tracker.id, date: today)

        
        if let trackersVC = presentingViewController as? TrackersViewController {
            if let index = trackersVC.categories.firstIndex(where: { $0.title == "Категория нерегулярных событий" }) {
                let updatedCategory = trackersVC.categories[index]
                let updatedTrackers = updatedCategory.trackers + [tracker]
                trackersVC.categories[index] = TrackerCategory(title: updatedCategory.title, trackers: updatedTrackers)
            } else {
                let newCategory = TrackerCategory(title: "Категория нерегулярных событий", trackers: [tracker])
                trackersVC.categories.append(newCategory)
            }
            
            trackersVC.completedTrackers.insert(record)
            trackersVC.reloadData()
        }
        
        onCreate?(TrackerCategory(title: "Категория нерегулярных событий", trackers: [tracker]))
    }
}


extension IrregularEventCreationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = tableData[indexPath.row]
        cell.accessoryType = .disclosureIndicator // Шеврон вправо
        cell.backgroundColor = Color.lightGray
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 1000)
        cell.layer.cornerRadius = 16
        cell.layer.masksToBounds = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            // Переход на экран выбора категории
            print("Выбрана категория")
        default:
            break
        }
    }
}

extension IrregularEventCreationViewController: UICollectionViewDelegate,UICollectionViewDataSource {
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
            return cell
        case .color(let colors):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.identifier, for: indexPath) as? ColorCell else {
                    return UICollectionViewCell()
                }
            cell.prepareForReuse()
            cell.configureCell(colors[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "trackerDetailHeader", for: indexPath) as? TrackerDetailHeaderSupplementaryView
        view?.titleLabel.text = trackerDetailCollectionViewData[indexPath.section].header
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

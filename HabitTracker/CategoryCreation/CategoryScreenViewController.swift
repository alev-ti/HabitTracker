import UIKit

protocol CreateNewCategoryDelegate: AnyObject {
    func createNewCategory(title: String)
}

final class CategoryScreenViewController: UIViewController {
    private var viewModel: CategoryViewModelProtocol?
    
    private lazy var tableView = UITableView()
    private let addCategoryButton: UIButton = UIButton()
    
    private lazy var stubView: StubView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "stub_no_trackers")
        
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.text = "Привычки и события \n можно объединить по смыслу"
        
        return StubView(imageView: imageView, label: label)
    }()
    
    private var selectedCategoryTitle: String?
    
    var completionHandler: ((String?) -> Void)?
    
    init(selectedCategory: String? = nil) {
        self.selectedCategoryTitle = selectedCategory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
        toggleStubVisibility(isVisible: viewModel?.trackerCategories.count == 0)
    }
    
    private func setupViewModel() {
        viewModel = CategoryViewModel()
        viewModel?.categoriesBinding = {[weak self] _ in
            self?.toggleStubVisibility(isVisible: self?.viewModel?.trackerCategories.count == 0)
            self?.tableView.reloadData()
        }
    }
    
    private func toggleStubVisibility(isVisible: Bool) {
        stubView.setVisibility(isVisible: isVisible)
    }
}

extension CategoryScreenViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.trackerCategories.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.reuseIdentifier, for: indexPath) as? CategoryTableViewCell,
              let category = viewModel?.trackerCategories[indexPath.row] else {
            return UITableViewCell()
        }
        
        let isSelected = selectedCategoryTitle == category.title
        let categoryCell = CategoryCellModel(title: category.title, isSelected: isSelected)
        cell.configureCell(with: categoryCell)
        return cell
    }
}

extension CategoryScreenViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        completionHandler?(viewModel?.trackerCategories[indexPath.row].title)
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let count = viewModel?.trackerCategories.count else { return }
        cell.layer.masksToBounds = false
        cell.layer.cornerRadius = 0
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        configureCellAppearance(cell, at: indexPath, for: count)
    }
    
    private func configureCellAppearance(_ cell: UITableViewCell, at indexPath: IndexPath, for count: Int) {
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 16
        if count == 1 {
            configureSingleCell(cell)
            return
        }
        
        if indexPath.row == 0 {
            configureTopCell(cell)
        } else if indexPath.row == count - 1 {
            configureBottomCell(cell)
        }
    }
    
    private func configureSingleCell(_ cell: UITableViewCell) {
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 1000)
    }
    
    private func configureTopCell(_ cell: UITableViewCell) {
        cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private func configureBottomCell(_ cell: UITableViewCell) {
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 1000)
        cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

extension CategoryScreenViewController: CreateNewCategoryDelegate {
    func createNewCategory(title: String) {
        viewModel?.addNewCategory(title: title)
    }
}

private extension CategoryScreenViewController {
    func setupUI() {
        view.backgroundColor = .white
        self.title = "Категория"
        configureAddCategoryButton()
        configureTableView()
        configureStubView()
    }
    
    func configureStubView() {
        stubView.imageView.translatesAutoresizingMaskIntoConstraints = false
        stubView.label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stubView.imageView)
        view.addSubview(stubView.label)
        
        NSLayoutConstraint.activate([
            stubView.imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stubView.imageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            stubView.label.topAnchor.constraint(equalTo: stubView.imageView.bottomAnchor, constant: 8),
            stubView.label.centerXAnchor.constraint(equalTo: stubView.imageView.centerXAnchor)
        ])
    }
    
    func configureAddCategoryButton() {
        addCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        addCategoryButton.backgroundColor = Color.lightBlack
        addCategoryButton.setTitle("Добавить категорию", for: .normal)
        addCategoryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addCategoryButton.layer.cornerRadius = 16
        addCategoryButton.clipsToBounds = true
        addCategoryButton.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        view.addSubview(addCategoryButton)
        
        NSLayoutConstraint.activate([
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc func addCategoryButtonTapped() {
        let createCategoryScreenViewController = CreateCategoryScreenViewController(delegate: self)
        let navigationController = UINavigationController(rootViewController: createCategoryScreenViewController)
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        navigationController.navigationBar.titleTextAttributes = textAttributes
        present(navigationController, animated: true)
    }
    
    func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = true
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16)
        ])
    }
}

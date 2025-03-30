import UIKit

class StatisticsViewController: UIViewController {
    
    private let theme = Theme()
    
    private lazy var stubView = createStubView()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(StatisticsTableViewCell.self, forCellReuseIdentifier: StatisticsTableViewCell.reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.allowsSelection = false
        return tableView
    }()
    
    private let viewModel = StatisticsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        updateStubVisibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reloadAllData()
        tableView.reloadData()
        updateStubVisibility()
    }
    
    private func updateStubVisibility() {
        stubView.setVisibility(isVisible: viewModel.cellData.isEmpty)
    }
}

// MARK: - UITableViewDataSource
extension StatisticsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.cellData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StatisticsTableViewCell.reuseIdentifier, for: indexPath) as? StatisticsTableViewCell else {
            return UITableViewCell()
        }
        let cellData = viewModel.cellData[indexPath.row]
        cell.configure(with: cellData.title, info: cellData.text!)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension StatisticsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
}

// MARK: - UI Setup
private extension StatisticsViewController {
    
    func setupUI() {
        view.backgroundColor = theme.backgroundColor
        configureTableView()
        configureStubView()
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 77),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func configureStubView() {
        view.addSubview(stubView.imageView)
        view.addSubview(stubView.label)
        NSLayoutConstraint.activate([
            stubView.imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubView.imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            stubView.imageView.widthAnchor.constraint(equalToConstant: 100),
            stubView.imageView.heightAnchor.constraint(equalToConstant: 100),
            
            stubView.label.topAnchor.constraint(equalTo: stubView.imageView.bottomAnchor, constant: 10),
            stubView.label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func createStubView() -> StubView {
        let imageView = UIImageView(image: UIImage(named: "stub_no_statistics"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = NSLocalizedString("statistics_view_controller.stub_text", comment: "stub text empty statistics")
        label.textColor = theme.textColor
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return StubView(imageView: imageView, label: label)
    }
}

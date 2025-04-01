import UIKit

final class MainTabBarController: UITabBarController {
    private let theme = Theme.shared
    private let viewModel: StatisticsViewModel
    
    init(statisticsService: StatisticsProviding) {
        self.viewModel = StatisticsViewModel(statisticsService: statisticsService)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }
    
    private func setupTabs() {
        let trackersVC = TrackersViewController()
        let statsVC = StatisticsViewController(viewModel: viewModel)
        
        let trackersText = NSLocalizedString("main_tab_bar_controller.tab_title_trackers", comment: "tab title Trackers")
        let statisticsText = NSLocalizedString("main_tab_bar_controller.tab_title_statistics", comment: "tab title Statistics")
        
        let trackersTabItem = setupUI(rootViewController: trackersVC, title: trackersText, image: UIImage(systemName: "record.circle.fill") ?? UIImage())
        let statisticsTabItem = setupUI(rootViewController: statsVC, title: statisticsText, image: UIImage(systemName: "hare.fill") ?? UIImage())
        tabBar.tintColor = Color.blue
        tabBar.unselectedItemTintColor = Color.gray
        tabBar.barTintColor = theme.backgroundColor
        tabBar.layer.borderWidth = 0.5
        setViewControllers([trackersTabItem, statisticsTabItem], animated: false)
    }
    
    private func setupUI(rootViewController: UIViewController, title: String, image: UIImage) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.barTintColor = theme.backgroundColor
        navigationController.navigationBar.backgroundColor = theme.backgroundColor
        navigationController.navigationItem.largeTitleDisplayMode = .automatic
        navigationController.viewControllers.first?.navigationItem.title = title
        
        let titleFont = UIFont.systemFont(ofSize: 34, weight: .bold)
        navigationController.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.font: titleFont,
            NSAttributedString.Key.foregroundColor: theme.textColor
        ]
        
        let tabFont = UIFont.systemFont(ofSize: 17, weight: .semibold)
            navigationController.navigationBar.titleTextAttributes = [
                NSAttributedString.Key.font: tabFont,
                NSAttributedString.Key.foregroundColor: theme.textColor
            ]
        
        navigationController.tabBarItem.title = title
        navigationController.tabBarItem.image = image
        return navigationController
    }
}

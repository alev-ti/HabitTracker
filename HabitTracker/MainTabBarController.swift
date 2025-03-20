import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }
    
    private func setupTabs() {
        let trackersVC = UINavigationController(rootViewController: TrackersViewController())
        trackersVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("main_tab_bar_controller.tab_title_trackers", comment: "tab title Trackers"),
            image: UIImage(systemName: "record.circle.fill"),
            tag: 0
        )
        
        let statsVC = UINavigationController(rootViewController: StatisticsViewController())
        statsVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("main_tab_bar_controller.tab_title_statistics", comment: "tab title Statistics"),
            image: UIImage(systemName: "hare.fill"),
            tag: 1
        )
        
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = Color.gray.cgColor
        tabBar.clipsToBounds = true
        
        viewControllers = [trackersVC, statsVC]
    }
}

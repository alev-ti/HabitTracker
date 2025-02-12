import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }
    
    private func setupTabs() {
        let trackersVC = UINavigationController(rootViewController: TrackersViewController())
        trackersVC.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(systemName: "record.circle.fill"), tag: 0)
        
        let statsVC = UIViewController()
        statsVC.view.backgroundColor = .white
        statsVC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(systemName: "hare.fill"), tag: 1)
        
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1).cgColor
        tabBar.clipsToBounds = true
        
        viewControllers = [trackersVC, statsVC]
    }
}

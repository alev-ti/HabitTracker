import UIKit

final class RootViewController: UIViewController {
    
    private var isOnboardingCompleted: Bool {
        return UserDefaults.standard.bool(forKey: "isOnboardingCompleted")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        showOnboardingIfNeeded()
    }
    
    private func setupTabBar() {
        let statisticsService = StatisticsProvider()
        let tabBarController = MainTabBarController(statisticsService: statisticsService)
        addChild(tabBarController)
        view.addSubview(tabBarController.view)
        tabBarController.view.frame = view.bounds
        tabBarController.didMove(toParent: self)
    }
    
    private func showOnboardingIfNeeded() {
        guard !isOnboardingCompleted else { return }
        
        let onboardingPageViewController = OnboardingPageViewController { [weak self] in
            self?.removeOnboardingViewController()
        }
        
        addChild(onboardingPageViewController)
        view.addSubview(onboardingPageViewController.view)
        onboardingPageViewController.view.frame = view.bounds
        onboardingPageViewController.didMove(toParent: self)
    }
    
    private func removeOnboardingViewController() {
        guard let onboardingViewController = children.first(where: { $0 is OnboardingPageViewController }) else { return }
        
        onboardingViewController.willMove(toParent: nil)
        
        UIView.animate(withDuration: 0.25, animations: {
            onboardingViewController.view.alpha = 0
        }) { _ in
            onboardingViewController.view.removeFromSuperview()
            onboardingViewController.removeFromParent()
            UserDefaults.standard.set(true, forKey: "isOnboardingCompleted")
        }
    }
}

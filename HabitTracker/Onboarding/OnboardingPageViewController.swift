import UIKit

protocol OnboardingScreenDelegate: AnyObject {
    func hideOnboarding()
}

final class OnboardingPageViewController: UIPageViewController, OnboardingScreenDelegate {
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .gray
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private let dismissOnboarding: (() -> Void)
    
    private lazy var pages: [UIViewController] = createPages()
    
    init(dismissOnboarding: @escaping (() -> Void)) {
        self.dismissOnboarding = dismissOnboarding
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func hideOnboarding() {
        dismissOnboarding()
    }
    
    private func createPages() -> [UIViewController] {
        let blueScreen = OnboardingScreenViewController(pageModel: .bluePage, delegate: self)
        let redScreen = OnboardingScreenViewController(pageModel: .redPage, delegate: self)
        return [blueScreen, redScreen]
    }
}

// MARK: - UIPageViewControllerDataSource, UIPageViewControllerDelegate

extension OnboardingPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let currentViewController = pageViewController.viewControllers?.first,
              let currentIndex = pages.firstIndex(of: currentViewController) else { return }
        pageControl.currentPage = currentIndex
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index > 0 else { return nil }
        return pages[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else { return nil }
        return pages[index + 1]
    }
}


private extension OnboardingPageViewController {
    func setupUI() {
        dataSource = self
        delegate = self
        
        guard let firstPage = pages.first else { return }
        setViewControllers([firstPage], direction: .forward, animated: true)
        
        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134)
        ])
    }
}

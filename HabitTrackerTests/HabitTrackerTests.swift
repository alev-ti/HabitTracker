import SnapshotTesting
import XCTest
@testable import HabitTracker

final class HabitTrackerTests: XCTestCase {

    func testTrackersViewControllerLightTheme() {
        let vc = TrackersViewController()
        vc.overrideUserInterfaceStyle = .light
        assertSnapshot(of: vc, as: .image)
    }
    
    func testTrackersViewControllerDarkTheme() {
        let vc = TrackersViewController()
        vc.overrideUserInterfaceStyle = .dark
        assertSnapshot(of: vc, as: .image)
    }
    
    func testStatisticsViewControllerLightTheme() {
        let vc = StatisticsViewController()
        vc.overrideUserInterfaceStyle = .light
        assertSnapshot(of: vc, as: .image)
    }
    
    func testStatisticsViewControllerDarkTheme() {
        let vc = StatisticsViewController()
        vc.overrideUserInterfaceStyle = .dark
        assertSnapshot(of: vc, as: .image)
    }
}

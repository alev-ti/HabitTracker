import UIKit

final class EditHabitViewController: HabitCreationViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Редактирование привычки"
        createButton.setTitle("Сохранить", for: .normal)
    }
}


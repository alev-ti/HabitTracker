import UIKit

final class EditIrregularEventViewController: IrregularEventCreationViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Редактирование события"
        createButton.setTitle("Сохранить", for: .normal)
    }
}


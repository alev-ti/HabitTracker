import UIKit

final class CreateCategoryScreenViewController: UIViewController {
    
    private lazy var nameCategoryTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = NSLocalizedString("create_category_screen_view_controller.category_name_input_placeholder", comment: "placeholder Category's title")
        textField.textColor = .black
        textField.backgroundColor = Color.lightGray
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 16
        textField.clipsToBounds = true
        return textField
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Color.gray
        button.isEnabled = false
        button.setTitle(NSLocalizedString("create_category_screen_view_controller.button_done", comment: "button done"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        return button
    }()
    
    private weak var delegate: CreateNewCategoryDelegate?
    
    init(delegate: CreateNewCategoryDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        hideKeyboardWhenTapped()
    }
}

// MARK: - UITextFieldDelegate

extension CreateCategoryScreenViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location == 0 && string == " " {
            return false
        }
        return true
    }
}

// MARK: - Configure UI

private extension CreateCategoryScreenViewController {
    func setupUI() {
        view.backgroundColor = .white
        title = NSLocalizedString("create_category_screen_view_controller.title", comment: "New category title")
        setupNameTextField()
        setupDoneButton()
    }
    
    func setupNameTextField() {
        nameCategoryTextField.delegate = self
        nameCategoryTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        view.addSubview(nameCategoryTextField)
        
        NSLayoutConstraint.activate([
            nameCategoryTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameCategoryTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameCategoryTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameCategoryTextField.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    func setupDoneButton() {
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func textFieldDidChange() {
        let isEmpty = nameCategoryTextField.text?.isEmpty ?? true
        doneButton.backgroundColor = isEmpty ? Color.gray : Color.lightBlack
        doneButton.isEnabled = !isEmpty
    }
    
    @objc private func doneButtonTapped() {
        guard let text = nameCategoryTextField.text else { return }
        dismiss(animated: true) {
            self.delegate?.createNewCategory(title: text)
        }
    }
}


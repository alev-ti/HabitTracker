import UIKit

final class CreateCategoryScreenViewController: UIViewController {
    
    private let nameCategoryTextField = UITextField()
    private let addCategoryButton = UIButton()
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
        title = "Новая категория"
        setupNameTextField()
        setupDoneButton()
    }
    
    func setupNameTextField() {
        nameCategoryTextField.delegate = self
        nameCategoryTextField.translatesAutoresizingMaskIntoConstraints = false
        nameCategoryTextField.placeholder = "Введите название категории"
        nameCategoryTextField.textColor = .black
        nameCategoryTextField.backgroundColor = Color.lightGray
        nameCategoryTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
        nameCategoryTextField.leftViewMode = .always
        nameCategoryTextField.layer.cornerRadius = 16
        nameCategoryTextField.clipsToBounds = true
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
        addCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        addCategoryButton.backgroundColor = Color.gray
        addCategoryButton.isEnabled = false
        addCategoryButton.setTitle("Готово", for: .normal)
        addCategoryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addCategoryButton.layer.cornerRadius = 16
        addCategoryButton.clipsToBounds = true
        addCategoryButton.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        
        view.addSubview(addCategoryButton)
        
        NSLayoutConstraint.activate([
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func textFieldDidChange() {
        let isEmpty = nameCategoryTextField.text?.isEmpty ?? true
        addCategoryButton.backgroundColor = isEmpty ? Color.gray : Color.lightBlack
        addCategoryButton.isEnabled = !isEmpty
    }
    
    @objc private func addCategoryButtonTapped() {
        guard let text = nameCategoryTextField.text else { return }
        dismiss(animated: true) {
            self.delegate?.createNewCategory(title: text)
        }
    }
}


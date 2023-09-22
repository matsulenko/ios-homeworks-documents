//
//  LoginViewController.swift
//  Documents
//
//  Created by Matsulenko on 05.09.2023.
//

import Foundation
import KeychainSwift
import UIKit

enum NewPasswordError: Error {
    case empty, short
}

final class LoginViewController: UIViewController {
        
    private let keychain = KeychainSwift()
    
    private let defaults = UserDefaults.standard
    
    private lazy var isNewUser = {
        var isNewUser: Bool
        if (keychain.get("myPassword") != nil) {
            isNewUser = false
        } else {
            isNewUser = true
        }
        
        return isNewUser
    }()
    
    private var isTypingAgain = false
    
    private var previousTextTyped: String?
    
    private var textTyped: String?
    
    private var isFromSettings: Bool?
    
    private lazy var passwordField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.cornerRadius = 10.0
        textField.placeholder = "Пароль"
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.textColor = .black
        textField.textAlignment = .center
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.isSecureTextEntry = true
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.backgroundColor = .white
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        
        textField.delegate = self
        
        return textField
    }()
    
    private lazy var confirmationButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentMode = .center
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10.0
        button.backgroundColor = .systemBlue
        button.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        button.layer.shadowRadius = 10.0
        button.layer.shadowOpacity = 0.3
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var errorAlert = {
        let alert = UIAlertController(
            title: "Произошла ошибка",
            message: "Проверьте правильность введённых данных",
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(
                title: "Ок",
                style: .default,
                handler: nil
            )
        )
        
        return alert
    }()
    
    init(isFromSettings: Bool? = false) {
        self.isFromSettings = isFromSettings
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        setupView()
        setupConstraints()
    }
    
    @objc
    private func textChanged(_ textField: UITextField) {
        textTyped = textField.text
    }
    
    @objc
    private func buttonTapped() {
        if isNewUser || isFromSettings == true {
            checkNewPassword() { [self] result in
                switch result {
                case .success(true):
                    if isFromSettings == true {
                        keychain.delete("myPassword")
                    }
                    if isNewUser {
                        defaults.set(true, forKey: "Sort")
                        defaults.set(true, forKey: "ABC")
                        defaults.set(false, forKey: "CBA")
                    }
                    keychain.set(textTyped!, forKey: "myPassword")
                    closeLoginVC()
                case .success(false):
                    if isTypingAgain {
                        self.errorAlert.title = "Введённые пароли не совпадают"
                        self.present(errorAlert, animated: true)
                        resetButtonHistory()
                    } else {
                        isTypingAgain = true
                        confirmationButton.setTitle("Повторите пароль", for: .normal)
                        passwordField.text = ""
                        previousTextTyped = textTyped
                        textTyped = ""
                    }
                case .failure(.empty):
                    self.errorAlert.title = "Пароль не введён"
                    self.present(errorAlert, animated: true)
                    resetButtonHistory()
                case .failure(.short):
                    self.errorAlert.title = "Минимальная длина пароля — 4 символа"
                    self.present(errorAlert, animated: true)
                    resetButtonHistory()
                }
            }
        } else {
            if checkPassword() {
                closeLoginVC()
            } else {
                self.errorAlert.title = "Введён неверный пароль"
                self.present(errorAlert, animated: true)
                resetButtonHistory()
            }
        }
    }
    
    private func closeLoginVC() {
        self.dismiss(animated: true)
    }
    
    private func checkNewPassword(completion: @escaping (Result<Bool,NewPasswordError>) -> Void) {
        if textTyped == previousTextTyped {
            completion(.success(true))
        } else {
            if textTyped == nil {
                completion(.failure(.empty))
            } else if textTyped == "" {
                completion(.failure(.empty))
            } else if textTyped!.count < 4 {
                completion(.failure(.short))
            } else {
                completion(.success(false))
            }
        }
    }
    
    private func checkPassword() -> Bool {
        if textTyped == keychain.get("myPassword") {
            return true
        } else {
            return false
        }
    }
    
    private func addSubviews() {
        view.addSubview(passwordField)
        view.addSubview(confirmationButton)
    }
    
    private func setupView() {
        view.backgroundColor = .systemGray5
        
        setButtonTitle()
    }
    
    private func resetButtonHistory() {
        isTypingAgain = false
        previousTextTyped = nil
        passwordField.text = ""
        textTyped = nil
        setButtonTitle()
    }
    
    private func setButtonTitle() {
        if isNewUser {
            confirmationButton.setTitle("Cоздать пароль", for: .normal)
        } else if isFromSettings == true {
            confirmationButton.setTitle("Изменить пароль", for: .normal)
        } else {
            confirmationButton.setTitle("Введите пароль", for: .normal)
        }
    }
    
    private func setupConstraints() {
        let safeAreaGuide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            passwordField.centerYAnchor.constraint(equalTo: safeAreaGuide.centerYAnchor, constant: -100),
            passwordField.heightAnchor.constraint(equalToConstant: 50),
            passwordField.leadingAnchor.constraint(equalTo: safeAreaGuide.leadingAnchor, constant: 30),
            passwordField.trailingAnchor.constraint(equalTo: safeAreaGuide.trailingAnchor, constant: -30),
            
            confirmationButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 20),
            confirmationButton.centerXAnchor.constraint(equalTo: safeAreaGuide.centerXAnchor),
            confirmationButton.widthAnchor.constraint(equalToConstant: 300),
            confirmationButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(
        _ textField: UITextField
    ) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}

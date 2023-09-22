//
//  SettingsViewController.swift
//  Documents
//
//  Created by Matsulenko on 06.09.2023.
//

import Foundation
import KeychainSwift
import UIKit

final class SettingsViewController: UIViewController {
    
    let cellReuseIdentifier = "cell"
    
    private let defaults = UserDefaults.standard
    
    private lazy var tableView: UITableView = {
        var tableView = UITableView.init(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    private var sortSwitch: UISwitch {
        let sortSwitch = UISwitch(frame: CGRectZero) as UISwitch
        if defaults.bool(forKey: "Sort") {
            sortSwitch.isOn = true
        }
        sortSwitch.addTarget(self, action: #selector(switchButton), for: .valueChanged)
        
        return sortSwitch
    }
    
    @objc
    private func switchButton(_ sender: UISwitch) {
        if sender.isOn == true {
            defaults.set(true, forKey: "Sort")
            if defaults.bool(forKey: "ABC") == false && defaults.bool(forKey: "CBA") == false {
                defaults.set(true, forKey: "ABC")
            }
            tableView.reloadData()
        } else {
            defaults.set(false, forKey: "Sort")
            tableView.reloadData()
        }
    }
    
    @objc
    private func openLoginViewController() {
        let loginVC = LoginViewController(isFromSettings: true)
        self.navigationController!.present(loginVC, animated: true)
    }
    
    @objc
    private func sortAsc() {
        defaults.set(true, forKey: "ABC")
        defaults.set(false, forKey: "CBA")
        tableView.reloadData()
    }
    
    @objc
    private func sortDesc() {
        defaults.set(true, forKey: "CBA")
        defaults.set(false, forKey: "ABC")
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        setupTable()
        setupView()
        setupConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(tableView)
    }
    
    private func setupTable() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupView() {
        title = "Настройки"
        view.backgroundColor = .systemGray6
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupConstraints() {
        let safeAreaGuide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: safeAreaGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeAreaGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: safeAreaGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeAreaGuide.bottomAnchor)
        ])
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        sortSwitch.isOn ? 3 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = (self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)! as UITableViewCell?)!
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17.0, weight: .regular)
        cell.isUserInteractionEnabled = true
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "Поменять пароль"
            cell.accessoryView = .none
            cell.accessoryType = .none
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openLoginViewController))
            cell.addGestureRecognizer(tapGesture)
        case 1:
            cell.textLabel?.text = "Cортировка"
            cell.accessoryView = sortSwitch
            cell.gestureRecognizers?.removeAll()
        case 2:
            if indexPath.row == 0 {
                cell.textLabel?.text = "В алфавитном порядке"
                cell.accessoryView = .none
                if defaults.bool(forKey: "ABC") {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(sortAsc))
                cell.addGestureRecognizer(tapGesture)
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "В обратном порядке"
                cell.accessoryView = .none
                if defaults.bool(forKey: "CBA") {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(sortDesc))
                cell.addGestureRecognizer(tapGesture)
            } else {
                preconditionFailure("Unknown setting for row number \(indexPath.row)")
            }
        default: preconditionFailure("Unknown setting for section number \(indexPath.section)")
        }
        
        return cell
        
    }
}


//
//  ViewController.swift
//  Documents
//
//  Created by Matsulenko on 01.09.2023.
//

import Foundation
import UIKit

final class FileManagerViewController: UIViewController {

    private let fileManagerService = FileManagerService()
    private var rootDirectory: String?
    private var directory: String?
    private var data: [DirectoryContent] = []
    private var loggedIn: Bool
    
    let cellReuseIdentifier = "cell"
    
    private lazy var tableView: UITableView = {
        var tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    init(rootDirectory: String? = nil, directory: String? = nil, loggedIn: Bool = true) {
        self.rootDirectory = rootDirectory
        self.directory = directory
        self.loggedIn = loggedIn
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        setupTable()
        setupView()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        
        if loggedIn == false {
            self.navigationController!.present(loginVC, animated: false)
            self.loggedIn = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupData()
        tableView.reloadData()
    }

    private func addSubviews() {
        view.addSubview(tableView)
    }
    
    private func setupTable() {
        setupData()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupData() {
        do {
            data = try fileManagerService.contentsOfDirectory(rootDirectory: rootDirectory, directory: directory)
        } catch {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            
            alert.addAction(
                UIAlertAction(
                    title: "OK",
                    style: .cancel,
                    handler: nil
                )
            )
            
            present(alert, animated: true)
        }
    }
    
    private func setupView() {
        title = directory ?? "Cписок файлов"
        view.backgroundColor = .systemGray6
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(picker)),
            UIBarButtonItem(image: UIImage(systemName: "folder.badge.plus"), style: .plain, target: self, action: #selector(newFolderAlert))
        ]
        self.navigationItem.rightBarButtonItem?.tintColor = .systemBlue
    }
    
    private func setupConstraints() {
        let safeAreaGuide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: safeAreaGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeAreaGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: safeAreaGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeAreaGuide.bottomAnchor),
        ])
    }
    @objc
    private func openFolder(recognizer: UITapGestureRecognizer) {
        if recognizer.state == UIGestureRecognizer.State.ended {
            let swipeLocation = recognizer.location(in: self.tableView)
            if let swipedIndexPath = tableView.indexPathForRow(at: swipeLocation) {
                if self.tableView.cellForRow(at: swipedIndexPath) != nil {
                    let row = swipedIndexPath.row
                    let name = data[row].name
                    var newRootDirectory: String?
                    if rootDirectory != nil {
                        newRootDirectory = rootDirectory! + "/" + directory!
                    } else {
                        if directory != nil {
                            newRootDirectory = directory
                        }
                    }
                    
                    let targetViewController = FileManagerViewController(rootDirectory: newRootDirectory, directory: name)
                    navigationController?.pushViewController(targetViewController, animated: true)
                }
            }
        }
    }
    
    @objc
    private func newFolderAlert() {
        let alert = UIAlertController(title: "Create new folder", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Folder name"
        }
        
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil
            )
        )

        alert.addAction(
            UIAlertAction(
                title: "Create",
                style: .default,
                handler: { [weak alert] _ in
                    guard let alert = alert, let textField = alert.textFields?.first else { return }
                    self.newFolder(name: textField.text ?? "New folder")
                }
            )
        )

        present(alert, animated: true)
    }
    
    private func newFolder(name: String) {
        do {
            try fileManagerService.createDirectory(name: name, rootDirectory: rootDirectory, directory: directory)
            setupData()
            tableView.reloadData()
        } catch {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            
            alert.addAction(
                UIAlertAction(
                    title: "OK",
                    style: .cancel,
                    handler: nil
                )
            )
            
            present(alert, animated: true)
        }
    }
}

extension FileManagerViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    @objc
    func picker() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

        do {
            try fileManagerService.createFile(image: image, rootDirectory: rootDirectory, directory: directory)
            setupData()
            tableView.reloadData()
        } catch {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            
            alert.addAction(
                UIAlertAction(
                    title: "OK",
                    style: .cancel,
                    handler: nil
                )
            )
            
            present(alert, animated: true)
        }

        dismiss(animated: true)
    }
}

extension FileManagerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = (self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)! as UITableViewCell?)!
        
        cell.textLabel?.text = self.data[indexPath.row].name
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17.0, weight: .regular)
        
        if data[indexPath.row].contentType == .folder {
            cell.accessoryType = .disclosureIndicator
            cell.accessoryView = nil
            cell.tintColor = .systemGray
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openFolder(recognizer:)))
            cell.isUserInteractionEnabled = true
            cell.addGestureRecognizer(tapGesture)

        } else if data[indexPath.row].contentType == .file {
            cell.selectionStyle = .none
            cell.accessoryType = .none
            cell.isUserInteractionEnabled = false
        }
        
        
        return cell
        
    }
}

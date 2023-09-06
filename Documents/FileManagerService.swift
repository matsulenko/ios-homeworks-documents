//
//  FileManagerService.swift
//  Documents
//
//  Created by Matsulenko on 01.09.2023.
//

import Foundation
import UIKit

protocol FileManagerServiceProtocol {
    func contentsOfDirectory(rootDirectory: String?, directory: String?) throws -> [DirectoryContent]
    func createDirectory(name: String, rootDirectory: String?, directory: String?) throws
    func createFile(image: UIImage, rootDirectory: String?, directory: String?) throws
    func removeContent(path: String) throws
}

final class FileManagerService: FileManagerServiceProtocol {
    
    private let defaults = UserDefaults.standard

    func contentsOfDirectory(rootDirectory: String?, directory: String?) throws -> [DirectoryContent] {
        
        var directoryContent: [DirectoryContent] = []
        let fileManager = FileManager.default
        
        do {
            let documentsUrl = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            var url = documentsUrl
            if rootDirectory != nil {
                url = documentsUrl.appendingPathComponent(rootDirectory! + "/" + directory!)
            } else {
                if directory != nil {
                    url = documentsUrl.appendingPathComponent(directory!)
                }
            }
            let items = try fileManager.contentsOfDirectory(atPath: url.path)
            for i in items {
                if i != ".DS_Store" {
                var isDirectory: ObjCBool = true
                var contentType: ContentType?
                    if fileManager.fileExists(atPath: url.appendingPathComponent(i).path, isDirectory: &isDirectory) {
                        if isDirectory.boolValue {
                            contentType = .folder
                        } else {
                            contentType = .file
                        }
                        guard let contentType = contentType else { continue }
                        let element = DirectoryContent(name: i, contentType: contentType)
                        directoryContent.append(element)
                    }
                }
            }
            if defaults.bool(forKey: "Sort") {
                if defaults.bool(forKey: "ABC") {
                    directoryContent.sort { $0.name.lowercased() < $1.name.lowercased() }
                } else if defaults.bool(forKey: "CBA") {
                    directoryContent.sort { $1.name.lowercased() < $0.name.lowercased() }
                }
            }
            
            return directoryContent
        } catch let error {
            throw error
        }
    }
    
    func createDirectory(name: String, rootDirectory: String?, directory: String?) throws {
        let fileManager = FileManager.default
        
        do {
            let documentsUrl = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            var url = documentsUrl
            
            if rootDirectory != nil {
                url = documentsUrl.appendingPathComponent(rootDirectory! + "/" + directory! + "/" + name)
            } else {
                url = documentsUrl.appendingPathComponent((directory ?? "") + "/" + name)
            }
            
            try fileManager.createDirectory(at: url, withIntermediateDirectories: false)
            
        } catch let error {
            throw error
        }
    }
    
    func createFile(image: UIImage, rootDirectory: String?, directory: String?) throws {
        let fileManager = FileManager.default
        
        do {
            let name = UUID().uuidString
            
            let documentsUrl = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            var url = documentsUrl
            
            if rootDirectory != nil {
                url = documentsUrl.appendingPathComponent(rootDirectory! + "/" + directory! + "/" + name + ".jpg")
            } else {
                url = documentsUrl.appendingPathComponent((directory ?? "") + "/" + name + ".jpg")
            }
            
            if let jpegData = image.jpegData(compressionQuality: 1.0) {
                try? jpegData.write(to: url)
            }
            
        } catch let error {
            throw error
        }
    }
    
    func removeContent(path: String) throws {
        let fileManager = FileManager.default
        
        do {
            try fileManager.removeItem(atPath: path)
        } catch let error {
            throw error
        }
    }
}

//
//  DirectoryContent.swift
//  Documents
//
//  Created by Matsulenko on 01.09.2023.
//

import Foundation

enum ContentType {
    case file
    case folder
}

struct DirectoryContent {
    let name: String
    let contentType: ContentType
}

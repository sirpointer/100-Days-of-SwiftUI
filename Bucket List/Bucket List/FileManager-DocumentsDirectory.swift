//
//  FileManager-DocumentsDirectory.swift
//  Bucket List
//
//  Created by Nikita Novikov on 14.09.2022.
//

import Foundation

extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

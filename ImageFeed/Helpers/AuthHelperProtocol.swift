//
//  AuthHelperProtocol.swift
//  ImageFeed
//
//  Created by Igor Ignatov on 12.06.2023.
//

import Foundation

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest
    func code(from url: URL) -> String?
} 

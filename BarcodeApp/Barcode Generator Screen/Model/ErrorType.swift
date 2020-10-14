//
//  ErrorType.swift
//  BarcodeApp
//
//  Created by Colin Murphy on 10/14/20.
//  Copyright © 2020 ExaData. All rights reserved.
//

import Foundation

enum ErrorType {
    
    case generatingQRCode
    case emptyTextField
    case failedToReadQRCode
    case noQRCodeFound
    case noCameraFound
    case noQRCodeToExport
}

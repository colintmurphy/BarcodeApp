//
//  GeneratorViewModel.swift
//  BarcodeApp
//
//  Created by Colin Murphy on 10/14/20.
//  Copyright © 2020 ExaData. All rights reserved.
//

import UIKit
import EFQRCode

// MARK: - GeneratorViewModelProtocol

protocol GeneratorViewModelProtocol: AnyObject {
    
    func updateQRCodeImage(with image: UIImage?)
    func didFailWithError(_ error: ErrorType)
}

// MARK: - GeneratorViewModel

class GeneratorViewModel {
    
    // MARK: - Public Attributes
    
    weak var delegate: GeneratorViewModelProtocol?
    
    // MARK: - Public Methods
    
    func generateQRCode(urlString: String?, image: UIImage?) -> UIImage? {
        
        guard let urlString = urlString,
            !urlString.isEmpty else {
            delegate?.didFailWithError(.emptyTextField)
            return nil
        }
        
        if let qrcodeCGImage = EFQRCode.generate(content: urlString, watermark: image?.cgImage) {
            return UIImage(cgImage: qrcodeCGImage)
        } else {
            delegate?.didFailWithError(.generatingQRCode)
            return nil
        }
    }
    
    func presentImagePicker() {
        delegate?.updateQRCodeImage(with: nil)
    }
    
    func readQRCode(with image: UIImage?) -> String? {
        
        if let testImage = image?.cgImage,
            let tryCodes = EFQRCode.recognize(image: testImage) {
            
            if !tryCodes.isEmpty {
                return tryCodes[0]
            }
            delegate?.didFailWithError(.noQRCodeFound)
        } else {
            delegate?.didFailWithError(.failedToReadQRCode)
        }
        return nil
    }
}

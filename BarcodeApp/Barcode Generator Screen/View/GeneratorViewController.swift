//
//  GeneratorViewController.swift
//  BarcodeApp
//
//  Created by Colin Murphy on 10/14/20.
//  Copyright © 2020 ExaData. All rights reserved.
//

import EFQRCode
import UIKit

class GeneratorViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var qrCodeButton: UIButton!
    @IBOutlet private weak var createQRCodeButton: UIButton!
    @IBOutlet private weak var readQRCodeButton: UIBarButtonItem!
    @IBOutlet private weak var shareQRCodeButton: UIBarButtonItem!
    
    @IBOutlet private weak var urlTextField: UITextField! {
        didSet {
            urlTextField.delegate = self
        }
    }
    
    // MARK: - Public Attributes
    
    var viewModel: GeneratorViewModel = GeneratorViewModel()
    
    // MARK: - Private Attributes
    
    private var imagePickerUse: ImagePickerUseCase = .selectImage
    
    // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
        
        viewModel.delegate = self
        createQRCodeButton.layer.cornerRadius = createQRCodeButton.bounds.height / 2
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        urlTextField.resignFirstResponder()
    }
    
    // MARK: - IBActions
    
    @IBAction private func createQRCode(_ sender: Any) {
        
        if let qrCodeImage = viewModel.generateQRCode(urlString: urlTextField.text, image: qrCodeButton.backgroundImage(for: .normal)) {
            qrCodeButton.setBackgroundImage(qrCodeImage, for: .normal)
        }
    }
    
    @IBAction private func readQRCode(_ sender: Any) {
        
        imagePickerUse = .readImage
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showImagePicker(with: .camera)
        } else {
            didFailWithError(.noCameraFound)
            imagePickerUse = .selectImage
        }
    }
    
    @IBAction private func shareQRCode(_ sender: Any) {
        
        guard let image = qrCodeButton.backgroundImage(for: .normal) else {
            didFailWithError(.noQRCodeToExport)
            return
        }
        let shareVC = UIActivityViewController(activityItems: [image], applicationActivities: [])
        shareVC.popoverPresentationController?.sourceView = view // ensure doesn't crash on iPad
        present(shareVC, animated: true)
    }
    
    @IBAction private func setImage(_ sender: Any) {
        showImagePickerActionSheet()
    }
}

// MARK: - GeneratorViewModelProtocol

extension GeneratorViewController: GeneratorViewModelProtocol {
    
    func updateQRCodeImage(with image: UIImage?) {
        qrCodeButton.setBackgroundImage(image, for: .normal)
    }
    
    func didFailWithError(_ error: ErrorType) {
        
        switch error {
        case .generatingQRCode:
            showAlert(title: "Sorry", message: "It looks like we failed to create your beatiful QRCode.")
            
        case .emptyTextField:
            showAlert(title: "Error", message: "Please make sure you enter a website for you barcode.")
            
        case .failedToReadQRCode:
            showAlert(title: "Sorry", message: "It looks like we have trouble reading that QRCode.")
            
        case .noQRCodeFound:
            showAlert(title: "Sorry", message: "No QRCode detected.")
            
        case .noCameraFound:
            showAlert(title: "Sorry", message: "It looks like this device does not have a camera.")
            
        case .noQRCodeToExport:
            showAlert(title: "Sorry", message: "It looks like you haven't created a QRCode to export")
        }
    }
}

// MARK: - UITextFieldDelegate

extension GeneratorViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        urlTextField.resignFirstResponder()
        return false
    }
}

// MARK: - UIImagePickerControllerDelegate

extension GeneratorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showImagePicker(with sourceType: UIImagePickerController.SourceType) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true)
    }
    
    func showImagePickerActionSheet() {
        
        let alert = UIAlertController(title: "Choose an image", message: nil, preferredStyle: .actionSheet)
        let photosAction = UIAlertAction(title: "Choose from library", style: .default) { _ in
            self.showImagePicker(with: .photoLibrary)
        }
        let cameraAction = UIAlertAction(title: "Take photo", style: .default) { _ in
            self.showImagePicker(with: .camera)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            cameraAction.isEnabled = false
        }
        alert.addAction(photosAction)
        alert.addAction(cameraAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[.editedImage] as? UIImage {
            handleReadOrSelectImage(with: editedImage)
        } else if let originalImage = info[.originalImage] as? UIImage {
            handleReadOrSelectImage(with: originalImage)
        } else {
            if #available(iOS 13.0, *) {
                qrCodeButton.setBackgroundImage(UIImage(systemName: "qrcode")?.withTintColor(.systemPink), for: .normal)
            } else {
                qrCodeButton.setBackgroundImage(UIImage(named: "qrCode"), for: .normal)
            }
        }
        dismiss(animated: true)
    }
    
    private func handleReadOrSelectImage(with image: UIImage) {
        
        switch imagePickerUse {
        case .selectImage:
            qrCodeButton.setBackgroundImage(image, for: .normal)
        case .readImage:
            readQRCode(of: image)
        }
    }
    
    private func readQRCode(of image: UIImage) {
        
        if let urlString = viewModel.readQRCode(with: image) {
            urlTextField.text = urlString
        }
        imagePickerUse = .selectImage
    }
}

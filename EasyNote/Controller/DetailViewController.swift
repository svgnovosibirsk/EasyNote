//
//  DetailViewController.swift
//  EasyNote
//
//  Created by Sergey Golovin on 25.09.2021.
//  Copyright © 2021 GoldenWindGames LLC. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var notesHandleDelegate: NotesHandleDelegate!
    var note: Note?
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var imageImageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bodyTextView.layer.borderWidth = 2
        bodyTextView.layer.borderColor = #colorLiteral(red: 1, green: 0.04167353739, blue: 0.0673128325, alpha: 1)
        
        if note == nil {
            setEmptyNote()
        }
        setEditStyleUI()
        setDismissKeyboardGesture()
        
    }
    
    @IBAction func loadImageBtnPressed(_ sender: UIButton) {
        loadImage()
    }
    
    @IBAction func imageBtnPressed(_ sender: UIButton) {
        loadImage()
    }
    
    @IBAction func deleteBtnPressed(_ sender: UIButton) {
        notesHandleDelegate.deleteNote()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        guard isTitleFieldCorrect() else { return }
        configureNote()
        if let note = note {
            notesHandleDelegate.saveChanges(note: note)
        }
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func textStyleBtnPressed(_ sender: UIBarButtonItem) {
        presentTextStyleAlert()
    }
    
    private func loadImage() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
     // Checks that note title is not empty
    private func isTitleFieldCorrect() -> Bool {
        if titleTextField.text == "" {
            let ac = UIAlertController(title: "Empty note", message: "Set title please", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true)
            return false
        }
        return true
    }
    
    // Sets empty note when view loads
    private func setEmptyNote() {
        note = Note(context: context)
        note?.title = ""
        note?.body = ""
        note?.image = nil
    }
    
    // Sets text fields and imageView when note is editing
    private func setEditStyleUI() {
        titleTextField.text = note?.title
        bodyTextView.text = note?.body
        guard let imageData = note?.image else { return }
        imageImageView.image = UIImage(data: imageData)
        
        switch  note?.textStyle {
        case TextStyle.largeFont.rawValue:
            let attributes: [NSAttributedString.Key : Any] = [.font: UIFont.systemFont(ofSize: 20)]
            bodyTextView.attributedText = NSAttributedString(string: note?.body ?? "", attributes: attributes)
        case TextStyle.mediumFont.rawValue:
            let attributes: [NSAttributedString.Key : Any] = [.font: UIFont.systemFont(ofSize: 15)]
            bodyTextView.attributedText = NSAttributedString(string: note?.body ?? "", attributes: attributes)
        case TextStyle.smallFont.rawValue:
            let attributes: [NSAttributedString.Key : Any] = [.font: UIFont.systemFont(ofSize: 10)]
            bodyTextView.attributedText = NSAttributedString(string: note?.body ?? "", attributes: attributes)
        case TextStyle.italicFont.rawValue:
            let attributes: [NSAttributedString.Key : Any] = [.font: UIFont.italicSystemFont(ofSize: 15)]
            bodyTextView.attributedText = NSAttributedString(string: note?.body ?? "", attributes: attributes)
        case TextStyle.boldFont.rawValue:
            let attributes: [NSAttributedString.Key : Any] = [.font: UIFont.boldSystemFont(ofSize: 15)]
            bodyTextView.attributedText = NSAttributedString(string: note?.body ?? "", attributes: attributes)
        case TextStyle.chalkdusterFont.rawValue:
            let attributes: [NSAttributedString.Key : Any] = [.font: UIFont.init(name: "chalkduster", size: 15) ?? UIFont.systemFont(ofSize: 15)]
            bodyTextView.attributedText = NSAttributedString(string: note?.body ?? "", attributes: attributes)
        case TextStyle.noteworthyFont.rawValue:
            let attributes: [NSAttributedString.Key : Any] = [.font: UIFont.init(name: "noteworthy", size: 15) ?? UIFont.systemFont(ofSize: 15)]
            bodyTextView.attributedText = NSAttributedString(string: note?.body ?? "", attributes: attributes)
        default:
            let attributes: [NSAttributedString.Key : Any] = [.font: UIFont.systemFont(ofSize: 15)]
            bodyTextView.attributedText = NSAttributedString(string: note?.body ?? "", attributes: attributes)
        }
    }
    
    // Sets note's properties by data from text fields and imageView
    private func configureNote() {
        let title = titleTextField.text!
        let body = bodyTextView.text!
        let noteImage = imageImageView.image?.jpegData(compressionQuality: 1)
        
        note?.title = title
        note?.body = body
        note?.image = noteImage
    }
    
    // MARK: - Dismiss keyboard
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - Set note's body text style
    
    private func presentTextStyleAlert() {
        let ac = UIAlertController(title: "TEXT STYLE", message: "Choose text style", preferredStyle: .actionSheet)
        
        let largeFontAction = UIAlertAction(title: TextStyle.largeFont.rawValue, style: .default) { [weak self] (action) in
            let attributes: [NSAttributedString.Key : Any] = [.font: UIFont.systemFont(ofSize: 20)]
            self?.editTextStyle(with: attributes)
            self?.note?.textStyle = TextStyle.largeFont.rawValue
        }
        
        let mediumFontAction = UIAlertAction(title: TextStyle.mediumFont.rawValue, style: .default) { [weak self] (action) in
            let attributes: [NSAttributedString.Key : Any] = [.font: UIFont.systemFont(ofSize: 15)]
            self?.editTextStyle(with: attributes)
            self?.note?.textStyle = TextStyle.mediumFont.rawValue
        }
        
        let smallFontAction = UIAlertAction(title: TextStyle.smallFont.rawValue, style: .default) { [weak self] (action) in
            let attributes: [NSAttributedString.Key : Any] = [.font: UIFont.systemFont(ofSize: 10)]
            self?.editTextStyle(with: attributes)
            self?.note?.textStyle = TextStyle.smallFont.rawValue
        }
        
        let italicFontAction = UIAlertAction(title: TextStyle.italicFont.rawValue, style: .default) { [weak self] (action) in
            let attributes: [NSAttributedString.Key : Any] = [.font: UIFont.italicSystemFont(ofSize: 15)]
            self?.editTextStyle(with: attributes)
            self?.note?.textStyle = TextStyle.italicFont.rawValue
        }
        
        let boldFontAction = UIAlertAction(title: TextStyle.boldFont.rawValue, style: .default) { [weak self] (action) in
            let attributes: [NSAttributedString.Key : Any] = [.font: UIFont.boldSystemFont(ofSize: 15)]
            self?.editTextStyle(with: attributes)
            self?.note?.textStyle = TextStyle.boldFont.rawValue
        }
        
        let chalkdusterFontAction = UIAlertAction(title: TextStyle.chalkdusterFont.rawValue, style: .default) { [weak self] (action) in
            let attributes: [NSAttributedString.Key : Any] = [.font: UIFont.init(name: "chalkduster", size: 15) ?? UIFont.systemFont(ofSize: 15)]
            self?.editTextStyle(with: attributes)
            self?.note?.textStyle = TextStyle.chalkdusterFont.rawValue
        }
        
        let noteworthyFontAction = UIAlertAction(title: TextStyle.noteworthyFont.rawValue, style: .default) { [weak self] (action) in
            let attributes: [NSAttributedString.Key : Any] = [.font: UIFont.init(name: "noteworthy", size: 15) ?? UIFont.systemFont(ofSize: 15)]
            self?.editTextStyle(with: attributes)
            self?.note?.textStyle = TextStyle.noteworthyFont.rawValue
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        ac.addAction(largeFontAction)
        ac.addAction(mediumFontAction)
        ac.addAction(smallFontAction)
        ac.addAction(italicFontAction)
        ac.addAction(boldFontAction)
        ac.addAction(chalkdusterFontAction)
        ac.addAction(noteworthyFontAction)
        ac.addAction(cancelAction)
        
        present(ac, animated: true)
    }
    
    private func editTextStyle(with attributes: [NSAttributedString.Key : Any]) {
        guard let  stringToEdit = bodyTextView.text else { return }
        bodyTextView.attributedText = NSAttributedString(string: stringToEdit, attributes: attributes)
    }
}

// MARK: - UIImagePicker

extension DetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        DispatchQueue.main.async {
            self.imageImageView.image = image
        }
    }
}

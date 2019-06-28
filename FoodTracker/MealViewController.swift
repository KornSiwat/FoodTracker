//
//  ViewController.swift
//  FoodTracker
//
//  Created by Siwat Ponpued on 6/25/19.
//  Copyright © 2019 Siwat Ponpued. All rights reserved.
//

import UIKit
import os.log

class MealViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancel: UIBarButtonItem!

    var meal: Meal?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
}

// MARK: - Setup
private extension MealViewController {
    func setupView() {
        setupButton()
        setupMealView()
        updateSaveButtonState()
    }

    func setupButton() {
        nameTextField.delegate = self
    }

    func setupMealView() {
        guard let meal = meal else { return }

        navigationItem.title = meal.name
        nameTextField.text = meal.name
        photoImageView.image = meal.photo
        ratingControl.rating = meal.rating
    }
}

// MARK: - Actions
extension MealViewController {
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        nameTextField.resignFirstResponder()
        presentImagePickerScreen()
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let isPresentingInAddMealMode = presentingViewController is UINavigationController

        if isPresentingInAddMealMode {
            dismiss(animated: true)
        } else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        } else {
            fatalError("The MealViewController is not inside a navigation controller.")
        }
    }

    func presentImagePickerScreen() {
        let imagePickerController = UIImagePickerController()

        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self

        present(imagePickerController, animated: true)
    }
}

// MARK: - Update Save Button
private extension MealViewController {
    func updateSaveButtonState() {
        let text = nameTextField.text ?? ""

        saveButton.isEnabled = !text.isEmpty
    }
}

// MARK: - UITextFieldDelegate
extension MealViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = textField.text
    }
}

// MARK: - UIImagePickerControllerDelegate
extension MealViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController
                               , didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }

        photoImageView.image = selectedImage

        dismiss(animated: true)
    }
}

// MARK: - UINavigationControllerDelegate
extension MealViewController: UINavigationControllerDelegate { }

// MARK: - Navigation
extension MealViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        guard let button = sender as? UIBarButtonItem
            , button === saveButton else {
                os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)

                return
        }

        updateMealData()
    }

    func updateMealData() {
        let name = nameTextField.text ?? ""
        let photo = photoImageView.image
        let rating = ratingControl.rating

        meal = Meal(name: name,
                    photo: photo,
                    rating: rating)
    }
}

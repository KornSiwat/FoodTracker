//
//  RatingControl.swift
//  FoodTracker
//
//  Created by Siwat Ponpued on 6/27/19.
//  Copyright © 2019 Siwat Ponpued. All rights reserved.
//

import UIKit

@IBDesignable class RatingControl: UIStackView {
    private var ratingButtons: [UIButton] = []
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButtons()
        }
    }

    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }

    var rating = 0 {
        didSet {
            updateButtonSelectionStates()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
}

// MARK: - Setup
private extension RatingControl {
    func setupButtons() {
        removeExistingButton()

        let buttons = createRatingButtons()
        buttons.forEach { configButton(button: $0) }

        updateButtonSelectionStates()
    }

    func removeExistingButton() {
        ratingButtons.forEach { button in
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }

        ratingButtons.removeAll()
    }

    func createRatingButtons() -> [UIButton] {
        let filledStar = UIImage(named: "filledStar")
        let emptyStar = UIImage(named: "emptyStar")
        let highlightedStar = UIImage(named: "highlightedStar")

        return (0..<starCount).map { _ in
            let button = UIButton()

            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])

            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true

            return button
        }
    }

    func configButton(button: UIButton) {
        addArrangedSubview(button)
        ratingButtons.append(button)
        button.addTarget(self,
                         action: #selector(RatingControl.ratingButtonTapped(button:)),
                         for: .touchUpInside)
    }
}

// MARK: - Button Action
private extension RatingControl {
    @objc func ratingButtonTapped(button: UIButton) {
        guard let index = ratingButtons.firstIndex(of: button) else {
            fatalError("The button, \(button), is not in the ratingButtons array: \(ratingButtons)")
        }

        let selectedRating = index + 1
        rating = (selectedRating == rating) ? 0 : selectedRating
    }

    func updateButtonSelectionStates() {
        ratingButtons.enumerated().forEach { (index, button) in
            button.isSelected = index < rating
        }
    }
}

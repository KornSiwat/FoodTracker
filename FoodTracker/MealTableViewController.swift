//
//  MealTableViewController.swift
//  FoodTracker
//
//  Created by Siwat Ponpued on 6/27/19.
//  Copyright © 2019 Siwat Ponpued. All rights reserved.
//

import UIKit
import os.log

class MealTableViewController: UITableViewController {
    var meals: [Meal] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupData()
    }
}

// MARK: - Setup
private extension MealTableViewController {
    func setupView() {
        setupEditButton()
    }

    func setupEditButton() {
        navigationItem.leftBarButtonItem = editButtonItem
    }

    func setupData() {
        setupMealData()
    }

    func setupMealData() {
        meals += loadMeals() ?? loadSampleMeals()
    }
}

// MARK: - Load Save Meal Data
private extension MealTableViewController {
    func loadSampleMeals() -> [Meal] {
        let sampleMeals = [
            (name: "Caprese Salad", photoName: "meal1", rating: 3),
            (name: "Chicken and Potatoes", photoName: "meal2", rating: 2),
            (name: "Pasta with Meatballs", photoName: "meal3", rating: 3)
        ]

        return sampleMeals.compactMap {
            Meal(name: $0.name,
                 photo: UIImage(named: $0.photoName),
                 rating: $0.rating)
        }
    }

    func saveMeals() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(meals,
                                                                 toFile: Meal.ArchiveURL.path)

        guard isSuccessfulSave else {
            os_log("Failed to save meals...", log: OSLog.default, type: .error)
            return
        }

        os_log("Meals successfully saved.", log: OSLog.default, type: .debug)
    }

    func loadMeals() -> [Meal]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Meal.ArchiveURL.path) as? [Meal]
    }
}

// MARK: - UITableViewDataSource
extension MealTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "MealTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                 for: indexPath) as! MealTableViewCell
        let meal = meals[indexPath.row]

        cell.nameLabel.text = meal.name
        cell.photoImageView.image = meal.photo
        cell.ratingControl.rating = meal.rating

        return cell
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            meals.remove(at: indexPath.row)
            saveMeals()
            tableView.deleteRows(at: [indexPath], with: .fade)
        default:
            break
        }
    }
}

// MARK: - Navigation
extension MealTableViewController {
    enum SegueIdentifier {
        static let addItem = "AddItem"
        static let showDetail = "ShowDetail"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch(segue.identifier ?? "") {
        case SegueIdentifier.addItem:
            os_log("Adding a new meal.",
                   log: OSLog.default,
                   type: .debug)
        case SegueIdentifier.showDetail:
            let mealDetailViewController = segue.destination as! MealViewController
            let selectedMealCell = sender as! MealTableViewCell
            let indexPath = tableView.indexPath(for: selectedMealCell)!
            let selectedMeal = meals[indexPath.row]

            mealDetailViewController.meal = selectedMeal
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }

    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        guard let sourceViewController = sender.source as? MealViewController
            , let meal = sourceViewController.meal else {
                return
        }

        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            meals[selectedIndexPath.row] = meal
            tableView.reloadRows(at: [selectedIndexPath],
                                 with: .none)
        } else {
            let newIndexPath = IndexPath(row: meals.count,
                                         section: 0)

            meals.append(meal)
            tableView.insertRows(at: [newIndexPath],
                                 with: .automatic)
        }

        saveMeals()
    }
}

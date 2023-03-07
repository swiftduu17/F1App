//
//  homeCollection.swift
//  F1App
//
//  Created by Arman Husic on 7/14/22.
//

import Foundation
import UIKit
import Firebase

class HomeCollection: UICollectionViewController, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
    @IBOutlet weak var cellActivityIndicator: UIActivityIndicatorView!
    
    let f1routes = F1ApiRoutes()
    var homeModel = HomeModel()
    let collectionModel = CollectionModel()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        navigationController?.delegate = self

        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "https://www.example.com")
        // The sign-in operation has to always be completed in the app.
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        actionCodeSettings.setAndroidPackageName("com.example.android",
                                                 installIfNotAvailable: false, minimumVersion: "12")
        
        
        
        // testing new race results queries
        print("Test Results Below")
        print(F1ApiRoutes.testResults(seasonYear: "2014", position: "5")
)
        
    }
    
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController == self {
            print("Showing self now")
        }
    }
    
    func recognizeTap(){
        //Looks for single or multiple taps.
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        
        if indexPath.item == 0 {
            return CGSize(width: view.frame.width * 0.99, height: view.frame.height * 0.15)

        }
        else if indexPath.item == 3 {
            return CGSize(width: view.frame.width * 0.990, height: view.frame.height * 0.30)

        }
        return CGSize(width: CGFloat((collectionView.frame.size.width / 2) - 1), height: view.frame.height * 0.30)
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myHomeCell", for: indexPath) as! myHomeCell
        
        if indexPath.item == 0 {
            cell.bottomLabel.text = ""
            cell.topLabel.text = "Enter F1 Season"
            cell.enterF1SeasonYear.isHidden = false
            cell.enterF1SeasonYear.backgroundColor = UIColor.clear
            cell.homeCellImageView.image = UIImage(named: "Screen Shot 2022-04-12 at 9.47.47 PM")
            cell.homeBaseView.backgroundColor = UIColor.clear
            cell.layer.borderWidth = 0.0
        }
        
        if indexPath.item == 1 {
            Data.whichQuery = 0
            cell.layer.borderWidth = 0.75
            cell.homeBaseView.backgroundColor = UIColor.lightGray
            cell.homeBaseView.alpha = 0.5
            cell.bottomLabel.text = "Constructors"
            cell.topLabel.isHidden = true
            cell.enterF1SeasonYear.isHidden = true
            cell.homeCellImageView.image = UIImage(named: "F1Logo")
        }
        
        if indexPath.item == 2 {
            Data.whichQuery = 1
            cell.layer.borderWidth = 0.75
            cell.homeBaseView.backgroundColor = UIColor.lightGray
            cell.homeBaseView.alpha = 0.5
            cell.bottomLabel.text = "Drivers"
            cell.topLabel.isHidden = true
            cell.enterF1SeasonYear.isHidden = true
            cell.homeCellImageView.image = UIImage(named: "teamLH")
        }
        
        if indexPath.item == 3 {
            Data.whichQuery = 2
            cell.layer.borderWidth = 0.75

            cell.homeBaseView.backgroundColor = UIColor.lightGray
            cell.homeBaseView.alpha = 0.5
            cell.bottomLabel.text = "Grand Prix"
            cell.topLabel.isHidden = true
            cell.enterF1SeasonYear.isHidden = true
            cell.homeCellImageView.image = UIImage(named: "circuitLogo")
        }
        
        if indexPath.item == 4 {
            Data.whichQuery = 3
            cell.layer.borderWidth = 0.75
            cell.homeBaseView.backgroundColor = UIColor.lightGray
            cell.homeBaseView.alpha = 0.5
            cell.bottomLabel.text = "WDC"
            cell.topLabel.text = "Top 5"
            cell.enterF1SeasonYear.isHidden = true
            cell.homeCellImageView.image = UIImage(named: "F1Logo")
        }
        
        if indexPath.item == 5 {
            Data.whichQuery = 4
            cell.layer.borderWidth = 0.75
            cell.homeBaseView.backgroundColor = UIColor.lightGray
            cell.homeBaseView.alpha = 0.5
            cell.topLabel.text = "Top 10"
            cell.bottomLabel.text = "Quali Results"
            cell.enterF1SeasonYear.isHidden = true
            cell.homeCellImageView.image = UIImage(named: "F1Logo")

        }
        
        cell.layer.borderColor = UIColor.systemRed.cgColor
        cell.layer.cornerRadius = 5
        
        return cell
    }
    
    
    

    
    
    // selecting a cell
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myHomeCell", for: indexPath) as? myHomeCell {
            dismissKeyboard()
            cell.layer.borderColor = UIColor.clear.cgColor

            // have to disable cells so that the user doesnt send multiple queries as the data loads
            if indexPath.item == 0 {
                print("THIS IS THE TITLE CELL, maybe place to select year")
            }
            if indexPath.item == 1 {
                print("Constructors cell is selected")
                Data.whichQuery = 0  
                let cell = collectionView.cellForItem(at:  [0,0]) as! myHomeCell
                homeModel.setQueryNum(activityIndicator: cellActivityIndicator, enterYear: cell.enterF1SeasonYear, homeSelf: self, cellIndex: indexPath)
            }
            if indexPath.item == 2 {
                print("Drivers cell is selected")
                Data.whichQuery = 1
                let cell = collectionView.cellForItem(at:  [0,0]) as! myHomeCell
                homeModel.setQueryNum(activityIndicator: cellActivityIndicator, enterYear: cell.enterF1SeasonYear, homeSelf: self, cellIndex: indexPath)
            }
            if indexPath.item == 3 {
                print("Circuits cell is selected")
                Data.whichQuery = 2
                let cell = collectionView.cellForItem(at:  [0,0]) as! myHomeCell
                homeModel.setQueryNum(activityIndicator: cellActivityIndicator, enterYear: cell.enterF1SeasonYear, homeSelf: self, cellIndex: indexPath)
            }
            if indexPath.item == 4 {
                print("Standings cell is selected")
                Data.whichQuery = 3
                let cell = collectionView.cellForItem(at:  [0,0]) as! myHomeCell
                homeModel.setQueryNum(activityIndicator: cellActivityIndicator, enterYear: cell.enterF1SeasonYear, homeSelf: self, cellIndex: indexPath)
            }
            if indexPath.item == 5 {
                print("Standings cell is selected")
                Data.whichQuery = 4
                let cell = collectionView.cellForItem(at:  [0,0]) as! myHomeCell
                homeModel.setQueryNum(activityIndicator: cellActivityIndicator, enterYear: cell.enterF1SeasonYear, homeSelf: self, cellIndex: indexPath)
            }
        }
        
    }
    
    
    // deselectuing a cell - hides cell
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myHomeCell", for: indexPath) as? myHomeCell {
            print("Cell deselected")
            dismissKeyboard()
            cell.homeBaseView.backgroundColor = UIColor.clear
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismissKeyboard()

        
    }
    
    
    
}
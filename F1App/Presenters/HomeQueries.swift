//
//  homeCollection.swift
//  F1App
//
//  Created by Arman Husic on 7/14/22.
//

import Foundation
import UIKit
import FirebaseCore


class HomeQueries: UICollectionViewController, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
    let f1routes = F1ApiRoutes()
    var homeModel = HomeModel()
    let collectionModel = CollectionModel()
    let firebaseDB = FirebaseDataStorage()
    let coreDataHelper = CoreDataHelper.shared
    
    var seasonYear:Int?
    var myIndexPath:Int?
    let cellBorderWidth = 2.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        navigationController?.delegate = self
//        firebaseDB.getImag(coreData: coreDataHelper, img: "WDCLogo.png")
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? FirstResults {
            // Pass data to destinationVC here
            print("prepare function fires")
            destinationVC.seasonYear = seasonYear
        }
        if let cell = collectionView.cellForItem(at:  [0,myIndexPath ?? 0]) as? hqCell {
            cell.cellActivitySpinner.stopAnimating()
            cell.cellActivitySpinner.isHidden = true
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController == self {
            print("Showing self now")
            // Team Data
            F1DataStore.constructorID.removeAll()
            F1DataStore.teamURL.removeAll()
            F1DataStore.teamNames.removeAll()
            F1DataStore.teamNationality.removeAll()
            F1DataStore.teamImgURL.removeAll()
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
            return CGSize(width: view.frame.width * 1.0, height: view.frame.height * 0.20)
        }
        else if indexPath.item == 3{
            return CGSize(width: view.frame.width * 0.90, height: view.frame.height * 0.22)
        }
        else {
            return CGSize(width: view.frame.width * 0.90, height: view.frame.height * 0.22)
        }
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    

    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myHomeCell", for: indexPath) as! hqCell
        cell.delegate = self
        
        switch indexPath.item {
        case 0:
            cell.menuButton.isHidden = false
            cell.bottomLabel.text = ""
            cell.topLabel.text = "Enter F1 Season"
            cell.enterF1SeasonYear.isHidden = false
            cell.enterF1SeasonYear.backgroundColor = UIColor.clear
            cell.homeCellImageView.image = UIImage(named: "40x40")
            cell.homeCellImageView.alpha = 0.10
            cell.homeBaseView.backgroundColor = UIColor.clear
            cell.layer.borderWidth = 0.0
            cell.cellActivitySpinner.isHidden = true
            cell.layer.cornerRadius = 20
            return cell
        case 1:
            cell.menuButton.isHidden = true
            F1DataStore.whichQuery = 0
            cell.layer.borderWidth = cellBorderWidth
            cell.layer.borderColor = UIColor.systemRed.cgColor
            cell.homeBaseView.alpha = 1.0
            cell.bottomLabel.text = "WCC"
            cell.topLabel.isHidden = true
            cell.enterF1SeasonYear.isHidden = true
            cell.homeCellImageView.image = UIImage(named: "genericF1Car")
            cell.homeCellImageView.alpha = 0.25
            cell.cellActivitySpinner.isHidden = true
            cell.layer.cornerRadius = 20
            return cell
        case 2:
            cell.menuButton.isHidden = true
            F1DataStore.whichQuery = 1
            cell.layer.borderWidth = cellBorderWidth
            cell.layer.borderColor = UIColor.systemYellow.cgColor
            cell.homeBaseView.alpha = 1.0
            cell.bottomLabel.text = "WDC"
            cell.topLabel.isHidden = true
            cell.enterF1SeasonYear.isHidden = true
            cell.homeCellImageView.image = UIImage(named: "lewis2")
            cell.homeCellImageView.alpha = 0.25
            cell.cellActivitySpinner.isHidden = true
            cell.layer.cornerRadius = 20
            return cell
        case 3:
            cell.menuButton.isHidden = true
            F1DataStore.whichQuery = 2
            cell.layer.borderWidth = cellBorderWidth
            cell.layer.borderColor = UIColor.systemGray.cgColor
            cell.homeBaseView.alpha = 1.0
            cell.bottomLabel.text = "GP"
            cell.topLabel.isHidden = true
            cell.enterF1SeasonYear.isHidden = true
            cell.homeCellImageView.image = UIImage(named: "circuitLogo")
            cell.homeCellImageView.alpha = 0.5
            cell.cellActivitySpinner.isHidden = true
            cell.layer.cornerRadius = 20
            return cell

        case 4:
            cell.menuButton.isHidden = true
            F1DataStore.whichQuery = 3
            cell.layer.borderWidth = cellBorderWidth
            cell.layer.borderColor = UIColor.systemRed.cgColor
            cell.homeBaseView.alpha = 1.0
            cell.bottomLabel.text = "WDC"
            cell.topLabel.isHidden = true
            cell.enterF1SeasonYear.isHidden = true
            cell.homeCellImageView.image = UIImage(named: "WDCLogo")
            cell.homeCellImageView.alpha = 1.0
            cell.cellActivitySpinner.isHidden = true
            cell.layer.cornerRadius = 20
            return cell

        default:
            cell.menuButton.isHidden = true
            cell.enterF1SeasonYear.isHidden = true
            cell.topLabel.isHidden = true
            cell.homeCellImageView.image = UIImage(named: "lewis")
            cell.cellActivitySpinner.isHidden = false
            cell.layer.cornerRadius = 20
            return cell
        }
    }
    
    
    

    
    
    // selecting a cell
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dismissKeyboard()
        myIndexPath = indexPath.item
        // have to disable cells so that the user doesnt send multiple queries as the data loads
        if indexPath.item == 0 {
            print("THIS IS THE TITLE CELL, maybe place to select year")
           
        }
        if indexPath.item == 1 {
            if let cell = collectionView.cellForItem(at:  [0,0]) as? hqCell {
                print("Constructors cell is selected")
                F1DataStore.whichQuery = 0
                cell.layer.borderColor = UIColor.clear.cgColor
                homeModel.setQueryNum(enterYear: cell.enterF1SeasonYear, homeSelf: self, cellIndex: indexPath)
            }
        }
        if indexPath.item == 2 {
            if let cell = collectionView.cellForItem(at:  [0,0]) as? hqCell {
                print("Drivers cell is selected")
                F1DataStore.whichQuery = 1
                cell.layer.borderColor = UIColor.clear.cgColor

                seasonYear = Int(cell.enterF1SeasonYear.text)
                homeModel.setQueryNum(enterYear: cell.enterF1SeasonYear, homeSelf: self, cellIndex: indexPath)
            }
        }
        if indexPath.item == 3 {
            if let cell = collectionView.cellForItem(at:  [0,0]) as? hqCell {
                print("Circuits cell is selected")
                F1DataStore.whichQuery = 2
                // set season year
                seasonYear = Int(cell.enterF1SeasonYear.text)
                cell.layer.borderColor = UIColor.clear.cgColor
                homeModel.setQueryNum(enterYear: cell.enterF1SeasonYear, homeSelf: self, cellIndex: indexPath)
            }
        }
        if indexPath.item == 4 {
            if let cell = collectionView.cellForItem(at:  [0,0]) as? hqCell {
                print("WDC cell is selected")
                F1DataStore.whichQuery = 3
                cell.layer.borderColor = UIColor.clear.cgColor

                seasonYear = Int(cell.enterF1SeasonYear.text)
                homeModel.setQueryNum(enterYear: cell.enterF1SeasonYear, homeSelf: self, cellIndex: indexPath)
            }
        }
        
        // This check makes sure the first cell does not animate when being pressed
        if myIndexPath != 0 {
            if let cell = collectionView.cellForItem(at:  indexPath) as? hqCell {
                DispatchQueue.main.async {
                    cell.cellActivitySpinner.startAnimating()
                    cell.cellActivitySpinner.isHidden = false
                }
                
            }
        }
       
        
    }
    
    
    // deselectuing a cell - hides cell
//    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//
//    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismissKeyboard()
        if let cell = collectionView.cellForItem(at:  [0,0]) as? hqCell {
            cell.cellActivitySpinner.stopAnimating()
            cell.cellActivitySpinner.isHidden = true
        }
    }
    
    
    
}

extension HomeQueries: CollectionViewCellDelegate {
    func menuButtonPressed(cell: UICollectionViewCell) {
        // perform segue or any other action
        performSegue(withIdentifier: "menuTransition", sender: cell)
    }
}

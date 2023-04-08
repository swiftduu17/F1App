//
//  ConstructorsCollection_VC.swift
//  F1App
//
//  Created by Arman Husic on 4/12/22.
//

import Foundation
import UIKit
import MapKit

class ResultsCollection : UICollectionViewController, UICollectionViewDelegateFlowLayout, MKMapViewDelegate {

    var collectionmodel = CollectionModel()
    let resultsModel = ResultsModel()
    let myData = Data()
    
    var seasonYear:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // Number of cells from model
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionmodel.howManyCells()
    }
    
    
    // Size of cells from model
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionmodel.cellSizeFromQuery(view: view)
    }
    
    // setup for each individual cell, setting mapview delegate to each cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! myCell
        
        cell.F1MapView.delegate = self
        
        collectionmodel.cellViewFormat(cell: cell)
        collectionmodel.cellLogic(cell: cell, indexPath: indexPath, mapView: cell.F1MapView)
        cell.cellImage.layer.cornerRadius = 15
        cell.activitySpinner.isHidden = true
        return cell
    }
    
    // selecting a cell
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellIndexPath = indexPath.item
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as? myCell {
            print("Cell is selected")
            cell.activitySpinner.isHidden = false
            cell.activitySpinner.startAnimating()
            
            cell.getCellIndexPath(myCell: cell, myCellIP: cellIndexPath)
            if Data.whichQuery == 2 {
                print("SEASON YEAR BELOW")
                print(seasonYear)
                F1ApiRoutes.singleRaceResults(seasonYear: seasonYear!, roundNumber: cellIndexPath)
               
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.75 ){
                    self.performSegue(withIdentifier: "closerLookTransition", sender: self)
                }
            } else {
                resultsModel.loadResults(myself: self)
            }
        }
    }
    // deselectuing a cell - hides cell
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as? myCell {
            print("Cell deselected")
            cell.self.isHidden = false
            cell.activitySpinner.stopAnimating()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        myData.removeAllCellData()
    }
    
    
    

    
}


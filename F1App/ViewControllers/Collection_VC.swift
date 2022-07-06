//
//  ConstructorsCollection_VC.swift
//  F1App
//
//  Created by Arman Husic on 4/12/22.
//

import Foundation
import UIKit
import WebKit
import MapKit

class Collection_VC : UICollectionViewController, UICollectionViewDelegateFlowLayout, MKMapViewDelegate {

    let collectionmodel = CollectionModel()


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

        return cell
    }
    
    // selecting a cell
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellIndexPath = indexPath.item
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as? myCell {
            print("Cell is selected")
            cell.getCellIndexPath(myCell: cell, myCellIP: cellIndexPath)
            performSegue(withIdentifier: "resultsTransition", sender: self)
        }
        
    }
    // deselectuing a cell - hides cell
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as? myCell {
            print("Cell deselected")
            cell.self.isHidden = false
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        collectionmodel.removeAllCellData()
        
    }
    
    
    

    
}


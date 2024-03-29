//
//  myCell.swift
//  F1App
//
//  Created by Arman Husic on 3/27/22.
//

import Foundation
import UIKit
import MapKit

class frCell: UICollectionViewCell {
    
    
    @IBOutlet weak var cellBaseView: UIView!
    @IBOutlet weak var topCellLabel: UILabel!
    @IBOutlet weak var bottomCellLabel: UILabel!
    @IBOutlet weak var bottomCellLabel2: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var F1MapView: MKMapView!
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var cellImage2: UIImageView!
    
    
    var myCellIndexPath:Int?
    
    func getCellIndexPath(myCell:frCell, myCellIP: Int){
        myCellIndexPath = myCellIP
        F1DataStore.cellIndexPassed = myCellIndexPath
    }
    
   
    
    
}

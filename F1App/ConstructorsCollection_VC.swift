//
//  ConstructorsCollection_VC.swift
//  F1App
//
//  Created by Arman Husic on 4/12/22.
//

import Foundation
import UIKit

class ConstructorsCollection_VC : UICollectionViewController, UICollectionViewDelegateFlowLayout {

    let myData = Data()
    let names = Data.teamNames
    let nationalities = Data.teamNationality
    let teamWikis = Data.teamURL
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        
        
        
    }
        
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Data.teamNames.count
         
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let availableWidth = view.frame.width
            let availableHeight = view.frame.height
            
        return CGSize(width: availableWidth * 0.90, height: availableHeight * 0.50)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! myCell
        
        
        
        
        cell.topCellLabel.text = names[indexPath.item]
        cell.layer.borderWidth = 2
        cell.bottomCellLabel.text = nationalities[indexPath.item]
        cell.layer.borderColor = CGColor.init(red: 123, green: 123, blue: 123, alpha: 0.0)
        
        cell.cellImage.image = UIImage.strokedCheckmark
        let url = URL(string: teamWikis[indexPath.item]!)!
        cell.webView.load(URLRequest(url: url ))
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        
        print(names[indexPath.item])
        
    
       
    }

    
    

    
}

//
//  TodBiteViewController.swift
//  Faby
//
//  Created by Batch - 1 on 13/01/25.
//

import UIKit

class TodBiteViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var CollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let nib = UINib(nibName: "TodBitCollectionViewCell", bundle: nil)
        CollectionView.register(nib, forCellWithReuseIdentifier: "cell")
    }
    

    @IBAction func segmentedControlTapped(_ sender: UISegmentedControl) {
        let select = segmentedControl.selectedSegmentIndex
        switch select{
        case 0:
            CollectionView.isHidden = false
        case 1:
            CollectionView.isHidden = true
        default :
            CollectionView.isHidden = false
        }
    
        
    }
    

}

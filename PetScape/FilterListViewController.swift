//
//  FilterListViewController.swift
//  PetScape
//
//  Created by David Warner on 6/20/16.
//  Copyright © 2016 drw. All rights reserved.
//

import UIKit

class FilterListViewController: UIViewController {
	
	var collectionView: UICollectionView!
	
	init() {
		super.init(nibName: nil, bundle: nil)
		title = NSLocalizedString("Filters", comment: "")
		
		let layout = UICollectionViewFlowLayout()
		layout.sectionInset = UIEdgeInsetsZero
		layout.minimumLineSpacing = 0
		layout.minimumInteritemSpacing = 0
		layout.estimatedItemSize = CGSize(width: 200, height: 10)
		collectionView = UICollectionView(frame: CGRect.zero,
		                                  collectionViewLayout: layout)
		collectionView.alwaysBounceVertical = false
		self.view = collectionView
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		
		collectionView.delegate = self
//		collectionView.dataSource = self
		
		navigationController?.hidesBarsOnSwipe = false
		addConstraints()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
	}
	
	private func addConstraints() {
		collectionView.autoPinEdgesToSuperviewEdges()
	}
}

extension FilterListViewController: UICollectionViewDelegate {
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		collectionView.deselectItemAtIndexPath(indexPath, animated: false)
	}
}

//extension FilterListViewController: UICollectionViewDataSource {
//	
//	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//		return 6
//	}
//	
//	func collectionView(collectionView: UICollectionView,
//	                    cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//		
//	}
//}

//
//
//extension FilterListViewController: UICollectionViewDataSource {
//	
//	func tableView(tableView: UITableView,
//	               cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//		if indexPath.row == 0 {
//			let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(FilterLocationCell.self), forIndexPath: indexPath) as! FilterLocationCell
//			cell.label.text = "Location"
//			return cell
//		} else {
//			let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(SimpleFilterCell.self), forIndexPath: indexPath) as! SimpleFilterCell
//			cell.accessoryType = .DisclosureIndicator
//			cell.tintColor = .blackColor()
//			
//			switch indexPath.row {
//			case 1:
//				cell.label.text = "Animal"
//			case 2:
//				cell.label.text = "Breed"
//			case 3:
//				cell.label.text = "Size"
//			case 4:
//				cell.label.text = "Sex"
//			case 5:
//				cell.label.text = "Age"
//			default: return cell
//			}
//			return cell
//		}
//	}
//	
//	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		return 6
//	}
//}

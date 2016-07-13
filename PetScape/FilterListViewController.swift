//
//  FilterListViewController.swift
//  PetScape
//
//  Created by David Warner on 6/20/16.
//  Copyright © 2016 drw. All rights reserved.
//

import UIKit
import ReactiveCocoa

protocol FilterListViewControllerDelegate: class {
	func rowSelected()
}

class FilterListViewController: UIViewController {
	
	var collectionView: UICollectionView!
	let filterManager: FilterManager
	let locationManager: LocationManager
	weak var delegate: FilterListViewControllerDelegate?
	
	init(filterManager: FilterManager,
	     locationManager: LocationManager) {
		self.filterManager = filterManager
		self.locationManager = locationManager
		super.init(nibName: nil, bundle: nil)
		title = NSLocalizedString("Filters", comment: "")
		
		let layout = UICollectionViewFlowLayout()
		layout.sectionInset = UIEdgeInsetsMake(10, 0, 0, 0)
		layout.minimumLineSpacing = 0
		layout.minimumInteritemSpacing = 0
		layout.estimatedItemSize = CGSize(width: 200, height: 10)
		collectionView = UICollectionView(frame: CGRect.zero,
		                                  collectionViewLayout: layout)
		collectionView.alwaysBounceVertical = false
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		view = UIView()
		
		collectionView.delegate = self
		collectionView.dataSource = self
		collectionView.registerClass(TextfieldCell.self, forCellWithReuseIdentifier: NSStringFromClass(TextfieldCell.self))
		collectionView.registerClass(SimpleTextCell.self, forCellWithReuseIdentifier: NSStringFromClass(SimpleTextCell.self))
		view.addSubview(collectionView)
		
		collectionView.backgroundColor = .lightGrayColor()
		
		view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FilterListViewController.viewTapped)))
		
		navigationController?.hidesBarsOnSwipe = false
		addConstraints()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		filterManager
			.filter
			.signal
			.skipRepeats(==)
			.observeOn(UIScheduler())
			.observeNext { [unowned self] _ in
				self.collectionView.reloadData()
		}
	}
	
	private func addConstraints() {
		collectionView.autoPinEdgesToSuperviewEdges()
	}
	
	func viewTapped() {
		view.endEditing(true)
	}
}

extension FilterListViewController: UICollectionViewDelegate {
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		collectionView.deselectItemAtIndexPath(indexPath, animated: false)
		if indexPath.section == 1 {
			delegate?.rowSelected()
		}
	}
}

extension FilterListViewController: UICollectionViewDataSource {
	
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 2
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return section == 0 ? 1 : 5
	}
	
	func collectionView(collectionView: UICollectionView,
	                    cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		
		if indexPath.section == 0 {
			let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(TextfieldCell.self), forIndexPath: indexPath) as! TextfieldCell
			if case .Some(let location) = locationManager.locationStatusProperty.value {
				cell.textField.text = location
				cell.textField.delegate = self
			}
			return cell
		} else {
			let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(SimpleTextCell.self), forIndexPath: indexPath) as! SimpleTextCell
			cell.accessoryImageView.image = UIImage(named: "arrow-right")?.imageWithRenderingMode(.AlwaysTemplate)
			cell.accessoryImageView.tintColor = .darkGrayColor()
			switch indexPath.row {
			case 0:
				cell.leftLabel.text = "Animal"
				cell.rightLabel.text = filterManager.filter.value.animal?.rawValue ?? "Any"
			case 1:
				cell.leftLabel.text = "Breed"
				cell.rightLabel.text = filterManager.filter.value.breed ?? "Any"
			case 2:
				cell.leftLabel.text = "Size"
				cell.rightLabel.text = filterManager.filter.value.size?.rawValue ?? "Any"
			case 3:
				cell.leftLabel.text = "Sex"
				cell.rightLabel.text = filterManager.filter.value.sex?.rawValue ?? "Any"
			case 4:
				cell.leftLabel.text = "Age"
				cell.rightLabel.text = filterManager.filter.value.age?.rawValue ?? "Any"
			default: return cell
			}
			return cell
		}
	}
}

extension FilterListViewController: UICollectionViewDelegateFlowLayout {
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		return CGSize(width: view.frame.width, height: 50)
	}
}

extension FilterListViewController: UITextFieldDelegate {
	
	func textFieldDidEndEditing(textField: UITextField) {
		guard let trimmed = textField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) else { return }
		if trimmed.characters.count > 0 {
			locationManager.forceSetLocation(trimmed)
		}
	}
}

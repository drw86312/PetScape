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
	func rowSelected(field: FilterField)
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
		collectionView.delaysContentTouches = true
		collectionView.registerClass(TextfieldCell.self, forCellWithReuseIdentifier: NSStringFromClass(TextfieldCell.self))
		collectionView.registerClass(SimpleTextCell.self, forCellWithReuseIdentifier: NSStringFromClass(SimpleTextCell.self))
		view.addSubview(collectionView)
		
		collectionView.backgroundColor = UIColor(color: .MediumGray)
				
		navigationController?.hidesBarsOnSwipe = false
		addConstraints()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		filterManager
			.filter
			.producer
			.skipRepeats(==)
			.observeOn(UIScheduler())
			.takeUntil(rac_WillDeallocSignalProducer())
			.startWithNext { [unowned self] _ in
				self.collectionView.reloadData()
		}
	}

	private func addConstraints() {
		collectionView.autoPinEdgesToSuperviewEdges()
	}
	
	deinit {
		print("Disposing \(self)")
	}
}

extension FilterListViewController: UICollectionViewDelegate {
	
	func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
		let cell = collectionView.cellForItemAtIndexPath(indexPath)
		cell?.contentView.backgroundColor = UIColor(color: .MediumGray)
	}
	
	func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
		let cell = collectionView.cellForItemAtIndexPath(indexPath)
		cell?.contentView.backgroundColor = UIColor(color: .LightGray)
	}
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//		let cell = collectionView.cellForItemAtIndexPath(indexPath)
//		cell?.contentView.backgroundColor = .lightGrayColor()
		
//		collectionView.deselectItemAtIndexPath(indexPath, animated: false)
		if indexPath.section == 1 {
			delegate?.rowSelected(FilterField.all[indexPath.row])
		}
	}
}

extension FilterListViewController: UICollectionViewDataSource {
	
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 2
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return section == 0 ? 1 : FilterField.all.count
	}
	
	func collectionView(collectionView: UICollectionView,
	                    cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		
		if indexPath.section == 0 {
			let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(TextfieldCell.self), forIndexPath: indexPath) as! TextfieldCell
			if case .Some(let location) = locationManager.locationStatusProperty.value {
				cell.textField.text = location
				cell.textField.delegate = self
				cell.textField.returnKeyType = .Done
			}
			return cell
		} else {
			let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(SimpleTextCell.self), forIndexPath: indexPath) as! SimpleTextCell
			cell.accessoryImageView.image = UIImage(named: "arrow-right")?.imageWithRenderingMode(.AlwaysTemplate)
			cell.accessoryImageView.tintColor = .darkGrayColor()
			cell.leftLabel.text = FilterField.all[indexPath.row].rawValue
			switch indexPath.row {
			case 0:
				cell.rightLabel.text = filterManager.filter.value.animal?.titleString ?? "Any"
			case 1:
				cell.rightLabel.text = filterManager.filter.value.breed ?? "Any"
			case 2:
				cell.rightLabel.text = filterManager.filter.value.size?.titleString ?? "Any"
			case 3:
				cell.rightLabel.text = filterManager.filter.value.sex?.titleString ?? "Any"
			case 4:
				cell.rightLabel.text = filterManager.filter.value.age?.titleString ?? "Any"
			case 5:
				if let hasPhotos = filterManager.filter.value.hasPhotos {
					cell.rightLabel.text = hasPhotos ? "Yes" : "No"
				} else {
					cell.rightLabel.text = "Any"
				}
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
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	func textFieldDidEndEditing(textField: UITextField) {
		guard let trimmed = textField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) else { return }
		if trimmed.characters.count > 0 {
			locationManager.forceSetLocation(trimmed)
		}
	}
}

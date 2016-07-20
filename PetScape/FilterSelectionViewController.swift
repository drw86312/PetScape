//
//  FilterSelectionViewController.swift
//  PetScape
//
//  Created by David Warner on 7/12/16.
//  Copyright © 2016 drw. All rights reserved.
//

import UIKit
import ReactiveCocoa
import PureLayout

protocol FilterSelectionViewControllerDelegate: class {
//	func filterRowSelected()
	
}

class FilterSelectionViewController: UIViewController {
	
	var collectionView: UICollectionView!
	let filterField: FilterField
	let filterManager: FilterManager
	weak var delegate: FilterSelectionViewControllerDelegate?
	var breeds: [String] = []
	let spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
	
	init(field: FilterField,
	     filterManager: FilterManager) {
		self.filterField = field
		self.filterManager = filterManager
		super.init(nibName: nil, bundle: nil)
		
		let layout = UICollectionViewFlowLayout()
		layout.sectionInset = UIEdgeInsetsZero
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
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func loadView() {
		view = UIView()
		
		collectionView.delegate = self
		collectionView.dataSource = self
		collectionView.registerClass(SimpleTextCell.self,
		                             forCellWithReuseIdentifier: NSStringFromClass(SimpleTextCell.self))
		view.addSubview(collectionView)
		collectionView.backgroundColor = UIColor(color: .MediumGray)
		
		navigationController?.hidesBarsOnSwipe = false
		
		spinner.hidesWhenStopped = true
		spinner.color = UIColor(color: .MainColor)
		view.addSubview(spinner)
		
		addConstraints()
	}
	
	private func addConstraints() {
		collectionView.autoPinEdgesToSuperviewEdges()
		spinner.autoCenterInSuperview()
	}
}

extension FilterSelectionViewController: UICollectionViewDelegate {
	
	func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
		let cell = collectionView.cellForItemAtIndexPath(indexPath) as! SimpleTextCell
		cell.accessoryImageView.image = UIImage(named: "checkmark")?.imageWithRenderingMode(.AlwaysTemplate)
	}
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		let cell = collectionView.cellForItemAtIndexPath(indexPath) as! SimpleTextCell
		cell.accessoryImageView.image = UIImage(named: "checkmark-filled")?.imageWithRenderingMode(.AlwaysTemplate)
		
		var age = filterManager.filter.value.age
		var animal = filterManager.filter.value.animal
		var size = filterManager.filter.value.size
		var sex = filterManager.filter.value.sex
		var breed = filterManager.filter.value.breed
		var hasPhotos = filterManager.filter.value.hasPhotos

		switch filterField {
		case .Age:
			age = Age.all[indexPath.row]
		case .Animal:
			animal = Animal.all[indexPath.row]
		case .Size:
			size = Size.all[indexPath.row]
		case .Sex:
			sex = Sex.all[indexPath.row]
		case .Breed:
			breed = breeds[indexPath.row]
		case .HasPhotos:
			hasPhotos = indexPath.row == 0
		}
		
		let filter = Filter(animal: animal,
		                    breed: breed,
		                    size: size,
		                    sex: sex,
		                    age: age,
		                    hasPhotos: hasPhotos)
		
		if filter != filterManager.filter.value {
			filterManager.filter.value = filter
		}
	}
}

extension FilterSelectionViewController: UICollectionViewDataSource {
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		switch self.filterField {
		case .Age:
			return Age.all.count
		case .Animal:
			return Animal.all.count
		case .Size:
			return Size.all.count
		case .Sex:
			return Sex.all.count
		case .Breed:
			return breeds.count
		case .HasPhotos:
			return 2
		}
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(SimpleTextCell.self), forIndexPath: indexPath) as! SimpleTextCell
		
		var text: String {
			switch self.filterField {
			case .Age:
				return Age.all[indexPath.row].titleString
			case .Animal:
				return Animal.all[indexPath.row].titleString
			case .Size:
				return Size.all[indexPath.row].titleString
			case .Sex:
				return Sex.all[indexPath.row].titleString
			case .Breed:
				return breeds[indexPath.row]
			case .HasPhotos:
				return indexPath.row == 0 ? "Yes" : "No"
			}
		}
		cell.leftLabel.text = text
		cell.accessoryImageView.image = UIImage(named: "checkmark")?.imageWithRenderingMode(.AlwaysTemplate)
		cell.accessoryImageView.tintColor = UIColor(color: .MainColor)

		return cell
	}
}

extension FilterSelectionViewController: UICollectionViewDelegateFlowLayout {
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		return CGSize(width: view.frame.width, height: 50)
	}
}



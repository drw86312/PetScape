//
//  FilterSelectionViewController.swift
//  PetScape
//
//  Created by David Warner on 7/12/16.
//  Copyright © 2016 drw. All rights reserved.
//

import UIKit
import ReactiveCocoa

protocol FilterSelectionViewControllerDelegate: class {
	func filterRowSelected()
	
}

class FilterSelectionViewController: UIViewController {
	
	var collectionView: UICollectionView!
	let filterManager: FilterManager
	weak var delegate: FilterSelectionViewControllerDelegate?
	
	init(filterManager: FilterManager) {
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
	
	override func loadView() {
		view = UIView()
		
		collectionView.delegate = self
		collectionView.registerClass(SimpleTextCell.self, forCellWithReuseIdentifier: NSStringFromClass(SimpleTextCell.self))
		view.addSubview(collectionView)
		
		collectionView.backgroundColor = .lightGrayColor()
		
		view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FilterListViewController.viewTapped)))
		
		navigationController?.hidesBarsOnSwipe = false
		addConstraints()
	}
	
	private func addConstraints() {
		collectionView.autoPinEdgesToSuperviewEdges()
	}
}

extension FilterSelectionViewController: UICollectionViewDelegate {
	
}



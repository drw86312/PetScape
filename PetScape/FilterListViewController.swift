//
//  FilterListViewController.swift
//  PetScape
//
//  Created by David Warner on 6/20/16.
//  Copyright © 2016 drw. All rights reserved.
//

import UIKit

class FilterListViewController: UIViewController {
	
	let tableView = UITableView(frame: CGRectZero, style: .Plain)
	
	init() {
		super.init(nibName: nil, bundle: nil)
		title = NSLocalizedString("Filters", comment: "")
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		view = UIView()
		view.backgroundColor = .blackColor()
		
		tableView.registerClass(FilterLocationCell.self,
		                        forCellReuseIdentifier: NSStringFromClass(FilterLocationCell.self))
		tableView.registerClass(SimpleFilterCell.self,
		                        forCellReuseIdentifier: NSStringFromClass(SimpleFilterCell.self))
		tableView.separatorStyle = .None
		tableView.backgroundColor = .blackColor()
		tableView.dataSource = self
		tableView.delegate = self
		tableView.keyboardDismissMode = .OnDrag
		view.addSubview(tableView)
		
		addConstraints()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
	}
	
	private func addConstraints() {
		tableView.autoPinEdgesToSuperviewEdges()
	}
}

extension FilterListViewController: UITableViewDelegate {
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: false)
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 60
	}
}


extension FilterListViewController: UITableViewDataSource {
	
	func tableView(tableView: UITableView,
	               cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if indexPath.row == 0 {
			let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(FilterLocationCell.self), forIndexPath: indexPath) as! FilterLocationCell
			cell.label.text = "Location"
			return cell
		} else {
			let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(SimpleFilterCell.self), forIndexPath: indexPath) as! SimpleFilterCell
			cell.accessoryType = .DisclosureIndicator
			cell.tintColor = .blackColor()
			
			switch indexPath.row {
			case 1:
				cell.label.text = "Animal"
			case 2:
				cell.label.text = "Breed"
			case 3:
				cell.label.text = "Size"
			case 4:
				cell.label.text = "Sex"
			case 5:
				cell.label.text = "Age"
			default: return cell
			}
			return cell
		}
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 6
	}
}

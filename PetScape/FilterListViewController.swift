//
//  FilterListViewController.swift
//  PetScape
//
//  Created by David Warner on 6/20/16.
//  Copyright © 2016 drw. All rights reserved.
//

import UIKit

class FilterListViewController: UIViewController {
	
	let tableView = UITableView(frame: CGRect.zero, style: .plain)
	
	init() {
		super.init(nibName: nil, bundle: nil)
		title = NSLocalizedString("Filters", comment: "")
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		view = UIView()
		view.backgroundColor = .black()
		
		tableView.register(FilterLocationCell.self,
		                        forCellReuseIdentifier: NSStringFromClass(FilterLocationCell.self))
		tableView.register(SimpleFilterCell.self,
		                        forCellReuseIdentifier: NSStringFromClass(SimpleFilterCell.self))
		tableView.separatorStyle = .none
		tableView.backgroundColor = .black()
		tableView.dataSource = self
		tableView.delegate = self
		tableView.keyboardDismissMode = .onDrag
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
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: false)
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}
}


extension FilterListViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView,
	               cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if (indexPath as NSIndexPath).row == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(FilterLocationCell.self), for: indexPath) as! FilterLocationCell
			cell.label.text = "Location"
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SimpleFilterCell.self), for: indexPath) as! SimpleFilterCell
			cell.accessoryType = .disclosureIndicator
			cell.tintColor = .black()
			
			switch (indexPath as NSIndexPath).row {
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
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 6
	}
}

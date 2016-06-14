//
//  StreamViewController.swift
//  PetScape
//
//  Created by David Warner on 5/17/16.
//  Copyright © 2016 drw. All rights reserved.
//

import PureLayout
import ReactiveCocoa
import WebImage
import UIKit

class StreamViewController: UIViewController {
	
	let viewModel = StreamViewModel()
	let tableView = UITableView(frame: CGRectZero, style: .Plain)
	
	init() {
		super.init(nibName: nil, bundle: nil)
		title = NSLocalizedString("Pets", comment: "")
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		view = UIView()
		view.backgroundColor = .whiteColor()
		
		tableView.delegate = self
		tableView.dataSource = self
		tableView.rowHeight = 420.0
		tableView.registerClass(LargePetCell.self,
		                        forCellReuseIdentifier: NSStringFromClass(LargePetCell.self))
		view.addSubview(tableView)
		
		addConstraints()
	}
	
	private func addConstraints() {
		tableView.autoPinEdgesToSuperviewEdges()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		let endpoint = Endpoint<Pet>.findPets("60606")
		viewModel
			.loadNext?
			.apply(endpoint)
			.start { [unowned self] event in
				if case .Next = event {
					self.tableView.reloadData()
				}
		}
	}
}

extension StreamViewController: UITableViewDelegate {
	
}

extension StreamViewController: UITableViewDataSource {
	
	func tableView(tableView: UITableView,
	               cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(LargePetCell.self), forIndexPath: indexPath) as! LargePetCell
		cell.pet = viewModel.content[indexPath.row]
		return cell
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.content.count
	}
}

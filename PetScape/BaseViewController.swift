//
//  BaseViewController.swift
//  PetScape
//
//  Created by David Warner on 5/17/16.
//  Copyright © 2016 drw. All rights reserved.
//

import PureLayout
import UIKit

class BaseViewController: UIViewController {
	
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
		tableView.rowHeight = 300.0
		tableView.registerClass(LargePetCell.self,
		                        forCellReuseIdentifier: NSStringFromClass(LargePetCell.self))
		view.addSubview(tableView)
		tableView.backgroundColor = .redColor()
		
		addConstraints()
	}
	
	private func addConstraints() {
		tableView.autoPinEdgesToSuperviewEdges()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		let endpoint = Endpoint<Shelter>.getShelter("IL608")
		API.fetch(endpoint) { response in
			switch response.result {
			case .Success(let pets):
				print(pets)
			case .Failure(let error):
				print(error)
			}
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
}

extension BaseViewController: UITableViewDelegate {
	
}

extension BaseViewController: UITableViewDataSource {
	
	func tableView(tableView: UITableView,
	               cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(LargePetCell.self), forIndexPath: indexPath)
		return cell
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 3
	}
}


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
	let backgroundView = TableViewBackground()
	let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
	
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
		tableView.rowHeight = 450.0
		tableView.registerClass(PetCell.self,
		                        forCellReuseIdentifier: NSStringFromClass(PetCell.self))
		tableView.backgroundView = backgroundView
		tableView.tableFooterView = UIView()
		view.addSubview(tableView)
		
		spinner.hidesWhenStopped = true
		view.addSubview(spinner)
		
		addConstraints()
	}
	
	private func addConstraints() {
		tableView.autoPinEdgesToSuperviewEdges()
		
		spinner.autoAlignAxisToSuperviewAxis(.Vertical)
		spinner.autoAlignAxis(.Horizontal, toSameAxisOfView: view, withOffset: -25)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		fetchData()
	}
	
	func fetchData() {
		viewModel
			.loadNext?
			.apply()
			.start { [unowned self] event in
				if case .Next(let content) = event {
					let paths = (self.tableView.numberOfRowsInSection(0)..<content.count)
						.map { NSIndexPath(forRow: $0, inSection: 0) }
					UIView.setAnimationsEnabled(false)
					self.tableView.insertRowsAtIndexPaths(paths, withRowAnimation: .None)
					UIView.setAnimationsEnabled(true)
				} else if case .Failed(let error) = event {
					print(error)
				}
		}
	}
}

extension StreamViewController: UITableViewDelegate {
	
	func scrollViewDidScroll(scrollView: UIScrollView) {
		let offsetY = scrollView.contentOffset.y
		let bounds = scrollView.bounds
		let size = scrollView.contentSize
		let insets = scrollView.contentInset
		guard let executing = viewModel.loadNext?.executing.value else { return }
		if ((offsetY + bounds.size.height - insets.bottom) > size.height && !executing) {
			fetchData()
		}
	}
}

extension StreamViewController: UITableViewDataSource {
	
	func tableView(tableView: UITableView,
	               cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(PetCell.self), forIndexPath: indexPath) as! PetCell
		cell.pet = viewModel.content[indexPath.row]
		print(cell)
		return cell
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.content.count
	}
}


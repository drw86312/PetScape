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
	let loadMoreSpinner = UIActivityIndicatorView(activityIndicatorStyle: .White)
	
	init() {
		super.init(nibName: nil, bundle: nil)
		title = NSLocalizedString("Pets", comment: "")
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		view = UIView()
		view.backgroundColor = .blackColor()
		
		tableView.delegate = self
		tableView.dataSource = self
		tableView.rowHeight = 450.0
		tableView.registerClass(PetCell.self,
		                        forCellReuseIdentifier: NSStringFromClass(PetCell.self))
		tableView.backgroundView = backgroundView
		backgroundView.refreshButton.addTarget(self,
		                                       action: #selector(StreamViewController.refreshButtonPressed),
		                                       forControlEvents: .TouchUpInside)
		tableView.backgroundColor = .blackColor()
		tableView.backgroundView?.backgroundColor = .blackColor()
		tableView.backgroundView?.hidden = true
		tableView.separatorStyle = .None
		view.addSubview(tableView)
		
		loadMoreSpinner.frame = CGRectMake(0, 0, 320, 65)
		loadMoreSpinner.hidesWhenStopped = true
		tableView.tableFooterView = loadMoreSpinner
		
		spinner.hidesWhenStopped = true
		view.addSubview(spinner)
		
		let button = UIButton(type: .Custom)
		button.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
		button.addTarget(self,
		                 action: #selector(StreamViewController.filterIconPressed),
		                 forControlEvents: .TouchUpInside)
		button.setImage(UIImage(named: "filter")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
		button.imageView?.tintColor = .whiteColor()
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
		
		addConstraints()
	}
	
	private func addConstraints() {
		tableView.autoPinEdgesToSuperviewEdges()
		
		spinner.autoAlignAxisToSuperviewAxis(.Vertical)
		spinner.autoAlignAxis(.Horizontal, toSameAxisOfView: view, withOffset: -25)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let loadState = viewModel
			.loadState
			.producer
			.observeOn(UIScheduler())
			.skipRepeats()
		
		loadState
			.start() { [unowned self] event in
				if case .Next(let state) = event {
					if case .LoadingNext = state { self.loadMoreSpinner.startAnimating() } else { self.loadMoreSpinner.stopAnimating() }
					if case .Loading = state { self.spinner.startAnimating() } else { self.spinner.stopAnimating() }
					if case .LoadFailed = state {
						self.backgroundView.hidden = false
						self.emptyDataSet()
					} else {
						self.backgroundView.hidden = true
					}
				}
		}
		
		viewModel
			.reload?
			.events
			.observeOn(UIScheduler())
			.observeNext { event in
				if case .Next = event {
					self.tableView.reloadData()
				}
		}
		
		viewModel
			.loadNext?
			.events
			.observeOn(UIScheduler())
			.observeNext { event in
				if case .Next(let range) = event {
					let paths = range.map { NSIndexPath(forRow: $0, inSection: 0) }
					UIView.setAnimationsEnabled(false)
					self.tableView.insertRowsAtIndexPaths(paths, withRowAnimation: .None)
					UIView.setAnimationsEnabled(true)
				}
		}
		
		DynamicProperty(object: backgroundView.refreshButton, keyPath: "enabled")
			<~ loadState.map { state -> Bool in
				if state == .LoadFailed {
					return true
				}
				return false
		}
	}
	
	private func emptyDataSet() {
		if viewModel.content.count > 0 {
			viewModel.content = []
			tableView.reloadData()
		}
	}
	
	func filterIconPressed() {
		let vc = FilterListViewController()
		navigationController?.pushViewController(vc, animated: true)
	}
	
	func refreshButtonPressed() {
		if case .Some(let location) = viewModel.locationStatus.value {
			viewModel.reload?.apply(location).start()
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
		if ((offsetY + bounds.size.height - insets.bottom) > size.height &&
			!executing &&
			viewModel.loadState.value == .Loaded) {
			if case .Some(let location) = viewModel.locationStatus.value {
				viewModel.loadNext?.apply(location).start()
			}
		}
	}
}

extension StreamViewController: UITableViewDataSource {
	
	func tableView(tableView: UITableView,
	               cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(PetCell.self), forIndexPath: indexPath) as! PetCell
		cell.pet = viewModel.content[indexPath.row]
		return cell
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.content.count
	}
}


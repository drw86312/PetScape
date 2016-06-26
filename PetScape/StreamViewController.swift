//
//  StreamViewController.swift
//  PetScape
//
//  Created by David Warner on 5/17/16.
//  Copyright © 2016 drw. All rights reserved.
//

import PureLayout
import ReactiveCocoa
import Result
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
		tableView.rowHeight = 500.0
		tableView.registerClass(PetCell.self,
		                        forCellReuseIdentifier: NSStringFromClass(PetCell.self))
		tableView.backgroundView = backgroundView
		backgroundView.refreshButton.addTarget(self,
		                                       action: #selector(StreamViewController.refreshButtonPressed),
		                                       forControlEvents: .TouchUpInside)
		tableView.backgroundColor = .blackColor()
		tableView.backgroundView?.backgroundColor = .blackColor()
		tableView.separatorStyle = .None
		view.addSubview(tableView)
		
		loadMoreSpinner.frame = CGRectMake(0, 0, 320, 65)
		loadMoreSpinner.hidesWhenStopped = true
		tableView.tableFooterView = loadMoreSpinner
		
		spinner.hidesWhenStopped = true
		view.addSubview(spinner)
		
		let filterIcon = UIButton(type: .Custom)
		filterIcon.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
		filterIcon.addTarget(self,
		                 action: #selector(StreamViewController.filterIconPressed),
		                 forControlEvents: .TouchUpInside)
		filterIcon.setImage(UIImage(named: "filter")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
		filterIcon.imageView?.tintColor = .whiteColor()
		
		let locationIcon = UIButton(type: .Custom)
		locationIcon.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
		locationIcon.addTarget(self,
		                     action: #selector(StreamViewController.locationIconPressed),
		                     forControlEvents: .TouchUpInside)
		locationIcon.setImage(UIImage(named: "location")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
		locationIcon.imageView?.tintColor = .whiteColor()
		
		let space = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
		space.width = 20
		
		navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: filterIcon), space, UIBarButtonItem(customView: locationIcon)]
		navigationController?.hidesBarsOnSwipe = true
		
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
		
		let locationState = viewModel
			.locationStatus
			.producer
			.observeOn(UIScheduler())
		
		DynamicProperty(object: backgroundView, keyPath: "hidden") <~
			loadState
				.map { state -> Bool in
					if case .Failed = state {
						return false
					}
					return true
				}
				.skipRepeats()
		
		DynamicProperty(object: backgroundView.label, keyPath: "text") <~
			locationState
				.map { state -> String in
					if case .Denied = state {
						return "Please enable location Services or Set Location in Filters"
					} else {
						return ""
					}
		}
		
		let loadingFirst = loadState
			.map { state -> Bool in
				if case .Loading = state where self.viewModel.content.count == 0 {
					return true
				}
				return false
			}
			.skipRepeats()
			.flatMapError { _ in SignalProducer<Bool, NoError>.empty }
		
		let loadingMore = loadState
			.map { state -> Bool in
				if case .Loading = state where self.viewModel.content.count != 0 {
					return true
				}
				return false
			}
			.skipRepeats()
			.flatMapError { _ in SignalProducer<Bool, NoError>.empty }

		
		self.spinner.loading(loadingFirst)
		self.loadMoreSpinner.loading(loadingMore)
		
		DynamicProperty(object: backgroundView.refreshButton, keyPath: "enabled")
			<~ loadState.map { state -> Bool in
				if state == .Failed {
					return true
				}
				return false
		}
		
		// Observe next values on -load Action and insert rows for corresponding range
		viewModel
			.load
			.events
			.observeOn(UIScheduler())
			.observeNext { [unowned self] event in
				if case .Next(let range) = event {
					let paths = range.map { NSIndexPath(forRow: $0, inSection: 0) }
					UIView.setAnimationsEnabled(false)
					self.tableView.insertRowsAtIndexPaths(paths, withRowAnimation: .None)
					UIView.setAnimationsEnabled(true)
				}
		}
		
		viewModel
			.load?
			.events
			.observeOn(UIScheduler())
			.observeFailed { error in
				// TODO handle errors
				print(error)
		}
		
		viewModel.loadState.producer.startWithNext { state in
//			print(state)
		}
	}
	
	private func emptyDataSet() {
		if viewModel.content.count > 0 {
			viewModel.content = []
			tableView.reloadData()
		}
	}
	
	func filterIconPressed() {
		navigationController?.pushViewController(FilterListViewController(), animated: true)
//		let vc = BaseModalViewController()
//		vc.modalPresentationStyle = .OverCurrentContext
//		tabBarController?.presentViewController(vc, animated: false, completion: nil)
	}
	
	func locationIconPressed() {
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		if case .Denied = viewModel.locationStatus.value {
			if let url  = NSURL(string: UIApplicationOpenSettingsURLString) where UIApplication.sharedApplication().canOpenURL(url)  {
				UIApplication.sharedApplication().openURL(url)
			}
		} else {
			appDelegate.locationManager.scanLocation()
		}
	}
	
	func refreshButtonPressed() {
		viewModel.reload()
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}
}

extension StreamViewController: UITableViewDelegate {
	
	func scrollViewDidScroll(scrollView: UIScrollView) {
		let offsetY = scrollView.contentOffset.y
		let bounds = scrollView.bounds
		let size = scrollView.contentSize
		let insets = scrollView.contentInset
		
		if ((offsetY + bounds.size.height - insets.bottom) > size.height &&
			viewModel.load.executing.value == false) {
			viewModel.loadNext()
			print("Load next")
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


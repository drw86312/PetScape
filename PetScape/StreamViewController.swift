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
		
		DynamicProperty(object: backgroundView.label, keyPath: "text") <~
			locationState
				.map { state -> String in
					if case .Denied = state {
						return "Please enable location Services or Set Location in Filters"
					} else {
						return ""
					}
		}
		
		loadState
			.start() { [unowned self] event in
				if case .Next(let state) = event {
					print(state)
					if case .LoadingNext = state { self.loadMoreSpinner.startAnimating() } else { self.loadMoreSpinner.stopAnimating() }
					if case .Loading = state { self.spinner.startAnimating() } else { self.spinner.stopAnimating() }
					if case .LoadFailed = state {
//						self.backgroundView.hidden = false
//						self.emptyDataSet()
					} else {
//						self.backgroundView.hidden = true
					}
				}
		}
		
		DynamicProperty(object: backgroundView.refreshButton, keyPath: "enabled")
			<~ loadState.map { state -> Bool in
				if state == .LoadFailed {
					return true
				}
				return false
		}
		
		viewModel
			.reload?
			.events
			.observeOn(UIScheduler())
			.observeNext { [unowned self] event in
				if case .Next = event {
					self.tableView.reloadData()
				}
		}
		
		viewModel
			.loadNext?
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
			appDelegate.locationManager.manager.startUpdatingLocation()
		}
	}
	
	func refreshButtonPressed() {
		if case .Some(let location) = viewModel.locationStatus.value {
			viewModel.reload?.apply(location).start()
		}
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


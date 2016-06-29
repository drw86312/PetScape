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
	
	let scrollSignal: Signal<UIScrollView, NoError>
	private let scrollObserver: Observer<UIScrollView, NoError>
	
	init() {
		(scrollSignal, scrollObserver) = Signal.pipe()
		super.init(nibName: nil, bundle: nil)
		title = NSLocalizedString("Pets", comment: "")
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		view = UIView()
		view.backgroundColor = UIColor(color: .LightGray)
		
		tableView.dataSource = self
		tableView.delegate = self
		tableView.rowHeight = 500.0
		tableView.registerClass(PetCell.self,
		                        forCellReuseIdentifier: NSStringFromClass(PetCell.self))
		tableView.backgroundView = backgroundView
		backgroundView.refreshButton.addTarget(self,
		                                       action: #selector(StreamViewController.refreshButtonPressed),
		                                       forControlEvents: .TouchUpInside)
		tableView.backgroundColor = UIColor(color: .LightGray)
		tableView.backgroundView?.backgroundColor = UIColor(color: .LightGray)
		tableView.separatorStyle = .None
		view.addSubview(tableView)
		
		loadMoreSpinner.frame = CGRectMake(0, 0, 320, 65)
		loadMoreSpinner.hidesWhenStopped = true
		loadMoreSpinner.color = UIColor(color: .MainColor)
		tableView.tableFooterView = loadMoreSpinner
		
		spinner.hidesWhenStopped = true
		spinner.color = UIColor(color: .MainColor)
		view.addSubview(spinner)
		
		let filterIcon = UIButton(type: .Custom)
		filterIcon.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
		filterIcon.addTarget(self,
		                 action: #selector(StreamViewController.filterIconPressed),
		                 forControlEvents: .TouchUpInside)
		filterIcon.setImage(UIImage(named: "filter")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
		filterIcon.imageView?.tintColor = UIColor(color: .LightGray)
		
		let locationIcon = UIButton(type: .Custom)
		locationIcon.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
		locationIcon.addTarget(self,
		                     action: #selector(StreamViewController.locationIconPressed),
		                     forControlEvents: .TouchUpInside)
		locationIcon.setImage(UIImage(named: "location")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
		locationIcon.imageView?.tintColor = UIColor(color: .LightGray)
		
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
		
		let loadSignal = viewModel
			.loadState
			.signal
			.observeOn(UIScheduler())
			.skipRepeats()
		
		let locationState = viewModel
			.locationStatus
			.producer
			.observeOn(UIScheduler())
		
		DynamicProperty(object: backgroundView, keyPath: "hidden") <~
			loadSignal
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
		
		let loadingFirst = loadSignal
			.map { state -> Bool in
				if case .Loading = state where self.viewModel.content.count == 0 {
					return true
				}
				return false
			}
			.skipRepeats()
			.flatMapError { _ in SignalProducer<Bool, NoError>.empty }
		
		let loadingMore = loadSignal
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
			<~ loadSignal.map { state -> Bool in
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
		
		// Start loading next batch when scrolled to end of loaded content
		scrollSignal
			.map { scrollView -> Bool in
				return ((scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom) > scrollView.contentSize.height)
			}
			.skipRepeats()
			.observeNext { [unowned self] didReachBottom in
				if didReachBottom &&
					!self.viewModel.load.executing.value &&
					self.viewModel.loadState.value == .Loaded {
					self.viewModel.loadNext()
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
	
	deinit {
		scrollObserver.sendCompleted()
	}
}

extension StreamViewController: UITableViewDelegate {
	
	func scrollViewDidScroll(scrollView: UIScrollView) {
		scrollObserver.sendNext(scrollView)
	}
}

extension StreamViewController: PetCellDelegate {
	
	func contactButtonPressed(pet: Pet) {
		let vc = ContactViewController(pet: pet)
		vc.delegate = self
		vc.modalPresentationStyle = .OverCurrentContext
		tabBarController?.presentViewController(vc, animated: false, completion: nil)
	}
	
	func bottomButtonPressed() {
		
	}
}

extension StreamViewController: UITableViewDataSource {
	
	func tableView(tableView: UITableView,
	               cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(PetCell.self), forIndexPath: indexPath) as! PetCell
		cell.pet = viewModel.content[indexPath.row]
		cell.delegate = self
		return cell
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.content.count
	}
}

extension StreamViewController: ContactViewControllerDelegate {
	
	func didSelectAction(action: ContactAction) {
		switch action {
		case .Phone(let phone):
			let set = NSCharacterSet.decimalDigitCharacterSet().invertedSet
			let strippedNumber = phone.componentsSeparatedByCharactersInSet(set).joinWithSeparator("")
			print(strippedNumber)
			
//			NSString *newString = [[origString componentsSeparatedByCharactersInSet:
//				[[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
//				componentsJoinedByString:@""];
			
//			NSString *phoneNumber = [@"tel://" stringByAppendingString:mymobileNO.titleLabel.text];
//			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
		print(phone)
		case .Email(let email):
		print(email)
		case .Link(let link):
		print(link)
		}
	}
}


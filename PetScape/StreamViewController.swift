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
	
	var reloadCocoaAction: CocoaAction?
	
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
		
		guard let reload = viewModel.reload else { return }
		reloadCocoaAction = CocoaAction(reload) { [unowned self] button in
		 return self.viewModel.location
		}
		
//		viewModel
//			.reload?
//			.apply()
//			.observeOn(UIScheduler())
//			.start { [unowned self] event in
//				if case .Next(let content) = event {
//					// TODO: Figure out why this isn't sending -Next values on button-press action.
//					self.tableView.reloadData()
//				} else if case .Failed(let error) = event {
//					print(error)
//				}
//		}
		
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		
		appDelegate
			.locationManager
			.locationStatusProperty
			.producer
			.start() { [unowned self] event in
				if case .Next(let state) = event {
					switch state {
					case .None:
						print("None")
					case .Error(let error):
						print("Error: \(error)")
					case .Some(let location):
						print("Success: \(location)")
						self.viewModel.location = location
						self.reloadCocoaAction?.execute(nil)
					}
				}
		}
		
		backgroundView
			.refreshButton
			.addTarget(reloadCocoaAction,
			           action: CocoaAction.selector,
			           forControlEvents: .TouchUpInside)
	}
	
	private func loadNext() {
//		if viewModel.loadState.value != .LoadFailed &&
//		   viewModel.loadState.value != .LoadedLast {
//			viewModel
//				.loadNext?
//				.apply()
//				.start { [unowned self] event in
//					if case .Next(let content) = event {
//						let paths = (self.tableView.numberOfRowsInSection(0)..<content.count)
//							.map { NSIndexPath(forRow: $0, inSection: 0) }
//						UIView.setAnimationsEnabled(false)
//						self.tableView.insertRowsAtIndexPaths(paths, withRowAnimation: .None)
//						UIView.setAnimationsEnabled(true)
//					} else if case .Failed(let error) = event {
//						print(error)
//					}
//			}
//		}
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
}

extension StreamViewController: UITableViewDelegate {
	
	func scrollViewDidScroll(scrollView: UIScrollView) {
		let offsetY = scrollView.contentOffset.y
		let bounds = scrollView.bounds
		let size = scrollView.contentSize
		let insets = scrollView.contentInset
		guard let executing = viewModel.loadNext?.executing.value else { return }
		if ((offsetY + bounds.size.height - insets.bottom) > size.height && !executing) {
			loadNext()
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


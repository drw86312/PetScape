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
	let tableView = UITableView(frame: CGRect.zero, style: .plain)
	let backgroundView = TableViewBackground()
	let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
	let loadMoreSpinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
	
	init() {
		super.init(nibName: nil, bundle: nil)
		title = NSLocalizedString("Pets", comment: "")
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		view = UIView()
		view.backgroundColor = .black()
		
		tableView.delegate = self
		tableView.dataSource = self
		tableView.rowHeight = 500.0
		tableView.register(PetCell.self,
		                        forCellReuseIdentifier: NSStringFromClass(PetCell.self))
		tableView.backgroundView = backgroundView
		backgroundView.refreshButton.addTarget(self,
		                                       action: #selector(StreamViewController.refreshButtonPressed),
		                                       for: .touchUpInside)
		tableView.backgroundColor = .black()
		tableView.backgroundView?.backgroundColor = .black()
		tableView.separatorStyle = .none
		view.addSubview(tableView)
		
		loadMoreSpinner.frame = CGRect(x: 0, y: 0, width: 320, height: 65)
		loadMoreSpinner.hidesWhenStopped = true
		tableView.tableFooterView = loadMoreSpinner
		
		spinner.hidesWhenStopped = true
		view.addSubview(spinner)
		
		let filterIcon = UIButton(type: .custom)
		filterIcon.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
		filterIcon.addTarget(self,
		                 action: #selector(StreamViewController.filterIconPressed),
		                 for: .touchUpInside)
		filterIcon.setImage(UIImage(named: "filter")?.withRenderingMode(.alwaysTemplate), for: UIControlState())
		filterIcon.imageView?.tintColor = .white()
		
		let locationIcon = UIButton(type: .custom)
		locationIcon.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
		locationIcon.addTarget(self,
		                     action: #selector(StreamViewController.locationIconPressed),
		                     for: .touchUpInside)
		locationIcon.setImage(UIImage(named: "location")?.withRenderingMode(.alwaysTemplate), for: UIControlState())
		locationIcon.imageView?.tintColor = .white()
		
		let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
		space.width = 20
		
		navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: filterIcon), space, UIBarButtonItem(customView: locationIcon)]
		navigationController?.hidesBarsOnSwipe = true
		
		addConstraints()
	}
	
	private func addConstraints() {
		tableView.autoPinEdgesToSuperviewEdges()
		
		spinner.autoAlignAxis(toSuperviewAxis: .vertical)
		spinner.autoAlignAxis(.horizontal, toSameAxisOf: view, withOffset: -25)
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
					if case .denied = state {
						return "Please enable location Services or Set Location in Filters"
					} else {
						return ""
					}
		}
		
		loadState
			.start() { [unowned self] event in
				if case .next(let state) = event {
					if case .loadingNext = state { self.loadMoreSpinner.startAnimating() } else { self.loadMoreSpinner.stopAnimating() }
					if case .loading = state { self.spinner.startAnimating() } else { self.spinner.stopAnimating() }
					if case .loadFailed = state {
//						self.backgroundView.hidden = false
//						self.emptyDataSet()
					} else {
//						self.backgroundView.hidden = true
					}
				}
		}
		
		DynamicProperty(object: backgroundView.refreshButton, keyPath: "enabled")
			<~ loadState.map { state -> Bool in
				if state == .loadFailed {
					return true
				}
				return false
		}
		
		viewModel
			.reload?
			.events
			.observeOn(UIScheduler())
			.observeNext { [unowned self] event in
				if case .next = event {
					self.tableView.reloadData()
				}
		}
		
		viewModel
			.loadNext?
			.events
			.observeOn(UIScheduler())
			.observeNext { [unowned self] event in
				if case .next(let range) = event {
					let paths = range.map { IndexPath(row: $0, section: 0) }
					UIView.setAnimationsEnabled(false)
					self.tableView.insertRows(at: paths, with: .none)
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
		let appDelegate = UIApplication.shared().delegate as! AppDelegate
		if case .denied = viewModel.locationStatus.value {
			if let url  = URL(string: UIApplicationOpenSettingsURLString) where UIApplication.shared().canOpenURL(url)  {
				UIApplication.shared().openURL(url)
			}
		} else {
			appDelegate.locationManager.manager.startUpdatingLocation()
		}
	}
	
	func refreshButtonPressed() {
		if case .some(let location) = viewModel.locationStatus.value {
			viewModel.reload?.apply(location).start()
		}
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .lightContent
	}
}

extension StreamViewController: UITableViewDelegate {
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let offsetY = scrollView.contentOffset.y
		let bounds = scrollView.bounds
		let size = scrollView.contentSize
		let insets = scrollView.contentInset
		
		guard let executing = viewModel.loadNext?.executing.value else { return }
		if ((offsetY + bounds.size.height - insets.bottom) > size.height &&
			!executing &&
			viewModel.loadState.value == .loaded) {
			if case .some(let location) = viewModel.locationStatus.value {
				viewModel.loadNext?.apply(location).start()
			}
		}
	}
}

extension StreamViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView,
	               cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(PetCell.self), for: indexPath) as! PetCell
		cell.pet = viewModel.content[(indexPath as NSIndexPath).row]
		return cell
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.content.count
	}
}


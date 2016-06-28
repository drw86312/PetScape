//
//  CircularProgressView.swift
//  PetScape
//
//  Created by David Warner on 6/26/16.
//  Copyright © 2016 drw. All rights reserved.
//

import ReactiveCocoa
import Result
import UIKit

class CircularProgressView: UIView {
	
	enum LoadState {
		case NotLoaded
		case Loaded
		case Loading
		case Error
	}
	
	var layerBackgroundColor: UIColor
	var layerTintColor: UIColor
	var lineWidth: CGFloat
	
	let progress = MutableProperty<CGFloat>(0.0)
	let loadState = MutableProperty<LoadState>(.NotLoaded)
	
	private var loadingLayers: [CAShapeLayer] = []
	private let accessoryView = UIImageView()
	private var backingLayer: CAShapeLayer!
	
	init(layerBackgroundColor: UIColor = .lightGrayColor(),
	     layerTintColor: UIColor = UIColor(color: .MainColor),
	     lineWidth: CGFloat = 15) {
		self.layerBackgroundColor = layerBackgroundColor
		self.layerTintColor = layerTintColor
		self.lineWidth = lineWidth
		
		super.init(frame: CGRectZero)
		
		frame.size = CGSize(width: 100, height: 100)
		
		accessoryView.frame = CGRect(x: 0, y: 0, width: frame.size.width - (2 * lineWidth), height: frame.size.height - (2 * lineWidth))
		accessoryView.image = UIImage(named: "bash")?.imageWithRenderingMode(.AlwaysTemplate)
		accessoryView.tintColor = layerBackgroundColor
		accessoryView.contentMode = .ScaleToFill
		addSubview(accessoryView)
		
		// Add background layer
		backingLayer = generateLayer(0.0,
		                             endPoint: 1.0,
		                             strokeColor: layerBackgroundColor)
		layer.addSublayer(backingLayer)
		
		let progressSignal = AnyProperty(progress).signal
		
		progressSignal
			.combinePrevious(0.0)
			.observeOn(UIScheduler())
			.observeNext { [unowned self] (prev, next) in
				let prev = prev == 1 ? 0 : prev
				if fabs(next) - fabs(prev) != 0 {
					let newLayer = self.generateLayer(prev, endPoint: next)
					self.loadingLayers.append(newLayer)
					self.layer.addSublayer(newLayer)
				}
		}
		
		loadState <~ progressSignal
			.map { progress in
				if progress >= 1.0 { return .Loaded }
				else if progress <= 0.0 { return .NotLoaded }
				else { return .Loading }
		}
		
		let didFinishLoading = loadState
			.signal
			.observeOn(UIScheduler())
			.map { $0 == .Loaded }
			.skipRepeats()
		
		didFinishLoading
			.observeNext { [unowned self] finished in
				if finished {
					self.loadingLayers.forEach { $0.removeFromSuperlayer() }
					self.loadingLayers = []
				}
		}
		
		DynamicProperty(object: self,
		                keyPath: "hidden") <~ didFinishLoading
		
		let didError = loadState
			.signal
			.map { $0 == .Error }
			.skipRepeats()
		
		DynamicProperty(object: backingLayer,
		                keyPath: "hidden") <~ didError
		
		DynamicProperty(object: accessoryView,
		                keyPath: "hidden") <~ didError.map { !$0 }
	}
	
	func generateLayer(startPoint: CGFloat,
	                   endPoint: CGFloat,
	                   strokeColor: UIColor = UIColor(color: .MainColor)) -> CAShapeLayer {
		let originDegrees = (360 * startPoint) - 90
		let terminusDegrees = (360 * endPoint) - 90
		
		let originRadians = originDegrees * CGFloat(M_PI/180)
		let terminusRadians = terminusDegrees * CGFloat(M_PI/180)
		
		let circlePath = UIBezierPath(arcCenter: CGPoint(x: bounds.origin.x + bounds.size.width/2,
														 y: bounds.origin.y + bounds.size.height/2),
		                              radius: CGFloat(frame.size.width/2) - lineWidth/2,
		                              startAngle: originRadians,
		                              endAngle: terminusRadians,
		                              clockwise: true)
		let newLayer = CAShapeLayer()
		newLayer.path = circlePath.CGPath
		newLayer.fillColor = UIColor.clearColor().CGColor
		newLayer.strokeColor = strokeColor.CGColor
		newLayer.lineWidth = lineWidth
		return newLayer
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		accessoryView.center = CGPoint(x: bounds.origin.x + bounds.size.width/2, y: bounds.origin.y + bounds.size.height/2)
	}
}

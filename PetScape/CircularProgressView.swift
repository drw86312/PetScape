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
	
	var loadingLayers: [CAShapeLayer] = []

	var layerBackgroundColor: UIColor
	var layerTintColor: UIColor
	var lineWidth: CGFloat
	
	let isLoading = MutableProperty<Bool>(false)
	
	let loadingSignal: Signal<(progress: CGFloat, total: CGFloat), NoError>
	let loadingObserver: Observer<(progress: CGFloat, total: CGFloat), NoError>
	
	init(layerBackgroundColor: UIColor = .lightGrayColor(),
	     layerTintColor: UIColor = UIColor(color: .MainColor),
	     lineWidth: CGFloat = 15) {
		
		self.layerBackgroundColor = layerBackgroundColor
		self.layerTintColor = layerTintColor
		self.lineWidth = lineWidth
		(loadingSignal, loadingObserver) = Signal.pipe()
		
		super.init(frame: CGRectZero)
		frame.size = CGSize(width: 100, height: 100)
		
		// Add background layer
		layer.addSublayer(generateLayer(0.0,
			endPoint: 1.0,
			strokeColor: layerBackgroundColor))
		
		isLoading
			.producer
			.skipRepeats()
			.observeOn(UIScheduler())
			.takeUntil(rac_WillDeallocSignalProducer())
			.startWithNext { [unowned self] loading in
				if !loading {
					self.loadingLayers.forEach { $0.removeFromSuperlayer() }
					self.loadingLayers = []
					self.hidden = true
				} else {
					self.hidden = false
				}
		}
		
		// Observe progress -> generate arcs representing incremental progress -> add to self.layer
		loadingSignal
			.combinePrevious((0.0, 0.0))
			.observeOn(UIScheduler())
			.observeNext { [unowned self] (previous: (progress: CGFloat, total: CGFloat),
										   next: (progress: CGFloat, total: CGFloat)) in
				let oldProgress = previous.progress/previous.total
				let newProgress = next.progress/next.total
				if fabs(newProgress) - fabs(oldProgress) != 0 {
					let newLayer = self.generateLayer(oldProgress, endPoint: newProgress)
					self.loadingLayers.append(newLayer)
					self.layer.addSublayer(newLayer)
				}
		}
	}
	
	func generateLayer(startPoint: CGFloat,
	                   endPoint: CGFloat,
	                   strokeColor: UIColor = UIColor(color: .MainColor)) -> CAShapeLayer {
		let originDegrees = (360 * startPoint) - 90
		let terminusDegrees = (360 * endPoint) - 90
		
		let originRadians = originDegrees * CGFloat(M_PI/180)
		let terminusRadians = terminusDegrees * CGFloat(M_PI/180)
		
		let circlePath = UIBezierPath(arcCenter: CGPoint(x: bounds.origin.x + bounds.size.width/2, y: bounds.origin.y + bounds.size.height/2),
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
	
	deinit {
		loadingObserver.sendCompleted()
	}
}

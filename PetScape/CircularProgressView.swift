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
	
	private let accessoryView = UIImageView()
	
	private var backingLayer: CAShapeLayer!
	private var loadingLayer: CAShapeLayer!
	
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
		let backPath = CircularProgressView.generatePath(0.0,
		                                              endPoint: 1.0,
		                                              lineWidth: lineWidth,
		                                              drawRect: bounds)
		backingLayer = CAShapeLayer()
		backingLayer.path = backPath.CGPath
		backingLayer.fillColor = UIColor.clearColor().CGColor
		backingLayer.strokeColor = layerBackgroundColor.CGColor
		backingLayer.lineWidth = lineWidth
		layer.addSublayer(backingLayer)
		
		
		// Add loading layer
		let loadingPath = CircularProgressView.generatePath(0.0,
		                                              endPoint: 0.0,
		                                              lineWidth: lineWidth,
		                                              drawRect: bounds)
		loadingLayer = CAShapeLayer()
		loadingLayer.path = loadingPath.CGPath
		loadingLayer.fillColor = UIColor.clearColor().CGColor
		loadingLayer.strokeColor = layerTintColor.CGColor
		loadingLayer.lineWidth = lineWidth
		layer.addSublayer(loadingLayer)
		
		let progressSignal = AnyProperty(progress).signal
		
		progressSignal
			.map { [unowned self] progress -> UIBezierPath in
			 return CircularProgressView.generatePath(0.0,
				endPoint: progress,
				lineWidth: lineWidth,
				drawRect: self.bounds)
			}
			.combinePrevious(CircularProgressView.generatePath(0.0,
				endPoint: 0.0,
				lineWidth: lineWidth,
				drawRect: bounds))
			.observeOn(UIScheduler())
			.observeNext { [unowned self] oldPath, newPath in
				
			let pathAnim = CABasicAnimation(keyPath: "path")
			pathAnim.fromValue = self.loadingLayer.path
			pathAnim.toValue = newPath
				
			let animGroup = CAAnimationGroup()
			animGroup.animations = [pathAnim]
			animGroup.removedOnCompletion = false
			animGroup.duration = 0.5
			animGroup.fillMode = kCAFillModeForwards
			
			self.loadingLayer.addAnimation(animGroup, forKey: nil)
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
		
//		didFinishLoading
//			.observeNext { [unowned self] finished in
//				self.loadingLayer.hidden = finished
//		}
		
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
	
	static func generatePath(startPoint: CGFloat,
	                          endPoint: CGFloat,
	                          lineWidth: CGFloat,
	                          drawRect: CGRect) -> UIBezierPath {
		
		let originDegrees = (360 * startPoint) - 90
		let terminusDegrees = (360 * endPoint) - 90
		
		let originRadians = originDegrees * CGFloat(M_PI/180)
		let terminusRadians = terminusDegrees * CGFloat(M_PI/180)
		
		return UIBezierPath(arcCenter: CGPoint(x: drawRect.origin.x + drawRect.size.width/2,
			y: drawRect.origin.y + drawRect.size.height/2),
		                    radius: CGFloat(drawRect.size.width/2) - lineWidth/2,
		                    startAngle: originRadians,
		                    endAngle: terminusRadians,
		                    clockwise: true)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		accessoryView.center = CGPoint(x: bounds.origin.x + bounds.size.width/2, y: bounds.origin.y + bounds.size.height/2)
	}
}

//
//  PetCell.swift
//  PetScape
//
//  Created by David Warner on 6/13/16.
//  Copyright © 2016 drw. All rights reserved.
//

import UIKit
import PureLayout
import WebImage

protocol PetCellDelegate {
	func contactButtonPressed(pet: Pet)
	func bottomButtonPressed()
}

class PetCell: UITableViewCell {
	
	private let scrollView = UIScrollView()
	private let labelView = PetCellLabelView()
	private let pageControl = UIPageControl()
	private var imageViews = [LoadingImageView(frame: CGRectZero)]
	var delegate: PetCellDelegate?

	var pet: Pet? {
		didSet {
			guard let pet = pet else { return }
			configureLabel(pet)
			configureScrollView(pet)
		}
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		scrollView.pagingEnabled = true
		scrollView.alwaysBounceVertical = false
		scrollView.alwaysBounceHorizontal = false
		scrollView.bounces = false
		scrollView.delegate = self
		scrollView.backgroundColor = .grayColor()
		
		labelView.layer.cornerRadius = 5.0
		labelView.layer.masksToBounds = true
		
		labelView.topButton.addTarget(self, action: #selector(PetCell.contactButtonPressed(_:)), forControlEvents: .TouchUpInside)
		labelView.bottomButton.addTarget(self, action: #selector(PetCell.bottomButtonPressed(_:)), forControlEvents: .TouchUpInside)
		
		pageControl.pageIndicatorTintColor = .whiteColor()
		pageControl.currentPageIndicatorTintColor = UIColor(color: .MainColor)
		
		contentView.addSubview(scrollView)
		contentView.addSubview(labelView)
		contentView.addSubview(pageControl)
		
		addConstraints()
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func addConstraints() {
		labelView.autoPinEdgeToSuperviewEdge(.Left, withInset: 10)
		labelView.autoPinEdgeToSuperviewEdge(.Right, withInset: 10)
		labelView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 10)
		
		pageControl.autoAlignAxisToSuperviewAxis(.Vertical)
		pageControl.autoPinEdgeToSuperviewEdge(.Top, withInset: 10)
	}
	
	private func configureLabel(pet: Pet) {
		
		if let name = pet.name, let sex  = pet.sex {
			let nameString = NSMutableAttributedString(string: name, attributes: [NSFontAttributeName : UIFont.boldSystemFontOfSize(24)])
			let ageString = NSMutableAttributedString(string: "  |  " + sex.titleString, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(18)])
			nameString.appendAttributedString(ageString)
			labelView.titleLabel.attributedText = nameString
		} else {
			labelView.titleLabel.attributedText =  NSMutableAttributedString(string: pet.name ?? "",
			                                                                 attributes: [NSFontAttributeName : UIFont.systemFontOfSize(24, weight: 0.5)])
		}
		
		if let breeds = pet.breeds,
			let age  = pet.age {
			labelView.detailLabel.text = age.rawValue + "  |  " + breeds.joinWithSeparator(" / ")
		}
		
		if let size = pet.size, mix = pet.mix, status = pet.adoptionStatus {
			let mixString = mix ? "Y" : "N"
			labelView.detailLabel2.text = "Size: \(size.rawValue)  |  Mix: \(mixString)  |  Status: \(status.titleString)"
		}
	}
	
	private func configureScrollView(pet: Pet) {
		if scrollView.frame != contentView.frame { scrollView.frame = contentView.frame }
		
		guard let photos = pet.photos else {
			// Remove all but one imageView
			imageViews[1..<imageViews.count].forEach { $0.removeFromSuperview() }
			imageViews.removeRange(1..<imageViews.count)
			scrollView.contentSize = CGSize(width: CGFloat(imageViews.count) * scrollView.frame.width, height: scrollView.frame.height)
			scrollView.setContentOffset(scrollView.frame.origin, animated: false)
			pageControl.hidden = true
			pageControl.currentPage = 0
			return
		}
		
		if photos.count > imageViews.count {
			// Add imageViews
			let new = (imageViews.count..<photos.count).map { _ in return LoadingImageView(frame: CGRectZero) }
			imageViews.appendContentsOf(new)
			imageViews
				.enumerate()
				.forEach { index, imageView in
				if imageView.superview == nil {
					imageView.frame = CGRect(
						x: CGFloat(index) * scrollView.frame.width,
						y: scrollView.frame.origin.y,
						width: scrollView.frame.width,
						height: scrollView.frame.height)
					imageView.contentMode = .ScaleToFill
					scrollView.addSubview(imageView)
				}
			}
		} else if photos.count < imageViews.count {
			// Remove imageViews
			imageViews[photos.count..<imageViews.count].forEach { $0.removeFromSuperview() }
			imageViews.removeRange(photos.count..<imageViews.count)
		}
		
		// At this point photos and imageViews count should be equal
		if photos.count == imageViews.count {
			imageViews
				.enumerate()
				.forEach { index, imageView in
				 if let url = photos[index].extraLargeURL {
					imageView.sd_setImageWithURL(
						url,
						placeholderImage: UIColor.grayColor().imageFromColor(),
						options: .HighPriority,
						progress: { (loaded, total) in
							imageView.loadingView.progress.value = CGFloat(loaded)/CGFloat(total)
						}, completed: { (image, error, _, _) in
							if error != nil || image == nil {
								imageView.loadingView.loadState.value = .Error
							} else {
								if imageView.loadingView.progress.value != 1.0 {
									imageView.loadingView.progress.value = 1.0
								}
							}
					})
					}
			}
		}
		
		scrollView.contentSize = CGSize(width: CGFloat(imageViews.count) * scrollView.frame.width, height: scrollView.frame.height)
		scrollView.setContentOffset(scrollView.frame.origin, animated: false)
		pageControl.numberOfPages = photos.count
		pageControl.hidden = photos.count < 2
		pageControl.currentPage = 0
	}
	
	func contactButtonPressed(sender: UIButton) {
		guard let delegate = delegate, let pet = pet  else { return }
		delegate.contactButtonPressed(pet)
	}
	
	func bottomButtonPressed(sender: UIButton) {
		guard let delegate = delegate else { return }
		delegate.bottomButtonPressed()
	}
}

extension PetCell: UIScrollViewDelegate {
	
	func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
		pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
	}
}

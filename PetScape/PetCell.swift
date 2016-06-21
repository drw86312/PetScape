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

class PetCell: UITableViewCell {
	
	private let scrollView = UIScrollView()
	private let labelView = PetCellLabelView()

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
		
		labelView.layer.cornerRadius = 5.0
		labelView.layer.masksToBounds = true
		
		contentView.addSubview(scrollView)
		contentView.addSubview(labelView)
		
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
		labelView.autoSetDimension(.Height, toSize: 100)
	}
	
	private func configureLabel(pet: Pet) {
		
		if let name = pet.name, let sex  = pet.sex {
			let nameString = NSMutableAttributedString(string: name, attributes: [NSFontAttributeName : UIFont.boldSystemFontOfSize(21)])
			let ageString = NSMutableAttributedString(string: "  |  " + sex.titleString, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(18)])
			nameString.appendAttributedString(ageString)
			labelView.titleLabel.attributedText = nameString
		} else {
			labelView.titleLabel.attributedText =  NSMutableAttributedString(string: pet.name ?? "",
			                                                                 attributes: [NSFontAttributeName : UIFont.systemFontOfSize(21, weight: 0.5)])
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
		scrollView.subviews.forEach { $0.removeFromSuperview() }
		if scrollView.frame != contentView.frame {
			scrollView.frame = contentView.frame
		}
		if let photos = pet.photos {
			photos
				.enumerate()
				.forEach { index, photo in
					guard let url = photo.extraLargeURL else { return }
					let imageView = UIImageView(frame: CGRect(
						x: CGFloat(index) * scrollView.frame.width,
						y: scrollView.frame.origin.y,
						width: scrollView.frame.width,
						height: scrollView.frame.height))
					imageView.contentMode = .ScaleToFill
					scrollView.addSubview(imageView)
					imageView.sd_setImageWithURL(url, placeholderImage: UIColor.grayColor().imageFromColor())
			}
			scrollView.contentSize = CGSize(width: CGFloat(photos.count) * scrollView.frame.width, height: scrollView.frame.height)
			labelView.pageControl.numberOfPages = photos.count
			scrollView.setContentOffset(scrollView.frame.origin, animated: false)
			labelView.pageControl.currentPage = 0
			labelView.pageControl.hidden = photos.count < 2
		}
	}
}

extension PetCell: UIScrollViewDelegate {
	
	func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
		labelView.pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
	}
}

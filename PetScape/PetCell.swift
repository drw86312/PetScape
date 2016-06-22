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
		
		scrollView.isPagingEnabled = true
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
		labelView.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
		labelView.autoPinEdge(toSuperviewEdge: .right, withInset: 10)
		labelView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
		labelView.autoSetDimension(.height, toSize: 100)
	}
	
	private func configureLabel(_ pet: Pet) {
		
		if let name = pet.name, let sex  = pet.sex {
			let nameString = NSMutableAttributedString(string: name, attributes: [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 21)])
			let ageString = NSMutableAttributedString(string: "  |  " + sex.titleString, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 18)])
			nameString.append(ageString)
			labelView.titleLabel.attributedText = nameString
		} else {
			labelView.titleLabel.attributedText =  NSMutableAttributedString(string: pet.name ?? "",
			                                                                 attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 21, weight: 0.5)])
		}
		
		if let breeds = pet.breeds,
			let age  = pet.age {
			labelView.detailLabel.text = age.rawValue + "  |  " + breeds.joined(separator: " / ")
		}
		
		if let size = pet.size, mix = pet.mix, status = pet.adoptionStatus {
			let mixString = mix ? "Y" : "N"
			labelView.detailLabel2.text = "Size: \(size.rawValue)  |  Mix: \(mixString)  |  Status: \(status.titleString)"
		}
	}
	
	private func configureScrollView(_ pet: Pet) {
		scrollView.subviews.forEach { $0.removeFromSuperview() }
		if scrollView.frame != contentView.frame {
			scrollView.frame = contentView.frame
		}
		if let photos = pet.photos {
			photos
				.enumerated()
				.forEach { index, photo in
					guard let url = photo.extraLargeURL else { return }
					let imageView = UIImageView(frame: CGRect(
						x: CGFloat(index) * scrollView.frame.width,
						y: scrollView.frame.origin.y,
						width: scrollView.frame.width,
						height: scrollView.frame.height))
					imageView.contentMode = .scaleToFill
					scrollView.addSubview(imageView)
					imageView.sd_setImage(with: url, placeholderImage: UIColor.gray().imageFromColor())
			}
			scrollView.contentSize = CGSize(width: CGFloat(photos.count) * scrollView.frame.width, height: scrollView.frame.height)
			labelView.pageControl.numberOfPages = photos.count
			scrollView.setContentOffset(scrollView.frame.origin, animated: false)
			labelView.pageControl.currentPage = 0
			labelView.pageControl.isHidden = photos.count < 2
		}
	}
}

extension PetCell: UIScrollViewDelegate {
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		labelView.pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
	}
}

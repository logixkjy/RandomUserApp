//
//  UserCell.swift
//  RandomUserApp
//
//  Created by JooYoung Kim on 1/12/26.
//

import UIKit
import SnapKit
import Kingfisher

final class UserCell: UICollectionViewCell {
    static let reuseIdentifier: String = "UserCell"
    
    private let thumbImageView = UIImageView()
    private let nameLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let emailLabel = UILabel()
    
    private let textStackView = UIStackView()
    private let rootStackView = UIStackView()
    
    private var aspectRatioConstraint: Constraint?
    private var fixedWidthConstraint: Constraint?
    
    private var userItem: UserListItem? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        apply(mode: .oneColumn)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbImageView.kf.cancelDownloadTask()
        thumbImageView.image = nil
    }
    
    private func setupUI() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 14
        contentView.layer.masksToBounds = true
        
        thumbImageView.contentMode = .scaleAspectFill
        thumbImageView.clipsToBounds = true
        thumbImageView.layer.cornerRadius = 10
        thumbImageView.backgroundColor = .tertiarySystemBackground
        
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 1
        
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = .label
        subtitleLabel.numberOfLines = 2
        
        emailLabel.font = .systemFont(ofSize: 13, weight: .regular)
        emailLabel.textColor = .label
        emailLabel.numberOfLines = 2
        
        textStackView.axis = .vertical
        textStackView.spacing = 6
        textStackView.addArrangedSubview(nameLabel)
        textStackView.addArrangedSubview(subtitleLabel)
        textStackView.addArrangedSubview(emailLabel)
        
        rootStackView.spacing = 12
        rootStackView.alignment = .fill
        rootStackView.distribution = .fill
        rootStackView.addArrangedSubview(thumbImageView)
        rootStackView.addArrangedSubview(textStackView)
        
        contentView.addSubview(rootStackView)
    }

    private func setupConstraints() {
        rootStackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(12)
        }
        
        thumbImageView.snp.makeConstraints { (make) in
            aspectRatioConstraint = make.height.equalTo(thumbImageView.snp.width).multipliedBy(4.0/3.0).constraint
        }
    }
    
    func configure(item: UserListItem) {
        userItem = item
        
        nameLabel.text = userItem?.name
        subtitleLabel.text = userItem?.subtitle
        emailLabel.text = userItem?.email
        
        if let url = userItem?.largeURL {
            thumbImageView.kf.setImage(with: url)
        } else {
            thumbImageView.image = UIImage(systemName: "person.crop.square")
            thumbImageView.tintColor = .tertiaryLabel
        }
    }
    
    func apply(mode: LayoutMode) {
        switch mode {
        case .oneColumn:
            rootStackView.axis = .horizontal
            rootStackView.alignment = .center
            
            fixedWidthConstraint?.deactivate()
            thumbImageView.snp.makeConstraints { (make) in
                fixedWidthConstraint = make.width.equalTo(60).constraint
            }
            
        case .twoColumn:
            rootStackView.axis = .vertical
            rootStackView.alignment = .fill
            
            fixedWidthConstraint?.deactivate()
            fixedWidthConstraint = nil
        }
        
        setNeedsLayout()
    }
    
    override var isSelected: Bool {
        didSet {
            contentView.alpha = isSelected ? 0.7 : 1.0
            contentView.layer.borderWidth = isSelected ? 2.0 : 0.0
            contentView.layer.borderColor = isSelected ? UIColor.systemRed.cgColor : UIColor.clear.cgColor
        }
    }
}

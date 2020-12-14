//
//  PublicationCell.swift
//  Marvel
//
//  Created by Hugo Alonso on 09/12/2020.
//

import Foundation
import UIKit

final class PublicationCell: UICollectionViewCell {
    static var cellSize: CGSize = CGSize(width: 119, height: 250)

    lazy var image: UIImageView = setupImageView()
    lazy var nameLabel: UILabel = createTitleButton()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    func setup() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        clipsToBounds = true

        contentView.addSubview(image)
        image.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview().inset(4)
            make.height.greaterThanOrEqualTo(100)
        }

        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(image.snp.bottom).offset(2)
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(2)
        }

        needsUpdateConstraints()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        image.image = nil
        nameLabel.text = ""
    }

    private func setupImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.clipsToBounds = true
        imageView.accessibilityIdentifier = "image"

        return imageView
    }

    private func createTitleButton() -> UILabel {
        let nameLabel = UILabel()
        nameLabel.textColor = .white
        nameLabel.backgroundColor = .clear
        nameLabel.font = UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize)
        nameLabel.accessibilityIdentifier = "title"
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.numberOfLines = 0
        nameLabel.clipsToBounds = true
        nameLabel.textAlignment = .center
        
        return nameLabel
    }

}

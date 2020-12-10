//
//  PublicationCell.swift
//  Marvel
//
//  Created by Hugo Alonso on 09/12/2020.
//

import Foundation
import UIKit

final class PublicationCell: UICollectionViewCell {
    static var cellSize: CGSize = CGSize(width: 119, height: 176)

    lazy var image: UIImageView = setupImageView()
    lazy var nameLabel: UILabel = UILabel()

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
            make.edges.equalToSuperview().inset(8)
        }

        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(8)
        }

        needsUpdateConstraints()
    }

    private func setupImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        imageView.clipsToBounds = true
        imageView.accessibilityIdentifier = "image"
        return imageView
    }

}

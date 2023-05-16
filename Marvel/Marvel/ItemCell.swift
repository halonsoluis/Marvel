import Foundation
import SnapKit
import UIKit

final class ItemCell: UITableViewCell {
    private lazy var name: UIButton = self.createNameButton()
    private lazy var heroImage: UIImageView = self.createHeroImageView()

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    private func setupUI() {
        backgroundColor = .clear
        clipsToBounds = true
        selectionStyle = .none

        addSubview(heroImage)
        addSubview(name)

        heroImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        name.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(1.5)
            make.left.equalToSuperview().inset(16)
            make.right.equalToSuperview().inset(16).priority(.low)
        }
    }

    func setup(using feedDataProvider: FeedDataProvider, itemAt index: Int) {
        feedDataProvider.perform(action: .setHeroImage(index: index, on: heroImage))
        name.setTitle(feedDataProvider.items[index].name, for: .normal)
    }
}

// MARK: Initialisers

extension ItemCell {
    private func createHeroImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.accessibilityIdentifier = "heroImage"
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }

    private func createNameButton() -> UIButton {
        let nameLabel = UIButton()
        nameLabel.setTitleColor(.black, for: .normal)
        nameLabel.titleLabel?.adjustsFontSizeToFitWidth = true
        nameLabel.titleLabel?.autoresizesSubviews = true
        nameLabel.autoresizingMask = [UIView.AutoresizingMask.flexibleRightMargin, UIView.AutoresizingMask.flexibleTopMargin]
        nameLabel.backgroundColor = .clear
        nameLabel.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
        nameLabel.accessibilityIdentifier = "name"
        nameLabel.titleLabel?.lineBreakMode = .byWordWrapping
        nameLabel.titleLabel?.numberOfLines = 0
        nameLabel.setBackgroundImage(UIImage(named: "bg-cell-title"), for: .normal)

        nameLabel.titleEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        return nameLabel
    }
}

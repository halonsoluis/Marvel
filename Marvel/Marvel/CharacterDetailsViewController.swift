//
//  CharacterDetailsViewController.swift
//  Marvel
//
//  Created by Hugo Alonso on 29/11/2020.
//

import Foundation
import UIKit
import SnapKit

class CharacterDetailsViewController: UIViewController {
    private let loadImageHandler: (ImageFormula, UIImageView, @escaping (Error?) -> Void) -> Void
    private let feedDataProvider: () -> PublicationFeedDataProvider

    private lazy var scrollBar: UIScrollView = self.createScrollBar()
    private lazy var stack: UIStackView = self.createStackView()
    private lazy var heroDescription: UILabel = self.createDescriptionLabel()
    private lazy var heroName: UIButton = self.createNameButton()
    private lazy var heroImage: UIImageView = self.createHeroImageView()

    private var sections: [PublicationCollection] = []

    init(loadImageHandler: @escaping (ImageFormula, UIImageView, @escaping ((Error?) -> Void)) -> Void,
         feedDataProvider: @escaping () -> PublicationFeedDataProvider) {
        self.loadImageHandler = loadImageHandler
        self.feedDataProvider = feedDataProvider

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        adjustHeroImageAspect()
    }

    func drawCharacter(item: BasicCharacterData, sections: [PublicationCollection]) {

        loadImageHandler(item.imageFormula, heroImage, { _ in })
        heroName.setTitle(item.name, for: .normal)
        heroDescription.text = item.description

        adjustHeroImageAspect()

        self.sections.map { $0.view }.forEach { $0?.removeFromSuperview() }

        self.sections = sections

        sections.forEach { publication in
            stack.addArrangedSubview(publication.view)

            publication.view.snp.makeConstraints { make in
                make.width.equalToSuperview().inset(20)
            }
        }

    }

    private func adjustHeroImageAspect() {
        guard let imageSize = heroImage.image?.size else { return }

        let superviewWidth = view.bounds.width
        let ratio = superviewWidth / imageSize.width
        let imageHeight = imageSize.height * ratio

        heroImage.sizeToFit()

        heroImage.snp.updateConstraints { make in
            make.height.equalTo(imageHeight).priority(.high)
            make.width.equalTo(superviewWidth).priority(.medium)
        }

        stack.setNeedsLayout()
    }

    private func setupUI() {

        view.backgroundColor = .black
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.isTranslucent = true

        view.addSubview(scrollBar)
        scrollBar.addSubview(stack)

        scrollBar.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        heroName.translatesAutoresizingMaskIntoConstraints = false
        heroImage.translatesAutoresizingMaskIntoConstraints = false

        stack.addArrangedSubview(heroImage)
        stack.addArrangedSubview(heroDescription)

        heroImage.addSubview(heroName)

        scrollBar.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.left.right.equalToSuperview()
        }

        stack.snp.makeConstraints { make in
            make.topMargin.equalTo(scrollBar.contentLayoutGuide.snp.top)
            make.bottomMargin.equalToSuperview()
            make.width.equalTo(self.view)
        }

        heroDescription.snp.makeConstraints { make in
            make.width.equalToSuperview().inset(20)
        }

        heroName.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(20)
        }
    }
}

// MARK: Initialisers
extension CharacterDetailsViewController {

    private func createScrollBar() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.bouncesZoom = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.isDirectionalLockEnabled = true
        scrollView.contentInset = UIEdgeInsets.zero
        
        return scrollView
    }

    private func createStackView() -> UIStackView {
        let stack = UIStackView()
        stack.alignment = .center
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = 16
        stack.layoutMargins.right = 4
        stack.layoutMargins.left = 4
        return stack
    }

    private func createHeroImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.accessibilityIdentifier = "heroImage"
        imageView.backgroundColor = .red
        imageView.contentMode = .scaleAspectFit

        return imageView
    }

    private func createDescriptionLabel() -> UILabel {
        let descriptionLabel = UILabel()
        descriptionLabel.textColor = .white
        descriptionLabel.backgroundColor = .clear
        descriptionLabel.font = UIFont.boldSystemFont(ofSize: 17)
        descriptionLabel.accessibilityIdentifier = "description"
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .justified

        return descriptionLabel
    }

    private func createNameButton() -> UIButton {
        let nameLabel = UIButton()
        nameLabel.setTitleColor(.black, for: .normal)
        nameLabel.titleLabel?.adjustsFontSizeToFitWidth = false
        nameLabel.titleLabel?.autoresizesSubviews = true
        nameLabel.autoresizingMask = [.flexibleLeftMargin]
        nameLabel.backgroundColor = .clear
        nameLabel.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        nameLabel.accessibilityIdentifier = "name"
        nameLabel.titleLabel?.lineBreakMode = .byWordWrapping
        nameLabel.titleLabel?.numberOfLines = 0
        nameLabel.setBackgroundImage(UIImage(named: "bg-cell-title"), for: .normal)
        nameLabel.isUserInteractionEnabled = false

        nameLabel.titleEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        return nameLabel
    }
}

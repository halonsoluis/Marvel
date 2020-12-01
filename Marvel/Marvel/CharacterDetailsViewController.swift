//
//  CharacterDetailsViewController.swift
//  Marvel
//
//  Created by Hugo Alonso on 29/11/2020.
//

import Foundation
import UIKit
import SnapKit
import CharactersAPI

class CharacterDetailsViewController: UIViewController {
    private let item: MarvelCharacter
    private let loadImageHandler: (URL, String, UIImageView, @escaping (Error?) -> Void) -> Void

    private lazy var scrollBar: UIScrollView = self.createScrollBar()
    private lazy var stack: UIStackView = self.createStackView()
    private lazy var heroDescription: UILabel = self.createDescriptionLabel()
    private lazy var heroName: UIButton = self.createNameButton()
    private lazy var heroImage: UIImageView = self.createHeroImageView()

    init(item: MarvelCharacter, loadImageHandler: @escaping (URL, String, UIImageView, @escaping ((Error?) -> Void)) -> Void) {
        self.item = item
        self.loadImageHandler = loadImageHandler

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        drawCharacter()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        heroImage.sizeToFit()
        view.setNeedsLayout()
    }

    private func drawCharacter() {
        if let thumbnail = item.thumbnail, let modified = item.modified {
            loadImageHandler(thumbnail, modified, heroImage) { [weak self] _ in
                guard let strongSelf = self else { return }

                if let size = strongSelf.heroImage.image?.size {
                    let ratio = UIScreen.main.bounds.width / size.width
                    let imageHeight = size.height * ratio

                    strongSelf.heroImage.snp.updateConstraints { make in
                        make.height.equalTo(imageHeight)
                    }
                }
            }
        }
        heroName.setTitle(item.name, for: .normal)
        heroDescription.text = item.description
    }

    private func setupUI() {

        view.backgroundColor = .black
        navigationController?.navigationBar.barTintColor = .black

        navigationItem.titleView = UIImageView(image: UIImage(named: "icn-nav-marvel"))

        //view.addSubview(stack)

       // scrollBar.addSubview(stack)

        view.addSubview(heroImage)
        view.addSubview(heroDescription)
        view.addSubview(heroName)

//        scrollBar.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }

//        stack.snp.makeConstraints { make in
//            make.top.left.right.equalToSuperview()
//            make.width.equalTo(view.snp.width)
//        }

        heroImage.snp.makeConstraints { make in
            make.top.width.centerX.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(200)
        }

        heroDescription.snp.makeConstraints { make in
            make.top.equalTo(heroImage.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(8)
        }

        heroName.snp.makeConstraints { make in
            make.right.equalTo(heroImage.snp.right).inset(16)
            make.bottom.equalTo(heroImage.snp.bottom).inset(16)
        }
    }
}

// MARK: Initialisers
extension CharacterDetailsViewController {
    private func createScrollBar() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.bouncesZoom = true
        scrollView.isDirectionalLockEnabled = true
        return scrollView
    }

    private func createStackView() -> UIStackView {
        let scrollView = UIStackView()
        scrollView.alignment = .leading
        scrollView.axis = .vertical
        scrollView.distribution = .equalSpacing
        return scrollView
    }

    private func createHeroImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.accessibilityIdentifier = "heroImage"
        imageView.backgroundColor = .red
        imageView.contentMode = .scaleAspectFit

        imageView.autoresizingMask = .flexibleBottomMargin
        imageView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)

        return imageView
    }

    private func createDescriptionLabel() -> UILabel {
        let descriptionLabel = UILabel()
        descriptionLabel.textColor = .white
        descriptionLabel.backgroundColor = .clear
        descriptionLabel.font = UIFont.boldSystemFont(ofSize: 17)
        descriptionLabel.accessibilityIdentifier = "name"
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.numberOfLines = 0
        return descriptionLabel
    }

    private func createNameButton() -> UIButton {
        let nameLabel = UIButton()
        nameLabel.setTitleColor(.black, for: .normal)
        nameLabel.titleLabel?.adjustsFontSizeToFitWidth = false
        nameLabel.titleLabel?.autoresizesSubviews = true
        nameLabel.autoresizingMask = [.flexibleRightMargin, .flexibleTopMargin]
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

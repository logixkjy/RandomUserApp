//
//  PhotoDetailViewController.swift
//  RandomUserApp
//
//  Created by JooYoung Kim on 1/12/26.
//

import UIKit
import SnapKit
import Kingfisher

final class PhotoDetailViewController: UIViewController, UIScrollViewDelegate {
    
    private let imageURL: URL?
    private let titleText: String?
    
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    
    init(imageURL: URL?, title: String? = nil) {
        self.imageURL = imageURL
        self.titleText = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = titleText
        
        configureNavigation()
        configureScrollView()
        configureImageView()
        loadImage()
    }
    
    private func configureNavigation() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(onClose)
        )
    }

    @objc private func onClose() {
        dismiss(animated: true)
    }

    private func configureScrollView() {
        view.addSubview(scrollView)
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 2.0
        scrollView.bouncesZoom = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func configureImageView() {
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .secondarySystemBackground
        imageView.isUserInteractionEnabled = true

        scrollView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
            make.height.equalTo(scrollView.snp.height)
        }

        // 더블 탭 줌
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(onDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTap)
    }
    
    private func loadImage() {
        imageView.kf.setImage(
            with: imageURL,
            placeholder: UIImage(systemName: "photo"),
            options: [
                .transition(.fade(0.25)),
                .cacheOriginalImage
            ]
        )
    }
    
    @objc private func onDoubleTap(_ gr: UITapGestureRecognizer) {
        let targetScale: CGFloat = scrollView.zoomScale > 1.01 ? 1.0 : 2.0
        scrollView.setZoomScale(targetScale, animated: true)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}

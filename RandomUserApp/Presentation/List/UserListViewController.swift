//
//  UserListViewController.swift
//  RandomUserApp
//
//  Created by JooYoung Kim on 1/12/26.
//

import UIKit
import SnapKit

final class UserListViewController: UIViewController, UserListLayoutApplicable {

    private enum Section: Int, CaseIterable {
        case main
    }

    private let gender: Gender

    private var layoutMode: LayoutMode = .oneColumn
    private var items: [UserListItem] = []

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeLayout(for: layoutMode))
        cv.backgroundColor = .clear
        cv.alwaysBounceVertical = true
        cv.allowsMultipleSelection = false
        cv.keyboardDismissMode = .onDrag
        return cv
    }()

    private var dataSource: UICollectionViewDiffableDataSource<Section, UserListItem>!

    init(gender: Gender) {
        self.gender = gender
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        configureUI()
        configureConstraints()
        configureCollectionView()
        configureDataSource()

        applySnapshot(animated: false)

        // 데모 데이터(네트워크 붙이면 제거)
        seedDemoItems()
    }

    private func configureUI() {
        view.addSubview(collectionView)
    }

    private func configureConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func configureCollectionView() {
        collectionView.register(UserCell.self, forCellWithReuseIdentifier: UserCell.reuseIdentifier)
        collectionView.delegate = self
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, UserListItem>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, item in
            guard let self else { return UICollectionViewCell() }

            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: UserCell.reuseIdentifier,
                for: indexPath
            ) as? UserCell else { return UICollectionViewCell() }

            cell.configure(
                name: item.name,
                subtitle: item.subtitle,
                thumbnailURL: item.thumbnailURL
            )
            cell.apply(mode: self.layoutMode)
            
            return cell
        }
    }

    private func makeLayout(for mode: LayoutMode) -> UICollectionViewLayout {
        let columns = (mode == .oneColumn) ? 1 : 2

        let spacing: CGFloat = 12
        let contentInset = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)

        let estimatedHeight: CGFloat = (mode == .oneColumn) ? 96 : 320

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(estimatedHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(estimatedHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
        group.interItemSpacing = .fixed(spacing)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = contentInset
        section.interGroupSpacing = spacing

        return UICollectionViewCompositionalLayout(section: section)
    }

    func setItems(_ newItems: [UserListItem], animated: Bool) {
        items = newItems
        applySnapshot(animated: animated)
    }

    private func applySnapshot(animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, UserListItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    func applyLayout(_ mode: LayoutMode, animated: Bool) {
        guard layoutMode != mode else { return }
        layoutMode = mode
        
        let wasAtTop = isAtTop()

        let newLayout = makeLayout(for: mode)
        collectionView.setCollectionViewLayout(newLayout, animated: animated)
        
        for case let cell as UserCell in collectionView.visibleCells {
            cell.apply(mode: mode)
        }
        if wasAtTop {
            DispatchQueue.main.async { [weak self] in
                self?.scrollToTop(animated: false)
            }
        }
    }
    
    private func isAtTop() -> Bool {
        collectionView.contentOffset.y <= -collectionView.adjustedContentInset.top + 0.5
    }

    func scrollToTop(animated: Bool) {
        guard !items.isEmpty else { return }
        collectionView.setContentOffset(.zero, animated: animated)
    }

    private func seedDemoItems() {
        let prefix = (gender == .male) ? "M" : "F"
        let demo: [UserListItem] = (1...18).map { i in
            UserListItem(
                uuid: "\(prefix)-uuid-\(i)",
                name: "\(prefix) User \(i)",
                subtitle: "subtitle \(i)",
                thumbnailURL: nil
            )
        }
        setItems(demo, animated: false)
    }
}

extension UserListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

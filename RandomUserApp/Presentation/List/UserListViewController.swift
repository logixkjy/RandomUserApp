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
    
    private let resultsPerPage: Int = 20
    private var currentPage: Int = 1
    
    private var isLoading: Bool = false
    private var reachedEnd: Bool = false
    
    private var seedUUIDs = Set<String>()
    private var deletedUUIDs = Set<String>()

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
        configureRefresh()

        applySnapshot(animated: false)

        Task { await refresh() }
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

            cell.configure(item: item)
            cell.apply(mode: self.layoutMode)
            
            return cell
        }
    }
    
    private func configureRefresh() {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(onPullToRefresh), for: .valueChanged)
        collectionView.refreshControl = rc
    }
    
    @objc private func onPullToRefresh() {
        Task { await refresh() }
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
    
    @MainActor
    private func setLoading(_ isLoading: Bool) async {
        self.isLoading = isLoading
        if !isLoading {
            collectionView.refreshControl?.endRefreshing()
        }
    }
    
    private func resetStateFoRefresh() {
        currentPage = 1
        reachedEnd = false
        seedUUIDs.removeAll()
        items.removeAll()
    }
    
    private func appendDedupKeepingOrder(_ newItems: [UserListItem]) {
        for item in newItems {
            guard !deletedUUIDs.contains(item.uuid) else { continue }
            if seedUUIDs.insert(item.uuid).inserted {
                items.append(item)
            }
        }
    }
    
    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func refresh() async {
        if isLoading { return }
        await setLoading(true)
        resetStateFoRefresh()
        
        do {
            let result = try await RandomUserAPI.fetchUsers(
                gender: gender,
                page: currentPage,
                results: resultsPerPage
            )
            
            appendDedupKeepingOrder(result.items)
            applySnapshot(animated: false)
        } catch {
            await MainActor.run {
                showErrorAlert("Failed to fetch users. Please try again. \n\(error)")
            }
        }
        
        await setLoading(false)
    }
    
    func loadNextPageIfNeeded() async {
        if isLoading || reachedEnd { return }
        
        let nextPage = currentPage + 1
        await setLoading(true)
        
        do {
            let result = try await RandomUserAPI.fetchUsers(
                gender: gender,
                page: nextPage,
                results: resultsPerPage
            )
            
            if result.items.isEmpty {
                reachedEnd = true
            } else {
                currentPage = nextPage
                appendDedupKeepingOrder(result.items)
                applySnapshot(animated: true)
            }
        } catch {
            await MainActor.run {
                showErrorAlert("Failed to load next page. Please try again. \n\(error)")
            }
        }
        
        await setLoading(false)
    }
}

extension UserListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let threshold: CGFloat = 400.0
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let visibleHeight = scrollView.frame.size.height
        
        guard contentHeight > 0 else { return }
        if offsetY > contentHeight - visibleHeight - threshold {
            Task {
                await loadNextPageIfNeeded()
            }
        }
    }
}

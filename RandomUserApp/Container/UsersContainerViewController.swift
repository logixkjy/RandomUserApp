//
//  UsersContainerViewController.swift
//  RandomUserApp
//
//  Created by JooYoung Kim on 1/10/26.
//

import UIKit
import SnapKit

protocol UserListLayoutApplicable: AnyObject {
    func applyLayout(_ mode: LayoutMode, animated: Bool)
    func scrollToTop(animated: Bool)
}

final class UsersContainerViewController: UIViewController {
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: Gender.allCases.map(\.title))
        return control
    }()
    
    private let floatingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.grid.2x2"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 28
        button.layer.masksToBounds = true
        button.accessibilityLabel = "Toggle layout"
        return button
    }()
    
    private let pageViewController: UIPageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        return pageViewController
    }()
    
    private lazy var listVCs: [UserListViewController] = Gender.allCases.map { gender in
        let vc = UserListViewController(gender: gender)
        attachCallbacks(to: vc)
        return vc
    }
    
    private var currentIndex: Int = 0
    
    private var layoutMode: LayoutMode = .oneColumn {
        didSet {
            updateFloatingButtonIcon()
        }
    }
    
    private lazy var editItem = UIBarButtonItem(
        title: "Edit",
        style: .plain,
        target: self,
        action: #selector(onTapEdit)
    )
    
    private lazy var deleteItem = UIBarButtonItem(
        title: "Delete",
        style: .plain,
        target: self,
        action: #selector(onTapDelete)
    )
    
    private lazy var countItem = UIBarButtonItem(
        title: "0 selected",
        style: .plain,
        target: self,
        action: nil
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Random Users"
        
        navigationController?.isToolbarHidden = false
        
        configureUI()
        configureConstraints()
        configureActions()
        configureInitialPage()
        updateFloatingButtonIcon()
        configureToolbar(isEditing: false, selectedCount: 0)
    }
    
    private func configureUI() {
        segmentedControl.selectedSegmentIndex = currentIndex
        view.addSubview(segmentedControl)
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        view.addSubview(floatingButton)
    }
    
    private func configureConstraints() {
        segmentedControl.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(12)
            make.height.equalTo(32)
        }
        
        pageViewController.view.snp.makeConstraints { (make) in
            make.top.equalTo(segmentedControl.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        floatingButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(56)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
    
    private func configureActions() {
        segmentedControl.addTarget(self, action: #selector(onSegmentChange), for: .valueChanged)
        floatingButton.addTarget(self, action: #selector(onTapFloating), for: .touchUpInside)
    }
    
    private func configureInitialPage() {
        pageViewController.setViewControllers([listVCs[currentIndex]], direction: .forward, animated: false, completion: nil)
    }
    
    private var currentListVC: UserListViewController {
       listVCs[currentIndex]
    }
    
    private func attachCallbacks(to vc: UserListViewController) {
        vc.onSelectionStateChanged = { [weak self, weak vc] selectedCount, isEditing in
            guard let self else { return }
            
            guard vc === self.currentListVC else { return }
            self.configureToolbar(isEditing: isEditing, selectedCount: selectedCount)
        }
    }
    
    private func configureToolbar(isEditing: Bool, selectedCount: Int) {
        editItem.title = isEditing ? "Done" : "Edit"
        deleteItem.isEnabled = isEditing && selectedCount > 0
        countItem.isEnabled = isEditing
        countItem.title = "\(selectedCount) selected"

        let flex = UIBarButtonItem(systemItem: .flexibleSpace)
        setToolbarItems([editItem, flex, countItem, flex, deleteItem], animated: false)
    }
    
    @objc private func onSegmentChange() {
        let newIndex = segmentedControl.selectedSegmentIndex
        guard newIndex != currentIndex else { return }
        
        let direction: UIPageViewController.NavigationDirection = (newIndex > currentIndex) ? .forward : .reverse
        let prevVC = currentListVC
        
        currentIndex = newIndex
        let nextVC = currentListVC
        
        prevVC.setEditingMode(false)
        nextVC.setEditingMode(false)
        
        pageViewController.setViewControllers([nextVC], direction: direction, animated: true) { _ in
            nextVC.scrollToTop(animated: true)
        }
        
        // toolbar 초기화
        configureToolbar(isEditing: nextVC.isInEditingMode, selectedCount: 0)
    }
    
    @objc private func onTapFloating() {
        layoutMode.toggle()
        broadcastLayoutMode(animated: true)
    }
    
    private func updateFloatingButtonIcon() {
        let image = UIImage(systemName: layoutMode.iconName)
        floatingButton.setImage(image, for: .normal)
    }
    
    private func broadcastLayoutMode(animated: Bool) {
        for vc in listVCs {
            vc.applyLayout(layoutMode, animated: animated)
        }
    }

    @objc private func onTapEdit() {
        let vc = currentListVC
        vc.setEditingMode(!vc.isInEditingMode)
    }

    @objc private func onTapDelete() {
        currentListVC.deleteSelected()
    }
    
}

extension UsersContainerViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let idx = listVCs.firstIndex(where: { $0 === viewController }) else { return nil }
        let prev = idx - 1
        guard prev >= 0 else { return nil }
        return listVCs[prev]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let idx = listVCs.firstIndex(where: { $0 === viewController }) else { return nil }
        let next = idx + 1
        guard next < listVCs.count else { return nil }
        return listVCs[next]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
              let shown = pageViewController.viewControllers?.first,
              let idx = listVCs.firstIndex(where: { $0 === shown }) else { return }
        
        currentIndex = idx
        segmentedControl.selectedSegmentIndex = idx
        
        currentListVC.setEditingMode(false)
        configureToolbar(isEditing: false, selectedCount: 0)
    }
}

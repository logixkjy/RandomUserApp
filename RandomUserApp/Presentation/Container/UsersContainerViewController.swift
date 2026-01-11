//
//  UsersContainerViewController.swift
//  RandomUserApp
//
//  Created by JooYoung Kim on 1/10/26.
//

import UIKit
import SnapKit

enum Gender: Int, CaseIterable {
    case male = 0
    case female = 1
    
    var title: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        }
    }
}

enum LayoutMode {
    case oneColumn
    case twoColumn
    
    mutating func toggle() {
        self = (self == .oneColumn) ? .twoColumn : .oneColumn
    }
    
    var iconName: String {
        switch self {
        case .oneColumn: return "rectangle.grid.1x2"
        case .twoColumn: return "square.grid.2x2"
        }
    }
}

protocol UserListLayoutApplicable: AnyObject {
    func applyLayout(_ mode: LayoutMode, animated: Bool)
    func scrollToTop(animated: Bool)
}


final class UsersContainerViewController: UIViewController {
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: Gender.allCases.map(\.title))
        control.selectedSegmentIndex = Gender.male.rawValue
        return control
    }()
    
    private let floatingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "rectangle.grid.1x2"), for: .normal)
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
    
    private var pages: [UIViewController] = []
    
    private var layoutMode: LayoutMode = .oneColumn {
        didSet {
            updateFloatingButtonIcon()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Random Users"
        
        configurePages()
        configureUI()
        configureConstraints()
        configureActions()
        configureInitialPage()
        updateFloatingButtonIcon()
    }
    
    private func configurePages() {
        let maleListVC = UserListViewController(gender: .male)
        let femaleListVC = UserListViewController(gender: .female)
        pages.append(maleListVC)
        pages.append(femaleListVC)
    }
    
    private func configureUI() {
        navigationItem.titleView = segmentedControl
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        view.addSubview(floatingButton)
        
        pageViewController.dataSource = self
        pageViewController.delegate = self
    }
    
    private func configureConstraints() {
        pageViewController.view.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
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
        guard let firstViewController = pages.first else { return }
        pageViewController.setViewControllers([firstViewController], direction: .forward, animated: false, completion: nil)
    }
    
    @objc private func onSegmentChange() {
        let targetIdx = segmentedControl.selectedSegmentIndex
        moveToPage(index: targetIdx, animated: true, alsoScrollToTop: true)
    }
    
    @objc private func onTapFloating() {
        layoutMode.toggle()
        broadcastLayoutMode(animated: true)
    }
    
    private func moveToPage(index: Int, animated: Bool, alsoScrollToTop: Bool) {
        guard index >= 0, index < pages.count else { return }
        
        let curIdx = currentPageIndex() ?? 0
        let direction: UIPageViewController.NavigationDirection = index > curIdx ? .forward : .reverse
        let targetVC = pages[index]
        
        pageViewController.setViewControllers([targetVC], direction: direction, animated: animated) { _ in
            if alsoScrollToTop, let applicable = targetVC as? UserListLayoutApplicable {
                applicable.scrollToTop(animated: true)
            }
        }
    }
    
    private func currentPageIndex() -> Int? {
        guard let current = pageViewController.viewControllers?.first else {
            return nil
        }
        return pages.firstIndex(of: current)
    }
    
    private func updateFloatingButtonIcon() {
        let image = UIImage(systemName: layoutMode.iconName)
        floatingButton.setImage(image, for: .normal)
    }
    
    private func broadcastLayoutMode(animated: Bool) {
        for vc in pages {
            (vc as? UserListLayoutApplicable)?.applyLayout(layoutMode, animated: animated)
        }
    }

}

extension UsersContainerViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let idx = pages.firstIndex(of: viewController) else { return nil }
        let prev = idx - 1
        guard prev >= 0 else { return nil }
        return pages[prev]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let idx = pages.firstIndex(of: viewController) else { return nil }
        let next = idx + 1
        guard next < pages.count else { return nil }
        return pages[next]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed, let idx = currentPageIndex() else { return }
        segmentedControl.selectedSegmentIndex = idx
    }
}

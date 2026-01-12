📱 Random User List App

RandomUser API를 활용하여 사용자 리스트를 조회·관리하는 iOS 애플리케이션입니다.
리스트 필터링, 페이지네이션, 삭제, 레이아웃 전환, 사진 상세 보기 등 요구사항을 충족하도록 구현했습니다.

⸻

🛠 개발 환경
-	Language: Swift
- 	UI Framework: UIKit
-  	Minimum iOS Version: iOS 15.0
-  	rchitecture: MVC (ViewController 중심 상태 관리)
- 	Async: Swift Concurrency (async/await)
- 	Package Manager: Swift Package Manager

⸻

📦 사용한 오픈소스
라이브러리       사용 목적
SnapKit       Auto Layout DSL을 통한 UI 코드 가독성 및 유지보수성 향상
Kingfisher    이미지 비동기 로딩 및 메모리/디스크 캐싱 처리

✨ 주요 기능

1. 사용자 리스트 조회
-	RandomUser API를 사용하여 사용자 리스트 조회
- 	gende +	page 기반 페이지네이션

3. 탭 & 스와이프
-	상단 UISegmentedControl + UIPageViewController
-	좌우 스와이프 및 탭 선택 시 해당 리스트로 이동

4. Pull To Refresh
-	UIRefreshControl을 사용한 새로고침
-	새로고침 시 리스트 초기화 → 완전히 새로운 데이터 시퀀스

5. Infinite Scroll
-	스크롤 하단 도달 시 자동 페이지 로드
-	login 정보의 uuid 기반 중복 제거 및 순서 유지

6. 리스트 편집 및 삭제
-	하단 Toolbar를 통한 Edit / Delete 제어
-	멀티 선택 삭제
-	삭제 전 Confirm Alert 제공
-	삭제된 항목은 이후 페이지네이션에서도 재노출되지 않도록 처리

7. 1단 / 2단 레이아웃 전환
-	UICollectionView Compositional Layout 사용
-	플로팅 버튼을 통해 1단/2단 레이아웃 전환
-	모든 탭에 공통으로 적용

8. 이미지 상세 보기
-	셀 선택 시 사진 상세 화면 표시
-	UIScrollView 기반 확대/축소 (최대 2배)
-	더블 탭으로 줌 토글
-	Kingfisher 캐시를 활용한 빠른 이미지 표시

⸻

🧠 주요 설계 포인트

Diffable Data Source (Snapshot)
-	리스트 상태를 단일 source of truth(items)로 관리
- 	삭제, 추가, 페이지네이션 시 안정적인 애니메이션 제공
- 	eloadData() 대신 Snapshot 기반 업데이트 사용

Container 중심 제어
-	상단 NavigationBar는 ContainerViewController에서 단일 관리
-	하단 Toolbar를 통해 현재 페이지(UserListVC)를 제어
-	Page 전환 시 편집 상태 자동 초기화

⸻

📂 프로젝트 구조
- App
	- AppDelegate.swift
	- SceneDelegate.swift

- Container
	- UsersContainerViewController.swift

- List
	- UserListViewController.swift
	- UserCell.swift

- Detail
	- PhotoDetailViewController.swift

- Network
	- RandomUserAPI.swift

- Model
	- UserListItem.swift
	-  Gender.swift
	- LayoutMode.swift

🚀 실행 방법
1.	Xcode 15 이상에서 프로젝트 열기
2.	Swift Package Manager를 통해 SnapKit, Kingfisher 자동 설치	
3.	iOS 15 이상 시뮬레이터 또는 실제 기기에서 실행

⸻

🙌 마무리

본 과제는 UIKit 기반 환경에서 실무에서 자주 사용하는
-	리스트 상태 관리
-	비동기 네트워크 처리
-	페이지네이션
-	사용자 인터랙션 처리

를 중심으로 구현하였습니다.

읽어주셔서 감사합니다.
  

# mohaeng_app_service

AI Expo `모행` Flutter 앱 프로젝트입니다.  
인증(일반/소셜), 메인(여행 코스/블로그/유저 정보), 로드맵(여행 계획 입력), 마이페이지 기능을 포함합니다.

## 기술 스택

- Flutter, Dart (`sdk: ^3.10.1`)
- 상태/구조: Feature 기반 + Data/Domain/Presentation 분리 + Riverpod(StateNotifier)
- Networking: Dio, Interceptor(토큰 자동 첨부/갱신)
- Local storage: flutter_secure_storage
- Code generation: json_serializable, build_runner
- 기타: flutter_screenutil, flutter_dotenv, kakao/naver/google 로그인 SDK

## 시작하기

### 1) 의존성 설치

```bash
flutter pub get
```

### 2) `.env` 파일 준비

프로젝트 루트의 `.env`에 아래 키를 설정합니다.

```env
BASE_URL=https://your-api-host
KAKAO_NATIVE_KEY=your_kakao_native_key
ANDROID_GOOGLE_KEY=your_google_server_client_id
```

- `BASE_URL`: 백엔드 API 기본 URL
- `KAKAO_NATIVE_KEY`: 카카오 SDK 초기화 키
- `ANDROID_GOOGLE_KEY`: 안드로이드 구글 로그인 `serverClientId`(선택 값, 없으면 기본값 사용)

### 3) 앱 실행

```bash
flutter run
```

## 프로젝트 구조

```text
lib/
  core/
    constants/      # 라우트 상수
    mohaeng/        # 색상, 텍스트 스타일, 이미지 상수
    network/        # API 클라이언트, 인터셉터, 에러 매핑
    widgets/        # 공통 레이아웃/탭 위젯
  features/
    auth/           # 로그인/회원가입/소셜 로그인
    main/           # 메인 화면, 코스/블로그/유저 조회
    roadmap/        # 여행 계획 입력 플로우
    mypage/         # 마이페이지
    splash/         # 스플래시
  main.dart         # 앱 진입점/라우트 등록
```

## 주요 라우트

`lib/core/constants/app_routes.dart` 기준:

- `/splash`
- `/login`, `/signup`
- `/main`, `/root`
- `/roadmap`
- `/roadmap/schedule`
- `/roadmap/people`
- `/roadmap/companion`
- `/roadmap/concept`
- `/roadmap/travel-style`
- `/roadmap/budget-range`
- `/roadmap/additional-request`

## 로드맵 플로우

현재 연결된 여행 계획 입력 흐름:

1. 지역 선택
2. 일정 선택
3. 인원 선택
4. 동행자 선택
5. 여행 컨셉 선택
6. 여행 스타일 선택
7. 예산 범위 입력
8. 추가 요청 사항 입력

## 네트워크/인증 메모

- `BASE_URL` 미설정 시 앱 초기화/요청 단계에서 예외가 발생합니다.
- 인증 요청은 `Authorization: Bearer <token>` 자동 첨부됩니다.
- 401 응답 시 refresh 토큰으로 재발급 후 1회 재시도합니다.
- 주요 API 엔드포인트 prefix는 `/api/v1`입니다.

## 개발 명령어

### 정적 분석

```bash
flutter analyze
```

### 코드 생성(json_serializable)

모델 변경 시:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 에셋/폰트

- 이미지: `assets/images/**`
- 폰트: `Pretendard`, `GmarketSansBold`, `GmarketSansMedium`

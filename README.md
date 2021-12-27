# Emotraction Client

Emotraction Project의 Client Github

## 프로젝트 목표: 음성대화로부터 기쁨, 슬픔, 화남과 같은 감정을 인식하고, 채팅 형태로 표시하기

서버 Github: [EmotractionServer](https://github.com/excited-hyun/EmotractionServer)<br>
클라이언트 Github(현재 페이지): [EmotractionApp](https://github.com/FirstDo/Emotraction)

## Team Emotraction
### 구성원
팀장: 강주형<br>
팀원: 신나현, 조보현, 김도연

### 역할
- 서버: 신나현<br>
- ML모델개발: 조보현, 강주형<br>
- 클라이언트(iOS App): 김도연<br>

## 개발환경
Xcode13, target: iOS 14.0 ~
#### 개발언어
Swift

#### 사용한 라이브러리
- Speech
- Chart
- Firebase(Auth, FireStore)

### 앱 작동 순서 
1. 입력된 음성을 텍스트로 변환(Speech framework 사용) + (영어 모델을 사용했을 경우, Naver Papago api를 이용해서 번역)
2. 변환된 텍스트를 포함해서 서버에 POST 요청을 보내고 결과감정값을 얻음
3. 결과감정값을 서버에 저장하고, FirebaseCloud에 업로드
4. FirebaseCloud에 있는 데이터를 화면에 표시

### 왼쪽(단일감정값을 추출하는 KoBert 모델) 오른쪽
![EmotractionResult](https://user-images.githubusercontent.com/69573768/147467617-d9470584-537b-44d6-a0e1-71a2a1b8e045.gif)

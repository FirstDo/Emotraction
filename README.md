# Emotraction Team Project

## 서강대학교 4-2 캡스톤디자인2 프로젝트

팀장: 강주형
팀원: 신나현, 조보현, 김도연

## 프로젝트 목표: 기쁨, 슬픔, 화남과 같은 감정을 인식하는 기술 개발

1. 대화는 음성으로 이루어지며, 사용자의 음성 및 텍스트로부터 감정을 추출
2. 추출된 감정을 시각화하여 표시

## 해야할일
1. 음성 -> 텍스트 변환 => 여러 api중 인식률이 가장 높은걸 사용해보자. 일단 apple의 기본 speech 모듈 사용하였음
2. 텍스트에서 감정추출 => koBert모델과 aiHub의 코퍼스로 모델을 만들었음 + colab으로 모델 학습완료
3. 모델을 동작시킬 서버 구축 => 학교에서 gpu서버를 대여
4. 앱 -> 서버 통신. rest api 방식으로 통신
5. 감정의 시각화

## 더 개선할점
1. 음성 -> 텍스트 변환후 추출이 아닌, 음성자체에서 추출하는 방법 생각해보기
2. 감정 시각화 방법 생각해보기


## 서버동작방법

서버유효기간:  최소 12/15일까지는 보장

#### 서버에 접속후, 가상환경을 실행하고, 모델에 맞는 파이썬 코드를 실행

#### 접속방법

id = s20171601<br>
pw = id와 동일<br>
ip = 163.239.28.25<br>
포트번호 = 22<br>

ssh [id]@[ip] -p [portNum]

#### 가상환경 생성방법

virtualenv myenv --python=python3

#### 가상환경 실행

venv-python3 폴더로 이동후

source bin/activate

앱에서 선택한 모델에 맞는 파이썬 코드 실행
python TestEmotion.py => 7가지 감정분류
python NewEmotion.py => 3가지 감정분류



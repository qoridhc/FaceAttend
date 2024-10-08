# face_check

A new Flutter project.


1. **:golf: 프로젝트 소개**

2. :star:  **주요 기능**

3. :closed_book:**시스템 아키텍처**

## :golf: 프로젝트 소개

#### 학생의 얼굴을 자동으로 인식하고 판별하여 해당학생의 출결정보를 자동으로 업데이트 하는 어플리케이션

#### 일일이 블루투스를 키고 출결앱을 켜야했던 기존 출석체크 방식을 개선한 편리한 출석체크 방식 구현

## :star: 주요 기능

#### 얼굴 인식

- 학생의 얼굴을 자동으로 인식

#### 얼굴 판별

- 얼굴 인식이 이루어진 학생이 어떤학생인지 판별

#### 자동 출석체크

- 얼굴 인식이 성공적으로 이루어지면 해당학생의 출결정보를 DB에 업데이트하여 자동 출석체크를 구현함

## :closed_book:시스템 아키텍처
![image](https://github.com/user-attachments/assets/2709a459-3ef9-47ed-9b5f-a67422907013)

## 모델 선정 이유
- 얼굴인식 관련 다양한 모델 중 어떤 모델이 가장 성능이 좋은지 자체 테스트를 진행
- 테스트 결과 RetinaFace모델이 가장 우수한 성능을 보여주는것을 확인
  
![image](https://github.com/user-attachments/assets/79f39e95-a5e6-48a7-9505-452eea7fa672)

## 얼굴 판별 플로우
![image](https://github.com/user-attachments/assets/402b3f41-37fc-408d-9a7e-9c5a7702f1e0)

## 얼굴 인식 결과

![image](https://github.com/user-attachments/assets/72d53007-0359-4ffa-b787-4370338aad03)
- 다수의 인원 얼굴 인식 성능 95% 이상
  
![20240918_213824](https://github.com/user-attachments/assets/4f2f8650-dbfa-4819-b973-705f96e70fe0)
- 얼굴 판별 구현 결과

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

얼굴인식에 필요한 준비(파이썬 3.9로)
- anacoda 설치 및 가상환경 [https://stcodelab.com/entry/Anaconda-%EC%84%A4%EC%B9%98-Python-%EA%B0%80%EC%83%81-%ED%99%98%EA%B2%BD-%EC%84%A4%EC%A0%95]
- conda 설칠 목록: tensorflow-gpu(버전 맞게)
- cuda 설치 [https://separang.tistory.com/112]
- cudnn 설치 (로그인 필수) [https://separang.tistory.com/113]
- tsnsorflow gpu 버전 [https://www.tensorflow.org/install/source_windows#gpu]
- pip 설치 목록 :numpy, pillow, matplotlib, deepface, mtcnn, opencv-python, cmake
- 명령어: pip install [설치할 라이브러리]

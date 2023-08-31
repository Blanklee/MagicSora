# MagicSora
- Network Port Check Program
- 나의 Device로부터 Server별 Port별 Open/Close 여부를 Check함


# Release Note

ver 1.0 - Create App
 . Date : 2018.05.01 밤
 . 처음 작성, Screen Design, Server 1개 및 Port 1개 입력 \
 . Run 클릭시 Socket Message 그대로 출력, Open/Close 여부를 알수있음 \
 . IdTCPClient 및 IdLogEvent 놓고 구현해봄 (IdTelnet, IdFTP도 놓았으나 미사용)

-ver 1.1 / 2018.05.10 새벽, 오전
 . Screen을 Landscape(가로)로 전환
 . 불필요한 IdLogEvent, IdTelnet, IdFTP 삭제, IdLogEvent 관련함수 삭제
 . Project 이름을 MagicSora로 변경
 . TClient 작성, IdTCPClient 및 ListViewItem 포함, 주요부분 구현
 . ConnectTimeout, ReadTimeout 모두 3초로 주어 빠른 결과 출력
 . MainForm에서는 array of Client 및 ListView 관리
 . ListViewItem의 Button을 누르면 해당 Port만 Check


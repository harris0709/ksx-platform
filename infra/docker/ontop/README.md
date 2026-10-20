# Ontop JDBC 드라이버

Ontop 컨테이너에는 PostgreSQL JDBC 드라이버를 넣어야 합니다.
https://jdbc.postgresql.org 에서 `postgresql-<버전>.jar`를 받아 이 폴더의 `jdbc/`에 둡니다(망분리 시 반입).
compose가 `jdbc/`를 `/opt/ontop/jdbc`로 마운트합니다.

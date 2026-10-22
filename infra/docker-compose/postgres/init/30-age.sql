-- Apache AGE (S8 속성 그래프). apache/age 이미지에서만 설치되며, 없으면 건너뛴다.
-- 서버 전체 preload 는 하지 않으므로, AGE 를 쓰는 세션은 LOAD 'age'; 로 시작한다.
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_available_extensions WHERE name = 'age') THEN
    CREATE EXTENSION IF NOT EXISTS age;
    RAISE NOTICE 'AGE extension installed';
  ELSE
    RAISE WARNING 'AGE extension not available in this image — S8 전에 apache/age 이미지 사용 필요';
  END IF;
END $$;

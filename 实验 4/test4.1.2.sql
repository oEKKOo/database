CREATE TABLE course (
    Cno INT NOT NULL AUTO_INCREMENT PRIMARY KEY,  -- 课程号，主码，自增
    Cname VARCHAR(40) NOT NULL,                   -- 课程名
    credit FLOAT(255, 1) NOT NULL                 -- 学分，保留一位小数
);

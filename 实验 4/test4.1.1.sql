CREATE TABLE teacher (
    Tno INT NOT NULL PRIMARY KEY,            -- 工号，主码
    Tname VARCHAR(20) NOT NULL,              -- 姓名
    gender CHAR(1) NOT NULL,                 -- 性别
    age TINYINT NOT NULL,                    -- 年龄
    institute VARCHAR(40) NOT NULL,          -- 院系
    professional_title VARCHAR(20) NOT NULL  -- 职称
);

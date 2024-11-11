CREATE TABLE sc (
    Sno INT NOT NULL,                          -- 学号，主码，外键
    Cno INT NOT NULL,                          -- 课程号，主码，外键
    grade FLOAT(255, 2),                       -- 分数，保留两位小数，可为空
    PRIMARY KEY (Sno, Cno),                    -- 复合主键
    FOREIGN KEY (Sno) REFERENCES student(Sno), -- 学号外键引用学生表的Sno
    FOREIGN KEY (Cno) REFERENCES course(Cno)   -- 课程号外键引用课程表的Cno
);

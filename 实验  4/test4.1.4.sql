CREATE TABLE tc (
    Tno INT NOT NULL,                          -- 工号，主码，外键
    Cno INT NOT NULL,                          -- 课程号，主码，外键
    PRIMARY KEY (Tno, Cno),                    -- 复合主键
    FOREIGN KEY (Tno) REFERENCES teacher(Tno), -- 工号外键引用教师表的Tno
    FOREIGN KEY (Cno) REFERENCES course(Cno)   -- 课程号外键引用课程表的Cno
);

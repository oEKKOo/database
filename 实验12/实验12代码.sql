②在sc表上定义一个DELETE触发器，删除学生选修课程明细时，自动修改student表中该学生的总学分credit，以保持数据的一致性。
定义相应的触发器并验证触发器的有效性。
1）创建触发器
在 sc 表上定义一个 AFTER DELETE 的触发器，用于在删除选课信息时，自动更新 student 表中的总学分 credit。
CREATE TRIGGER trg_after_delete_sc
AFTER DELETE ON sc
FOR EACH ROW
BEGIN
    -- 如果被删除的记录的成绩大于等于60，更新student表中的credit
    IF OLD.grade >= 60 THEN
        UPDATE student
        SET credit = credit - 4  -- 假设每门课程的学分为4
        WHERE Sno = OLD.Sno;
    END IF;
END;

2）验证触发器的效果
首先查询 student 表中某学生的总学分，例如：
SELECT * FROM student WHERE Sno = '2020102001';

3）从sc表删除数据：
DELETE FROM sc
WHERE Sno = '2020102001' AND Cno = '18';  

4）查询student表：
SELECT * FROM student WHERE Sno = '2020102001';

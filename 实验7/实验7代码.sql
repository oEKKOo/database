/*三、课后练习题
1、建立选修数据库课程的视图。*/
CREATE VIEW db_system_students AS
SELECT 
  Sname,  Cname, grade
FROM 
    sc_grade
WHERE 
    Cname = '数据库系统原理';

/*、建立属于计算机科学与技术学院学生的视图，并要求进行修改和插入操作时仍须保证该视图只有数统学院的学生。*/
CREATE VIEW cs_students AS
SELECT 
    Sno, Sname, gender, age, institute, major, `class`, credit
FROM 
    student
WHERE 
    institute = '计算机科学与技术学院';

/*插入触发器：*/
DELIMITER $$

CREATE TRIGGER cs_students_update
BEFORE UPDATE ON student
FOR EACH ROW
BEGIN
    IF NEW.institute != '数统学院' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = '只能修改为数统学院的学生';
    END IF;
END$$

DELIMITER ;
/*尝试插入操作：*/
INSERT INTO student (Sno, Sname, gender, age, institute, major, `class`, credit)
VALUES ('2023001', '张三', '男', 20, '数统学院', '数学与应用数学', '2023', 25);

/*测试修改操作：*/
UPDATE student
SET institute = '数统学院'
WHERE Sno = '2023001';

/*如果试图插入或更新非数统学院的学生记录，触发器将报错。*/

/*3、建立选修数据库系统原理课程且成绩在90分以上的选修视图。*/

CREATE VIEW db_system_top_students AS
SELECT 
    Sname, Cname, grade
FROM 
    sc_grade
WHERE 
    Cname = '数据库系统原理' 
    AND grade > 90;

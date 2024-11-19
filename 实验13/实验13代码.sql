2、自定义函数实验：自定义函数定义，自定义函数运行，自定义函数更名，自定义函数删除，自定义函数的参数传递。掌握PL/SQL和编程规范，规范设计自定义函数。
1）定义函数查询职称为“讲师”的教师姓名：
使用函数查询 teacher 表中职称为“讲师”（professional_title = '讲师'）的教师姓名。
DELIMITER $$

CREATE FUNCTION GetLecturers()
RETURNS VARCHAR(1000) DETERMINISTIC
BEGIN
    DECLARE result VARCHAR(1000);
    SELECT GROUP_CONCAT(Tname) INTO result
    FROM teacher
    WHERE professional_title = '讲师';
    RETURN result;
END$$

DELIMITER ;

2）测试函数运行
调用定义的函数 GetLecturers 查询职称为“讲师”的教师姓名：
SELECT GetLecturers();

3）使用函数更改职称为“副教授”
编写存储过程，将 professional_title 从“讲师”修改为“副教授”。
创建存储过程：
DELIMITER $$

CREATE PROCEDURE UpdateToAssociateProfessor()
BEGIN
    UPDATE teacher
    SET professional_title = '副教授'
    WHERE professional_title = '讲师';
END$$

DELIMITER ;

执行存储过程：
CALL UpdateToAssociateProfessor();
验证更新结果：
SELECT * FROM teacher WHERE professional_title = '副教授';

4）更名自定义函数
重新创建新函数或删除旧函数：
删除旧函数：
DROP FUNCTION IF EXISTS GetLecturers;
重新创建新函数：
DELIMITER $$

CREATE FUNCTION GetAssociateProfessors()
RETURNS VARCHAR(1000) DETERMINISTIC
BEGIN
    DECLARE result VARCHAR(1000);
    SELECT GROUP_CONCAT(Tname) INTO result
    FROM teacher
    WHERE professional_title = '副教授';
    RETURN result;
END$$

DELIMITER ;

5）删除函数
DROP FUNCTION IF EXISTS GetAssociateProfessors;
删除存储过程：
DROP PROCEDURE IF EXISTS UpdateToAssociateProfessor;
6）恢复原始数据
UPDATE teacher
SET professional_title = '讲师'
WHERE professional_title = '副教授';
验证恢复：
SELECT * FROM teacher WHERE professional_title = '讲师';




四、课后习题
1、尝试定义无参数的存储过程、有局部变量的存储过程、有输出参数的存储过程，执行相应存储过程并查看存储过程执行结果。
1）定义无参数的存储过程：
无参数存储过程：查询 teacher 表中所有教师信息。
创建存储过程：
DELIMITER $$
CREATE PROCEDURE GetAllTeachers()
BEGIN
    SELECT * FROM teacher;
END$$
DELIMITER ;
执行存储过程：
CALL GetAllTeachers();

3）定义有局部变量的存储过程
有局部变量的存储过程：计算 teacher 表中职称为“讲师”的教师人数。
创建存储过程：
DELIMITER $$

CREATE PROCEDURE CountLecturers()
BEGIN
    DECLARE lecturer_count INT;  -- 声明局部变量
    SELECT COUNT(*) INTO lecturer_count
    FROM teacher
    WHERE professional_title = '讲师';
    SELECT lecturer_count AS 'Number of Lecturers'; -- 返回结果
END$$

DELIMITER ;
执行存储过程：
CALL CountLecturers();

4）定义有输出参数的存储过程
有输出参数的存储过程：根据教师编号返回对应教师的姓名。
创建存储过程：
DELIMITER $$

CREATE PROCEDURE GetTeacherName(IN teacher_id VARCHAR(10), OUT teacher_name VARCHAR(50))
BEGIN
    SELECT Tname INTO teacher_name
    FROM teacher
    WHERE Tno = teacher_id;
END$$

DELIMITER ;
执行存储过程：
-- 声明一个变量用于接收输出结果
SET @teacher_name = NULL;
-- 调用存储过程
CALL GetTeacherName('2008156246', @teacher_name);
-- 查看输出参数的值
SELECT @teacher_name;
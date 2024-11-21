二、实验内容
1.数据库查询性能调优实验：学会使用EXPLAIN命令分析查询执行计划、利用索引优化查询性能、优化SQL语句，以及理解和掌握数据库模式规范化设计对查询性能的影响。能针对给定的数据库模式，设计不同的示例验证查询性能优化效果。
（1）使用EXPLAIN命令查看查询执行计划
查看student、course、sc三个表连接查询的查询执行计划。

该SQL语句时要查询学生名字为’范星河’的学生相关信息、选修课程相关信息和课程成绩，并按照课程成绩（降序），排序输出结果。

EXPLAIN 
SELECT 
    student.sno, 
    student.sname, 
    course.cname, 
    sc.grade
FROM 
    student
JOIN 
    sc ON student.sno = sc.sno
JOIN 
    course ON sc.cno = course.cno;

(2)利用索引优化查询性能
利用索引实验创建的索引进行SQL查询，优化SQL查询性能。比较在student表的Sname上有索引和无索引时，两种执行计划有何异同，并实际执行该查询，验证有索引和无索引时此查询语句的执行性能。
1. 初始查询语句
SELECT * 
FROM student 
WHERE sname = '范星河';

查看无索引时的查询执行计划:
EXPLAIN 
SELECT * 
FROM student 
WHERE sname = '范星河';


-- 无索引查询
SELECT * 
FROM student 
WHERE sname = '范星河';

-- 创建索引后查询
CREATE INDEX idx_sname ON student(sname);

SELECT * 
FROM student 
WHERE sname = '范星河';


（3）优化SQL语句
①IN与EXISTS查询：一般地使用EXISTS查询效率要高于IN查询。分别利用IN和EXISTS进行SQL查询，比较两种执行计划，并实际测试执行性能哪种情况好。
使用 IN 查询
EXPLAIN 
SELECT * 
FROM student 
WHERE sno IN (
    SELECT sno 
    FROM sc 
    WHERE institute = '软件学院'
);

使用 EXISTS 查询
EXPLAIN 
SELECT * 
FROM student s
WHERE EXISTS (
    SELECT 1 
    FROM sc 
    WHERE sc.sno = s.sno 
      AND institute ='软件学院'
);


结论：
·  IN 更适合子查询返回较少结果的场景。
·  EXISTS 更适合子查询结果较大或涉及复杂逻辑的场景，性能通常优于 IN。

②尽可能使用不相关子查询，避免使用相关子查询。不相关子查询一般比相关子查询执行效率高，在可能的情况下，改写相关子查询为不相关子查询。比较两种执行计划，并实际测试执行性能哪种情况好。
相关子查询：
SELECT sname 
FROM student 
WHERE sno IN (
    SELECT sno 
    FROM sc 
    WHERE grade > (
        SELECT AVG(grade) 
        FROM sc
    )
);

不相关子查询：
SET @avg_grade = (SELECT AVG(grade) FROM sc);

SELECT sname 
FROM student 
WHERE sno IN (
    SELECT sno 
    FROM sc 
    WHERE grade > @avg_grade
);

·  不相关子查询 性能明显优于相关子查询，特别是在处理大数据量时。
·  通过优化，将相关子查询改写为不相关子查询，可以显著提高查询效率。
·  该实验验证了提前计算常用结果（如 @avg_grade）是一种有效的性能优化手段。

（4）数据库模式规范化对查询性能的影响
分析该数据库模式中是否存在不规范的设计。该设计在海量数据的情况下查询效率咋样？如何在设计上进一步提高海量数据的查询效率？
第三范式在一定程度上减少了不必要的冗余，提高了数据库的查询效率，但是如果数据量大且需要大量联合查询的时候，第三范式设计又可能会影响查询效率。

2.（了解）数据库性能监视实验：使用MySQL的数据库性能监视工具，通过标准统计视图和统计访问函数查看数据库系统收集到的性能统计信息、ANALYZE更新数据库统计信息，通过专门工具监视系统性能。希望能够熟悉数据库系统有关性能统计信息的标准视图和统计访问函数，了解如何通过系统收集到的性能数据监视系统性能。
3.（了解）数据库系统配置参数调优实验：熟悉和了解数据库各级参数的作用以及配置，包括系统级参数配置和调优、数据库级参数配置和调优、会话（连接）级参数配置和调优。
三、课后习题
1.对表数据的高级查询实验中的查询，使用不同的SQL语句来表达，比较它们的查询效率，体会并总结查询优化的技巧和方法。
使用 IN 查询：

SELECT sname 
FROM student 
WHERE sno IN (
    SELECT sno 
    FROM sc 
    WHERE cno = 1
);


使用 EXISTS 查询：
SELECT sname 
FROM student s
WHERE EXISTS (
    SELECT 1 
    FROM sc 
    WHERE sc.sno = s.sno AND cno = 1
);




使用内连接：

SELECT s.sname 
FROM student s
JOIN sc 
ON s.sno = sc.sno
WHERE sc.cno = 1;



使用半连接（WITH 子句）：
WITH Temp AS (
    SELECT sno 
    FROM sc 
    WHERE cno = 1
)
SELECT s.sname 
FROM student s
JOIN Temp 
ON s.sno = Temp.sno;
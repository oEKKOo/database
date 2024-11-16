/*练习巩固
7、查询course表中学分（credit）为2分的课程的课程名Cname和学分credit。*/
SELECT Cname, credit
FROM course
WHERE credit = 2;

/*8、student表中查询前20个软件学院学生的姓名。*/
SELECT Sname
FROM student
WHERE institute = '软件学院'
LIMIT 20;

/*9、student表中查询软件学院所有学生的姓名和总学分，并要求对查询结果按总学分的降序排列。*/
SELECT Sname, credit
FROM student
WHERE institute = '软件学院'
ORDER BY credit DESC;

/*10、student表中查询总学分介于15和30之间的学生的名字、院系和专业以及总学分。*/
SELECT Sname, institute, major, credit
FROM student
WHERE credit BETWEEN 15 AND 30;

/*11、查询名称以“汪”开头的属于软件学院或属于计算机科学与技术学院的学生姓名和院系。*/
SELECT Sname, institute
FROM student
WHERE Sname LIKE '汪%' 
  AND (institute = '软件学院' OR institute = '计算机科学与技术学院');


/*三、课后练习题
以下题目在数据库hub中完成。
1、查询teacher表中所有软件学院教师的名字、职称、年龄，要求查询结果按年龄的升序排列。*/
USE hub;

SELECT Tname, professional_title, age
FROM teacher
WHERE institute = '软件学院'
ORDER BY age ASC;


/*2、查询student表中属于数学与统计学院或机械科学与工程学院的学生姓名。*/
USE hub;

SELECT Sname
FROM student
WHERE institute = '数学与统计学院' OR institute = '机械科学与工程学院';



/*3、查询SC表中grade字段大于90分的全部信息.*/
USE hub;

SELECT *
FROM SC
WHERE grade > 90;

/*2、试将表course中的所有记录插入到表newcourse中去。*/
INSERT INTO newcourse
SELECT * FROM course;

/*3、在表newcourse中插入马克思主义基本原理，其内容为Cname为马克思主义基本原理，credit为4。 */
INSERT INTO newcourse (Cno, Cname, credit)
VALUES (32, '马克思主义基本原理', 4);


/*4、将表newcourse中credit为“2”的课程的credit改为2.5。*/
UPDATE newcourse
SET credit = 2.5
WHERE credit = 2;

/*5、将表newcourse中课程的credit均加上0.5。*/
UPDATE newcourse
SET credit = credit + 0.5;

/*6、删除表newcourse中课程名为复变函数的课程。*/
DELETE FROM newcourse
WHERE Cname = '复变函数';

/*三、课后练习题
以下题目在数据库hub中完成。
1、通过Navicat，在newcourse输入10条记录。*/
INSERT INTO newcourse (Cno, Cname, credit) VALUES
(11, '数学分析', 4),
(12, '线性代数', 3),
(13, '大学物理', 5),
(14, '计算机导论', 2),
(15, '数据结构', 4),
(16, '操作系统', 3),
(17, '数据库原理', 3),
(18, '概率论与数理统计', 3),
(19, '离散数学', 4),
(20, '英语听说', 2);

/*2、插入一条课程记录（“null”，“大学英语”，3）到表newcourse。*/
INSERT INTO newcourse (Cno, Cname, credit)
VALUES (1, '大学英语', 3);

/*3、清空表newcourse的所有记录。*/
TRUNCATE TABLE newcourse;

/*4、删除表newcourse。*/
DROP TABLE newcourse;


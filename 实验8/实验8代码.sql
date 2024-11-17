/*三、课后练习题
1.用Navicat和SQL语言两种方式将数据库hub中teacher表的age字段的数据类型改为int.*/
USE hub;
ALTER TABLE teacher
MODIFY COLUMN age INT;

/*2. 在MySQL中建立一个表，有一列为float(5, 3).做以下试验：
	①插入12.345，成功则查询该表得到结果；
	②插入12.3456，成功则查询该表得到结果；
	③插入123.456，成功则查询该表得到结果。
	比较三次结果的差异，并分析原因*/
/*创建test表：*/
CREATE TABLE test (
    value FLOAT(5, 3) -- 定义一个浮点列，5 位总宽度，其中小数部分占 3 位
);
/*①插入12.345，成功则查询该表得到结果；*/
INSERT INTO test (value) VALUES (12.345);
SELECT * FROM test;

/*原因：该值符合 FLOAT(5, 3) 的定义，满足总宽度 5 位，小数部分 3 位，因此成功存储且值不变。
②插入12.3456，成功则查询该表得到结果；*/
INSERT INTO test (value) VALUES (12.3456);
SELECT * FROM test;

/*原因：FLOAT(5, 3) 定义的小数部分只能存储 3 位，MySQL 会对多余的小数部分进行四舍五入，因此 12.3456 被四舍五入为 12.346。
③插入123.456，成功则查询该表得到结果。*/
INSERT INTO test (value) VALUES (123.456);
SELECT * FROM test;
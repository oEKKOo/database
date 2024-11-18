三、课后习题
1.在一个表的多个字段上创建的复合索引，与相应的每个字段上创建的多个简单索引有何异同？请设计相应的例子加以验证。
在已给的teacher表中进行索引：
创建简单索引和复合索引：
-- 简单索引
CREATE INDEX idx_gender ON teacher(gender);
CREATE INDEX idx_age ON teacher(age);
CREATE INDEX idx_institute ON teacher(institute);

-- 复合索引
CREATE INDEX idx_gender_age_institute ON teacher(gender, age, institute);




测试查询性能：

-- 使用简单索引
EXPLAIN SELECT * FROM teacher WHERE gender = '男';
EXPLAIN SELECT * FROM teacher WHERE age = 30;
EXPLAIN SELECT * FROM teacher WHERE gender = '男' AND age = 30;

-- 使用复合索引
EXPLAIN SELECT * FROM teacher WHERE gender = '男' AND age = 30 AND institute = '软件学院';
EXPLAIN SELECT * FROM teacher WHERE age = 30 AND institute = '软件学院'; -- 注意此时复合索引未完全匹配


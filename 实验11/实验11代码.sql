三、课后练习题
1、使用两个不同的用户通过Navicat和查询分析器查看hub数据库中student、course两个表的所有数据。
用户elm查看hub数据库中student,course表：
用户data查看hub数据库中student,course表:
2、删除用户xmuser，尝试新建另一个用户来管理数据库、表等：
添加新用户对数据库hub的权限，比较在有无相关权限的情况之下进行操作的区别：
①Create。尝试新建表
②Update。尝试修改表数据或结构
③……..（自行设计，总共尝试5组，进行对比）
1.删除用户 xmuser：
DROP USER 'xmuser'@'localhost';
2.创建新用户并赋权:
新建用户：
    CREATE USER 'dbmanager'@'localhost' IDENTIFIED BY 'password123';
 	给用户赋予 hub 数据库的权限：
    GRANT ALL PRIVILEGES ON hub.* TO 'dbmanager'@'localhost';
FLUSH PRIVILEGES;
3.不赋权的情况下操作：
创建一个新用户，无权限操作:
CREATE USER 'testuser'@'localhost' IDENTIFIED BY 'password456';

4.  设计5组操作对比：
  ① Create：尝试新建表
  有权限：
-- 使用 dbmanager 用户
USE hub;
CREATE TABLE test_table (
    id INT PRIMARY KEY,
    name VARCHAR(50)
);
无权限：
-- 使用 testuser 用户
USE hub;
CREATE TABLE test_table (
    id INT PRIMARY KEY,
    name VARCHAR(50)
);-- 预期错误：ERROR 1044 (42000): Access denied for user 'testuser'@'localhost'
② Update：修改表数据或结构
有权限：
-- 修改表数据
INSERT INTO test_table (id, name)VALUES (1, 'Alice');
UPDATE test_table SET name = 'Bob' WHERE id = 1;
-- 修改表结构
ALTER TABLE test_table ADD COLUMN age INT;
无权限：
-- 修改表数据
UPDATE test_table SET name = 'Charlie' WHERE id = 1;
-- 修改表结构
ALTER TABLE test_table DROP COLUMN age;
-- 预期错误：Access denied

③ Select：查询表数据
有权限：
SELECT * FROM test_table;
无权限：
SELECT * FROM test_table;-- 预期错误：Access denied

④ Drop：删除表
有权限：
DROP TABLE test_table;
无权限：
DROP TABLE test_table;-- 预期错误：Access denied

⑤ Grant：赋予权限
有权限（需有 GRANT OPTION 权限）：
GRANT SELECT ON hub.test_table TO 'anotheruser'@'localhost';
无权限：
GRANT SELECT ON hub.test_table TO 'anotheruser'@'localhost';-- 预期错误：Access denied
实验结果与对比：
有权限的用户可以顺利完成表的创建、更新、查询、删除等操作。
无权限的用户在操作时均会收到 Access denied 错误，无法对数据库或表进行任何修改。
权限管理有效地保障了数据库的安全性和操作的可控性。

四、思考题
1、解释10个数据库操作权限的含义和影响。
1.SELECT
含义：允许用户读取表或视图中的数据。
影响：只提供数据查询能力，适合需要分析或查看数据但不进行修改的用户，确保数据完整性。
2.INSERT
含义：允许用户向表中插入新记录。
影响：用户可以添加数据，但无法修改或删除已有数据，适合日志记录等场景。
3.UPDATE
含义：允许用户修改表中已有的数据。
影响：用户可以更改数据内容，适合需要实时更新数据的场景，但可能带来数据污染风险。
4.DELETE
含义：允许用户删除表中的记录。
影响：用户可移除不需要的数据，但需防止误删数据导致信息丢失。
5.CREATE
含义：允许用户创建新的数据库对象，如表、视图等。
影响：用户能扩展数据库功能，但可能因创建冗余对象导致数据库管理复杂性增加。
6.DROP
含义：允许用户删除数据库对象，如表、视图、数据库等。
影响：删除操作是不可逆的，需谨慎分配此权限以避免误删重要数据。
7.GRANT OPTION
含义：允许用户将其拥有的权限授予其他用户。
影响：适合管理员角色，但需注意避免权限滥用。
8.REVOKE
含义：允许用户收回已授予的权限。
影响：控制权限范围，提升数据库安全性。
9.ALTER
含义：允许用户修改数据库对象的结构，如表的列或索引。
影响：用户可调整数据库设计以满足需求，但需控制修改权限以防止错误操作。
10.EXECUTE
含义：允许用户运行存储过程或函数。
影响：提高了操作自动化水平，但需确保存储过程和函数的安全性。


2、试着设计一个例子，分析数据库审计对数据库性能的影响情况。
场景设计
一个电商平台的 orders 表存储了大量订单数据，需要审计所有数据操作（如 INSERT、UPDATE、DELETE），以满足数据合规性要求。
表结构：
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    order_date DATETIME,
    amount DECIMAL(10, 2)
);
启用审计功能：
配置审计以记录所有对 orders 表的修改操作：
CREATE TRIGGER audit_orders
AFTER INSERT OR UPDATE OR DELETE ON orders
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (action, order_id, timestamp, user)
    VALUES (CASE
                WHEN INSERTING THEN 'INSERT'
                WHEN UPDATING THEN 'UPDATE'
                WHEN DELETING THEN 'DELETE'
            END,
            NEW.order_id,
            NOW(),
            USER());
END;
audit_log 表：
CREATE TABLE audit_log (
    action VARCHAR(10),
    order_id INT,
    timestamp DATETIME,
    user VARCHAR(50)
);
实验步骤：
未启用审计：进行一组数据插入、更新、删除操作并记录执行时间。
-- 插入10000条记录
INSERT INTO orders (order_id, customer_id, product_id, order_date, amount)
VALUES (1, 101, 201, NOW(), 100.00), ..., (10000, 102, 202, NOW(), 150.00);
-- 测试更新和删除操作
UPDATE orders SET amount = amount * 1.1 WHERE order_id <= 5000;
DELETE FROM orders WHERE order_id > 8000;
启用审计：重复相同的操作，记录执行时间：
-- 插入10000条记录
INSERT INTO orders (order_id, customer_id, product_id, order_date, amount)
VALUES (1, 101, 201, NOW(), 100.00), ..., (10000, 102, 202, NOW(), 150.00);
-- 测试更新和删除操作
UPDATE orders SET amount = amount * 1.1 WHERE order_id <= 5000;
DELETE FROM orders WHERE order_id > 8000;
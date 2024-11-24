数据库表：
-- 账户表
CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    balance DECIMAL(10, 2),
    version INT DEFAULT 1
);

-- 订单表
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    amount DECIMAL(10, 2)
);

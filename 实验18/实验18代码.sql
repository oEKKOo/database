

2.表建立
1. Books 表
CREATE TABLE Books (
    BookID INT PRIMARY KEY, -- 主键
    Title VARCHAR(255) NOT NULL, -- 书名
    Author JSON NOT NULL, -- 作者列表，JSON格式
    Publisher VARCHAR(255) NOT NULL, -- 出版社
    Price DECIMAL(10, 2) NOT NULL CHECK (Price >= 0), -- 单价，非负
    Keywords JSON, -- 关键字列表，JSON格式
    Catalog TEXT, -- 目录，可选
    CoverImage TEXT, -- 封面图片路径，可选
    Stock INT NOT NULL CHECK (Stock >= 0), -- 库存，非负
    StorageLocation TEXT -- 存储位置，可选
);

2.BookSuppliers 表
CREATE TABLE BookSuppliers (
    SupplierID INT, -- 外键，供应商ID
    BookID INT, -- 外键，书号
    SupplyPrice DECIMAL(10, 2) NOT NULL CHECK (SupplyPrice > 0), -- 供货价格，正数
    PRIMARY KEY (SupplierID, BookID), -- 组合主键
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID), -- 供应商外键
    FOREIGN KEY (BookID) REFERENCES Books(BookID) -- 书号外键
);

3.PurchaseRequests 表
CREATE TABLE PurchaseRequests (
    RequestID INT PRIMARY KEY, -- 主键，缺书记录ID
    BookID INT NOT NULL, -- 外键，书号
    SupplierID INT, -- 外键，供应商ID，可选
    RequestDate DATE NOT NULL, -- 请求日期
    Quantity INT NOT NULL CHECK (Quantity > 0), -- 缺书数量，正数
    FOREIGN KEY (BookID) REFERENCES Books(BookID), -- 书号外键
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID) -- 供应商外键
);

4. PurchaseOrders 表

CREATE TABLE PurchaseOrders (
    OrderID INT PRIMARY KEY, -- 主键，采购订单ID
    RequestID INT NOT NULL, -- 外键，缺书记录ID
    OrderDate DATE NOT NULL, -- 下单日期
    ArrivalDate DATE, -- 到货日期，可选
    Status ENUM('Pending', 'Ordered', 'Arrived') NOT NULL, -- 状态
    FOREIGN KEY (RequestID) REFERENCES PurchaseRequests(RequestID) -- 缺书记录外键
);

5.Customers 表
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY, -- 主键，客户ID
    Password VARCHAR(255) NOT NULL, -- 登录密码
    Name VARCHAR(255) NOT NULL, -- 客户姓名
    Address VARCHAR(255) NOT NULL, -- 客户地址
    Balance DECIMAL(10, 2) NOT NULL CHECK (Balance >= 0), -- 帐户余额，非负
    CreditLevel INT NOT NULL CHECK (CreditLevel BETWEEN 1 AND 5) -- 信用等级，1-5
);

6.CreditRules 表
CREATE TABLE CreditRules (
    Level INT PRIMARY KEY, -- 主键，信用等级
    DiscountRate DECIMAL(5, 2) NOT NULL CHECK (DiscountRate BETWEEN 0 AND 1), -- 折扣率，0-1之间
    OverdraftLimit DECIMAL(10, 2) -- 透支额度，可为 NULL
);

7. Orders 表
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY, -- 主键，订单ID
    CustomerID INT NOT NULL, -- 外键，客户ID
    OrderDate DATE NOT NULL, -- 下单日期
    ShippingAddress VARCHAR(255) NOT NULL, -- 发货地址
    TotalAmount DECIMAL(10, 2) NOT NULL CHECK (TotalAmount >= 0), -- 总金额，非负
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) -- 客户外键
);

8. OrderDetails 表
CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY, -- 主键，订单明细ID
    OrderID INT NOT NULL, -- 外键，订单ID
    BookID INT NOT NULL, -- 外键，书号
    Quantity INT NOT NULL CHECK (Quantity > 0), -- 订购数量，正数
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID), -- 订单外键
    FOREIGN KEY (BookID) REFERENCES Books(BookID) -- 书号外键
);

9. Suppliers 表
CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY, -- 主键，供应商ID
    Name VARCHAR(255) NOT NULL, -- 供应商名称
    ContactInfo VARCHAR(255) NOT NULL -- 联系信息
);

10.Series (丛书表)
CREATE TABLE Series (
    SeriesID INT PRIMARY KEY, -- 丛书ID
    SeriesName VARCHAR(255) NOT NULL, -- 丛书名称
    Description TEXT, -- 丛书描述（可选）
    Stock INT NOT NULL DEFAULT 0 CHECK (Stock >= 0) -- 丛书总库存，非负
);
11.MissingRequests (顾客缺书请求表)
CREATE TABLE MissingRequests (
    RequestID INT PRIMARY KEY, -- 请求ID
    CustomerID INT NOT NULL, -- 顾客ID
    BookID INT NOT NULL, -- 缺书书号
    RequestDate DATE NOT NULL, -- 请求日期
    Status ENUM('Pending', 'Processed', 'Rejected') NOT NULL DEFAULT 'Pending', -- 请求状态
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) -- 外键，关联顾客表
    ON DELETE CASCADE, -- 删除顾客时级联删除请求
    FOREIGN KEY (BookID) REFERENCES Books(BookID) -- 外键，关联书籍表
    ON DELETE CASCADE -- 删除书籍时级联删除请求
);
12.Shipping (发货表)
CREATE TABLE Shipping (
    ShippingID INT PRIMARY KEY, -- 发货ID
    OrderID INT NOT NULL, -- 订单ID
    ShippingDate DATE NOT NULL, -- 发货日期
    Status ENUM('Pending', 'Partially Shipped', 'Shipped') NOT NULL DEFAULT 'Pending', -- 发货状态
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) -- 外键，关联订单表
    ON DELETE CASCADE -- 删除订单时级联删除发货记录
);



3.触发器设计
1. 库存更新时自动生成缺书记录
功能说明：当书籍库存量低于设定的最小库存时，自动生成缺书记录。
CREATE TRIGGER Trigger_AutoGenerateMissingRecord
AFTER UPDATE ON Books
FOR EACH ROW
BEGIN
    IF NEW.Stock < 10 THEN
        INSERT INTO PurchaseRequests (BookID, RequestDate, Quantity)
        VALUES (NEW.BookID, NOW(), 10)
        ON DUPLICATE KEY UPDATE RequestDate = NOW();
    END IF;
END;
解释：
在 Books 表中更新库存时触发。
如果库存量低于10，则在 PurchaseRequests 表中生成缺书记录。
2. 触发器：采购订单到货后更新库存
功能说明：采购订单到货时自动更新库存量并删除缺书记录。
CREATE TRIGGER Trigger_UpdateStockOnArrival
AFTER UPDATE ON PurchaseOrders
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Arrived' THEN
        UPDATE Books
        SET Stock = Stock + (
            SELECT Quantity
            FROM PurchaseRequests
            WHERE RequestID = NEW.RequestID
        )
        WHERE BookID = (
            SELECT BookID
            FROM PurchaseRequests
            WHERE RequestID = NEW.RequestID
        );

        DELETE FROM PurchaseRequests
        WHERE RequestID = NEW.RequestID;
    END IF;
END;

解释：
在 PurchaseOrders 表中状态更新为 Arrived 时触发。
更新 Books 表中的库存量，并删除对应的 PurchaseRequests 记录。
3. 触发器：客户订单扣减余额并判断信用等级
功能说明：当订单发货时扣减客户余额，并根据余额更新信用等级。

CREATE TRIGGER Trigger_DeductBalanceOnOrder
AFTER UPDATE ON Orders
FOR EACH ROW
BEGIN
    IF NEW.TotalAmount <= (
        SELECT Balance FROM Customers WHERE CustomerID = NEW.CustomerID
    ) THEN
        UPDATE Customers
        SET Balance = Balance - NEW.TotalAmount
        WHERE CustomerID = NEW.CustomerID;

        -- 自动更新信用等级（可选功能）
        IF (SELECT Balance FROM Customers WHERE CustomerID = NEW.CustomerID) >= 1000 THEN
            UPDATE Customers
            SET CreditLevel = GREATEST(CreditLevel + 1, 5)
            WHERE CustomerID = NEW.CustomerID;
        END IF;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient balance for this order.';
    END IF;
END;
解释：
在订单发货时触发。
如果余额足够，扣减客户账户余额。
可选功能：余额超过一定值时自动提升信用等级。
4. 触发器：删除客户时清理相关订单
功能说明：当客户被删除时，自动删除其相关订单及订单明细。
CREATE TRIGGER Trigger_CascadeDeleteCustomer
BEFORE DELETE ON Customers
FOR EACH ROW
BEGIN
    DELETE FROM OrderDetails
    WHERE OrderID IN (
        SELECT OrderID FROM Orders WHERE CustomerID = OLD.CustomerID
    );

    DELETE FROM Orders
    WHERE CustomerID = OLD.CustomerID;
END;
解释：
在 Customers 表删除记录时触发。
删除相关联的订单明细和订单记录。
5. 触发器：自动调整信用等级
功能说明：每月初根据累计消费或账户余额自动调整客户信用等级。
CREATE TRIGGER Trigger_AutoUpdateCreditLevel
BEFORE UPDATE ON Customers
FOR EACH ROW
BEGIN
    IF NEW.Balance >= 1000 THEN
        SET NEW.CreditLevel = LEAST(NEW.CreditLevel + 1, 5);
    ELSEIF NEW.Balance < 500 THEN
        SET NEW.CreditLevel = GREATEST(NEW.CreditLevel - 1, 1);
    END IF;
END;
解释：
在客户余额更新后触发。
根据余额提高或降低信用等级。
6. 触发器：防止库存量为负值
功能说明：当尝试减少库存时，阻止库存量变为负值

CREATE TRIGGER Trigger_PreventNegativeStock
BEFORE UPDATE ON Books
FOR EACH ROW
BEGIN
    IF NEW.Stock < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock cannot be negative.';
    END IF;
END;
解释：
在 Books 表更新时触发。
如果库存量更新后为负，抛出错误。
7.触发器：自动更新丛书库存
功能：当 Books 表的库存更新时，同时更新其关联的丛书库存
CREATE TRIGGER Trigger_UpdateSeriesStock
AFTER UPDATE ON Books
FOR EACH ROW
BEGIN
    IF NEW.Stock <> OLD.Stock THEN
        UPDATE Series
        SET Stock = (SELECT SUM(Stock) FROM Books WHERE SeriesID = NEW.SeriesID)
        WHERE SeriesID = NEW.SeriesID;
    END IF;
END;
8.触发器：顾客缺书请求的自动处理
功能：当缺书请求被处理后自动将状态更新为 "已答复"。
CREATE TRIGGER Trigger_ProcessMissingRequest
AFTER INSERT ON PurchaseOrders
FOR EACH ROW
BEGIN
    UPDATE MissingRequests
    SET Status = 'Processed'
    WHERE BookID = (
        SELECT BookID FROM PurchaseRequests WHERE RequestID = NEW.RequestID
    ) AND Status = 'Pending';
END;
9.触发器：发货时检查库存和信用
功能：在订单发货时检查库存和顾客信用等级，确保满足发货条件。
CREATE TRIGGER Trigger_CheckShippingBeforeUpdate
BEFORE INSERT ON Shipping
FOR EACH ROW
BEGIN
    DECLARE CurrentStock INT;
    DECLARE CreditLevel INT;
    DECLARE TotalRequired INT;

    -- 获取库存
    SELECT SUM(Stock) INTO CurrentStock
    FROM Books
    WHERE BookID IN (SELECT BookID FROM OrderDetails WHERE OrderID = NEW.OrderID);

    -- 获取信用等级
    SELECT CreditLevel INTO CreditLevel
    FROM Customers
    WHERE CustomerID = (SELECT CustomerID FROM Orders WHERE OrderID = NEW.OrderID);

    -- 计算订单总需求
    SELECT SUM(Quantity) INTO TotalRequired
    FROM OrderDetails
    WHERE OrderID = NEW.OrderID;

    -- 检查库存
    IF CurrentStock < TotalRequired THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Not enough stock for shipping.';
    END IF;

    -- 检查信用等级
    IF CreditLevel < 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient credit level for pre-shipping.';
    END IF;
END;
10. 触发器:自动生成采购单
功能：当缺书记录生成时自动生成采购单。
CREATE TRIGGER Trigger_AutoGeneratePurchaseOrder
AFTER INSERT ON PurchaseRequests
FOR EACH ROW
BEGIN
    INSERT INTO PurchaseOrders (RequestID, OrderDate, Status)
    VALUES (NEW.RequestID, NOW(), 'Pending');
END;
11. 触发器：顾客累计消费更新信用等级
功能：根据顾客的累计消费金额提升信用等级。
CREATE TRIGGER Trigger_UpdateCreditLevelOnTotalAmount
AFTER UPDATE ON Orders
FOR EACH ROW
BEGIN
    DECLARE TotalSpent DECIMAL(10, 2);

    -- 计算累计消费金额
    SELECT SUM(TotalAmount) INTO TotalSpent
    FROM Orders
    WHERE CustomerID = NEW.CustomerID;

    -- 更新信用等级
    IF TotalSpent >= 5000 THEN
        UPDATE Customers
        SET CreditLevel = LEAST(CreditLevel + 1, 5)
        WHERE CustomerID = NEW.CustomerID;
    END IF;
END;


4.视图设计
1. 供书目录视图
显示书籍的基本信息和库存状态，包括关联的丛书信息。
CREATE VIEW View_BookInventory AS
SELECT 
    b.BookID,
    b.Title,
    b.Author,
    b.Publisher,
    b.Price,
    b.Stock,
    s.SeriesName AS Series,
    CASE 
        WHEN b.Stock = 0 THEN 'Out of Stock'
        WHEN b.Stock < 10 THEN 'Low Stock'
        ELSE 'In Stock'
    END AS StockStatus
FROM 
    Books b
LEFT JOIN 
    Series s ON b.SeriesID = s.SeriesID;
用途：
提供书籍的基本库存状态，便于管理人员查看哪些书籍需要补货。
2. 缺书信息视图
显示缺书登记的详细信息，包括顾客缺书请求和书籍的库存状态。
CREATE VIEW View_MissingBooks AS
SELECT 
    pr.RequestID,
    b.BookID,
    b.Title,
    b.Stock,
    pr.Quantity AS RequestedQuantity,
    c.Name AS CustomerName,
    pr.RequestDate,
    pr.Status
FROM 
    PurchaseRequests pr
LEFT JOIN 
    Books b ON pr.BookID = b.BookID
LEFT JOIN 
    Customers c ON pr.CustomerID = c.CustomerID
WHERE 
    pr.Status = 'Pending';
用途：
管理人员查看缺书记录及顾客的缺书请求，方便采购管理。
3. 客户订单视图
显示客户的订单及发货状态。
CREATE VIEW View_CustomerOrders AS
SELECT 
    o.OrderID,
    o.OrderDate,
    c.CustomerID,
    c.Name AS CustomerName,
    od.BookID,
    b.Title AS BookTitle,
    od.Quantity,
    o.TotalAmount,
    s.Status AS ShippingStatus,
    s.ShippingDate
FROM 
    Orders o
JOIN 
    OrderDetails od ON o.OrderID = od.OrderID
JOIN 
    Books b ON od.BookID = b.BookID
JOIN 
    Customers c ON o.CustomerID = c.CustomerID
LEFT JOIN 
    Shipping s ON o.OrderID = s.OrderID;
用途：
提供客户订单的详细信息及发货情况，便于查询订单状态。
4. 客户消费记录视图
显示每位客户的累计消费金额和信用等级。
CREATE VIEW View_CustomerSpending AS
SELECT 
    c.CustomerID,
    c.Name AS CustomerName,
    c.CreditLevel,
    c.Balance,
    IFNULL(SUM(o.TotalAmount), 0) AS TotalSpent
FROM 
    Customers c
LEFT JOIN 
    Orders o ON c.CustomerID = o.CustomerID
GROUP BY 
    c.CustomerID, c.Name, c.CreditLevel, c.Balance;
用途：
用于管理客户的消费信息，便于信用等级调整和促销活动。
5. 订单发货视图
显示订单的发货详情，包括未发货订单。
CREATE VIEW View_ShippingStatus AS
SELECT 
    o.OrderID,
    o.OrderDate,
    c.Name AS CustomerName,
    s.ShippingID,
    s.ShippingDate,
    s.Status AS ShippingStatus,
    o.TotalAmount
FROM 
    Orders o
LEFT JOIN 
    Shipping s ON o.OrderID = s.OrderID
JOIN 
    Customers c ON o.CustomerID = c.CustomerID
WHERE 
    s.Status IS NULL OR s.Status != 'Shipped';
用途：
查看未完全发货的订单，便于跟进发货。
6. 供应商供货视图
显示供应商的基本信息及供货书籍。
CREATE VIEW View_SupplierBooks AS
SELECT 
    s.SupplierID,
    s.Name AS SupplierName,
    b.BookID,
    b.Title AS BookTitle,
    bs.SupplyPrice
FROM 
    Suppliers s
JOIN 
    BookSuppliers bs ON s.SupplierID = bs.SupplierID
JOIN 
    Books b ON bs.BookID = b.BookID;
用途：
管理人员查看供应商的供货书籍信息，便于供货关系维护。
7. 顾客浏览书目视图
显示书籍信息，支持按关键字、作者或出版社进行模糊查询。
CREATE VIEW View_BrowseBooks AS
SELECT 
    b.BookID,
    b.Title,
    b.Author,
    b.Publisher,
    b.Price,
    b.Keywords,
    CASE 
        WHEN b.Stock = 0 THEN 'Out of Stock'
        ELSE 'Available'
    END AS Availability
FROM 
    Books b;
用途：
提供顾客查询书籍信息的视图，用于网上浏览。




5.存储过程
1. 自动生成缺书记录
当库存低于设定值时，自动生成缺书记录。
DELIMITER //

CREATE PROCEDURE GenerateMissingRecords()
BEGIN
    INSERT INTO PurchaseRequests (BookID, RequestDate, Quantity, Status)
    SELECT 
        BookID,
        CURDATE(),
        10 AS Quantity,
        'Pending' AS Status
    FROM 
        Books
    WHERE 
        Stock < 10
    ON DUPLICATE KEY UPDATE
        RequestDate = VALUES(RequestDate); -- 防止重复生成缺书记录
END //

DELIMITER ;
用途：
定期检查库存并生成缺书记录。
2. 创建采购订单
根据缺书记录生成采购订单，并将状态更新为“已处理”。
DELIMITER //

CREATE PROCEDURE CreatePurchaseOrder(IN RequestID INT)
BEGIN
    DECLARE BookID INT;
    DECLARE Quantity INT;

    -- 获取缺书记录信息
    SELECT 
        BookID, 
        Quantity 
    INTO 
        BookID, Quantity
    FROM 
        PurchaseRequests
    WHERE 
        RequestID = RequestID;

    -- 创建采购订单
    INSERT INTO PurchaseOrders (RequestID, OrderDate, Status)
    VALUES (RequestID, CURDATE(), 'Pending');

    -- 更新缺书记录状态
    UPDATE PurchaseRequests
    SET Status = 'Processed'
    WHERE RequestID = RequestID;
END //

DELIMITER ;
用途：
根据特定的缺书记录生成采购订单并更新状态。
3. 更新客户信用等级
根据客户的账户余额或累计消费金额自动调整信用等级。
DELIMITER //

CREATE PROCEDURE UpdateCreditLevel(IN CustomerID INT)
BEGIN
    DECLARE TotalSpent DECIMAL(10, 2);
    DECLARE CurrentBalance DECIMAL(10, 2);
    DECLARE NewCreditLevel INT;

    -- 获取累计消费金额和账户余额
    SELECT 
        IFNULL(SUM(TotalAmount), 0), 
        Balance
    INTO 
        TotalSpent, CurrentBalance
    FROM 
        Orders
    JOIN 
        Customers ON Orders.CustomerID = Customers.CustomerID
    WHERE 
        Customers.CustomerID = CustomerID;

    -- 计算新的信用等级
    IF TotalSpent >= 5000 OR CurrentBalance >= 1000 THEN
        SET NewCreditLevel = LEAST(CreditLevel + 1, 5);
    ELSEIF CurrentBalance < 500 THEN
        SET NewCreditLevel = GREATEST(CreditLevel - 1, 1);
    ELSE
        SET NewCreditLevel = CreditLevel;
    END IF;

    -- 更新信用等级
    UPDATE Customers
    SET CreditLevel = NewCreditLevel
    WHERE CustomerID = CustomerID;
END //

DELIMITER ;
用途：
按账户余额或消费金额动态调整信用等级。
4. 更新库存和删除缺书记录
采购到货时更新库存，并自动删除相关缺书记录。
DELIMITER //

CREATE PROCEDURE UpdateStockAndClearRequest(IN RequestID INT)
BEGIN
    DECLARE BookID INT;
    DECLARE Quantity INT;

    -- 获取缺书记录信息
    SELECT 
        BookID, 
        Quantity 
    INTO 
        BookID, Quantity
    FROM 
        PurchaseRequests
    WHERE 
        RequestID = RequestID;

    -- 更新库存
    UPDATE Books
    SET Stock = Stock + Quantity
    WHERE BookID = BookID;

    -- 删除缺书记录
    DELETE FROM PurchaseRequests
    WHERE RequestID = RequestID;
END //

DELIMITER ;
用途：
到货后自动更新库存并清理相关缺书记录。
5. 查询顾客订单及发货情况
根据顾客 ID 查询订单及其发货状态。
DELIMITER //

CREATE PROCEDURE GetCustomerOrders(IN CustomerID INT)
BEGIN
    SELECT 
        o.OrderID,
        o.OrderDate,
        o.TotalAmount,
        s.Status AS ShippingStatus,
        s.ShippingDate
    FROM 
        Orders o
    LEFT JOIN 
        Shipping s ON o.OrderID = s.OrderID
    WHERE 
        o.CustomerID = CustomerID;
END //

DELIMITER ;
用途：
提供顾客订单和发货情况查询。
6. 自动处理未发货订单
将所有信用等级满足条件的未发货订单状态更新为“已发货”。
DELIMITER //

CREATE PROCEDURE ProcessPendingOrders()
BEGIN
    UPDATE Orders o
    SET 
        o.Status = 'Shipped'
    WHERE 
        o.Status = 'Pending'
        AND o.CustomerID IN (
            SELECT CustomerID
            FROM Customers
            WHERE CreditLevel >= 3
        );
END //

DELIMITER ;
用途：
自动处理未发货订单。
















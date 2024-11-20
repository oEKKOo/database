三、课后习题
1.新建函数和事件，每20秒统计student表中gender字段的总数和各性别所占的百分比。（如学生的总数为100，男生的百分比为68%，女生32%等等）。
1）创建统计函数
DELIMITER $$

CREATE FUNCTION GetGenderStats()
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE total INT;
    DECLARE male_count INT;
    DECLARE female_count INT;
    DECLARE male_percentage DECIMAL(5,2);
    DECLARE female_percentage DECIMAL(5,2);
    DECLARE result VARCHAR(255);

    -- 获取总人数
    SELECT COUNT(*) INTO total FROM student;

    -- 获取男性人数
    SELECT COUNT(*) INTO male_count FROM student WHERE gender = '男';

    -- 获取女性人数
    SELECT COUNT(*) INTO female_count FROM student WHERE gender = '女';

    -- 计算百分比
    IF total > 0 THEN
        SET male_percentage = (male_count / total) * 100;
        SET female_percentage = (female_count / total) * 100;
    ELSE
        SET male_percentage = 0;
        SET female_percentage = 0;
    END IF;

    -- 拼接结果
    SET result = CONCAT('Total: ', total, ', 男: ', male_percentage, '%, 女: ', female_percentage, '%');
    RETURN result;
END$$

DELIMITER ;

2）创建事件
DELIMITER $$

CREATE EVENT GenderStatsEvent
ON SCHEDULE EVERY 20 SECOND
DO
BEGIN
    -- 调用函数并输出结果（可将结果存入日志表以便记录）
    SELECT GetGenderStats() AS GenderStatistics;
END$$

DELIMITER ;


3）启动事件调度器
SET GLOBAL event_scheduler = ON;

4）验证
将结果存储到日志表中
CREATE TABLE GenderStatsLog (
    id INT AUTO_INCREMENT PRIMARY KEY,
    total INT,
    male_percentage DECIMAL(5,2),
    female_percentage DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$

CREATE PROCEDURE LogGenderStats()
BEGIN
    DECLARE total INT;
    DECLARE male_count INT;
    DECLARE female_count INT;
    DECLARE male_percentage DECIMAL(5,2);
    DECLARE female_percentage DECIMAL(5,2);

    -- 获取总人数
    SELECT COUNT(*) INTO total FROM student;

    -- 获取男性人数
    SELECT COUNT(*) INTO male_count FROM student WHERE gender = '男';

    -- 获取女性人数
    SELECT COUNT(*) INTO female_count FROM student WHERE gender = '女';

    -- 计算百分比
    IF total > 0 THEN
        SET male_percentage = (male_count / total) * 100;
        SET female_percentage = (female_count / total) * 100;
    ELSE
        SET male_percentage = 0;
        SET female_percentage = 0;
    END IF;

    -- 插入日志
    INSERT INTO GenderStatsLog (total, male_percentage, female_percentage)
    VALUES (total, male_percentage, female_percentage);
END$$

DELIMITER ;

CREATE EVENT GenderStatsLogEvent
ON SCHEDULE EVERY 20 SECOND
DO
CALL LogGenderStats();

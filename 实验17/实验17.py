import pymysql

# 数据库连接配置
DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "password",
    "database": "test_db",
    "autocommit": False  # 关闭自动提交，手动管理事务
}

def avoid_non_repeatable_read(account_id):
    """
    避免不可重复读：读取账户余额，并通过版本号检查是否被修改
    """
    connection = pymysql.connect(**DB_CONFIG)
    try:
        with connection.cursor() as cursor:
            # 第一次读取账户余额和版本号
            cursor.execute("SELECT balance, version FROM accounts WHERE account_id = %s", (account_id,))
            result = cursor.fetchone()
            if result is None:
                print("Account not found.")
                return
            balance, version = result
            print(f"Initial Balance: {balance}, Version: {version}")

            # 模拟其他事务可能的更新操作
            input("Simulate update in another transaction and press Enter to continue...")

            # 第二次读取并检查版本号
            cursor.execute("SELECT balance, version FROM accounts WHERE account_id = %s", (account_id,))
            new_balance, new_version = cursor.fetchone()
            if new_version != version:
                print("Non-repeatable read detected!")
            else:
                print(f"No changes detected. Balance: {new_balance}, Version: {new_version}")
    finally:
        connection.rollback()  # 确保事务回滚，保持测试环境稳定
        connection.close()

def avoid_phantom_read(min_amount):
    """
    避免幻读：统计高金额订单数量，使用加锁机制
    """
    connection = pymysql.connect(**DB_CONFIG)
    try:
        with connection.cursor() as cursor:
            # 第一次统计高金额订单
            cursor.execute("SELECT COUNT(*) FROM orders WHERE amount > %s FOR UPDATE", (min_amount,))
            initial_count = cursor.fetchone()[0]
            print(f"Initial Count of Orders > {min_amount}: {initial_count}")

            # 模拟其他事务插入新的订单
            input("Simulate insert in another transaction and press Enter to continue...")

            # 第二次统计高金额订单
            cursor.execute("SELECT COUNT(*) FROM orders WHERE amount > %s FOR UPDATE", (min_amount,))
            new_count = cursor.fetchone()[0]
            if new_count != initial_count:
                print("Phantom read detected!")
            else:
                print(f"No phantom read detected. Order Count: {new_count}")
    finally:
        connection.rollback()  # 确保事务回滚
        connection.close()

if __name__ == "__main__":
    print("Choose an option:")
    print("1. Avoid Non-Repeatable Read")
    print("2. Avoid Phantom Read")
    choice = input("Enter your choice: ")

    if choice == "1":
        account_id = int(input("Enter Account ID: "))
        avoid_non_repeatable_read(account_id)
    elif choice == "2":
        min_amount = float(input("Enter Minimum Order Amount: "))
        avoid_phantom_read(min_amount)
    else:
        print("Invalid choice.")

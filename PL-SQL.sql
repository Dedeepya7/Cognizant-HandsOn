-- Combined BankDB SQL script: schema, sample data, procedures, functions, triggers
-- Drop and recreate database
DROP DATABASE IF EXISTS BankDB;
CREATE DATABASE BankDB;
USE BankDB;

-- ---------- Tables ----------
CREATE TABLE IF NOT EXISTS Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    DOB DATE,
    Balance DECIMAL(10,2) DEFAULT 0.00,
    LastModified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS Accounts (
    AccountID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    AccountType VARCHAR(20),
    Balance DECIMAL(10,2) DEFAULT 0.00,
    LastModified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_accounts_customer FOREIGN KEY (CustomerID)
      REFERENCES Customers(CustomerID)
      ON DELETE CASCADE
      ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS Transactions (
    TransactionID INT AUTO_INCREMENT PRIMARY KEY,
    AccountID INT NOT NULL,
    TransactionDate DATE DEFAULT (CURRENT_DATE),
    Amount DECIMAL(10,2) NOT NULL,
    TransactionType VARCHAR(20),
    CONSTRAINT fk_transactions_account FOREIGN KEY (AccountID)
      REFERENCES Accounts(AccountID)
      ON DELETE CASCADE
      ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS Loans (
    LoanID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    LoanAmount DECIMAL(10,2) NOT NULL,
    InterestRate DECIMAL(5,2),
    StartDate DATE,
    EndDate DATE,
    CONSTRAINT fk_loans_customer FOREIGN KEY (CustomerID)
      REFERENCES Customers(CustomerID)
      ON DELETE CASCADE
      ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS Employees (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Position VARCHAR(50),
    Salary DECIMAL(10,2),
    Department VARCHAR(50),
    HireDate DATE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ErrorLog and AuditLog
CREATE TABLE IF NOT EXISTS ErrorLog (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    ErrorMessage VARCHAR(255),
    ErrorDate DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS AuditLog (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    TransactionID INT,
    AccountID INT,
    Amount DECIMAL(10,2),
    TransactionType VARCHAR(20),
    LogDate DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------- Sample data ----------
INSERT INTO Customers (Name, DOB, Balance, LastModified) VALUES
('John Doe','1985-05-15',1000.00,NOW()),
('Jane Smith','1990-07-20',1500.00,NOW());

INSERT INTO Accounts (CustomerID, AccountType, Balance, LastModified) VALUES
(1,'Savings',1000.00,NOW()),
(2,'Checking',1500.00,NOW());

INSERT INTO Transactions (AccountID, TransactionDate, Amount, TransactionType) VALUES
(1,CURDATE(),200.00,'Deposit'),
(2,CURDATE(),300.00,'Withdrawal');

INSERT INTO Loans (CustomerID, LoanAmount, InterestRate, StartDate, EndDate) VALUES
(1,5000.00,5.00,CURDATE(),DATE_ADD(CURDATE(), INTERVAL 60 MONTH));

INSERT INTO Employees (Name, Position, Salary, Department, HireDate) VALUES
('Alice Johnson','Manager',70000.00,'HR','2015-06-15'),
('Bob Brown','Developer',60000.00,'IT','2017-03-20');

-- ---------- Procedures / Functions / Triggers ----------
-- Drop existing objects to allow re-run
DELIMITER //

-- Exercise 1: Procedures and Cursors
DROP PROCEDURE IF EXISTS ApplySeniorCitizenDiscount;//
CREATE PROCEDURE ApplySeniorCitizenDiscount()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_customerId INT;
    DECLARE v_age INT;

    DECLARE cur CURSOR FOR
    SELECT CustomerID, TIMESTAMPDIFF(YEAR, DOB, CURDATE())
    FROM Customers;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_customerId, v_age;
        IF done THEN
            LEAVE read_loop;
        END IF;
        IF v_age > 60 THEN
            UPDATE Loans
            SET InterestRate = InterestRate - 1
            WHERE CustomerID = v_customerId;
        END IF;
    END LOOP;
    CLOSE cur;
END//

DROP PROCEDURE IF EXISTS PromoteVIPCustomers;//
-- Add VIP column if not exists
ALTER TABLE Customers
ADD COLUMN IF NOT EXISTS IsVIP BOOLEAN DEFAULT FALSE;//

CREATE PROCEDURE PromoteVIPCustomers()
BEGIN
    UPDATE Customers c
    SET IsVIP = TRUE
    WHERE c.CustomerID IN (
        SELECT a.CustomerID
        FROM Accounts a
        GROUP BY a.CustomerID
        HAVING SUM(a.Balance) >= 10000
    );
END//

DROP PROCEDURE IF EXISTS LoanDueReminders;//
CREATE PROCEDURE LoanDueReminders()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_customerId INT;
    DECLARE v_loanId INT;
    DECLARE v_endDate DATE;
    DECLARE cur CURSOR FOR
    SELECT LoanID, CustomerID, EndDate
    FROM Loans
    WHERE EndDate BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY);
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;
    reminder_loop: LOOP
        FETCH cur INTO v_loanId, v_customerId, v_endDate;
        IF done THEN
            LEAVE reminder_loop;
        END IF;
        SELECT CONCAT('Reminder: Customer ', v_customerId, ' Loan ', v_loanId, ' is due on ', v_endDate) AS Reminder_Message;
    END LOOP;
    CLOSE cur;
END//

-- Exercise 2: Error Handling
DROP TABLE IF EXISTS ErrorLog;//
CREATE TABLE ErrorLog (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    ErrorMessage VARCHAR(255),
    ErrorDate DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;//

DROP PROCEDURE IF EXISTS SafeTransferFunds;//
CREATE PROCEDURE SafeTransferFunds(
    IN p_fromAccount INT,
    IN p_toAccount INT,
    IN p_amount DECIMAL(10,2)
)
BEGIN
    DECLARE v_balance DECIMAL(10,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        INSERT INTO ErrorLog(ErrorMessage) VALUES('Error occurred during fund transfer');
    END;

    START TRANSACTION;
    SELECT Balance INTO v_balance FROM Accounts WHERE AccountID = p_fromAccount FOR UPDATE;

    IF v_balance < p_amount THEN
        INSERT INTO ErrorLog(ErrorMessage) VALUES('Insufficient Funds');
        ROLLBACK;
    ELSE
        UPDATE Accounts SET Balance = Balance - p_amount WHERE AccountID = p_fromAccount;
        UPDATE Accounts SET Balance = Balance + p_amount WHERE AccountID = p_toAccount;
        COMMIT;
    END IF;
END//

DROP PROCEDURE IF EXISTS UpdateSalary;//
CREATE PROCEDURE UpdateSalary(
    IN p_employeeId INT,
    IN p_percentage DECIMAL(5,2)
)
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count FROM Employees WHERE EmployeeID = p_employeeId;
    IF v_count = 0 THEN
        INSERT INTO ErrorLog(ErrorMessage) VALUES('Employee ID does not exist');
    ELSE
        UPDATE Employees SET Salary = Salary + (Salary * p_percentage / 100) WHERE EmployeeID = p_employeeId;
    END IF;
END//

DROP PROCEDURE IF EXISTS AddNewCustomer;//
CREATE PROCEDURE AddNewCustomer(
    IN p_customerId INT,
    IN p_name VARCHAR(100),
    IN p_dob DATE,
    IN p_balance DECIMAL(10,2)
)
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count FROM Customers WHERE CustomerID = p_customerId;
    IF v_count > 0 THEN
        INSERT INTO ErrorLog(ErrorMessage) VALUES('Customer ID already exists');
    ELSE
        INSERT INTO Customers(CustomerID, Name, DOB, Balance, LastModified)
        VALUES(p_customerId, p_name, p_dob, p_balance, NOW());
    END IF;
END//

-- Exercise 3: Stored Procedures
DROP PROCEDURE IF EXISTS ProcessMonthlyInterest;//
CREATE PROCEDURE ProcessMonthlyInterest()
BEGIN
    UPDATE Accounts SET Balance = Balance + (Balance * 0.01) WHERE AccountType = 'Savings';
END//

DROP PROCEDURE IF EXISTS UpdateEmployeeBonus;//
CREATE PROCEDURE UpdateEmployeeBonus(
    IN p_department VARCHAR(50),
    IN p_bonusPercent DECIMAL(5,2)
)
BEGIN
    UPDATE Employees
    SET Salary = Salary + (Salary * p_bonusPercent / 100)
    WHERE EmployeeID IN (
        SELECT EmployeeID FROM (SELECT EmployeeID FROM Employees WHERE Department = p_department) temp
    );
END//

DROP PROCEDURE IF EXISTS TransferFunds;//
CREATE PROCEDURE TransferFunds(
    IN p_fromAccount INT,
    IN p_toAccount INT,
    IN p_amount DECIMAL(10,2)
)
BEGIN
    DECLARE v_balance DECIMAL(10,2);
    SELECT Balance INTO v_balance FROM Accounts WHERE AccountID = p_fromAccount FOR UPDATE;
    IF v_balance >= p_amount THEN
        UPDATE Accounts SET Balance = Balance - p_amount WHERE AccountID = p_fromAccount;
        UPDATE Accounts SET Balance = Balance + p_amount WHERE AccountID = p_toAccount;
        SELECT 'Transfer Successful' AS Message;
    ELSE
        SELECT 'Insufficient Balance' AS Message;
    END IF;
END//

-- Exercise 4: Functions
DROP FUNCTION IF EXISTS CalculateAge;//
CREATE FUNCTION CalculateAge(p_dob DATE) RETURNS INT DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, p_dob, CURDATE());
END//

DROP FUNCTION IF EXISTS CalculateMonthlyInstallment;//
CREATE FUNCTION CalculateMonthlyInstallment(p_loanAmount DECIMAL(10,2), p_interestRate DECIMAL(5,2), p_years INT)
RETURNS DECIMAL(10,2) DETERMINISTIC
BEGIN
    DECLARE totalAmount DECIMAL(10,2);
    SET totalAmount = p_loanAmount + (p_loanAmount * p_interestRate / 100);
    RETURN totalAmount / (p_years * 12);
END//

DROP FUNCTION IF EXISTS HasSufficientBalance;//
CREATE FUNCTION HasSufficientBalance(p_accountId INT, p_amount DECIMAL(10,2)) RETURNS BOOLEAN DETERMINISTIC
BEGIN
    DECLARE v_balance DECIMAL(10,2);
    SELECT Balance INTO v_balance FROM Accounts WHERE AccountID = p_accountId;
    RETURN v_balance >= p_amount;
END//

-- Exercise 5: Triggers
DROP TRIGGER IF EXISTS UpdateCustomerLastModified;//
CREATE TRIGGER UpdateCustomerLastModified
BEFORE UPDATE ON Customers
FOR EACH ROW
BEGIN
    SET NEW.LastModified = NOW();
END//

DROP TRIGGER IF EXISTS LogTransaction;//
CREATE TRIGGER LogTransaction
AFTER INSERT ON Transactions
FOR EACH ROW
BEGIN
    INSERT INTO AuditLog(TransactionID, AccountID, Amount, TransactionType, LogDate)
    VALUES(NEW.TransactionID, NEW.AccountID, NEW.Amount, NEW.TransactionType, NOW());
END//

DROP TRIGGER IF EXISTS CheckTransactionRules;//
CREATE TRIGGER CheckTransactionRules
BEFORE INSERT ON Transactions
FOR EACH ROW
BEGIN
    DECLARE v_balance DECIMAL(10,2);
    SELECT Balance INTO v_balance FROM Accounts WHERE AccountID = NEW.AccountID;
    IF NEW.TransactionType = 'Deposit' AND NEW.Amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Deposit amount must be positive';
    END IF;
    IF NEW.TransactionType = 'Withdrawal' AND NEW.Amount > v_balance THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient balance for withdrawal';
    END IF;
END//

-- Exercise 6: Cursor-based Procedures
DROP PROCEDURE IF EXISTS GenerateMonthlyStatements;//
CREATE PROCEDURE GenerateMonthlyStatements()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_transactionId INT;
    DECLARE v_accountId INT;
    DECLARE v_amount DECIMAL(10,2);
    DECLARE v_type VARCHAR(20);

    DECLARE cur CURSOR FOR
    SELECT TransactionID, AccountID, Amount, TransactionType FROM Transactions
    WHERE MONTH(TransactionDate)=MONTH(CURDATE()) AND YEAR(TransactionDate)=YEAR(CURDATE());
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_transactionId, v_accountId, v_amount, v_type;
        IF done THEN LEAVE read_loop; END IF;
        SELECT CONCAT('Transaction ID: ', v_transactionId, ', Account: ', v_accountId, ', Amount: ', v_amount, ', Type: ', v_type) AS MonthlyStatement;
    END LOOP;
    CLOSE cur;
END//

DROP PROCEDURE IF EXISTS ApplyAnnualFee;//
CREATE PROCEDURE ApplyAnnualFee()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_accountId INT;
    DECLARE cur CURSOR FOR SELECT AccountID FROM Accounts;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    OPEN cur;
    fee_loop: LOOP
        FETCH cur INTO v_accountId;
        IF done THEN LEAVE fee_loop; END IF;
        UPDATE Accounts SET Balance = Balance - 100 WHERE AccountID = v_accountId;
    END LOOP;
    CLOSE cur;
END//

DROP PROCEDURE IF EXISTS UpdateLoanInterestRates;//
CREATE PROCEDURE UpdateLoanInterestRates()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_loanId INT;
    DECLARE cur CURSOR FOR SELECT LoanID FROM Loans;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    OPEN cur;
    loan_loop: LOOP
        FETCH cur INTO v_loanId;
        IF done THEN LEAVE loan_loop; END IF;
        UPDATE Loans SET InterestRate = InterestRate + 0.5 WHERE LoanID = v_loanId;
    END LOOP;
    CLOSE cur;
END//

-- Exercise 7: Package-style Procedures/Functions
-- Customer Management
DROP PROCEDURE IF EXISTS AddCustomer;//
CREATE PROCEDURE AddCustomer(
    IN p_customerId INT,
    IN p_name VARCHAR(100),
    IN p_dob DATE,
    IN p_balance DECIMAL(10,2)
)
BEGIN
    INSERT INTO Customers(CustomerID, Name, DOB, Balance, LastModified)
    VALUES(p_customerId, p_name, p_dob, p_balance, NOW());
END//

DROP PROCEDURE IF EXISTS UpdateCustomerDetails;//
CREATE PROCEDURE UpdateCustomerDetails(IN p_customerId INT, IN p_name VARCHAR(100))
BEGIN
    UPDATE Customers SET Name = p_name WHERE CustomerID = p_customerId;
END//

DROP FUNCTION IF EXISTS GetCustomerBalance;//
CREATE FUNCTION GetCustomerBalance(p_customerId INT) RETURNS DECIMAL(10,2) DETERMINISTIC
BEGIN
    DECLARE v_balance DECIMAL(10,2);
    SELECT Balance INTO v_balance FROM Customers WHERE CustomerID = p_customerId;
    RETURN v_balance;
END//

-- Employee Management
DROP PROCEDURE IF EXISTS HireEmployee;//
CREATE PROCEDURE HireEmployee(
    IN p_employeeId INT,
    IN p_name VARCHAR(100),
    IN p_position VARCHAR(50),
    IN p_salary DECIMAL(10,2),
    IN p_department VARCHAR(50)
)
BEGIN
    INSERT INTO Employees(EmployeeID, Name, Position, Salary, Department, HireDate)
    VALUES(p_employeeId, p_name, p_position, p_salary, p_department, CURDATE());
END//

DROP PROCEDURE IF EXISTS UpdateEmployeeDetails;//
CREATE PROCEDURE UpdateEmployeeDetails(IN p_employeeId INT, IN p_position VARCHAR(50))
BEGIN
    UPDATE Employees SET Position = p_position WHERE EmployeeID = p_employeeId;
END//

DROP FUNCTION IF EXISTS CalculateAnnualSalary;//
CREATE FUNCTION CalculateAnnualSalary(p_employeeId INT) RETURNS DECIMAL(10,2) DETERMINISTIC
BEGIN
    DECLARE v_salary DECIMAL(10,2);
    SELECT Salary INTO v_salary FROM Employees WHERE EmployeeID = p_employeeId;
    RETURN v_salary * 12;
END//

-- Account Operations
DROP PROCEDURE IF EXISTS OpenAccount;//
CREATE PROCEDURE OpenAccount(
    IN p_accountId INT,
    IN p_customerId INT,
    IN p_accountType VARCHAR(20),
    IN p_balance DECIMAL(10,2)
)
BEGIN
    INSERT INTO Accounts(AccountID, CustomerID, AccountType, Balance, LastModified)
    VALUES(p_accountId, p_customerId, p_accountType, p_balance, NOW());
END//

DROP PROCEDURE IF EXISTS CloseAccount;//
CREATE PROCEDURE CloseAccount(IN p_accountId INT)
BEGIN
    DELETE FROM Accounts WHERE AccountID = p_accountId;
END//

DROP FUNCTION IF EXISTS GetTotalBalance;//
CREATE FUNCTION GetTotalBalance(p_customerId INT) RETURNS DECIMAL(10,2) DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(10,2);
    SELECT IFNULL(SUM(Balance),0) INTO v_total FROM Accounts WHERE CustomerID = p_customerId;
    RETURN v_total;
END//

DELIMITER ;



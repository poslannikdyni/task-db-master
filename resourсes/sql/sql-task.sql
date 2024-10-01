-- 14) Написать DDL таблицы Customers, должны быть поля id, firstName, LastName, email, phone. Добавить ограничения на поля (constraints)
CREATE TABLE Customers (
    id SERIAL PRIMARY KEY,
    firstName VARCHAR(30) NOT NULL,
    lastName VARCHAR(30) NOT NULL,
    email VARCHAR(50) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL UNIQUE
);

ALTER TABLE Customers ADD CONSTRAINT email_format_check
    CHECK(email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$');

ALTER TABLE customers ADD CONSTRAINT phone_format_check
    CHECK (phone ~ '^[0-9]\d{1,14}$');



-- 15) Написать DDL таблицы Orders, должен быть id, customerId, quantity. Должен быть внешний ключ на таблицу customers + constraints
CREATE TABLE Orders (
    id SERIAL PRIMARY KEY,
    customerId INT NOT NULL,
    quantity INT NOT NULL CHECK(quantity > 0) ,
    FOREIGN KEY (customerId) REFERENCES Customers(id)
    ON DELETE CASCADE
);



-- 16) Написать 5 insert в эти таблицы
INSERT INTO Customers (firstName, lastName, email, phone) VALUES
('John', 'Doe', 'john.doe@shilomilo.com', '1234567890'),
('Иван', 'Иванович', 'ivan.kuzin@shilomilo.com', '0987654321'),
('Alice', 'Бобовна', 'alice.bobovna@shilomilo.com', '1122334455'),
('Bob', 'Ericson', 'bob.ericson@shilomilo.com', '6677889900'),
('Шарлота', 'Кактамеё', 'charlota@shilomilo.com', '5566778899');

INSERT INTO Orders (customerId, quantity) VALUES
(1, 10),
(2, 20),
(3, 30),
(4, 40),
(5, 50);



-- 17) Удалить таблицы
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;
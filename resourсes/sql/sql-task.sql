-- 1) Вывести к каждому самолету класс обслуживания и количество мест этого класса
SELECT
    a.aircraft_code,
    s.fare_conditions,
    COUNT(s.seat_no) AS seat_count
FROM
    aircrafts a
JOIN
    seats s ON a.aircraft_code = s.aircraft_code
GROUP BY
    a.aircraft_code, s.fare_conditions;



-- 2) Найти 3 самых вместительных самолета (модель + кол-во мест)
SELECT
    a.model,
    COUNT(s.seat_no) AS seat_count
FROM
    aircrafts a
JOIN
    seats s ON a.aircraft_code = s.aircraft_code
GROUP BY
    a.model
ORDER BY
    seat_count DESC
LIMIT 3;



-- 3) Найти все рейсы, которые задерживались более 2 часов
SELECT
    flight_id,
    scheduled_departure,
    actual_departure,
    (actual_departure - scheduled_departure) AS delay
FROM
    flights
WHERE
    actual_departure IS NOT NULL AND
    (actual_departure - scheduled_departure) > INTERVAL '2 hours';



-- 4) Найти последние 10 билетов, купленные в бизнес-классе (fare_conditions = 'Business'), с указанием имени пассажира и контактных данных
SELECT t.ticket_no,
       t.passenger_name,
       t.contact_data
FROM tickets t
         JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
         JOIN bookings b ON t.book_ref = b.book_ref
WHERE
    fare_conditions = 'Business'
ORDER BY
    book_date DESC
LIMIT 10;



-- 5) Найти все рейсы, у которых нет забронированных мест в бизнес-классе (fare_conditions = 'Business')
SELECT
	f.flight_no
FROM
	flights f
INNER JOIN
	ticket_flights tf ON f.flight_id = tf.flight_id
WHERE
	tf.fare_conditions != 'Business'
GROUP BY
	f.flight_id,
	tf.fare_conditions;



-- 6) Получить список аэропортов (airport_name) и городов (city), в которых есть рейсы с задержкой по вылету
SELECT DISTINCT
    a.airport_name,
    a.city
FROM
    airports a
JOIN
    flights f ON a.airport_code = f.departure_airport
WHERE
    f.actual_departure > f.scheduled_departure;



-- 7) Получить список аэропортов (airport_name) и количество рейсов, вылетающих из каждого аэропорта, отсортированный по убыванию количества рейсов
SELECT
    a.airport_name,
    COUNT(f.flight_id) AS flight_count
FROM
    airports a
JOIN
    flights f ON a.airport_code = f.departure_airport
GROUP BY
    a.airport_name
ORDER BY
    flight_count DESC;



-- 8) Найти все рейсы, у которых запланированное время прибытия (scheduled_arrival) было изменено и новое время прибытия (actual_arrival) не совпадает с запланированным
SELECT
    flight_id,
    scheduled_arrival,
    actual_arrival
FROM
    flights
WHERE
    scheduled_arrival != actual_arrival;



-- 9) Вывести код, модель самолета и места не эконом класса для самолета "Аэробус A321-200" с сортировкой по местам
SELECT
    a.aircraft_code,
    a.model,
    s.seat_no
FROM
    aircrafts a
JOIN
    seats s ON a.aircraft_code = s.aircraft_code
WHERE
    a.model = 'Аэробус A321-200' AND s.fare_conditions NOT LIKE 'Economy'
ORDER BY
    s.seat_no;



-- 10) Вывести города, в которых больше 1 аэропорта (код аэропорта, аэропорт, город)
SELECT 
    airport_code, 
    airport_name, 
    city
FROM 
    airports
WHERE city IN (
    SELECT 
        city
    FROM 
        airports
    GROUP BY city
    HAVING COUNT(*) > 1
);



-- 11) Найти пассажиров, у которых суммарная стоимость бронирований превышает среднюю сумму всех бронирований
SELECT
    passenger_id,
    passenger_name,
    SUM(total_amount) AS total_spent
FROM
    tickets
JOIN
    bookings ON tickets.book_ref = bookings.book_ref
GROUP BY
    passenger_id, passenger_name
HAVING
    SUM(total_amount) > (SELECT AVG(total_amount) FROM bookings);



-- 12) Найти ближайший вылетающий рейс из Екатеринбурга в Москву, на который еще не завершилась регистрация
SELECT flight_no
FROM flights
WHERE departure_airport = 'SVX'
  AND status = 'On Time'
  AND arrival_airport IN
                        (SELECT
                             airport_code
                         FROM
                             airports
                         WHERE city = 'Москва')
ORDER BY scheduled_departure ASC
LIMIT 1;



-- 13) Вывести самый дешевый и дорогой билет и стоимость (в одном результирующем ответе)
(SELECT
    ticket_no, amount
FROM
    ticket_flights
ORDER BY
    amount ASC
LIMIT 1)
UNION(
    SELECT
        ticket_no, amount
    FROM
        ticket_flights
    ORDER BY
        amount DESC
LIMIT 1);



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
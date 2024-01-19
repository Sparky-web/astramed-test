-- Создание таблиц

CREATE TABLE lists (
  id SERIAL PRIMARY KEY,
  id_zl VARCHAR(50) UNIQUE,
  list_type VARCHAR(50),
  dbegin DATE,
  dend DATE,
  description TEXT,
  Standard VARCHAR(50),
  usl VARCHAR(50),
  ree_disp_date DATE,
  nzap_gis_oms INTEGER,
  ree_disp_date_udvn DATE,
  status_zvl BOOLEAN
);

CREATE TABLE callresult (
  id SERIAL PRIMARY KEY,
  listid INTEGER REFERENCES lists(id),
  useruid VARCHAR(50),
  calldate DATE,
  callstep VARCHAR(50),
  callhow VARCHAR(50),
  callresult VARCHAR(50),
  callcomment TEXT,
  callcount INTEGER
);

CREATE TABLE phones (
  id SERIAL PRIMARY KEY,
  idzl VARCHAR(50),
  phone VARCHAR(20),
  actual_date DATE,
  email VARCHAR(50),
  unact_email BOOLEAN,
  status_phone BOOLEAN
);


-- Заполнение таблицы "lists"
INSERT INTO lists (id_zl, list_type, dbegin, dend, description, Standard, usl, ree_disp_date, nzap_gis_oms, ree_disp_date_udvn, status_zvl)
VALUES
    ('ZL001', '12', '2024-01-01', '2024-01-05', 'Описание 1', 'Стандарт 1', 'Услуги 1', '2024-01-02', 123, '2024-01-03', true),
    ('ZL002', 'Тема 2', '2024-01-06', '2024-01-10', 'Описание 2', 'Стандарт 2', 'Услуги 2', '2024-01-07', 456, '2024-01-08', false),
    ('ZL003', 'Тема 3', '2024-01-11', '2024-01-15', 'Описание 3', 'Стандарт 3', 'Услуги 3', '2024-01-12', 789, '2024-01-13', true),
    ('ZL004', '1', '2024-01-01', '2024-01-05', 'Описание 4', 'Стандарт 4', 'Услуги 4', '2024-01-02', 123, '2024-01-03', true),
    ('ZL005', '401', '2024-01-11', '2024-01-15', 'Описание 5', 'Стандарт 5', 'Услуги 5', '2024-01-12', 789, '2024-01-13', true),
    ('ZL006', '402', '2024-01-11', '2024-01-15', 'Описание 6', 'Стандарт 6', 'Услуги 6', '2024-01-12', 789, '2024-01-13', true);

-- Заполнение таблицы "callresult"
INSERT INTO callresult (listid, useruid, calldate, callstep, callhow, callresult, callcomment, callcount)
VALUES
    (1, 'User001', '2023-01-02', 'Шаг 1', '1', 'Результат 1', 'Комментарий 1', 1),
    (1, 'User001', '2023-01-03', 'Шаг 1', '2', 'Результат 2', 'Комментарий 2', 2),
    (2, 'User002', '2024-01-07', 'Шаг 1', '1', 'Результат 1', 'Комментарий 3', 1),
    (4, 'User003', '2023-10-04', 'Шаг 1', '1', 'Результат 1', 'Комментарий 4', 1),
    (5, 'User004', '2023-10-04', NULL, NULL, NULL, NULL, 0),
    (6, 'User005', '2023-10-04',  NULL, NULL, NULL, NULL, 0);

-- Заполнение таблицы "phones"
INSERT INTO phones (idzl, phone, actual_date, email, unact_email, status_phone)
VALUES
    ('ZL004', '000000000', '2024-01-11', 'email4@example.com', false, false),
    ('ZL001', '111111111', '2024-01-01', 'email1@example.com', false, true),
    ('ZL002', '222222222', '2024-01-06', 'email2@example.com', true, true),
    ('ZL003', '333333333', '2024-01-11', 'email4@example.com', false, false),
    ('ZL004', '444444444', '2024-01-11', 'email5@example.com', false, false),
    ('ZL005', '777777777', '2024-01-11', 'email6@example.com', false, false),
    ('ZL006', '555555555', '2024-01-11', 'email7@example.com', false, false);

  
-- Задание 1
SELECT DISTINCT lists.id_zl, lists.list_type FROM lists 
JOIN callresult ON callresult.listid = lists.id
WHERE EXTRACT(YEAR FROM callresult.calldate) = 2023 AND list_type = '12';

-- Задание 2
SELECT DISTINCT lists.id_zl, phones.phone FROM lists 
JOIN phones ON lists.id_zl = phones.idzl
JOIN callresult ON lists.id = callresult.listid
WHERE EXTRACT(YEAR FROM callresult.calldate) = 2023 AND EXTRACT(MONTH FROM callresult.calldate) = 10 AND lists.list_type = '1';

-- Задание 3 
-- "не прошедших профмероприятия в *том* году", тут не ясно какой год является *тем*, поэтому считаю его за 2023
SELECT DISTINCT lists.id_zl, phones.phone FROM lists
JOIN phones ON lists.id_zl = phones.idzl
JOIN callresult ON lists.id = callresult.listid
WHERE EXTRACT(YEAR FROM callresult.calldate) = 2023 AND EXTRACT(MONTH FROM callresult.calldate) = 10 AND lists.list_type IN ('401', '402', '403', '404', '405') 
AND EXTRACT(YEAR FROM lists.ree_disp_date) != 2023 AND callresult.callcount = 0;

-- Задание 4 - переформатировал таблицу в CSV формат для импорта. Создал временную таблицу для переноса данных.
CREATE TABLE data_transfer (id_zl VARCHAR(50), callresult VARCHAR(50), calldate VARCHAR(50), callhow VARCHAR(50));
\COPY data_transfer FROM 'data.csv' DELIMITER ';' CSV;

INSERT INTO lists (id_zl) SELECT id_zl FROM data_transfer;
INSERT INTO callresult (listid, calldate, callresult)
SELECT lists.id, TO_DATE(data_transfer.calldate, 'DD.MM.YYYY'), data_transfer.callresult FROM data_transfer INNER JOIN lists ON lists.id_zl = data_transfer.id_zl;
DROP TABLE data_transfer;


-- Задание 5
SELECT DISTINCT lists.id_zl, phones.phone, callresult.calldate FROM lists 
JOIN phones ON lists.id_zl = phones.idzl
JOIN callresult ON lists.id = callresult.listid
WHERE EXTRACT(YEAR FROM callresult.calldate) = 2023 AND EXTRACT(MONTH FROM callresult.calldate) = 10
AND EXTRACT(YEAR FROM lists.ree_disp_date) != 2023 AND lists.list_type IN ('401', '402', '403', '404', '405') 
AND (SELECT COUNT(*) FROM callresult WHERE listid = lists.id AND calldate < '2023-10-01') = 0;


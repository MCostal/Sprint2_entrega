## NIVEL 1
-- Ejercicio 1
-- A partir de los documentos adjuntos (estructura_dades y dades_introduir), importa las dos 
-- tablas. Muestra las caracterá­sticas principales del esquema creado y explica las diferentes 
-- tablas y variables que existen. Asegurate de incluir un diagrama que ilustre la relación entre 
-- las diferentes tablas y variables.

    -- Creamos la base de datos
    CREATE DATABASE IF NOT EXISTS transactions;
    USE transactions;

    -- Creamos la tabla company
    CREATE TABLE IF NOT EXISTS company (
        id VARCHAR(15) PRIMARY KEY,
        company_name VARCHAR(255),
        phone VARCHAR(15),
        email VARCHAR(100),
        country VARCHAR(100),
        website VARCHAR(255)
    );


    -- Creamos la tabla transaction
    CREATE TABLE IF NOT EXISTS transaction (
        id VARCHAR(255) PRIMARY KEY,
        credit_card_id VARCHAR(15) REFERENCES credit_card(id),
        company_id VARCHAR(20), 
        user_id INT REFERENCES user(id),
        lat FLOAT,
        longitude FLOAT,
        timestamp TIMESTAMP,
        amount DECIMAL(10, 2),
        declined BOOLEAN,
        FOREIGN KEY (company_id) REFERENCES company(id) 
    );
    
   SHOW TABLES FROM transactions;
   
   DESC company;
   DESC transaction;
    
    
    
    
    
    
    


-- Ejercicio 2.1 Listado de los paises que están haciendo compras.
USE transactions;

SELECT DISTINCT company.country FROM company
INNER JOIN transaction
ON company.id = transaction.company_id;



-- Ejercicio 2.2 Desde cuantos paises se realizan las compras.

SELECT count(DISTINCT company.country) as paises
FROM company
INNER JOIN transaction
ON company.id = transaction.company_id;

-- El resultado es 15





-- Ejercicio 2.3 Identifica la companyia amb la mitjana más gran de vendes.

SELECT company_name as empresa, round(avg(amount),2) as media_ventas FROM company
INNER JOIN transaction
ON company.id = transaction.company_id
WHERE declined = 0
GROUP BY empresa
ORDER BY media_ventas desc
LIMIT 1;



-- Ejercicio 3.1 Muestra todas las transacciones realizadas por empresas de Alemania.

SELECT * 
FROM transaction
WHERE company_id IN
	(SELECT id FROM company
	WHERE country = 'Germany');
    
-- El resultado es de 118 transacciones. Se han tenido encuenta todas las transacciones, 
-- incluidas las declinadas con posterioridad.


-- Ejercicio 3.2 Lista las empresas que han realizado transacciones por un amount 
-- superior a la media de todas las transacciones.

SELECT company_id, max(amount) as maximo
FROM transaction
GROUP BY company_id
HAVING maximo > (SELECT avg(amount) as mediaTotal
				FROM transaction);

-- El resultado es 70 paises.



-- Ejercicio 3.3 Eliminar del sistema las empresas que no tienen transacciones registradas, 
-- entrega el listado d'aquestes empreses.

SELECT company.company_name
FROM company
WHERE company.id NOT IN (SELECT DISTINCT transaction.company_id
				  FROM transaction);

                  
## NIVEL 2

-- Ejercicio 1 Identifica los cinco días que se generó la mayor cantidad de ingresos en la empresa
-- por ventas. Muestra la fecha de cada transacción junto con el total de las ventas.

SELECT 	date(timestamp) AS date, 
        sum(amount) AS total
FROM transaction
WHERE declined = 0
GROUP BY date
ORDER BY total DESC
LIMIT 5;

SELECT * FROM company;


-- Ejercicio 2 ¿Cuál es el promedio de ventas por país? Presenta los resultados ordenados 
-- de mayor a menor medio.

SELECT country, round(avg(amount),2) as media
FROM company
INNER JOIN transaction
ON company.id = transaction.company_id
WHERE declined = 0
GROUP BY country
ORDER BY media desc;




-- Ejercicio 3 En tu empresa, se plantea un nuevo proyecto para lanzar algunas campañas 
-- publicitarias para hacer competencia a la compañía "Non Institute". Para ello, te piden 
-- la lista de todas las transacciones realizadas por empresas que están situadas 
-- en el mismo país que esta compañía.
-- Muestra el listado aplicando JOIN y subconsultas.

-- Utilizando JOINS y subqueries

SELECT company.company_name, 
		transaction.user_id, 
        transaction.id, 
        transaction.lat, 
        transaction.longitude, 
        transaction.timestamp, 
        transaction.amount, 
        company.country
FROM company
INNER JOIN transaction
ON company.id = transaction.company_id
WHERE company.country = (SELECT company.country 
						FROM company
						WHERE company.company_name = 'Non Institute');
                
-- El resultado es 70 transacciones
SELECT * FROM transaction;
SELECT * FROM company;

-- Utilizando únicamente subqueries

SELECT company_name, 
		user_id, 
        transaction.id, 
        lat, 
        longitude, 
        timestamp, 
        amount, 
        country
FROM company, transaction
WHERE country = (SELECT country 
				FROM company
				WHERE company_name = 'Non Institute') 
                and company.id = transaction.company_id;
                
-- El resultado es 70 transacciones

SELECT * FROM transaction;
SELECT * FROM company;




## NIVEL 3 

-- Ejercicio 1 
-- Presenta el nombre, teléfono, país, fecha y amount, de aquellas empresas 
-- que realizaron transacciones con un valor comprendido entre 100 y 200 euros y en alguna 
-- de estas fechas: 29 de abril de 2021, 20 de julio de 2021 y 13 de marzo de 2022. 
-- Ordena los resultados de mayor a menor cantidad.


SELECT company.company_name, company.phone, company.country, date(transaction.timestamp) as date, transaction.amount
FROM company
INNER JOIN transaction
ON company.id = transaction.company_id
WHERE transaction.amount BETWEEN 100 AND 200
	   AND 
	  (date(transaction.timestamp) IN ('2021-04-29', '2021-07-20', '2022-03-13'))
ORDER BY amount desc;


-- Ejercicio 2 
-- Necesitamos optimizar la asignación de los recursos y dependerá de la capacidad 
-- operativa que se requiera, por lo que te piden la información sobre la cantidad de 
-- transacciones que realizan las empresas, pero el departamento de recursos humanos es exigente 
-- y quiere un listado de las empresas donde especifiques si tienen más de 4 transacciones o menos.

SELECT company.company_name as empresa,
		CASE WHEN count(transaction.id) >= 4 THEN 'Mayor o igual a 4'
			 ELSE 'Menor a 4'
		END AS Cantidad
FROM company
INNER JOIN transaction
ON company.id = transaction.company_id
GROUP BY company.id;

      
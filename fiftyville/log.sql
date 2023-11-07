-- Keep a log of any SQL queries you execute as you solve the mystery.

-- Getting a description of where the crime took place
SELECT description FROM crime_scene_reports
WHERE month=7 AND day= 28
AND street= 'Humphrey Street'; 

--Theft of the CS50 duck took place at 10:15am at the Humphrey Street bakery. Interviews were conducted today with three witnesses who were present at the time – each of their interview transcripts mentions the bakery.
--Littering took place at 16:36. No known witnesses.


--  Using transcript with keyword bakery to find out the events that happened at the crime scene
SELECT transcript FROM interviews
WHERE month=7 AND day=28 AND 
transcript LIKE '%Bakery%';

--Sometime within ten minutes of the theft, I saw the thief get into a car in the bakery parking lot and drive away. If you have security footage from the bakery parking lot, you might want to look for cars that left the parking lot in that time frame.
--I don't know the thief's name, but it was someone I recognized. Earlier this morning, before I arrived at Emma's bakery, I was walking by the ATM on Leggett Street and saw the thief there withdrawing some money.
--As the thief was leaving the bakery, they called someone who talked to them for less than a minute. In the call, I heard the thief say that they were planning to take the earliest flight out of Fiftyville tomorrow. The thief then asked the person on the other end of the phone to purchase the flight ticket.


--Want to get the license plate of vehicles entering or leaving at a specific time including their name
SELECT bakery_security_logs.activity,bakery_security_logs.license_plate,people.name FROM people
JOIN bakery_security_logs ON bakery_security_logs.license_plate = people.license_plate
WHERE bakery_security_logs.year  = 2021
AND bakery_security_logs.month=7
AND bakery_security_logs.day=28
AND bakery_security_logs.minute <= 25
AND bakery_security_logs.minute >= 15
AND bakery_security_logs.hour = 10;

-- Suspects
-- exit|5P2BI95|Vanessa
-- exit|94KL13X|Bruce
-- exit|6P58WS2|Barry
-- exit|4328GD8|Luca
-- exit|G412CB7|Sofia
-- exit|L93JTIZ|Iman
-- exit|322W7JE|Diana
-- exit|0NTHK55|Kelsey


-- using the bank transactions from the atm on legget street to identify a suspect
SELECT people.name, atm_transactions.transaction_type FROM people
JOIN bank_accounts ON bank_accounts.person_id = people.id
JOIN atm_transactions ON atm_transactions.account_number = bank_accounts.account_number
WHERE atm_transactions.year = 2021
AND atm_transactions.month = 7
AND atm_location = 'Leggett Street'
AND atm_transactions.day = 28
AND atm_transactions.transaction_type = 'withdraw';


-- found a few names of people that match the vehicles entering and leaving the 
-- parking lot of the bakery

-- Bruce|withdraw
-- Diana|withdraw
-- Brooke|withdraw
-- Kenny|withdraw
-- Iman|withdraw
-- Luca|withdraw
-- Taylor|withdraw
-- Benista|withdraw


--Checking phone calls because one of the witnesses said the suspect was on the phone with some once they left the bakery for less than a minute
SELECT phone_calls.caller,caller_people.name AS caller_name,phone_calls.receiver,receiver_people.name AS receiver_name
FROM phone_calls
JOIN people AS caller_people ON phone_calls.caller = caller_people.phone_number
JOIN people AS receiver_people ON phone_calls.receiver = receiver_people.phone_number
WHERE phone_calls.year = 2021
AND phone_calls.month = 7
AND phone_calls.day = 28
AND phone_calls.duration < 60;


-- people who where on a call at the time
--Checking if there isnt names that correspond to previous name checks
-- (130) 555-0289|Sofia|(996) 555-8899|Jack
-- (499) 555-9472|Kelsey|(892) 555-8872|Larry
-- (367) 555-5533|Bruce|(375) 555-8161|Robin
-- (499) 555-9472|Kelsey|(717) 555-1342|Melissa
-- (286) 555-6063|Taylor|(676) 555-6554|James
-- (770) 555-1861|Diana|(725) 555-3243|Philip
-- (031) 555-6622|Carina|(910) 555-3251|Jacqueline
-- (826) 555-1652|Kenny|(066) 555-9701|Doris
-- (338) 555-6650|Benista|(704) 555-2131|Anna


-- Name of passengers who got the earliest flight out of fiftyville
SELECT name FROM people
JOIN passengers ON passengers.passport_number = people.passport_number
WHERE passengers.flight_id = (
SELECT id FROM flights
WHERE year = 2021 AND month = 7 AND day = 29 AND origin_airport_id = (
SELECT id FROM airports WHERE city = 'Fiftyville')
ORDER BY hour,minute
LIMIT 1);

-- The destination of where the suspect will land
SELECT city FROM airports
WHERE id = (SELECT destination_airport_id FROM flights
WHERE year = 2021 AND month = 7 AND day = 29 AND origin_airport_id =(
SELECT id FROM airports WHERE city='Fiftyville')
ORDER BY hour,minute
LIMIT 1);

-- city where suspect has landed
-- New York City

-- Bruce has most of the evidence pointed at him so im gonna find out who he was on the phone with that morning morning
-- so i can know who the accomplice is
SELECT phone_number FROM people WHERE name='Bruce';

-- Bruce phone number
--(367) 555-5533

-- I checked the duration of the call that was less than 60 seconds that he had
-- Bruces accomplice is robin 
SELECT name FROM people WHERE phone_number = (
SELECT receiver FROM phone_calls
WHERE year = 2021 AND month = 7 AND day = 28 AND duration < 60 AND caller = "(367) 555-5533" );
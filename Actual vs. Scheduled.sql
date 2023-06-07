--Show the employees actual clock in time vs scheduled time
--Taking into account two different time zones and daylight savings (2nd Sunday of March to the 1st Sunday of November)

SELECT DISTINCT
t2.Store_Id, t1.Employee_Id, CONCAT(t3.First_Name, ' ', t3.Middle_Initial, ' ', t3.Last_Name) AS Name, t2.Clock_In_Time, t2.Clock_Out_Datetime_Local,  

--Shows employee's scheduled start time for stores in the east coast during daylight savings period
CASE
WHEN
t1.region = 'East Coast'
    AND (
Start_Time >=  DATEADD(DAY, 8 - DATEPART(WEEKDAY, DATEFROMPARTS(YEAR(Start_Time), 3, 8)), DATEFROMPARTS(YEAR(Start_Time), 3, 8))
AND Start_Time <= DATEADD(WEEK, 1, DATEADD(WEEKDAY, 1 - DATEPART(WEEKDAY, DATEFROMPARTS(YEAR(Start_Time), 11, 1)), DATEFROMPARTS(YEAR(Start_Time), 11, 1))))
    THEN DATEADD(hour, -4, t1.Start_Time)

--Shows employee's scheduled start time for stores in the east coast NOT during daylight savings period
WHEN
t1.region = 'East Coast' AND
(
Start_Time <  DATEADD(DAY, 8 - DATEPART(WEEKDAY, DATEFROMPARTS(YEAR(Start_Time), 3, 8)), DATEFROMPARTS(YEAR(Start_Time), 3, 8))
OR Start_Time > DATEADD(WEEK, 1, DATEADD(WEEKDAY, 1 - DATEPART(WEEKDAY, DATEFROMPARTS(YEAR(Start_Time), 11, 1)), DATEFROMPARTS(YEAR(Start_Time), 11, 1))))
THEN DATEADD(hour, -5, t1.Start_Time)

--Shows employee's scheduled start time for stores in the west coast during daylight savings period
WHEN
t1.region = 'West Coast'
    AND (
Start_Time >=  DATEADD(DAY, 8 - DATEPART(WEEKDAY, DATEFROMPARTS(YEAR(Start_Time), 3, 8)), DATEFROMPARTS(YEAR(Start_Time), 3, 8))
AND Start_Time <= DATEADD(WEEK, 1, DATEADD(WEEKDAY, 1 - DATEPART(WEEKDAY, DATEFROMPARTS(YEAR(Start_Time), 11, 1)), DATEFROMPARTS(YEAR(Start_Time), 11, 1))))
    THEN DATEADD(hour, -7, t1.Start_Time)

--Shows employee's scheduled start time for stores in the west coast NOT during daylight savings period
WHEN
t1.region = 'West Coast' AND
(
Start_Time <  DATEADD(DAY, 8 - DATEPART(WEEKDAY, DATEFROMPARTS(YEAR(Start_Time), 3, 8)), DATEFROMPARTS(YEAR(Start_Time), 3, 8))
OR Start_Time > DATEADD(WEEK, 1, DATEADD(WEEKDAY, 1 - DATEPART(WEEKDAY, DATEFROMPARTS(YEAR(Start_Time), 11, 1)), DATEFROMPARTS(YEAR(Start_Time), 11, 1))))
THEN DATEADD(hour, -8, t1.Start_Time)

END AS Scheduled_Start_Time,

--Shows employee's scheduled end time for stores in the east coast during daylight savings period
CASE
WHEN
t1.region = 'East Coast'
    AND (
End_Date_Time >=  DATEADD(DAY, 8 - DATEPART(WEEKDAY, DATEFROMPARTS(YEAR(End_Date_Time), 3, 8)), DATEFROMPARTS(YEAR(End_Date_Time), 3, 8))
AND End_Date_Time <= DATEADD(WEEK, 1, DATEADD(WEEKDAY, 1 - DATEPART(WEEKDAY, DATEFROMPARTS(YEAR(End_Date_Time), 11, 1)), DATEFROMPARTS(YEAR(End_Date_Time), 11, 1))))
    THEN DATEADD(hour, -4, t1.End_Date_Time)

--Shows employee's scheduled start time for stores in the east coast NOT during daylight savings period
WHEN
t1.region = 'East Coast' AND
(
End_Date_Time <  DATEADD(DAY, 8 - DATEPART(WEEKDAY, DATEFROMPARTS(YEAR(End_Date_Time), 3, 8)), DATEFROMPARTS(YEAR(End_Date_Time), 3, 8))
OR End_Date_Time > DATEADD(WEEK, 1, DATEADD(WEEKDAY, 1 - DATEPART(WEEKDAY, DATEFROMPARTS(YEAR(End_Date_Time), 11, 1)), DATEFROMPARTS(YEAR(End_Date_Time), 11, 1))))
THEN DATEADD(hour, -5, t1.End_Date_Time)

--Shows employee's scheduled start time for stores in the west coast during daylight savings period
WHEN
t1.region = 'West Coast'
    AND (
End_Date_Time >=  DATEADD(DAY, 8 - DATEPART(WEEKDAY, DATEFROMPARTS(YEAR(End_Date_Time), 3, 8)), DATEFROMPARTS(YEAR(End_Date_Time), 3, 8))
AND End_Date_Time <= DATEADD(WEEK, 1, DATEADD(WEEKDAY, 1 - DATEPART(WEEKDAY, DATEFROMPARTS(YEAR(End_Date_Time), 11, 1)), DATEFROMPARTS(YEAR(End_Date_Time), 11, 1))))
    THEN DATEADD(hour, -7, t1.End_Date_Time)

--Shows employee's scheduled start time for stores in the west coast NOT during daylight savings period
WHEN
t1.region = 'West Coast' AND
(
End_Date_Time <  DATEADD(DAY, 8 - DATEPART(WEEKDAY, DATEFROMPARTS(YEAR(End_Date_Time), 3, 8)), DATEFROMPARTS(YEAR(End_Date_Time), 3, 8))
OR End_Date_Time > DATEADD(WEEK, 1, DATEADD(WEEKDAY, 1 - DATEPART(WEEKDAY, DATEFROMPARTS(YEAR(End_Date_Time), 11, 1)), DATEFROMPARTS(YEAR(End_Date_Time), 11, 1))))
THEN DATEADD(hour, -8, t1.End_Date_Time)

END AS Scheduled_End_Time

FROM [Employees_Schedules_Tb] as t1

INNER JOIN [Employees_Times_Tb] AS t2
ON t1.Employee_Id = t2.Employee_Id AND t1.Store_Id = t2.Store_Id AND CAST(t1.Start_Time AS date) = CAST(t2.Clock_In_Time AS date)

LEFT JOIN [Employee_Info_Tb] AS t3
ON t1.Employee_Id = t3.Employee_Id

--Where the clock_in_time and start_time are from the beginning of the year to current date
WHERE (Clock_In_Time >= DATEFROMPARTS(YEAR(GETDATE()), 1, 1)
AND Clock_In_Time <= GETDATE()) AND (Start_Time >= DATEFROMPARTS(YEAR(GETDATE()), 1, 1)
AND Start_Time <= GETDATE())

-- Trying to find where the difference between clock_in_time and the scheduled_start_time is less than 2 hours
AND (ABS(DATEDIFF(hour, Clock_In_Time, (CASE
WHEN
t1.region = 'East Coast'
    AND (
Start_Time >=  DATEADD(DAY, 8 - DATEPART(WEEKDAY, DATEFROMPARTS(YEAR(Start_Time), 3, 8)), DATEFROMPARTS(YEAR(Start_Time), 3, 8))
AND Start_Time <= DATEADD(WEEK, 1, DATEADD(WEEKDAY, 1 - DATEPART(WEEKDAY, DATEFROMPARTS(YEAR(Start_Time), 11, 1)), DATEFROMPARTS(YEAR(Start_Time), 11, 1))))
    THEN DATEADD(hour, -4, t1.Start_Time)

WHEN
t1.region = 'East Coast' AND
(
Start_Time <  DATEADD(DAY, 8 - DATEPART(WEEKDAY, DATEFROMPARTS(YEAR(Start_Time), 3, 8)), DATEFROMPARTS(YEAR(Start_Time), 3, 8))
OR Start_Time > DATEADD(WEEK, 1, DATEADD(WEEKDAY, 1 - DATEPART(WEEKDAY, DATEFROMPARTS(YEAR(Start_Time), 11, 1)), DATEFROMPARTS(YEAR(Start_Time), 11, 1))))
THEN DATEADD(hour, -5, t1.Start_Time)

WHEN
t1.region = 'West Coast'
    AND (
Start_Time >=  DATEADD(DAY, 8 - DATEPART(WEEKDAY, DATEFROMPARTS(YEAR(Start_Time), 3, 8)), DATEFROMPARTS(YEAR(Start_Time), 3, 8))
AND Start_Time <= DATEADD(WEEK, 1, DATEADD(WEEKDAY, 1 - DATEPART(WEEKDAY, DATEFROMPARTS(YEAR(Start_Time), 11, 1)), DATEFROMPARTS(YEAR(Start_Time), 11, 1))))
    THEN DATEADD(hour, -7, t1.Start_Time)

WHEN
t1.region = 'West Coast' AND
(
Start_Time <  DATEADD(DAY, 8 - DATEPART(WEEKDAY, DATEFROMPARTS(YEAR(Start_Time), 3, 8)), DATEFROMPARTS(YEAR(Start_Time), 3, 8))
OR Start_Time > DATEADD(WEEK, 1, DATEADD(WEEKDAY, 1 - DATEPART(WEEKDAY, DATEFROMPARTS(YEAR(Start_Time), 11, 1)), DATEFROMPARTS(YEAR(Start_Time), 11, 1))))
THEN DATEADD(hour, -8, t1.Start_Time)

END))) <= 2)

ORDER BY Store_Id, Employee_Id, Clock_In_Time, Scheduled_Start_Time

/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
SELECT * FROM Facilities
WHERE membercost > 0;

/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT(*) FROM Facilities
WHERE membercost = 0;

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost < (monthlymaintenance * .2);

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
SELECT *
FROM Facilities
WHERE facid IN (1, 5);

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
SELECT name, monthlymaintenance,
(CASE WHEN monthlymaintenance > 100 THEN 'expensive'
    ELSE 'cheap'END) AS RelativeCost
FROM Facilities;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT * 
FROM Members
WHERE memid = 
    (SELECT MAX(memid) FROM Members);


/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT CONCAT_WS(" ", m.firstname, m.surname)AS memname, f.name
FROM 
    (SELECT facid, memid
     FROM Bookings
     WHERE facid IN (0,1)) AS Booking
LEFT JOIN Members AS m
ON Booking.memid = m.memid
LEFT JOIN Facilities AS f
ON Booking.facid = f.facid
-- Optional if member duplicates due to booking both courts should be eliminated. Include: "GROUP BY memname"
ORDER BY memname;


/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT f.name, CONCAT_WS(" ",m.firstname,m.surname) AS memname,
CASE WHEN m.memid = 0 THEN (guestcost * slots)
ELSE (membercost * slots) END AS totalcost
FROM Bookings as b
LEFT JOIN Facilities as f
ON b.facid = f.facid
LEFT JOIN Members as m
ON b.memid = m.memid
WHERE b.starttime LIKE "2012-09-14%"
HAVING totalcost >30
ORDER BY totalcost DESC;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT f.name, CONCAT_WS(" ",m.firstname,m.surname) AS memname, m.memid, b.facid, membercost, guestcost, slots,
CASE WHEN m.memid = 0 THEN (guestcost * slots)
ELSE (membercost * slots) END AS totalcost
FROM (SELECT * FROM Bookings WHERE Bookings.starttime LIKE "2012-09-14%") AS b
LEFT JOIN Facilities as f
ON b.facid = f.facid
LEFT JOIN Members as m
ON b.memid = m.memid
HAVING totalcost >30
ORDER BY totalcost DESC;

--SQLite Section Begins Below

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
        SELECT f.name,
        SUM(CASE WHEN m.memid = 0 THEN (guestcost * slots)
        ELSE (membercost * slots) END) AS totalrevenue
        FROM Bookings as b
        LEFT JOIN Facilities as f
        ON b.facid = f.facid
        LEFT JOIN Members as m
        ON b.memid = m.memid
        GROUP BY f.name
        ORDER BY totalrevenue DESC

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
        SELECT m1.surname, m1.firstname, m2.surname,  m2.firstname
        FROM Members AS m1
        INNER JOIN Members AS m2
        ON m1.recommendedby = m2.memid
        WHERE m1.memid > 0
        ORDER BY m2.surname

/* Q12: Find the facilities with their usage by member, but not guests */
        SELECT m.memid,
        m.firstname ||" "||m.surname AS memname,
        SUM(CASE WHEN m.memid = 0 THEN (guestcost * slots)
            ELSE (membercost * slots) END) AS totalrevenue
        FROM Bookings as b
        LEFT JOIN Facilities as f
        ON b.facid = f.facid
        LEFT JOIN Members as m
        ON b.memid = m.memid
        WHERE m.memid > 0
        GROUP BY m.memid

/* Q13: Find the facilities usage by month, but not guests */
        SELECT f.name, 
        strftime('%m', starttime) AS month, 
        SUM(slots)
        FROM Bookings as b
        LEFT JOIN Facilities as f
        ON b.facid = f.facid
        LEFT JOIN Members as m
        ON b.memid = m.memid
        WHERE m.memid > 0
        GROUP BY f.name, month


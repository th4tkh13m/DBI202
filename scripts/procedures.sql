CREATE OR ALTER PROCEDURE printInvoice
    @stuCode NVARCHAR(8)
AS

SELECT inv.invCode, stu.stuName, stu.roomCode , inv.semester, inv.basicCost, inv.totalCost
FROM STUDENT stu INNER JOIN INVOICE inv ON stu.stuCode = inv.stuCode
WHERE  stu.stuCode = @stuCode
GO

CREATE OR ALTER PROCEDURE room_incurred
    @roomCode NVARCHAR(4)
AS

SELECT r.roomCode , inc.semester, inc.incurredCost
FROM ROOM r INNER JOIN INCURRED inc ON r.roomCode = inc.roomCode
WHERE r.roomCode = @roomCode
GO
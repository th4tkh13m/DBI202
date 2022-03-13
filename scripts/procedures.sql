CREATE OR ALTER PROCEDURE printInvoiceHistory
    @stuCode NVARCHAR(8)
AS

SELECT inv.invCode, stu.stuName, stu.roomCode , inv.semester, inv.basicCost, inv.totalCost
FROM STUDENT stu INNER JOIN INVOICE inv ON stu.stuCode = inv.stuCode
WHERE  stu.stuCode = @stuCode
GO

CREATE OR ALTER PROCEDURE roomIncurredHistory
    @roomCode NVARCHAR(4)
AS

SELECT r.roomCode , inc.semester, inc.incurredCost
FROM ROOM r INNER JOIN INCURRED inc ON r.roomCode = inc.roomCode
WHERE r.roomCode = @roomCode
GO

CREATE OR ALTER PROCEDURE checkoutStudent
    @stuCode NVARCHAR(8),
    @semester NVARCHAR(4)
AS
IF EXISTS (SELECT *
FROM INVOICE
WHERE stuCode = @stuCode AND semester = @semester)
BEGIN
    DELETE FROM OWN
WHERE stuCode = @stuCode

    DELETE FROM INVOICE
WHERE stuCode = @stuCode AND semester = @semester

    DELETE FROM STUDENT
WHERE stuCode = @stuCode
END
GO
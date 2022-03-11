CREATE OR ALTER FUNCTION calculateTotal
(
    @invCode NVARCHAR(8)
)
RETURNS INT
AS
BEGIN
    DECLARE @total INT;
    DECLARE @semester NVARCHAR(4);
    DECLARE @roomCode NVARCHAR(4);
    DECLARE @stuCode NVARCHAR(8);
    SELECT @stuCode = stuCode
    FROM tblStudent
    WHERE stuCode = @invCode;
    SELECT @semester = semester
    FROM INVOICE
    WHERE invCode = @invCode;
    SELECT @roomCode = roomCode
    FROM STUDENT
    WHERE stuCode = @stuCode;
    SELECT @total = 6000 * waterAmount + 3500 * elecAmount
    FROM INCURRED
    WHERE roomCode = @roomCode AND semester = @semester;
    SELECT @total = @total + (SELECT basicCost
        FROM INVOICE
        WHERE invCode = @invCode);
    RETURN @total;
END
CREATE OR ALTER FUNCTION calculateRoomNumber
(
    @roomCode NVARCHAR(4)
)
RETURNS INT
AS
BEGIN
    RETURN (SELECT COUNT(*)
    FROM STUDENT
    WHERE roomCode = @roomCode);
END
GO
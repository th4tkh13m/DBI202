CREATE OR ALTER TRIGGER studentAdd ON STUDENT
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @count INT;
    DECLARE @roomCode NUMERIC(3);
    SELECT @roomCode = roomCode
    FROM inserted;
    SELECT @count = COUNT(*)
    FROM STUDENT
    WHERE roomCode = @roomCode;
    IF (@count > 8)
    BEGIN
        PRINT('Room is full');
        ROLLBACK TRANSACTION;
    END
END

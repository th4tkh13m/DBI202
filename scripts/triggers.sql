CREATE OR ALTER TRIGGER studentAdd ON STUDENT
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @count INT;
    DECLARE @roomCode NVARCHAR(4);
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
GO

CREATE OR ALTER TRIGGER limitFacility ON OWN
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @count INT;
    DECLARE @facCode NUMERIC(3);
    SELECT @facCode = facCode
    FROM inserted;
    SELECT @count = COUNT(*)
    FROM OWN
    WHERE facCode = @facCode;
    IF (@count > 1)
    BEGIN
        PRINT('Each student own only one facility');
        ROLLBACK TRANSACTION;
    END
END
GO


CREATE OR ALTER TRIGGER roomLimit ON ROOM
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @count INT;
    DECLARE @areaCode NVARCHAR(4);
    SELECT @areaCode = areaCode
    FROM inserted;
    SELECT @count = COUNT(*)
    FROM ROOM
    WHERE areaCode = @areaCode;
    IF (@count > 30)
    BEGIN
        PRINT('Area is full');
        ROLLBACK TRANSACTION;
    END
END
GO

CREATE OR ALTER TRIGGER addTotal ON INVOICE
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @total INT;
    DECLARE @invCode NVARCHAR(8);
    SELECT @invCode = invCode
    FROM inserted;
    SELECT @total = calculateTotal(@invCode);
    UPDATE INVOICE
    SET totalCost = @total
    WHERE invCode = @invCode;
END
GO
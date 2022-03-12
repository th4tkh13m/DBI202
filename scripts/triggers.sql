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
    SELECT TOP 1 @count = COUNT(*)
    FROM inserted
    GROUP BY stuCode, facCode
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

CREATE OR ALTER TRIGGER totalIncurred ON INCURRED
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE INCURRED
    SET incurredCost = 6000 * waterAmount + 3500 * elecAmount
    WHERE roomCode IN (SELECT roomCode FROM INSERTED) AND semester IN (SELECT semester FROM INSERTED);
END
GO


CREATE OR ALTER TRIGGER addTotal ON INVOICE
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE INVOICE
    SET totalCost = basicCost + incurredCost
    FROM (INVOICE INNER JOIN  STUDENT ON INVOICE.stuCode = STUDENT.stuCode) INNER JOIN INCURRED
    ON INCURRED.semester = INVOICE.semester AND INCURRED.roomCode = STUDENT.roomCode
    WHERE invCode IN (SELECT invCode FROM INSERTED);
END
GO
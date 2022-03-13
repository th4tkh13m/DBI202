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
    DECLARE @elecLimit INT;
    DECLARE @waterLimit INT;
    SET @elecLimit = 1600;
    SET @waterLimit = 108;
    UPDATE INCURRED
    SET incurredCost =
    CASE
        WHEN (elecAmount > @elecLimit AND waterAmount > @waterLimit) THEN (elecAmount - @elecLimit) * 3500 + (waterAmount - @waterLimit) * 6000
        WHEN (elecAmount > @elecLimit) THEN (elecAmount - @elecLimit) * 3500
        WHEN (waterAmount > @waterLimit) THEN (waterAmount - @waterLimit) * 6000
        ELSE 0
    END
    WHERE roomCode IN (SELECT roomCode
        FROM INSERTED) AND semester IN (SELECT semester
        FROM INSERTED);
END
GO

CREATE OR ALTER TRIGGER addTotal ON INVOICE
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE INVOICE
    SET totalCost = basicCost + incurredCost / dbo.calculateRoomNumber(INCURRED.roomCode)
    FROM (INVOICE INNER JOIN STUDENT ON INVOICE.stuCode = STUDENT.stuCode) INNER JOIN INCURRED
        ON INCURRED.semester = INVOICE.semester AND INCURRED.roomCode = STUDENT.roomCode
    WHERE invCode IN (SELECT invCode
    FROM INSERTED);
    DELETE FROM INVOICE WHERE totalCost IS NULL;
END
GO

CREATE OR ALTER TRIGGER changeRoom ON STUDENT
AFTER UPDATE
AS
BEGIN
    DECLARE @roomCode NVARCHAR(4);
    DECLARE @oldRoomCode NVARCHAR(4);
    SELECT @roomCode = roomCode
    FROM inserted;
    SELECT @oldRoomCode = roomCode
    FROM deleted;
    IF (@roomCode <> @oldRoomCode)
    BEGIN
        UPDATE STUDENT
        SET roomCode = @roomCode
        WHERE roomCode = @oldRoomCode;
    END
END
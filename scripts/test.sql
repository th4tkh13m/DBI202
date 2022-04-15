INSERT INTO AREA
VALUES
    (1, 'Test')

INSERT INTO ROOM
VALUES
    (219, 1)
GO

INSERT INTO INCURRED
    (roomCode, semester, waterAmount, elecAmount)
VALUES
    ('P01', 'SP20', 9, 10),
    ('P02', 'SP20', 65, 10),
    ('P03', 'SP20', 0, 100),
    ('P04', 'SP20', 2, 4),
    ('P05', 'SP20', 0, 9),
    ('P06', 'SP20', 0, 0),
    ('P07', 'SP20', 0, 0),
    ('P08', 'SP20', 0, 0),
    ('P09', 'SP20', 0, 0),
    ('P10', 'SP20', 0, 0),
    ('P11', 'SP20', 0, 0),
    ('P12', 'SP20', 0, 0),
    ('P13', 'SP20', 0, 0),
    ('P14', 'SP20', 0, 0),
    ('P15', 'SP20', 0, 0),
    ('P16', 'SP20', 0, 0),
    ('P17', 'SP20', 0, 0),
    ('P18', 'SP20', 0, 0),
    ('P19', 'SP20', 0, 0),
    ('P20', 'SP20', 0, 0),
    ('P21', 'SP20', 0, 0),
    ('P22', 'SP20', 0, 0),
    ('P23', 'SP20', 0, 0),
    ('P24', 'SP20', 0, 0),
    ('P25', 'SP20', 0, 0),
    ('P26', 'SP20', 0, 0),
    ('P27', 'SP20', 0, 0)
GO

SELECT TOP 20
    *
FROM INCURRED
GO

SELECT TOP 20
    *
FROM INVOICE

UPDATE STUDENT
SET roomCode = 'P02'
WHERE stuCode = 'SV10'
GO

EXEC printInvoiceHistory 'SV29'
GO

EXEC roomIncurredHistory 'P12'
GO

EXEC checkoutStudent 'SV18', 'SU21'
GO
SELECT *
FROM STUDENT
WHERE stuCode = 'SV18'
GO

BEGIN TRY 
EXEC checkoutStudent 'SV21', 'SU21'
END TRY
BEGIN CATCH
PRINT 'TEST PASS'
END CATCH

GO
SELECT *
FROM STUDENT
WHERE stuCode = 'SV21'
GO

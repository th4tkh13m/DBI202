INSERT INTO AREA VALUES
(1, 'Test')

INSERT INTO ROOM VALUES
(219, 1)
GO

INSERT INTO INCURRED(roomCode, semester, waterAmount, elecAmount)
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

SELECT TOP 20 * FROM INCURRED
GO

INSERT INTO INVOICE(invCode, StuCode, semester, basicCost)
VALUES
('INV01', 'SV01', 'SP20', 6000),
('INV02', 'SV02', 'SP20', 6000),
('INV03', 'SV03', 'SP20', 6000),
('INV04', 'SV04', 'SP20', 6000),
('INV05', 'SV05', 'SP20', 6000),
('INV06', 'SV06', 'SP20', 6000),
('INV07', 'SV07', 'SP20', 6000),
('INV08', 'SV08', 'SP20', 6000),
('INV09', 'SV09', 'SP20', 6000),
('INV10', 'SV10', 'SP20', 6000),
('INV11', 'SV11', 'SP20', 6000),
('INV12', 'SV12', 'SP20', 6000),
('INV13', 'SV13', 'SP20', 6000),
('INV14', 'SV14', 'SP20', 6000),
('INV15', 'SV15', 'SP20', 6000),
('INV16', 'SV16', 'SP20', 6000),
('INV17', 'SV17', 'SP20', 6000),
('INV18', 'SV18', 'SP20', 6000),
('INV19', 'SV19', 'SP20', 6000),
('INV20', 'SV20', 'SP20', 6000),
('INV21', 'SV21', 'SP20', 6000),
('INV22', 'SV22', 'SP20', 6000),
('INV23', 'SV23', 'SP20', 6000),
('INV24', 'SV24', 'SP20', 6000),
('INV25', 'SV25', 'SP20', 6000),
('INV26', 'SV26', 'SP20', 6000),
('INV27', 'SV27', 'SP20', 6000),
('INV28', 'SV28', 'SP20', 6000),
('INV29', 'SV29', 'SP20', 6000)
GO
SELECT TOP 20 * FROM INVOICE


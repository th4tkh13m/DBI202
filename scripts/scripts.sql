CREATE TABLE AREA
(
    areaCode NVARCHAR(4) PRIMARY KEY,
    areName NVARCHAR(50),
)

CREATE TABLE EMPLOYEE
(
    empCode NVARCHAR(4) PRIMARY KEY,
    empName NVARCHAR(50),
    empSex NVARCHAR(1) CHECK (empSex IN ('M', 'F')),
    empBirthdate DATE,
    empPhone NVARCHAR(20),
    empAddress NVARCHAR(70),
    empSSN NVARCHAR(20),
)

CREATE TABLE ROOM
(
    roomCode NVARCHAR(4) PRIMARY KEY,
    areaCode NVARCHAR(4),
    FOREIGN KEY(areaCode) REFERENCES AREA(areaCode)
)

CREATE TABLE STUDENT
(
    stuCode NVARCHAR(8) PRIMARY KEY,
    roomCode NVARCHAR(4),
    stuName NVARCHAR(50),
    stuSex NVARCHAR(1) CHECK(stuSex IN ('M', 'F')),
    stuBirthdate DATE,
    stuPhone NVARCHAR(20),
    stuAddress NVARCHAR(70),
    stuSSN NVARCHAR(20),
    FOREIGN KEY(roomCode) REFERENCES ROOM(roomCode)
)

CREATE TABLE FACILITY
(
    facCode NVARCHAR(4) PRIMARY KEY,
    facName NVARCHAR(50),
)

CREATE TABLE OWN
(
    facCode NVARCHAR(4),
    stuCode NVARCHAR(8),
    facStatus NVARCHAR(10) CHECK(facStatus IN (N'Tốt', N'Hỏng', N'Mất')),
    FOREIGN KEY(facCode) REFERENCES FACILITY(facCode),
    FOREIGN KEY(stuCode) REFERENCES STUDENT(stuCode),
    CONSTRAINT PK_OWN PRIMARY KEY (facCode, stuCode)
)


CREATE TABLE INCURRED
(
    roomCode NVARCHAR(4),
    semester NVARCHAR(4),
    waterAmount INT,
    elecAmount INT,
    incurredCost INT,
    FOREIGN KEY(roomCode) REFERENCES ROOM(roomCode),
    CONSTRAINT PK_INCURRED PRIMARY KEY (roomCode, semester)
)

CREATE TABLE INVOICE
(
    invCode NVARCHAR(8) PRIMARY KEY,
    stuCode NVARCHAR(8),
    semester NVARCHAR(4),
    basicCost INT,
    totalCost INT,
    FOREIGN KEY(stuCode) REFERENCES STUDENT(stuCode)
)

CREATE TABLE MANAGER
(
    areaCode NVARCHAR(4),
    empCode NVARCHAR(4),
    FOREIGN KEY(areaCode) REFERENCES AREA(areaCode),
    FOREIGN KEY(empCode) REFERENCES EMPLOYEE(empCode),
    CONSTRAINT PK_MANAGER PRIMARY KEY (areaCode, empCode)
)
GO

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
GO

INSERT INTO AREA
VALUES
    ('KV01', N'Khu vực 1'),
    ('KV02', N'Khu vực 2'),
    ('KV03', N'Khu vực 3'),
    ('KV04', N'Khu vực 4'),
    ('KV05', N'Khu vực 5');
GO

INSERT INTO EMPLOYEE
VALUES
    ('NV01', N'Khải Thuận', 'M', '1973-08-30', '0254209306', N'Xã Phước Tỉnh, Huyện Long Điền, Bà Rịa - Vũng Tàu', '0828923246'),
    ('NV02', N'Nguyễn Văn A', 'M', '1983-02-01', '8476207077', N'210 Phố Sâm, Thôn Thào Thắng, Huyện 20 Hồ Chí Minh', '9634662467'),
    ('NV03', N'Phạm Đào Nguyễn', 'F', '1998-02-22', '025420232206', N'3890 Phố Đới Khanh Duệ, Thôn Kha Hậu, Quận Xuân Vịnh Lào Cai', '0828923246'),
    ('NV04', N'Võ Văn Việt', 'M', '1993-08-05', '84732057471', N'Xã Phước Tỉnh, Huyện Long Điền, Bà Rịa - Vũng Tàu', '2583 5335 5478 7052'),
    ('NV05', N'Nguyễn Văn D', 'M', '1973-08-30', '0360172367', N'8697, Thôn Mai Khuê, Phường 5, Quận Đào Thôi Bình Thuận', '84732057471'),
    ('NV06', N'Nguyễn Trung Nguyễn', 'M', '2000-05-20', '0254209306', N'33, Thôn 75, Xã 7, Huyện Vu Tạ Quảng Ngã', '4024 007117845'),
    ('NV07', N'Nguyễn Đồng Bảo', 'M', '1992-08-16', '02303085877', N'7338 Phố Hứa, Xã Trác Thuận Kính, Quận Xuân Việt Hồ Chí Minh', '4024007195155097'),
    ('NV08', N'Nguyễn Ân Thục', 'F', '1983-08-30', '0661026674', N'0 Phố Hòa, Thôn La Trúc, Quận Lý Khiêm Bình Thuận', '5498502952848540'),
    ('NV09', N'Huỳnh Lệ Uyên', 'F', '1990-08-30', '84601199955', N'29, Thôn San Duệ, Phường Trầm Tuyền, Quận Tài TháiHưng Yên', '2661697971095160'),
    ('NV10', N'Nguyễn Duyên Đinh', 'F', '1973-08-30', '07800379338', N'Xã Phước Tỉnh, Huyện Long Điền, Bà Rịa - Vũng Tàu', '4532689426722'),
    ('NV11', N'Nguyễn Bé Cát', 'F', '1985-04-25', '(052) 643 9665', N'208, Ấp Học Diệu, Xã 35, Quận Phan Trác Trung Bắc Ninh', '5191 9088 2313 5274'),
    ('NV12', N'Nguyễn Linh Mộc', 'F', '1993-08-30', '84-280-664-8098', N'9 Phố Ngân Diệu Đạt, Phường Hà, Quận Tiến Châu Hải Phòng', '4532 9689 9968 4498'),
    ('NV13', N'Nguyễn Trọng Chí ', 'M', '1983-07-02', '(0129)486-3325', N'393, Thôn Đăng Vịnh, Phường Trang, Huyện Trang Lý Đắk Lắk', '4916 7189 1414 1561'),
    ('NV14', N'Nguyễn Văn Nhã Mộng', 'F', '1999-06-30', '+84-123-472-1295', N'6 Phố Đới Đình Uyên, Phường Độ Khánh, Huyện 8 Hà Nội', '4929 8093 9943 5910'),
    ('NV15', N'Nguyễn Kiệt Hoàng', 'M', '1998-02-22', '84-219-091-9878', N'2 Phố Chiêm Huynh An, Xã Từ, Huyện Doãn Trung Cà Mau', '4556 3794 9907 7962'),
    ('NV16', N'Phạm Trà Dung', 'F', '1997-06-16', '(031) 716 9683', N'5714, Thôn Hồng Sương, Thôn Nhữ Xuân, Huyện Thắng CấnLào Cai', '2623 2316 3514 4433');
GO

INSERT INTO MANAGER
VALUES
    ('KV01', 'NV02'),
    ('KV01', 'NV03'),
    ('KV01', 'NV04'),
    ('KV01', 'NV05'),
    ('KV02', 'NV03'),
    ('KV02', 'NV06'),
    ('KV02', 'NV07'),
    ('KV03', 'NV08'),
    ('KV03', 'NV09'),
    ('KV03', 'NV12'),
    ('KV03', 'NV11'),
    ('KV03', 'NV04'),
    ('KV04', 'NV12'),
    ('KV04', 'NV13'),
    ('KV04', 'NV14'),
    ('KV04', 'NV15'),
    ('KV04', 'NV16'),
    ('KV04', 'NV10'),
    ('KV05', 'NV13'),
    ('KV05', 'NV14'),
    ('KV05', 'NV15'),
    ('KV05', 'NV16'),
    ('KV05', 'NV10'),
    ('KV05', 'NV06');
GO

INSERT INTO ROOM
VALUES
    ('P01', 'KV01'),
    ('P02', 'KV01'),
    ('P03', 'KV01'),
    ('P04', 'KV01'),
    ('P05', 'KV01'),
    ('P06', 'KV01'),
    ('P07', 'KV02'),
    ('P08', 'KV02'),
    ('P09', 'KV02'),
    ('P10', 'KV02'),
    ('P11', 'KV03'),
    ('P12', 'KV03'),
    ('P13', 'KV03'),
    ('P14', 'KV03'),
    ('P15', 'KV03'),
    ('P16', 'KV04'),
    ('P17', 'KV04'),
    ('P18', 'KV04'),
    ('P19', 'KV04'),
    ('P20', 'KV04'),
    ('P21', 'KV04'),
    ('P22', 'KV05'),
    ('P23', 'KV05'),
    ('P24', 'KV05'),
    ('P25', 'KV05'),
    ('P26', 'KV05'),
    ('P27', 'KV05');
GO

INSERT INTO STUDENT
VALUES
    ('SV01', 'P01', N'Nguyễn Văn A', 'M', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV02', 'P01', N'Nguyễn Văn B', 'M', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV03', 'P01', N'Nguyễn Văn C', 'M', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV04', 'P01', N'Nguyễn Văn D', 'M', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV05', 'P01', N'Nguyễn Văn E', 'M', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV06', 'P01', N'Nguyễn Văn F', 'F', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV07', 'P02', N'Nguyễn Văn G', 'F', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV08', 'P02', N'Nguyễn Văn H', 'F', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV09', 'P02', N'Nguyễn Văn I', 'F', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV10', 'P02', N'Nguyễn Văn J', 'F', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV11', 'P02', N'Nguyễn Văn K', 'F', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV12', 'P02', N'Nguyễn Văn L', 'F', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV13', 'P02', N'Nguyễn Văn M', 'F', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV14', 'P03', N'Nguyễn Văn N', 'F', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV15', 'P03', N'Nguyễn Văn O', 'F', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV16', 'P03', N'Nguyễn Văn P', 'F', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV17', 'P03', N'Nguyễn Văn Q', 'F', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV18', 'P05', N'Nguyễn Văn R', 'M', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV19', 'P05', N'Nguyễn Văn S', 'M', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV20', 'P05', N'Nguyễn Văn T', 'M', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV21', 'P05', N'Nguyễn Văn U', 'M', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV22', 'P01', N'Nguyễn Văn V', 'M', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV23', 'P06', N'Nguyễn Văn W', 'M', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV24', 'P06', N'Nguyễn Văn X', 'M', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV25', 'P06', N'Nguyễn Văn Y', 'M', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV26', 'P06', N'Nguyễn Văn Z', 'M', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV27', 'P12', N'Huỳnh Văn A', 'F', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV28', 'P12', N'Huỳnh Văn B', 'F', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV29', 'P12', N'Huỳnh Văn C', 'F', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV30', 'P12', N'Huỳnh Văn D', 'F', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV31', 'P12', N'Huỳnh Văn E', 'F', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV32', 'P14', N'Huỳnh Văn F', 'F', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV33', 'P14', N'Huỳnh Văn G', 'F', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV34', 'P14', N'Huỳnh Văn H', 'F', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV35', 'P14', N'Huỳnh Văn I', 'F', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV36', 'P14', N'Huỳnh Văn J', 'M', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV37', 'P17', N'Huỳnh Văn K', 'M', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV38', 'P17', N'Huỳnh Văn L', 'M', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV39', 'P17', N'Huỳnh Văn M', 'M', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV40', 'P17', N'Huỳnh Văn N', 'M', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157'),
    ('SV41', 'P17', N'Huỳnh Văn O', 'M', '2002-02-02', '245125215252', N'Đà Nẵng', '25825728528157');
GO

INSERT INTO FACILITY
VALUES
    ('VC01', N'Ghế'),
    ('VC02', N'Bàn'),
    ('VC03', N'Tủ'),
    ('VC04', N'Giường')
GO

INSERT INTO OWN
VALUES
    ('VC01', 'SV01', N'Tốt'),
    ('VC01', 'SV02', N'Tốt'),
    ('VC01', 'SV03', N'Hỏng'),
    ('VC01', 'SV04', N'Tốt'),
    ('VC01', 'SV05', N'Tốt'),
    ('VC01', 'SV06', N'Tốt'),
    ('VC01', 'SV07', N'Mất'),
    ('VC01', 'SV08', N'Tốt'),
    ('VC01', 'SV09', N'Tốt'),
    ('VC01', 'SV10', N'Tốt'),
    ('VC01', 'SV11', N'Tốt'),
    ('VC01', 'SV12', N'Tốt'),
    ('VC01', 'SV13', N'Tốt'),
    ('VC01', 'SV14', N'Tốt'),
    ('VC01', 'SV15', N'Tốt'),
    ('VC01', 'SV16', N'Tốt'),
    ('VC01', 'SV17', N'Tốt'),
    ('VC01', 'SV18', N'Tốt'),
    ('VC01', 'SV19', N'Tốt'),
    ('VC01', 'SV20', N'Tốt'),
    ('VC01', 'SV21', N'Tốt'),
    ('VC01', 'SV22', N'Tốt'),
    ('VC01', 'SV23', N'Tốt'),
    ('VC01', 'SV24', N'Tốt'),
    ('VC01', 'SV25', N'Tốt'),
    ('VC01', 'SV26', N'Tốt'),
    ('VC01', 'SV27', N'Tốt'),
    ('VC01', 'SV28', N'Tốt'),
    ('VC01', 'SV29', N'Hỏng'),
    ('VC01', 'SV30', N'Tốt'),
    ('VC01', 'SV31', N'Tốt'),
    ('VC01', 'SV32', N'Tốt'),
    ('VC01', 'SV33', N'Tốt'),
    ('VC01', 'SV34', N'Tốt'),
    ('VC01', 'SV35', N'Tốt'),
    ('VC01', 'SV36', N'Tốt'),
    ('VC01', 'SV37', N'Tốt'),
    ('VC01', 'SV38', N'Tốt'),
    ('VC01', 'SV39', N'Tốt'),
    ('VC01', 'SV40', N'Tốt'),
    ('VC01', 'SV41', N'Tốt'),
    ('VC02', 'SV01', N'Tốt'),
    ('VC02', 'SV02', N'Tốt'),
    ('VC02', 'SV03', N'Tốt'),
    ('VC02', 'SV04', N'Tốt'),
    ('VC02', 'SV05', N'Tốt'),
    ('VC02', 'SV06', N'Tốt'),
    ('VC02', 'SV07', N'Tốt'),
    ('VC02', 'SV08', N'Mất'),
    ('VC02', 'SV09', N'Tốt'),
    ('VC02', 'SV10', N'Tốt'),
    ('VC02', 'SV11', N'Tốt'),
    ('VC02', 'SV12', N'Tốt'),
    ('VC02', 'SV13', N'Tốt'),
    ('VC02', 'SV14', N'Tốt'),
    ('VC02', 'SV15', N'Tốt'),
    ('VC02', 'SV16', N'Tốt'),
    ('VC02', 'SV17', N'Tốt'),
    ('VC02', 'SV18', N'Tốt'),
    ('VC02', 'SV19', N'Tốt'),
    ('VC02', 'SV20', N'Tốt'),
    ('VC02', 'SV21', N'Tốt'),
    ('VC02', 'SV22', N'Tốt'),
    ('VC02', 'SV23', N'Tốt'),
    ('VC02', 'SV24', N'Tốt'),
    ('VC02', 'SV25', N'Tốt'),
    ('VC02', 'SV26', N'Tốt'),
    ('VC02', 'SV27', N'Tốt'),
    ('VC02', 'SV28', N'Tốt'),
    ('VC02', 'SV29', N'Tốt'),
    ('VC02', 'SV30', N'Tốt'),
    ('VC02', 'SV31', N'Tốt'),
    ('VC02', 'SV32', N'Tốt'),
    ('VC02', 'SV33', N'Tốt'),
    ('VC02', 'SV34', N'Tốt'),
    ('VC02', 'SV35', N'Tốt'),
    ('VC02', 'SV36', N'Tốt'),
    ('VC02', 'SV37', N'Tốt'),
    ('VC02', 'SV38', N'Tốt'),
    ('VC02', 'SV39', N'Tốt'),
    ('VC02', 'SV40', N'Tốt'),
    ('VC02', 'SV41', N'Tốt'),
    ('VC03', 'SV01', N'Tốt'),
    ('VC03', 'SV02', N'Tốt'),
    ('VC03', 'SV03', N'Tốt'),
    ('VC03', 'SV04', N'Tốt'),
    ('VC03', 'SV05', N'Tốt'),
    ('VC03', 'SV06', N'Tốt'),
    ('VC03', 'SV07', N'Tốt'),
    ('VC03', 'SV08', N'Tốt'),
    ('VC03', 'SV09', N'Tốt'),
    ('VC03', 'SV10', N'Tốt'),
    ('VC03', 'SV11', N'Tốt'),
    ('VC03', 'SV12', N'Tốt'),
    ('VC03', 'SV13', N'Tốt'),
    ('VC03', 'SV14', N'Tốt'),
    ('VC03', 'SV15', N'Tốt'),
    ('VC03', 'SV16', N'Tốt'),
    ('VC03', 'SV17', N'Tốt'),
    ('VC03', 'SV18', N'Tốt'),
    ('VC03', 'SV19', N'Tốt'),
    ('VC03', 'SV20', N'Tốt'),
    ('VC03', 'SV21', N'Tốt'),
    ('VC03', 'SV22', N'Tốt'),
    ('VC03', 'SV23', N'Tốt'),
    ('VC03', 'SV24', N'Tốt'),
    ('VC03', 'SV25', N'Tốt'),
    ('VC03', 'SV26', N'Tốt'),
    ('VC03', 'SV27', N'Tốt'),
    ('VC03', 'SV28', N'Tốt'),
    ('VC03', 'SV29', N'Tốt'),
    ('VC03', 'SV30', N'Tốt'),
    ('VC03', 'SV31', N'Tốt'),
    ('VC03', 'SV32', N'Tốt'),
    ('VC03', 'SV33', N'Tốt'),
    ('VC03', 'SV34', N'Tốt'),
    ('VC03', 'SV35', N'Tốt'),
    ('VC03', 'SV36', N'Tốt'),
    ('VC03', 'SV37', N'Tốt'),
    ('VC03', 'SV38', N'Tốt'),
    ('VC03', 'SV39', N'Tốt'),
    ('VC03', 'SV40', N'Tốt'),
    ('VC03', 'SV41', N'Tốt'),
    ('VC04', 'SV01', N'Tốt'),
    ('VC04', 'SV02', N'Tốt'),
    ('VC04', 'SV03', N'Tốt'),
    ('VC04', 'SV04', N'Tốt'),
    ('VC04', 'SV05', N'Tốt'),
    ('VC04', 'SV06', N'Tốt'),
    ('VC04', 'SV07', N'Tốt'),
    ('VC04', 'SV08', N'Tốt'),
    ('VC04', 'SV09', N'Tốt'),
    ('VC04', 'SV10', N'Tốt'),
    ('VC04', 'SV11', N'Tốt'),
    ('VC04', 'SV12', N'Tốt'),
    ('VC04', 'SV13', N'Tốt'),
    ('VC04', 'SV14', N'Tốt'),
    ('VC04', 'SV15', N'Tốt'),
    ('VC04', 'SV16', N'Tốt'),
    ('VC04', 'SV17', N'Tốt'),
    ('VC04', 'SV18', N'Tốt'),
    ('VC04', 'SV19', N'Tốt'),
    ('VC04', 'SV20', N'Tốt'),
    ('VC04', 'SV21', N'Tốt'),
    ('VC04', 'SV22', N'Tốt'),
    ('VC04', 'SV23', N'Tốt'),
    ('VC04', 'SV24', N'Tốt'),
    ('VC04', 'SV25', N'Tốt'),
    ('VC04', 'SV26', N'Tốt'),
    ('VC04', 'SV27', N'Tốt'),
    ('VC04', 'SV28', N'Tốt'),
    ('VC04', 'SV29', N'Tốt'),
    ('VC04', 'SV30', N'Tốt'),
    ('VC04', 'SV31', N'Tốt'),
    ('VC04', 'SV32', N'Tốt'),
    ('VC04', 'SV33', N'Tốt'),
    ('VC04', 'SV34', N'Tốt'),
    ('VC04', 'SV35', N'Tốt'),
    ('VC04', 'SV36', N'Tốt'),
    ('VC04', 'SV37', N'Tốt'),
    ('VC04', 'SV38', N'Tốt'),
    ('VC04', 'SV39', N'Tốt'),
    ('VC04', 'SV40', N'Tốt'),
    ('VC04', 'SV41', N'Tốt')
GO

INSERT INTO INCURRED(roomCode, semester, waterAmount, elecAmount)
VALUES
    ('P01', 'SP21', '100', '1500'),
    ('P01', 'FA22', '148', '1550'),
    ('P01', 'SU21', '102', '1650'),
    ('P02', 'SP21', '120', '1700'),
    ('P02', 'SU22', '80', '1400'),
    ('P02', 'FA22', '90', '1600'),
    ('P03', 'SP21', '108', '1502'),
    ('P03', 'SU21', '108', '1600'),
    ('P05', 'SU21', '103', '1602'),
    ('P06', 'SP21', '103', '1600'),
    ('P12', 'FA22', '108', '1670');
GO

INSERT INTO INVOICE(invCode, stuCode, semester, basicCost)
VALUES
    ('INV01', 'SV01', 'SP21', 2400000),
    ('INV02', 'SV01', 'SU21', 2300000),
    ('INV03', 'SV03', 'SP21', 2400000),
    ('INV04', 'SV04', 'SP21', 2400000),
    ('INV05', 'SV05', 'SP21', 2400000),
    ('INV06', 'SV06', 'SP21', 2400000),
    ('INV07', 'SV07', 'SP21', 2400000),
    ('INV08', 'SV08', 'SP21', 2400000),
    ('INV09', 'SV09', 'SP21', 2400000),
    ('INV10', 'SV10', 'SP21', 2400000),
    ('INV11', 'SV11', 'SP21', 2400000),
    ('INV12', 'SV12', 'SP21', 2400000),
    ('INV13', 'SV13', 'SP21', 2400000),
    ('INV14', 'SV14', 'SP21', 2400000),
    ('INV15', 'SV15', 'SU21', 2300000),
    ('INV16', 'SV16', 'SU21', 2300000),
    ('INV17', 'SV17', 'SU21', 2300000),
    ('INV18', 'SV18', 'SU21', 2300000),
    ('INV19', 'SV19', 'SU21', 2300000),
    ('INV20', 'SV20', 'SU21', 2400000),
    ('INV21', 'SV21', 'SP21', 2400000),
    ('INV22', 'SV22', 'SP21', 2400000),
    ('INV23', 'SV23', 'SP21', 2400000),
    ('INV24', 'SV24', 'SP21', 2400000),
    ('INV25', 'SV25', 'SP21', 2400000),
    ('INV26', 'SV26', 'FA22', 2400000),
    ('INV27', 'SV27', 'FA22', 2400000),
    ('INV28', 'SV28', 'FA22', 2400000),
    ('INV29', 'SV29', 'FA22', 2400000),
    ('INV30', 'SV29', 'SP22', 2400000),
    ('INV31', 'SV29', 'SU22', 2300000);
GO

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
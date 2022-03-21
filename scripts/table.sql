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
    facStatus NVARCHAR(10) CHECK(facStatus IN (N'Tốt', N'Hỏng', N'Mất')) DEFAULT N'Tốt',
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


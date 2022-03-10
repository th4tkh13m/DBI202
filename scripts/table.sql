CREATE TABLE AREA
(
    areaCode NUMERIC(10) PRIMARY KEY,
    areName NVARCHAR(50),
)

CREATE TABLE EMPLOYEE
(
    empCode NUMERIC(8) PRIMARY KEY,
    areaCode NUMERIC(10),
    empName NVARCHAR(50),
    empSex NVARCHAR(1),
    empBirthdate DATE,
    empPhone NVARCHAR(10),
    empAddress NVARCHAR(70),
    empSSN NVARCHAR(10),
    FOREIGN KEY(areaCode) REFERENCES AREA(areaCode)
)

CREATE TABLE ROOM
(
    roomCode NUMERIC(8) PRIMARY KEY,
    areaCode NUMERIC(10),
    FOREIGN KEY(areaCode) REFERENCES AREA(areaCode)
)

CREATE TABLE STUDENT
(
    stuCode NUMERIC(8) PRIMARY KEY,
    roomCode NUMERIC(8),
    stuName NVARCHAR(50),
    stuSex NVARCHAR(1),
    stuBirthdate DATE,
    stuPhone NVARCHAR(10),
    stuAddress NVARCHAR(70),
    stuSSN NVARCHAR(10),
    FOREIGN KEY(roomCode) REFERENCES ROOM(roomCode)
)

CREATE TABLE FACILITY
(
    facCode NUMERIC(10) PRIMARY KEY,
    facName NVARCHAR(50),

)

CREATE TABLE OWN
(
    facCode NUMERIC(10),
    stuCode NUMERIC(8),
    FOREIGN KEY(facCode) REFERENCES FACILITY(facCode),
    FOREIGN KEY(stuCode) REFERENCES STUDENT(stuCode)
)

CREATE TABLE INCURRED
(
    roomCode NUMERIC(8),
    semester NVARCHAR(4),
    incurredCost NUMERIC(10),
)
CREATE TABLE AREA
(
    areaCode NVARCHAR(4) PRIMARY KEY,
    areName NVARCHAR(50),
)

CREATE TABLE EMPLOYEE
(
    empCode NVARCHAR(4) PRIMARY KEY,
    areaCode NVARCHAR(4),
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
    roomCode NUMERIC(3) PRIMARY KEY,
    areaCode NVARCHAR(4),
    FOREIGN KEY(areaCode) REFERENCES AREA(areaCode)
)

CREATE TABLE STUDENT
(
    stuCode NVARCHAR(8) PRIMARY KEY,
    roomCode NUMERIC(3),
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
    facCode NUMERIC(3) PRIMARY KEY,
    facName NVARCHAR(50),
    facStatus NVARCHAR(10)
)

CREATE TABLE OWN
(
    facCode NUMERIC(3),
    stuCode NVARCHAR(8),
    FOREIGN KEY(facCode) REFERENCES FACILITY(facCode),
    FOREIGN KEY(stuCode) REFERENCES STUDENT(stuCode)
)


CREATE TABLE INVOICE
(
    invCode NVARCHAR(8) PRIMARY KEY,
    stuCode NVARCHAR(8),
    basicCost INT,
    totalCost INT,
    FOREIGN KEY(stuCode) REFERENCES STUDENT(stuCode)
)

CREATE TABLE INCURRED
(   
    invCode NVARCHAR(8),
    roomCode NUMERIC(3),
    semester NVARCHAR(4),
    waterAmount INT,
    elecAmount INT,
    incurredCost INT,
    FOREIGN KEY(roomCode) REFERENCES ROOM(roomCode),
    FOREIGN KEY(invCode) REFERENCES INVOICE(invCode)
)

CREATE TABLE MANAGER 
(
    areaCode NVARCHAR(4),
    empCode NVARCHAR(4),
    FOREIGN KEY(areaCode) REFERENCES AREA(areaCode),
    FOREIGN KEY(empCode) REFERENCES EMPLOYEE(empCode)
)


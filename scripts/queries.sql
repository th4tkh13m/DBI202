-- 1. cho biết sinh viên đang ở phòng P01. Thông tin yêu cầu:  
-- mã sinh viên, họ và tên, giới tính, ngày tháng năm sinh, số đth
SELECT stuCode, stuName, stuSex, stuBirthdate, stuPhone FROM student WHERE roomCode = 'P01'

-- 2. cho biết sinh viên nguễn văn A đang sở hữu cơ sở vật chất gì. 
-- Thông tin yên cầu. mã sinh viên, tên sinh viên, tên cơ sở vật chất, tình trạng.
SELECT st.stuCode, st.stuName, f.facName, o.facStatus
FROM STUDENT st INNER JOIN (OWN o INNER JOIN FACILITY f ON o.facCode = f.facCode) ON st.stuCode = o.stuCode
WHERE st.stuName = N'Nguyễn Văn A'

-- 3. Cho biết nhân viên nào đang quản lý khu vực 1. 
-- Thông tin yêu cầu: mã nhân viên, tên  nhân viên, giới tính, ngày sinh, sốt điện thoại
SELECT e.empCode, e.empName, e.empSex, e.empBirthdate, e.empPhone
FROM EMPLOYEE e INNER JOIN (AREA a INNER JOIN MANAGER m ON a.areaCode = m.areaCode) ON e.empCode = m.empCode
WHERE a.areaCode = 'KV01' 

-- 4. cho biết nhân viên phạm đào nguyễn đang quản lý các khu vực nào, phòng nào.
--  thông tin yêu cầu: mã khu vực, mã phòng
SELECT a.areaCode, r.roomCode
FROM ROOM r INNER JOIN (AREA a INNER JOIN (MANAGER m INNER JOIN EMPLOYEE e ON m.empCode = e.empCode) ON a.areaCode = m.areaCode) ON r.areaCode = a.areaCode
WHERE e.empName = N'Phạm Đào Nguyễn'


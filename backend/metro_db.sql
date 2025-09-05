

--  BẢNG USERS
CREATE TABLE Users 
(
    UserID VARCHAR(10) PRIMARY KEY,               
    FullName VARCHAR(100),                        
    Email VARCHAR(100) UNIQUE,                  
    Phone VARCHAR(20),                            
    UserPassword VARCHAR(255),                      
    IsStudent BOOLEAN DEFAULT 0,  -- 0: không phải sinh viên ; 1: sinh viên                
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP  
);
SELECT * FROM Users;

-- BẢNG STATION
CREATE TABLE Station 
(
    StationID VARCHAR(10) PRIMARY KEY,       -- Mã ga viết tắt: Ga Ba Son -> GBS 
    StationName VARCHAR(100) NOT NULL,            
    Location VARCHAR(255)                           
);
SELECT * FROM Station;

-- BẢNG TRANSACTIONS
CREATE TABLE Transactions
(
    TransactionID VARCHAR(10) PRIMARY KEY,         
    UserID VARCHAR(10),                            
    Amount DECIMAL(10,2),                          
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,        
    TransactionStatus ENUM('Success','Failed'),                           
    Method ENUM('QR','NFC','Wallet','Other'),                                 
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
SELECT * FROM Transactions; 

-- BẢNG TICKET
CREATE TABLE Ticket 
(
    TicketID VARCHAR(10) PRIMARY KEY,    
    UserID VARCHAR(10),       
    TransactionID VARCHAR(10),                     
    TicketType ENUM('Month','Day_All','Day_Point_To_Point'),                       
    Price DECIMAL(10,2),                           
    ValidFrom DATETIME DEFAULT CURRENT_TIMESTAMP,  
    ValidTo DATETIME,                              
    TicketStatus ENUM('Active','Expired','Blocked'),                      
    StartStationID VARCHAR(10),                    
    EndStationID VARCHAR(10),                      
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (TransactionID) REFERENCES Transactions(TransactionID),
    FOREIGN KEY (StartStationID) REFERENCES Station(StationID),
    FOREIGN KEY (EndStationID) REFERENCES Station(StationID)
);
SELECT * FROM  Ticket ; 

-- BẢNG CHECK IN/OUT
CREATE TABLE CheckInOut 
(
    CheckID VARCHAR(10) PRIMARY KEY, 
    TicketID VARCHAR(10),             
    UserID VARCHAR(10),               
    StationID VARCHAR(10),           
    CheckTime DATETIME DEFAULT CURRENT_TIMESTAMP, 
    Direction ENUM('In','Out'),       
    FOREIGN KEY (TicketID) REFERENCES Ticket(TicketID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (StationID) REFERENCES Station(StationID)
);
SELECT * FROM CheckInOut ; 

-- BẢNG FRAUDLOG
CREATE TABLE FraudLog 
(
    FraudID VARCHAR(10) PRIMARY KEY,
    UserID VARCHAR(10),
    TicketID VARCHAR(10),
    DetectedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    Descriptions TEXT,
    Handled BOOLEAN DEFAULT 0, -- 0: chưa xử lý, 1: đã xử lý
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (TicketID) REFERENCES Ticket(TicketID)
);
SELECT * FROM FraudLog ;

-- DỮ LIỆU TEST 

-- DANH SÁCH CÁC GA
INSERT INTO Station (StationID, StationName, Location) VALUES
('GBT', 'Ga Bến Thành',' Quận 1, TP.HCM' ),
('GNHTP', 'Ga Nhà hát Thành phố','Quận 1, TP.HCM ' ),
('GBS', 'Ga Ba Son', 'Quận 1, TP.HCM ' ),
('GVT', 'Ga Văn Thánh', 'Quận Bình Thạnh, TP.HCM'),
('GTC', 'Ga Tân Cảng', 'Quận Bình Thạnh, TP.HCM'),
('GTD', 'Ga Thảo Điền','Thành phố Thủ Đức, TP.HCM' ),
('GAP', 'Ga An Phú', 'Thành phố Thủ Đức, TP.HCM'),
('GRC', 'Ga Rạch Chiếc','Thành phố Thủ Đức, TP.HCM' ),
('GPL', 'Ga Phước Long','Thành phố Thủ Đức, TP.HCM' ),
('GBThai', 'Ga Bình Thái', 'Thành phố Thủ Đức, TP.HCM'),  -- trùng với ga Bến Thành nên đặt khác
('GTDuc', 'Ga Thủ Đức', 'Thành phố Thủ Đức, TP.HCM'),
('GKCN', 'Ga Khu Công Nghệ Cao','Thành phố Thủ Đức, TP.HCM' ),
('GDHQG', 'Ga Đại học Quốc Gia','Thành phố Thủ Đức, TP.HCM' ),
('GBXST', 'Ga Bến xe Suối Tiên','Thành phố Thủ Đức, TP.HCM' );

SELECT * FROM Station;

-- NGƯỜI DÙNG 
INSERT INTO Users (UserID, FullName, Email, Phone, UserPassword, IsStudent) VALUES
('ND001', 'Phạm Văn Lực', 'lucpv@gmail.com', '0901234567', '030425', 0),
('ND002', 'Ngô Thị Thanh', 'thanhtn@gmail.com', '0902345678', '5153285', 0),
('ND003', 'Đinh Văn Tuấn', 'tuandv@gmail.com', '0903456789', '32562659', 1), 
('ND004', 'Trương Mỹ Linh', 'linhtm@gmail.com', '0904567890', '58762', 0),
('ND005', 'Hoàng Văn Hưng', 'hunghv@gmail.com', '0905678901', '87530', 0),
('ND006', 'Lý Thị Hương', 'huonglt@gmail.com', '0906789012', '78524', 1), 
('ND007', 'Vũ Đức Duy', 'duyvd@gmail.com', '0907890123', '23579', 0),
('ND008', 'Tăng Thị Nga', 'ngatt@gmail.com', '0908901234', '56738', 0),
('ND009', 'Nguyễn Bá Khôi', 'khoinb@gmail.com', '0909012345', '12782', 0),
('ND010', 'Trần Thị Diệu', 'dieutt@gmail.com', '0910123456', '22222', 1), 
('ND011', 'Lê Minh Châu', 'chaulm@gmail.com', '0911234567', '252525', 0),
('ND012', 'Bùi Văn Hiếu', 'hieubv@gmail.com', '0912345678', '434353', 0),
('ND013', 'Nguyễn Thị Hoa', 'hoant@gmail.com', '0913456789', '864357', 1), 
('ND014', 'Đặng Văn Toàn', 'toandv@gmail.com', '0914567890', '15578', 0),
('ND015', 'Mai Xuân Phát', 'phatmx@gmail.com', '0915678901', 'uyhjr', 0),
('ND016', 'Đỗ Quỳnh Trang', 'trangdq16@gmail.com', '0916789012', 'dfnjh', 1), 
('ND017', 'Nguyễn Hữu Tài', 'tainh@gmail.com', '0917890123', 'ybfmkgj', 0),
('ND018', 'Trần Quốc Anh', 'anhtq@gmail.com', '0918901234', 'tytktg', 1), 
('ND019', 'Phan Thị Bích', 'bichpt@gmail.com', '0919012345', 'yhhkrrsj', 0),
('ND020', 'Đào Đức Cường', 'cuongdd@gmail.com', '0920123456', 'dffgjghk', 0);

SELECT * FROM Users;

-- GIAO DỊCH THANH TOÁN
INSERT INTO Transactions (TransactionID, UserID, Amount, TransactionStatus, Method) VALUES
('GD001', 'ND001', 40000.00, 'Success', 'QR'),
('GD002', 'ND002', 300000.00, 'Success', 'Wallet'),
('GD003', 'ND003', 150000.00, 'Failed', 'Wallet'),
('GD004', 'ND004', 6000.00, 'Success', 'Other'),
('GD005', 'ND005', 12000.00, 'Success', 'QR'),
('GD006', 'ND006', 300000.00, 'Success', 'Wallet'),
('GD007', 'ND007', 150000.00, 'Success', 'NFC'),
('GD008', 'ND008', 7000.00, 'Success', 'QR'),
('GD009', 'ND009', 8000.00, 'Failed', 'Other'),
('GD010', 'ND010', 40000.00, 'Failed', 'Wallet'),
('GD011', 'ND011', 150000.00, 'Success', 'QR'),
('GD012', 'ND012', 9000.00, 'Success', 'Other'),
('GD013', 'ND013', 100000.00, 'Success', 'NFC'),
('GD014', 'ND014', 300000.00, 'Failed', 'QR'),
('GD015', 'ND015', 40000.00, 'Success', 'Wallet'),
('GD016', 'ND016', 7000.00, 'Success', 'Other'),
('GD017', 'ND017', 150000.00, 'Success', 'NFC'),
('GD018', 'ND018', 6000.00, 'Success', 'QR'),
('GD019', 'ND019', 8000.00, 'Failed', 'Wallet'),
('GD020', 'ND020', 12000.00, 'Success', 'Other');

SELECT * FROM  Transactions;

-- VÉ
INSERT INTO Ticket (TicketID, UserID, TransactionID, TicketType, Price, ValidTo, TicketStatus, StartStationID, EndStationID) VALUES
('VE001', 'ND001', 'GD001', 'Day_All', 40000.00, DATE_ADD(NOW(), INTERVAL 1 DAY), 'Active', NULL, NULL),
('VE002', 'ND002', 'GD002', 'Month', 300000.00, DATE_ADD(NOW(), INTERVAL 30 DAY), 'Active', NULL, NULL),
('VE003', 'ND003', 'GD003', 'Month', 150000.00, DATE_ADD(NOW(), INTERVAL 30 DAY), 'Active', NULL, NULL),
('VE004', 'ND004', 'GD004', 'Day_Point_To_Point', 6000.00, DATE_ADD(NOW(), INTERVAL 1 DAY), 'Expired', 'GBT', 'GBS'),
('VE005', 'ND005', 'GD005', 'Day_Point_To_Point', 7000.00, DATE_ADD(NOW(), INTERVAL 1 DAY), 'Active', 'GAP', 'GVT'),
('VE006', 'ND006', 'GD006', 'Month', 150000.00, DATE_ADD(NOW(), INTERVAL 30 DAY), 'Active', NULL, NULL),
('VE007', 'ND007', 'GD007', 'Month', 300000.00, DATE_ADD(NOW(), INTERVAL 30 DAY), 'Active', NULL, NULL),
('VE008', 'ND008', 'GD008', 'Day_Point_To_Point', 8000.00, DATE_ADD(NOW(), INTERVAL 1 DAY), 'Active', 'GBS', 'GTD'),
('VE009', 'ND009', 'GD009', 'Day_Point_To_Point', 12000.00, DATE_ADD(NOW(), INTERVAL 1 DAY), 'Active', 'GVT', 'GKCN'),
('VE010', 'ND010', 'GD010', 'Month', 150000.00, DATE_ADD(NOW(), INTERVAL 30 DAY), 'Active', NULL, NULL),
('VE011', 'ND011', 'GD011', 'Day_All', 40000.00, DATE_ADD(NOW(), INTERVAL 1 DAY), 'Expired', NULL, NULL),
('VE012', 'ND012', 'GD012', 'Day_Point_To_Point', 9000.00, DATE_ADD(NOW(), INTERVAL 1 DAY), 'Expired', 'GBT', 'GDHQG'),
('VE013', 'ND013', 'GD013', 'Month', 150000.00, DATE_ADD(NOW(), INTERVAL 30 DAY), 'Blocked', NULL, NULL),
('VE014', 'ND014', 'GD014', 'Month', 300000.00, DATE_ADD(NOW(), INTERVAL 30 DAY), 'Active', NULL, NULL),
('VE015', 'ND015', 'GD015', 'Day_Point_To_Point', 7000.00, DATE_ADD(NOW(), INTERVAL 1 DAY), 'Active', 'GAP', 'GBXST'),
('VE016', 'ND016', 'GD016', 'Month', 150000.00, DATE_ADD(NOW(), INTERVAL 30 DAY), 'Blocked', NULL, NULL),
('VE017', 'ND017', 'GD017', 'Day_Point_To_Point', 6000.00, DATE_ADD(NOW(), INTERVAL 1 DAY), 'Expired', 'GBThai', 'GTDuc'),
('VE018', 'ND018', 'GD018', 'Month', 150000.00, DATE_ADD(NOW(), INTERVAL 30 DAY), 'Active', NULL, NULL),
('VE019', 'ND019', 'GD019', 'Day_Point_To_Point', 12000.00, DATE_ADD(NOW(), INTERVAL 1 DAY), 'Blocked', 'GRC', 'GPL'),
('VE020', 'ND020', 'GD020', 'Month', 300000.00, DATE_ADD(NOW(), INTERVAL 30 DAY), 'Active', NULL, NULL);

SELECT * FROM Ticket;

-- LỊCH SỬ QUÉT
INSERT INTO CheckInOut (CheckID, TicketID, UserID, StationID, Direction) VALUES
('LSQ001', 'VE001', 'ND001', 'GBT',  'In'),
('LSQ002', 'VE001', 'ND001', 'GAP',  'Out'),
('LSQ003', 'VE002', 'ND002', 'GBS',  'In'),
('LSQ004', 'VE002', 'ND002', 'GTDuc','Out'),
('LSQ005', 'VE003', 'ND003', 'GTD',  'In'),
('LSQ006', 'VE004', 'ND004', 'GVT',  'In'),
('LSQ007', 'VE005', 'ND005', 'GBThai','In'),
('LSQ008', 'VE006', 'ND006', 'GTC',  'Out'),
('LSQ009', 'VE007', 'ND007', 'GBXST','In'),
('LSQ010', 'VE008', 'ND008', 'GKCN', 'Out'),
('LSQ011', 'VE009', 'ND009', 'GTDuc','In'),
('LSQ012', 'VE010', 'ND010', 'GBT',  'In'),
('LSQ013', 'VE010', 'ND010', 'GBS',  'Out'),
('LSQ014', 'VE011', 'ND011', 'GAP',  'In'),
('LSQ015', 'VE012', 'ND012', 'GVT',  'Out'),
('LSQ016', 'VE013', 'ND013', 'GTD',  'In'),
('LSQ017', 'VE014', 'ND014', 'GTC',  'In'),
('LSQ018', 'VE015', 'ND015', 'GBThai','Out'),
('LSQ019', 'VE016', 'ND016', 'GBXST','In'),
('LSQ020', 'VE016', 'ND016', 'GKCN', 'Out');

SELECT * FROM CheckInOut;

-- CẢNH BÁO GIAN LẬN
INSERT INTO FraudLog (FraudID, UserID, TicketID, DetectedAt, Descriptions, Handled) VALUES
('GL001', 'ND001', 'VE001', NOW(), 'Quét cùng vé tại 2 ga khác nhau trong 3 phút', 0),
('GL002', 'ND002', 'VE002', NOW(), 'Vé đã hết hạn', 1),
('GL003', 'ND003', 'VE003', NOW(), 'Tần suất sử dụng vé bất thường: 8 lần/ngày', 0),
('GL004', 'ND004', 'VE004', NOW(), 'Nghi ngờ chia sẻ vé với nhiều người', 0),
('GL005', 'ND005', 'VE001', NOW(), 'Quét vé từ 2 thiết bị khác nhau cùng lúc', 0),
('GL006', 'ND006', 'VE006', NOW(), 'Vé đã hết hạn', 1),
('GL007', 'ND007', 'VE007', NOW(), 'Vé đã hết hạn', 1),
('GL008', 'ND008', 'VE008', NOW(), 'Sử dụng vé cũ trùng với mã QR mới', 0),
('GL009', 'ND009', 'VE009', NOW(), 'Vé giả', 0),
('GL010', 'ND010', 'VE010', NOW(), 'Dùng vé tháng sinh viên cho nhiều người', 0),
('GL011', 'ND011', 'VE011', NOW(), 'Vé đã hết hạn', 1),
('GL012', 'ND012', 'VE012', NOW(), 'Quét vé từ thiết bị không xác thực', 0),
('GL013', 'ND013', 'VE013', NOW(), 'Quét liên tục tại nhiều ga trong 10 phút', 0),
('GL014', 'ND014', 'VE014', NOW(), 'Sử dụng vé trùng thời gian với người khác', 0),
('GL015', 'ND015', 'VE015', NOW(), 'Gian lận nghi ngờ từ hành vi quét NFC giả', 0),
('GL016', 'ND016', 'VE016', NOW(), 'Quét vé trong 5 phút tại 2 ga', 0),
('GL017', 'ND017', 'VE017', NOW(), 'QR code đã bị sao chép trái phép', 0),
('GL018', 'ND018', 'VE018', NOW(), 'Vé dùng trong khoảng thời gian chưa hiệu lực', 0),
('GL019', 'ND019', 'VE019', NOW(), 'Đã quét 3 ga khác nhau chỉ trong 2 phút', 0),
('GL020', 'ND020', 'VE020', NOW(), 'Chia sẻ vé với người dùng không đăng ký', 0);

SELECT * FROM  FraudLog;

-- TRUY VẤN

-- Danh sách người dùng thanh toán thành công
SELECT DISTINCT u.*
FROM Users u
JOIN Transactions t ON u.UserID = t.UserID
WHERE t.TransactionStatus = 'Success';

-- Danh sách người dùng thanh toán thất bại
SELECT DISTINCT u.*
FROM Users u
JOIN Transactions t ON u.UserID = t.UserID
WHERE t.TransactionStatus = 'Failed';

-- Lịch sử quét của một người dùng 
SELECT *
FROM CheckInOut
WHERE UserID = 'ND001'
ORDER BY CheckTime DESC;

-- Danh sách người dùng bị cảnh báo gian lận
SELECT f.FraudID, u.FullName, f.Descriptions, f.DetectedAt
FROM FraudLog f
JOIN Users u ON f.UserID = u.UserID;

-- Lượt quét ở từng ga
SELECT s.StationID, s.StationName, COUNT(c.CheckID) AS ScanCount
FROM Station s
LEFT JOIN CheckInOut c ON s.StationID = c.StationID
GROUP BY s.StationID, s.StationName
ORDER BY s.StationID;

-- Danh sách sinh viên đang dùng vé tháng
SELECT u.FullName, t.TicketID, t.TicketType, t.ValidTo
FROM Users u
JOIN Ticket t ON u.UserID = t.UserID
WHERE u.IsStudent = 1 AND t.TicketType = 'Month' AND t.TicketStatus = 'Active';

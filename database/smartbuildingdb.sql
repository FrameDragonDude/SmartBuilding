DROP DATABASE IF EXISTS smartbuildingdb;

CREATE DATABASE smartbuildingdb
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE smartbuildingdb;

-- 1. PHÂN HỆ CẤU TRÚC TÒA NHÀ

CREATE TABLE Buildings (
    Id VARCHAR(36) PRIMARY KEY,
    BuildingCode VARCHAR(20) NOT NULL UNIQUE,
    Name VARCHAR(100) NOT NULL,
    TotalFloors INT NOT NULL CHECK (TotalFloors > 0),
    TotalBasements INT NOT NULL DEFAULT 0 CHECK (TotalBasements >= 0),
    Address VARCHAR(255) NOT NULL,
    CreatedAt DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ENGINE=InnoDB;

CREATE TABLE Floors (
    Id VARCHAR(36) PRIMARY KEY,
    BuildingId VARCHAR(36) NOT NULL,
    FloorNumber INT NOT NULL,
    TotalApartments INT NOT NULL DEFAULT 0 CHECK (TotalApartments >= 0),
    Description VARCHAR(200) NULL,
    CONSTRAINT FK_Floors_Buildings FOREIGN KEY (BuildingId) REFERENCES Buildings(Id) ON DELETE CASCADE,
    CONSTRAINT UQ_Building_FloorNumber UNIQUE (BuildingId, FloorNumber)
) ENGINE=InnoDB;

CREATE TABLE Apartments (
    Id VARCHAR(36) PRIMARY KEY,
    FloorId VARCHAR(36) NOT NULL,
    ApartmentNumber VARCHAR(20) NOT NULL,
    Area DECIMAL(8, 2) NOT NULL CHECK (Area > 0),
    RoomsCount INT NOT NULL CHECK (RoomsCount >= 0),
    BathroomsCount INT NOT NULL CHECK (BathroomsCount >= 0),
    Status ENUM('Available', 'Occupied', 'UnderMaintenance', 'Reserved') NOT NULL DEFAULT 'Available',
    Version INT UNSIGNED NOT NULL DEFAULT 1,
    CONSTRAINT FK_Apartments_Floors FOREIGN KEY (FloorId) REFERENCES Floors(Id) ON DELETE RESTRICT,
    CONSTRAINT UQ_Floor_ApartmentNumber UNIQUE (FloorId, ApartmentNumber)
) ENGINE=InnoDB;

-- 2. PHÂN HỆ CƯ DÂN & PHƯƠNG TIỆN

CREATE TABLE Residents (
    Id CHAR(36) PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    IdentityCardNumber VARCHAR(20) NOT NULL UNIQUE,
    PhoneNumber VARCHAR(15) NOT NULL UNIQUE,
    Email VARCHAR(100) NULL,
    DateOfBirth DATE NOT NULL,
    Gender ENUM('Nam', 'Nữ', 'Khác') NOT NULL,
    AvatarUrl VARCHAR(500) NULL,
    CreatedAt DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ENGINE=InnoDB;

CREATE TABLE ApartmentHistories (
    Id VARCHAR(36) PRIMARY KEY,
    ApartmentId VARCHAR(36) NOT NULL,
    ResidentId VARCHAR(36) NOT NULL,
    ContractType ENUM('Owner', 'Tenant') NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NULL,
    ContractFileUrl VARCHAR(500) NULL,
    IsCurrent TINYINT(1) NOT NULL DEFAULT 1,
    CONSTRAINT FK_ApartmentHistories_Apartments FOREIGN KEY (ApartmentId) REFERENCES Apartments(Id) ON DELETE CASCADE,
    CONSTRAINT FK_ApartmentHistories_Residents FOREIGN KEY (ResidentId) REFERENCES Residents(Id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE ResidentDocuments (
    Id VARCHAR(36) PRIMARY KEY,
    ResidentId VARCHAR(36) NOT NULL,
    DocumentType ENUM('CCCD_Front', 'CCCD_Back', 'TamTru', 'TamVang', 'GiayKetHon') NOT NULL,
    DocumentNumber VARCHAR(50) NULL,
    IssuedDate DATE NULL,
    IssuedPlace VARCHAR(100) NULL,
    AttachmentUrl VARCHAR(500) NOT NULL,
    VerificationStatus ENUM('Pending', 'Approved', 'Rejected') NOT NULL DEFAULT 'Pending',
    UploadedAt DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT FK_ResidentDocuments_Residents FOREIGN KEY (ResidentId) REFERENCES Residents(Id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Vehicles (
    Id VARCHAR(50) PRIMARY KEY,
    ResidentId VARCHAR(36) NOT NULL,
    ApartmentId VARCHAR(36) NOT NULL,
    VehicleType ENUM('Motorbike', 'Car', 'ElectricBicycle') NOT NULL,
    LicensePlate VARCHAR(20) NOT NULL UNIQUE,
    RfidCardCode VARCHAR(50) NOT NULL UNIQUE,
    Brand VARCHAR(50) NULL,
    RegistrationPaperUrl VARCHAR(500) NULL,
    VehicleImageUrl VARCHAR(500) NULL,
    IsActive TINYINT(1) NOT NULL DEFAULT 1,
    RegisteredAt DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT FK_Vehicles_Residents FOREIGN KEY (ResidentId) REFERENCES Residents(Id) ON DELETE RESTRICT,
    CONSTRAINT FK_Vehicles_Apartments FOREIGN KEY (ApartmentId) REFERENCES Apartments(Id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE ParkingSlots (
    Id VARCHAR(36) PRIMARY KEY,
    BuildingId VARCHAR(36) NOT NULL,
    VehicleId VARCHAR(50) NULL UNIQUE,
    SlotCode VARCHAR(30) NOT NULL UNIQUE,
    BasementLevel VARCHAR(10) NOT NULL,
    SlotType ENUM('Car', 'Motorbike') NOT NULL,
    IsOccupied TINYINT(1) NOT NULL DEFAULT 0,
    CONSTRAINT FK_ParkingSlots_Buildings FOREIGN KEY (BuildingId) REFERENCES Buildings(Id) ON DELETE CASCADE,
    CONSTRAINT FK_ParkingSlots_Vehicles FOREIGN KEY (VehicleId) REFERENCES Vehicles(Id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 3. PHÂN HỆ DỊCH VỤ, TIỆN ÍCH & ĐIỆN NƯỚC

CREATE TABLE ServiceTariffs (
    Id VARCHAR(36) PRIMARY KEY,
    ServiceType ENUM('Electricity', 'Water', 'BuildingManagement', 'ParkingFee') NOT NULL,
    TierName VARCHAR(50) NOT NULL,
    FromUnit DECIMAL(10, 2) NOT NULL CHECK (FromUnit >= 0),
    ToUnit DECIMAL(10, 2) NULL,
    UnitPrice DECIMAL(18, 2) NOT NULL CHECK (UnitPrice >= 0),
    VatRate DECIMAL(5, 2) NOT NULL DEFAULT 0.00 CHECK (VatRate >= 0),
    EffectiveDate DATE NOT NULL,
    CONSTRAINT CHK_Tariff_Units CHECK (ToUnit IS NULL OR ToUnit > FromUnit)
) ENGINE=InnoDB;

CREATE TABLE UtilityMeters (
    Id VARCHAR(36) PRIMARY KEY,
    ApartmentId VARCHAR(36) NOT NULL,
    MeterType ENUM('Electricity', 'Water') NOT NULL,
    MeterSerialNumber VARCHAR(50) NOT NULL UNIQUE,
    InstallationDate DATE NOT NULL,
    IsActive TINYINT(1) NOT NULL DEFAULT 1,
    CONSTRAINT FK_UtilityMeters_Apartments FOREIGN KEY (ApartmentId) REFERENCES Apartments(Id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE UtilityUsages (
    Id VARCHAR(36) PRIMARY KEY,
    MeterId VARCHAR(36) NOT NULL,
    BillingMonth INT NOT NULL CHECK (BillingMonth BETWEEN 1 AND 12),
    BillingYear INT NOT NULL CHECK (BillingYear >= 2000),
    PreviousReading DECIMAL(12, 2) NOT NULL CHECK (PreviousReading >= 0),
    CurrentReading DECIMAL(12, 2) NOT NULL,
    Consumption DECIMAL(12, 2) GENERATED ALWAYS AS (CurrentReading - PreviousReading) STORED,
    CalculatedAmount DECIMAL(18, 2) NOT NULL DEFAULT 0.00 CHECK (CalculatedAmount >= 0),
    ProofImageUrl VARCHAR(500) NULL,
    RecordedAt DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT FK_UtilityUsages_UtilityMeters FOREIGN KEY (MeterId) REFERENCES UtilityMeters(Id) ON DELETE RESTRICT,
    CONSTRAINT UQ_Meter_BillingCycle UNIQUE (MeterId, BillingMonth, BillingYear),
    CONSTRAINT CHK_Reading_Values CHECK (CurrentReading >= PreviousReading)
) ENGINE=InnoDB;

CREATE TABLE Amenities (
    Id VARCHAR(36) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    ImageUrl VARCHAR(500) NULL,
    MaxCapacity INT NOT NULL CHECK (MaxCapacity > 0),
    OpenTime TIME NOT NULL,
    CloseTime TIME NOT NULL,
    SlotDurationMinutes INT NOT NULL DEFAULT 60,
    IsActive TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB;

CREATE TABLE AmenityBookings (
    Id VARCHAR(36) PRIMARY KEY,
    AmenityId VARCHAR(36) NOT NULL,
    ResidentId VARCHAR(36) NOT NULL,
    ApartmentId VARCHAR(36) NOT NULL,
    StartTime DATETIME(6) NOT NULL,
    EndTime DATETIME(6) NOT NULL,
    NumberOfGuests INT NOT NULL DEFAULT 1 CHECK (NumberOfGuests > 0),
    Status ENUM('Confirmed', 'Cancelled', 'Completed') NOT NULL DEFAULT 'Confirmed',
    CreatedAt DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT FK_AmenityBookings_Amenities FOREIGN KEY (AmenityId) REFERENCES Amenities(Id) ON DELETE RESTRICT,
    CONSTRAINT FK_AmenityBookings_Residents FOREIGN KEY (ResidentId) REFERENCES Residents(Id) ON DELETE RESTRICT,
    CONSTRAINT FK_AmenityBookings_Apartments FOREIGN KEY (ApartmentId) REFERENCES Apartments(Id) ON DELETE RESTRICT,
    CONSTRAINT CHK_Booking_Time CHECK (EndTime > StartTime)
) ENGINE=InnoDB;

-- 4. PHÂN HỆ HÓA ĐƠN, THANH TOÁN & PHẠT NỢ

CREATE TABLE MonthlyInvoices (
    Id VARCHAR(36) PRIMARY KEY,
    ApartmentId VARCHAR(36) NOT NULL,
    InvoiceCode VARCHAR(30) NOT NULL UNIQUE,
    BillingMonth INT NOT NULL CHECK (BillingMonth BETWEEN 1 AND 12),
    BillingYear INT NOT NULL CHECK (BillingYear >= 2000),
    TotalAmount DECIMAL(18, 2) NOT NULL DEFAULT 0.00 CHECK (TotalAmount >= 0),
    PaidAmount DECIMAL(18, 2) NOT NULL DEFAULT 0.00 CHECK (PaidAmount >= 0),
    DueDate DATE NOT NULL,
    GracePeriodUntil DATE NULL,
    Status ENUM('Unpaid', 'PartiallyPaid', 'Paid', 'Overdue') NOT NULL DEFAULT 'Unpaid',
    ReminderSent TINYINT(1) NOT NULL DEFAULT 0,
    ReminderDate DATETIME(6) NULL,
    CreatedAt DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT FK_MonthlyInvoices_Apartments FOREIGN KEY (ApartmentId) REFERENCES Apartments(Id) ON DELETE RESTRICT,
    CONSTRAINT UQ_Apartment_InvoiceCycle UNIQUE (ApartmentId, BillingMonth, BillingYear)
) ENGINE=InnoDB;

CREATE TABLE InvoiceDetails (
    Id VARCHAR(36) PRIMARY KEY,
    InvoiceId VARCHAR(36) NOT NULL,
    ItemType ENUM('ManagementFee', 'Electricity', 'Water', 'ParkingFee', 'PenaltyFee') NOT NULL,
    Description VARCHAR(255) NOT NULL,
    Quantity DECIMAL(10, 2) NOT NULL CHECK (Quantity >= 0),
    UnitPrice DECIMAL(18, 2) NOT NULL CHECK (UnitPrice >= 0),
    LineTotal DECIMAL(18, 2) NOT NULL CHECK (LineTotal >= 0),
    CONSTRAINT FK_InvoiceDetails_MonthlyInvoices FOREIGN KEY (InvoiceId) REFERENCES MonthlyInvoices(Id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Payments (
    Id VARCHAR(36) PRIMARY KEY,
    InvoiceId VARCHAR(36) NOT NULL,
    TransactionCode VARCHAR(100) NOT NULL UNIQUE,
    PaymentMethod ENUM('VNPay', 'BankTransfer', 'Cash', 'MoMo') NOT NULL,
    Amount DECIMAL(18, 2) NOT NULL CHECK (Amount > 0),
    ProofReceiptUrl VARCHAR(500) NULL,
    PaymentDate DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    Status ENUM('Success', 'Failed', 'Pending') NOT NULL DEFAULT 'Success',
    PayerNote VARCHAR(255) NULL,
    CONSTRAINT FK_Payments_MonthlyInvoices FOREIGN KEY (InvoiceId) REFERENCES MonthlyInvoices(Id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE LatePaymentPenalties (
    Id VARCHAR(36) PRIMARY KEY,
    InvoiceId VARCHAR(36) NOT NULL,
    OverdueDays INT NOT NULL CHECK (OverdueDays > 0),
    InterestRate DECIMAL(5, 2) NOT NULL CHECK (InterestRate >= 0),
    PenaltyAmount DECIMAL(18, 2) NOT NULL CHECK (PenaltyAmount >= 0),
    Reason VARCHAR(255) NOT NULL,
    IsResolved TINYINT(1) NOT NULL DEFAULT 0,
    CalculatedDate DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT FK_LatePaymentPenalties_MonthlyInvoices FOREIGN KEY (InvoiceId) REFERENCES MonthlyInvoices(Id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 5. PHÂN HỆ VẬN HÀNH & PHÂN QUYỀN

CREATE TABLE ComplaintRequests (
    Id VARCHAR(36) PRIMARY KEY,
    ResidentId VARCHAR(36) NOT NULL,
    ApartmentId VARCHAR(36) NOT NULL,
    Category ENUM('Sanitation', 'Noise', 'Security', 'FacilityDamage') NOT NULL,
    Title VARCHAR(150) NOT NULL,
    Content TEXT NOT NULL,
    AttachedImageUrl VARCHAR(500) NULL,
    ResolvedImageUrl VARCHAR(500) NULL,
    Status ENUM('Pending', 'Assigned', 'Processing', 'Resolved', 'Closed') NOT NULL DEFAULT 'Pending',
    CreatedAt DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    ResolvedAt DATETIME(6) NULL,
    CONSTRAINT FK_ComplaintRequests_Residents FOREIGN KEY (ResidentId) REFERENCES Residents(Id) ON DELETE RESTRICT,
    CONSTRAINT FK_ComplaintRequests_Apartments FOREIGN KEY (ApartmentId) REFERENCES Apartments(Id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE Accounts (
    Id VARCHAR(36) PRIMARY KEY,
    ResidentId VARCHAR(36) NULL UNIQUE,
    Username VARCHAR(50) NOT NULL UNIQUE,
    PasswordHash VARCHAR(500) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    IsActive TINYINT(1) NOT NULL DEFAULT 1,
    CreatedAt DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT FK_Accounts_Residents FOREIGN KEY (ResidentId) REFERENCES Residents(Id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE Roles (
    Id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    RoleCode VARCHAR(50) NOT NULL UNIQUE,
    RoleName VARCHAR(100) NOT NULL,
    Description VARCHAR(255) NULL
) ENGINE=InnoDB;

CREATE TABLE UserRoles (
    AccountId VARCHAR(36) NOT NULL,
    RoleId CHAR(36) NOT NULL,
    AssignedAt DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (AccountId, RoleId),
    CONSTRAINT FK_UserRoles_Accounts FOREIGN KEY (AccountId) REFERENCES Accounts(Id) ON DELETE CASCADE,
    CONSTRAINT FK_UserRoles_Roles FOREIGN KEY (RoleId) REFERENCES Roles(Id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE AuditTrails (
    Id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    AccountId VARCHAR(36) NULL,
    ActionType ENUM('INSERT', 'UPDATE', 'DELETE', 'LOGIN') NOT NULL,
    TableName VARCHAR(100) NOT NULL,
    RecordId VARCHAR(100) NOT NULL,
    OldValues JSON NULL,
    NewValues JSON NULL,
    IpAddress VARCHAR(45) NULL,
    Timestamp DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT FK_AuditTrails_Accounts FOREIGN KEY (AccountId) REFERENCES Accounts(Id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- INDEX TỐI ƯU TRUY VẤN
CREATE INDEX IX_Apartments_FloorId ON Apartments(FloorId);
CREATE INDEX IX_Apartments_Status ON Apartments(Status);
CREATE INDEX IX_Vehicles_ResidentId ON Vehicles(ResidentId);
CREATE INDEX IX_Vehicles_ApartmentId ON Vehicles(ApartmentId);
CREATE INDEX IX_UtilityUsages_BillingCycle ON UtilityUsages(BillingYear, BillingMonth);
CREATE INDEX IX_MonthlyInvoices_Status ON MonthlyInvoices(Status);
CREATE INDEX IX_MonthlyInvoices_DueDate ON MonthlyInvoices(DueDate, GracePeriodUntil);
CREATE INDEX IX_ComplaintRequests_Status ON ComplaintRequests(Status);


-- SEED DATA MẪU HOÀN CHỈNH

-- 1. BUILDINGS
INSERT INTO Buildings (Id, BuildingCode, Name, TotalFloors, TotalBasements, Address) VALUES 
    ('B1', 'RUBY-01', N'Tòa Ruby Suites', 25, 2, N'01 Mai Chí Thọ, Phường An Phú, TP. Thủ Đức'),
    ('B2', 'AQUA-02', N'Tòa Aqua Premier', 30, 3, N'02 Mai Chí Thọ, Phường An Phú, TP. Thủ Đức'),
    ('B3', 'EMERALD-03', N'Tòa Emerald Park', 28, 2, N'03 Mai Chí Thọ, Phường An Phú, TP. Thủ Đức'),
    ('B4', 'DIAMOND-04', N'Tòa Diamond Crown', 35, 3, N'04 Mai Chí Thọ, Phường An Phú, TP. Thủ Đức'),
    ('B5', 'SAPPHIRE-05', N'Tòa Sapphire Sky', 22, 2, N'05 Mai Chí Thọ, Phường An Phú, TP. Thủ Đức'),
    ('B6', 'TOPAZ-06', N'Tòa Topaz Residence', 20, 1, N'06 Mai Chí Thọ, Phường An Phú, TP. Thủ Đức'),
    ('B7', 'OPAL-07', N'Tòa Opal Garden', 26, 2, N'07 Mai Chí Thọ, Phường An Phú, TP. Thủ Đức'),
    ('B8', 'PEARL-08', N'Tòa Pearl Plaza', 32, 3, N'08 Mai Chí Thọ, Phường An Phú, TP. Thủ Đức');

-- 2. FLOORS
INSERT INTO Floors (Id, BuildingId, FloorNumber, TotalApartments, Description) VALUES 
    ('B1-F01', 'B1', 1, 3, N'Tòa Ruby - Tầng 1 (Khu căn hộ sân vườn)'),
    ('B1-F02', 'B1', 2, 3, N'Tòa Ruby - Tầng 2 (Khu căn hộ tiêu chuẩn)'),
    ('B1-F03', 'B1', 3, 2, N'Tòa Ruby - Tầng 3 (Khu căn hộ tiêu chuẩn)'),
    ('B1-F04', 'B1', 4, 3, N'Tòa Ruby - Tầng 4 (Khu căn hộ cao cấp)'),
    ('B1-F05', 'B1', 5, 3, N'Tòa Ruby - Tầng 5 (Khu căn hộ cao cấp)'),
    ('B2-F01', 'B2', 1, 3, N'Tòa Aqua - Tầng 1 (Khu căn hộ hướng hồ)'),
    ('B2-F02', 'B2', 2, 3, N'Tòa Aqua - Tầng 2 (Khu căn hộ hướng sông)'),
    ('B2-F03', 'B2', 3, 2, N'Tòa Aqua - Tầng 3 (Khu căn hộ view sông)'),
    ('B3-F01', 'B3', 1, 2, N'Tòa Emerald - Tầng 1 (Khu căn hộ sân vườn)'),
    ('B4-F01', 'B4', 1, 3, N'Tòa Diamond - Tầng 1 (Khu căn hộ ban công lớn)'),
    ('B5-F01', 'B5', 1, 3, N'Tòa Sapphire - Tầng 1 (Khu căn hộ tiêu chuẩn)');

-- 3. APARTMENTS
INSERT INTO Apartments (Id, FloorId, ApartmentNumber, Area, RoomsCount, BathroomsCount, Status, Version) VALUES 
    ('B1-F01-01', 'B1-F01', 'RB-0101', 95.00,  3, 2, 'Occupied', 1),
    ('B1-F01-02', 'B1-F01', 'RB-0102', 85.00,  2, 2, 'Occupied', 1),
    ('B1-F01-03', 'B1-F01', 'RB-0103', 75.00,  2, 1, 'Available', 1),
    ('B1-F02-01', 'B1-F02', 'RB-0201', 78.50,  2, 2, 'Occupied', 1),
    ('B1-F02-02', 'B1-F02', 'RB-0202', 85.00,  3, 2, 'Occupied', 1),
    ('B1-F02-03', 'B1-F02', 'RB-0203', 68.00,  2, 1, 'Occupied', 1),
    ('B1-F03-01', 'B1-F03', 'RB-0301', 92.00,  3, 2, 'Occupied', 1),
    ('B1-F03-02', 'B1-F03', 'RB-0302', 105.00, 3, 2, 'Occupied', 1),
    ('B1-F04-01', 'B1-F04', 'RB-0401', 80.00,  2, 2, 'Occupied', 1),
    ('B1-F04-02', 'B1-F04', 'RB-0402', 88.00,  3, 2, 'Occupied', 1),
    ('B1-F04-03', 'B1-F04', 'RB-0403', 95.00,  3, 2, 'Available', 1),
    ('B1-F05-01', 'B1-F05', 'RB-0501', 75.00,  2, 1, 'Occupied', 1),
    ('B1-F05-02', 'B1-F05', 'RB-0502', 82.00,  2, 2, 'Occupied', 1),
    ('B1-F05-03', 'B1-F05', 'RB-0503', 90.00,  3, 2, 'Occupied', 1),
    ('B3-F01-01', 'B3-F01', 'EM-0101', 88.00,  2, 2, 'Occupied', 1),
    ('B3-F01-02', 'B3-F01', 'EM-0102', 72.00,  2, 1, 'Occupied', 1);

-- 4. RESIDENTS
INSERT INTO Residents (Id, FullName, IdentityCardNumber, PhoneNumber, Email, DateOfBirth, Gender, AvatarUrl) VALUES 
    ('Res1',  N'Nguyễn Văn An',    '079095001234', '0901234567', 'an.nguyen@gmail.com',    '1985-05-12', 'Nam', 'https://storage.bms.vn/avatars/res1.jpg'),
    ('Res2',  N'Trần Thị Bình',    '079198002345', '0912345678', 'binh.tran@gmail.com',    '1990-08-20', 'Nữ',  'https://storage.bms.vn/avatars/res2.jpg'),
    ('Res3',  N'Lê Hoàng Cường',   '079088003456', '0923456789', 'cuong.le@outlook.com',   '1988-11-03', 'Nam', 'https://storage.bms.vn/avatars/res3.jpg'),
    ('Res4',  N'Phạm Minh Dũng',   '079092004567', '0934567890', 'dung.pham@yahoo.com',    '1992-02-14', 'Nam', 'https://storage.bms.vn/avatars/res4.jpg'),
    ('Res5',  N'Hoàng Thu Trang',  '079196005678', '0945678901', 'trang.hoang@gmail.com',  '1996-07-28', 'Nữ',  'https://storage.bms.vn/avatars/res5.jpg'),
    ('Res6',  N'Đỗ Quốc Bảo',      '079099006789', '0956789012', 'bao.do@fpt.edu.vn',     '1999-10-15', 'Nam', 'https://storage.bms.vn/avatars/res6.jpg'),
    ('Res7',  N'Vũ Quốc Khánh',    '079080004455', '0966889900', 'khanh.vu@techcorp.vn',   '1982-12-05', 'Nam', 'https://storage.bms.vn/avatars/res7.jpg'),
    ('Res8',  N'Bùi Thị Mai',      '079194006677', '0922334455', 'mai.bui@gmail.com',      '1994-04-18', 'Nữ',  'https://storage.bms.vn/avatars/res8.jpg'),
    ('Res9',  N'Trịnh Bá Phong',   '079091001122', '0981122334', 'phong.trinh@gmail.com',  '1987-03-22', 'Nam', 'https://storage.bms.vn/avatars/res9.jpg'),
    ('Res10', N'Đinh Ngọc Ánh',    '079193002233', '0972233445', 'anh.dinh@gmail.com',     '1993-09-10', 'Nữ',  'https://storage.bms.vn/avatars/res10.jpg'),
    ('Res11', N'Lý Minh Khang',    '079089003344', '0963344556', 'khang.ly@gmail.com',     '1995-12-01', 'Nam', 'https://storage.bms.vn/avatars/res11.jpg'),
    ('Res12', N'Tạ Phương Thảo',   '079197004455', '0954455667', 'thao.ta@gmail.com',      '1991-06-18', 'Nữ',  'https://storage.bms.vn/avatars/res12.jpg'),
    ('Res13', N'Hà Văn Nam',       '079090005566', '0945566778', 'nam.ha@gmail.com',       '1989-01-25', 'Nam', 'https://storage.bms.vn/avatars/res13.jpg'),
    ('Res14', N'Võ Mỹ Linh',       '079192006677', '0936677889', 'linh.vo@gmail.com',      '1997-08-14', 'Nữ',  'https://storage.bms.vn/avatars/res14.jpg'),
    ('Res15', N'Lương Tuấn Kiệt',  '079086007788', '0927788990', 'kiet.luong@gmail.com',   '1986-04-30', 'Nam', 'https://storage.bms.vn/avatars/res15.jpg'),
    ('Res16', N'Dương Thu Hà',     '079195008899', '0918899001', 'ha.duong@gmail.com',     '1998-11-11', 'Nữ',  'https://storage.bms.vn/avatars/res16.jpg');

-- 5. APARTMENT HISTORIES
INSERT INTO ApartmentHistories (Id, ApartmentId, ResidentId, ContractType, StartDate, EndDate, ContractFileUrl, IsCurrent) VALUES 
    ('AH1',  'B1-F01-01', 'Res1',  'Tenant', '2024-01-01', '2027-01-01', 'https://storage.bms.vn/contracts/c1.pdf',  1),
    ('AH2',  'B1-F01-02', 'Res2',  'Owner',  '2023-05-15', NULL,         'https://storage.bms.vn/contracts/c2.pdf',  1),
    ('AH3',  'B1-F02-01', 'Res3',  'Owner',  '2023-08-01', NULL,         'https://storage.bms.vn/contracts/c3.pdf',  1),
    ('AH4',  'B1-F02-02', 'Res4',  'Owner',  '2024-02-10', NULL,         'https://storage.bms.vn/contracts/c4.pdf',  1),
    ('AH5',  'B1-F02-03', 'Res5',  'Tenant', '2024-06-01', '2026-06-01', 'https://storage.bms.vn/contracts/c5.pdf',  1),
    ('AH6',  'B1-F03-01', 'Res6',  'Tenant', '2025-01-15', '2027-01-15', 'https://storage.bms.vn/contracts/c6.pdf',  1),
    ('AH7',  'B1-F03-02', 'Res7',  'Owner',  '2022-11-20', NULL,         'https://storage.bms.vn/contracts/c7.pdf',  1),
    ('AH8',  'B1-F04-01', 'Res8',  'Owner',  '2024-09-01', NULL,         'https://storage.bms.vn/contracts/c8.pdf',  1),
    ('AH9',  'B1-F04-02', 'Res9',  'Tenant', '2024-03-01', '2026-03-01', 'https://storage.bms.vn/contracts/c9.pdf',  1),
    ('AH10', 'B1-F05-01', 'Res10', 'Owner',  '2023-10-01', NULL,         'https://storage.bms.vn/contracts/c10.pdf', 1),
    ('AH11', 'B1-F05-02', 'Res11', 'Tenant', '2024-05-10', '2026-05-10', 'https://storage.bms.vn/contracts/c11.pdf', 1),
    ('AH12', 'B1-F05-03', 'Res12', 'Owner',  '2023-12-20', NULL,         'https://storage.bms.vn/contracts/c12.pdf', 1),
    ('AH13', 'B3-F01-01', 'Res13', 'Owner',  '2024-04-01', NULL,         'https://storage.bms.vn/contracts/c13.pdf', 1),
    ('AH14', 'B3-F01-02', 'Res14', 'Tenant', '2025-02-01', '2027-02-01', 'https://storage.bms.vn/contracts/c14.pdf', 1),
    ('AH15', 'B1-F02-01', 'Res15', 'Tenant', '2021-01-01', '2023-01-01', 'https://storage.bms.vn/contracts/c15.pdf', 0),
    ('AH16', 'B1-F02-02', 'Res16', 'Tenant', '2022-01-01', '2023-12-31', 'https://storage.bms.vn/contracts/c16.pdf', 0);

-- 6. RESIDENT DOCUMENTS
INSERT INTO ResidentDocuments (Id, ResidentId, DocumentType, DocumentNumber, IssuedDate, IssuedPlace, AttachmentUrl, VerificationStatus) VALUES 
    ('Doc1',  'Res1',  'CCCD_Front', '079095001234', '2021-06-10', N'Cục CSQLHC về TTXH', 'https://storage.bms.vn/docs/cccd_01_f.jpg', 'Approved'),
    ('Doc2',  'Res1',  'CCCD_Back',  '079095001234', '2021-06-10', N'Cục CSQLHC về TTXH', 'https://storage.bms.vn/docs/cccd_01_b.jpg', 'Approved'),
    ('Doc3',  'Res2',  'GiayKetHon', 'GKH-882910',   '2023-04-12', N'UBND Phường An Phú', 'https://storage.bms.vn/docs/gkh_02.jpg',    'Approved'),
    ('Doc4',  'Res3',  'TamTru',     'TT-2024-08A',  '2024-01-01', N'Công an Phường An Phú', 'https://storage.bms.vn/docs/tamtru_03.jpg', 'Approved'),
    ('Doc5',  'Res4',  'CCCD_Front', '079092004567', '2022-01-15', N'Cục CSQLHC về TTXH', 'https://storage.bms.vn/docs/cccd_04_f.jpg', 'Approved'),
    ('Doc6',  'Res5',  'TamTru',     'CT07-9921',    '2024-06-05', N'Công an Phường An Phú', 'https://storage.bms.vn/docs/ct07_05.jpg',   'Approved'),
    ('Doc7',  'Res6',  'TamVang',    'TV-150992',    '2023-09-01', N'Công an Xã Tân Lập', 'https://storage.bms.vn/docs/tamvang_06.jpg', 'Approved'),
    ('Doc8',  'Res7',  'GiayKetHon', 'GKH-2023-VN99','2023-03-01', N'UBND Phường Thảo Điền', 'https://storage.bms.vn/docs/gkh_07.jpg',  'Approved'),
    ('Doc9',  'Res8',  'CCCD_Front', '079194006677', '2021-08-10', N'Cục CSQLHC về TTXH', 'https://storage.bms.vn/docs/cccd_08_f.jpg', 'Approved'),
    ('Doc10', 'Res9',  'TamTru',     'TT-2024-11B',  '2024-03-15', N'Công an Phường An Phú', 'https://storage.bms.vn/docs/tamtru_09.jpg', 'Approved'),
    ('Doc11', 'Res10', 'CCCD_Front', '079193002233', '2022-05-12', N'Cục CSQLHC về TTXH', 'https://storage.bms.vn/docs/cccd_10_f.jpg', 'Approved'),
    ('Doc12', 'Res11', 'TamTru',     'TT-2024-12C',  '2024-05-20', N'Công an Phường An Phú', 'https://storage.bms.vn/docs/tamtru_11.jpg', 'Approved'),
    ('Doc13', 'Res12', 'GiayKetHon', 'GKH-2023-88',  '2023-11-15', N'UBND Phường An Phú', 'https://storage.bms.vn/docs/gkh_12.jpg',    'Approved'),
    ('Doc14', 'Res13', 'CCCD_Front', '079090005566', '2020-10-10', N'Cục CSQLHC về TTXH', 'https://storage.bms.vn/docs/cccd_13_f.jpg', 'Approved'),
    ('Doc15', 'Res14', 'TamTru',     'TT-2025-02A',  '2025-02-10', N'Công an Phường An Phú', 'https://storage.bms.vn/docs/tamtru_14.jpg', 'Pending'),
    ('Doc16', 'Res15', 'TamVang',    'TV-2021-01',   '2021-02-01', N'Công an Tỉnh Đồng Nai', 'https://storage.bms.vn/docs/tamvang_15.jpg', 'Approved');

-- 7. VEHICLES
INSERT INTO Vehicles (Id, ResidentId, ApartmentId, VehicleType, LicensePlate, RfidCardCode, Brand, RegistrationPaperUrl, VehicleImageUrl, IsActive) VALUES 
    ('XM-079095001234-59E112345', 'Res1',  'B1-F01-01', 'Motorbike',       '59E1-123.45', 'RFID-MB-001',  'Honda SH 150i',     'https://storage.bms.vn/cavet/xm01.jpg', 'https://storage.bms.vn/vehicles/xm01.jpg', 1),
    ('OT-079095001234-51H88866',  'Res1',  'B1-F01-01', 'Car',             '51H-888.66',  'RFID-CAR-002', 'Mercedes-Benz C200', 'https://storage.bms.vn/cavet/ot01.jpg', 'https://storage.bms.vn/vehicles/ot01.jpg', 1),
    ('XM-079198002345-59F298765', 'Res2',  'B1-F01-02', 'Motorbike',       '59F2-987.65', 'RFID-MB-003',  'Yamaha Grande',     'https://storage.bms.vn/cavet/xm02.jpg', 'https://storage.bms.vn/vehicles/xm02.jpg', 1),
    ('OT-079088003456-51K12399',  'Res3',  'B1-F02-01', 'Car',             '51K-123.99',  'RFID-CAR-004', 'Mazda CX-5',        'https://storage.bms.vn/cavet/ot02.jpg', 'https://storage.bms.vn/vehicles/ot02.jpg', 1),
    ('OT-079092004567-51G77788',  'Res4',  'B1-F02-02', 'Car',             '51G-777.88',  'RFID-CAR-005', 'VinFast VF8',       'https://storage.bms.vn/cavet/ot03.jpg', 'https://storage.bms.vn/vehicles/ot03.jpg', 1),
    ('XM-079196005678-59S355544', 'Res5',  'B1-F02-03', 'Motorbike',       '59S3-555.44', 'RFID-MB-006',  'Honda Vision',       'https://storage.bms.vn/cavet/xm03.jpg', 'https://storage.bms.vn/vehicles/xm03.jpg', 1),
    ('XM-079099006789-59N144433', 'Res6',  'B1-F03-01', 'Motorbike',       '59N1-444.33', 'RFID-MB-007',  'Honda AirBlade',     'https://storage.bms.vn/cavet/xm04.jpg', 'https://storage.bms.vn/vehicles/xm04.jpg', 1),
    ('OT-079080004455-51A99911',  'Res7',  'B1-F03-02', 'Car',             '51A-999.11',  'RFID-CAR-008', 'BMW 320i',           'https://storage.bms.vn/cavet/ot04.jpg', 'https://storage.bms.vn/vehicles/ot04.jpg', 1),
    ('XM-079194006677-59X166677', 'Res8',  'B1-F04-01', 'Motorbike',       '59X1-666.77', 'RFID-MB-009',  'Honda Lead',         'https://storage.bms.vn/cavet/xm05.jpg', 'https://storage.bms.vn/vehicles/xm05.jpg', 1),
    ('XEL-079091001122-59MD11122','Res9',  'B1-F04-02', 'ElectricBicycle', '59MD-111.22', 'RFID-EB-010',  'VinFast Klara',      'https://storage.bms.vn/cavet/xel01.jpg','https://storage.bms.vn/vehicles/xel01.jpg',1),
    ('OT-079193002233-51K55566',  'Res10', 'B1-F05-01', 'Car',             '51K-555.66',  'RFID-CAR-011', 'Toyota Camry',       'https://storage.bms.vn/cavet/ot05.jpg', 'https://storage.bms.vn/vehicles/ot05.jpg', 1),
    ('XM-079089003344-59P233388', 'Res11', 'B1-F05-02', 'Motorbike',       '59P2-333.88', 'RFID-MB-012',  'Yamaha Exciter',     'https://storage.bms.vn/cavet/xm06.jpg', 'https://storage.bms.vn/vehicles/xm06.jpg', 1),
    ('OT-079197004455-51L22233',  'Res12', 'B1-F05-03', 'Car',             '51L-222.33',  'RFID-CAR-013', 'Hyundai Tucson',     'https://storage.bms.vn/cavet/ot06.jpg', 'https://storage.bms.vn/vehicles/ot06.jpg', 1),
    ('XM-079090005566-59B188899', 'Res13', 'B3-F01-01', 'Motorbike',       '59B1-888.99', 'RFID-MB-014',  'Honda Vario',        'https://storage.bms.vn/cavet/xm07.jpg', 'https://storage.bms.vn/vehicles/xm07.jpg', 1),
    ('XM-079192006677-59D277711', 'Res14', 'B3-F01-02', 'Motorbike',       '59D2-777.11', 'RFID-MB-015',  'Yamaha Janus',       'https://storage.bms.vn/cavet/xm08.jpg', 'https://storage.bms.vn/vehicles/xm08.jpg', 1),
    ('XEL-079092004567-59MD99900','Res4',  'B1-F02-02', 'ElectricBicycle', '59MD-999.00', 'RFID-EB-016',  'Yadea G5',           'https://storage.bms.vn/cavet/xel02.jpg','https://storage.bms.vn/vehicles/xel02.jpg',1);

-- 8. PARKING SLOTS (Đã có BuildingId, chuẩn tòa hầm và khớp 100% Vehicles.Id)
INSERT INTO ParkingSlots (Id, BuildingId, VehicleId, SlotCode, BasementLevel, SlotType, IsOccupied) VALUES 
    -- TẦNG HẦM TÒA B1 (Ruby Suites)
    ('Lot1',  'B1', 'XM-079095001234-59E112345',  'B1-B1-MOTO-01', 'B1', 'Motorbike', 1),
    ('Lot2',  'B1', 'OT-079095001234-51H88866',   'B1-B1-CAR-01',  'B1', 'Car',       1),
    ('Lot3',  'B1', 'XM-079198002345-59F298765',  'B1-B1-MOTO-02', 'B1', 'Motorbike', 1),
    ('Lot4',  'B1', 'OT-079088003456-51K12399',   'B1-B2-CAR-01',  'B2', 'Car',       1),
    ('Lot5',  'B1', 'OT-079092004567-51G77788',   'B1-B2-CAR-02',  'B2', 'Car',       1),
    ('Lot6',  'B1', 'XM-079196005678-59S355544',  'B1-B1-MOTO-03', 'B1', 'Motorbike', 1),
    ('Lot7',  'B1', 'XM-079099006789-59N144433',  'B1-B1-MOTO-04', 'B1', 'Motorbike', 1),
    ('Lot8',  'B1', 'OT-079080004455-51A99911',   'B1-B1-CAR-02',  'B1', 'Car',       1),
    ('Lot9',  'B1', 'XM-079194006677-59X166677',  'B1-B1-MOTO-05', 'B1', 'Motorbike', 1),
    ('Lot10', 'B1', 'OT-079193002233-51K55566',   'B1-B2-CAR-03',  'B2', 'Car',       1),
    ('Lot11', 'B1', 'XM-079089003344-59P233388',  'B1-B1-MOTO-06', 'B1', 'Motorbike', 1),
    ('Lot12', 'B1', 'OT-079197004455-51L22233',   'B1-B1-CAR-03',  'B1', 'Car',       1),
    ('Lot13', 'B1', NULL,                         'B1-B1-MOTO-07', 'B1', 'Motorbike', 0),
    ('Lot14', 'B1', NULL,                         'B1-B2-CAR-04',  'B2', 'Car',       0),

    -- TẦNG HẦM TÒA B3 (Emerald Park)
    ('Lot15', 'B3', 'XM-079090005566-59B188899',  'B3-B1-MOTO-01', 'B1', 'Motorbike', 1),
    ('Lot16', 'B3', 'XM-079192006677-59D277711',  'B3-B1-MOTO-02', 'B1', 'Motorbike', 1),
    ('Lot17', 'B3', NULL,                         'B3-B1-CAR-01',  'B1', 'Car',       0);

-- 9. SERVICE TARIFFS
INSERT INTO ServiceTariffs (Id, ServiceType, TierName, FromUnit, ToUnit, UnitPrice, VatRate, EffectiveDate) VALUES 
    ('ST1', 'Electricity',        N'Điện bậc 1 (0-50 kWh)',       0.00,  50.00, 1806.00,    8.00,  '2026-01-01'),
    ('ST2', 'Electricity',        N'Điện bậc 2 (51-100 kWh)',     50.01, 100.00, 1866.00,   8.00,  '2026-01-01'),
    ('ST3', 'Electricity',        N'Điện bậc 3 (101-200 kWh)',    100.01,200.00, 2167.00,   8.00,  '2026-01-01'),
    ('ST4', 'Water',              N'Nước sinh hoạt Bậc 1',        0.00,  10.00,  8500.00,   5.00,  '2026-01-01'),
    ('ST5', 'Water',              N'Nước sinh hoạt Bậc 2',        10.01, 20.00,  11500.00,  5.00,  '2026-01-01'),
    ('ST6', 'BuildingManagement', N'Phí quản lý Căn hộ (m2/tháng)', 0.00, NULL,   18000.00,  10.00, '2026-01-01'),
    ('ST7', 'ParkingFee',         N'Phí gửi Xe máy / tháng',      0.00,  NULL,   120000.00, 10.00, '2026-01-01'),
    ('ST8', 'ParkingFee',         N'Phí gửi Ô tô / tháng',        0.00,  NULL,   1500000.00,10.00, '2026-01-01'),
    ('ST9', 'ParkingFee',         N'Phí gửi Xe đạp điện / tháng', 0.00,  NULL,   80000.00,  10.00, '2026-01-01');

-- 10. UTILITY METERS
INSERT INTO UtilityMeters (Id, ApartmentId, MeterType, MeterSerialNumber, InstallationDate, IsActive) VALUES 
    ('Mtr1',  'B1-F01-01', 'Electricity', 'EM-RB0101-01', '2023-12-01', 1),
    ('Mtr2',  'B1-F01-01', 'Water',       'WM-RB0101-01', '2023-12-01', 1),
    ('Mtr3',  'B1-F01-02', 'Electricity', 'EM-RB0102-01', '2023-04-10', 1),
    ('Mtr4',  'B1-F01-02', 'Water',       'WM-RB0102-01', '2023-04-10', 1),
    ('Mtr5',  'B1-F02-01', 'Electricity', 'EM-RB0201-01', '2023-07-15', 1),
    ('Mtr6',  'B1-F02-01', 'Water',       'WM-RB0201-01', '2023-07-15', 1),
    ('Mtr7',  'B1-F02-02', 'Electricity', 'EM-RB0202-01', '2024-01-20', 1),
    ('Mtr8',  'B1-F02-02', 'Water',       'WM-RB0202-01', '2024-01-20', 1),
    ('Mtr9',  'B1-F02-03', 'Electricity', 'EM-RB0203-01', '2024-02-15', 1),
    ('Mtr10', 'B1-F02-03', 'Water',       'WM-RB0203-01', '2024-02-15', 1),
    ('Mtr11', 'B1-F03-01', 'Electricity', 'EM-RB0301-01', '2024-03-01', 1),
    ('Mtr12', 'B1-F03-01', 'Water',       'WM-RB0301-01', '2024-03-01', 1),
    ('Mtr13', 'B1-F03-02', 'Electricity', 'EM-RB0302-01', '2024-03-01', 1),
    ('Mtr14', 'B1-F03-02', 'Water',       'WM-RB0302-01', '2024-03-01', 1),
    ('Mtr15', 'B1-F04-01', 'Electricity', 'EM-RB0401-01', '2024-04-10', 1),
    ('Mtr16', 'B1-F04-01', 'Water',       'WM-RB0401-01', '2024-04-10', 1);

-- 11. UTILITY USAGES
INSERT INTO UtilityUsages (Id, MeterId, BillingMonth, BillingYear, PreviousReading, CurrentReading, CalculatedAmount, ProofImageUrl) VALUES 
    ('UU1',  'Mtr1',  8, 2026, 420.00,  690.00,  585000.00,  'https://storage.bms.vn/meters/m1_0826.jpg'),
    ('UU2',  'Mtr2',  8, 2026, 35.00,   52.00,   185000.00,  'https://storage.bms.vn/meters/m2_0826.jpg'),
    ('UU3',  'Mtr3',  8, 2026, 310.00,  530.00,  468000.00,  'https://storage.bms.vn/meters/m3_0826.jpg'),
    ('UU4',  'Mtr4',  8, 2026, 28.00,   44.00,   164000.00,  'https://storage.bms.vn/meters/m4_0826.jpg'),
    ('UU5',  'Mtr5',  8, 2026, 310.00,  520.00,  488000.00,  'https://storage.bms.vn/meters/m5_0826.jpg'),
    ('UU6',  'Mtr6',  8, 2026, 62.00,   78.00,   233000.00,  'https://storage.bms.vn/meters/m6_0826.jpg'),
    ('UU7',  'Mtr7',  8, 2026, 920.00,  1380.00, 1255340.00, 'https://storage.bms.vn/meters/m7_0826.jpg'),
    ('UU8',  'Mtr8',  8, 2026, 110.00,  142.00,  501000.00,  'https://storage.bms.vn/meters/m8_0826.jpg'),
    ('UU9',  'Mtr9',  8, 2026, 200.00,  350.00,  350000.00,  'https://storage.bms.vn/meters/m9_0826.jpg'),
    ('UU10', 'Mtr10', 8, 2026, 30.00,   45.00,   180000.00,  'https://storage.bms.vn/meters/m10_0826.jpg'),
    ('UU11', 'Mtr11', 8, 2026, 500.00,  780.00,  690000.00,  'https://storage.bms.vn/meters/m11_0826.jpg'),
    ('UU12', 'Mtr12', 8, 2026, 75.00,   98.00,   290000.00,  'https://storage.bms.vn/meters/m12_0826.jpg'),
    ('UU13', 'Mtr13', 8, 2026, 400.00,  620.00,  510000.00,  'https://storage.bms.vn/meters/m13_0826.jpg'),
    ('UU14', 'Mtr14', 8, 2026, 50.00,   72.00,   270000.00,  'https://storage.bms.vn/meters/m14_0826.jpg'),
    ('UU15', 'Mtr15', 8, 2026, 350.00,  580.00,  520000.00,  'https://storage.bms.vn/meters/m15_0826.jpg'),
    ('UU16', 'Mtr16', 8, 2026, 40.00,   62.00,   220000.00,  'https://storage.bms.vn/meters/m16_0826.jpg');

-- 12. AMENITIES
INSERT INTO Amenities (Id, Name, ImageUrl, MaxCapacity, OpenTime, CloseTime, SlotDurationMinutes, IsActive) VALUES 
    ('Amn1', N'Khu Vườn Nướng BBQ Tầng Thượng', 'https://storage.bms.vn/amenities/bbq.jpg',    20, '16:00:00', '22:00:00', 120, 1),
    ('Amn2', N'Sân Tennis Tiêu Chuẩn Quốc Tế',  'https://storage.bms.vn/amenities/tennis.jpg', 4,  '06:00:00', '22:00:00', 60,  1),
    ('Amn3', N'Hồ Bơi Vô Cực Khối Aqua',         'https://storage.bms.vn/amenities/pool.jpg',   50, '05:30:00', '21:00:00', 120, 1),
    ('Amn4', N'Phòng Tập Gym & Cardio',          'https://storage.bms.vn/amenities/gym.jpg',    30, '05:00:00', '22:30:00', 90,  1),
    ('Amn5', N'Phòng Sinh Hoạt Cộng Đồng',       'https://storage.bms.vn/amenities/hall.jpg',   60, '08:00:00', '21:00:00', 180, 1),
    ('Amn6', N'Phòng Tập Yoga & Thiền Định',     'https://storage.bms.vn/amenities/yoga.jpg',   15, '06:00:00', '20:00:00', 60,  1),
    ('Amn7', N'Sân Bóng Rổ Mini Ngoài Trời',     'https://storage.bms.vn/amenities/basket.jpg', 10, '07:00:00', '21:00:00', 60,  1),
    ('Amn8', N'Khu Vui Chơi Trẻ Em KidZone',     'https://storage.bms.vn/amenities/kid.jpg',    25, '08:00:00', '20:30:00', 120, 1);

-- 13. AMENITY BOOKINGS
INSERT INTO AmenityBookings (Id, AmenityId, ResidentId, ApartmentId, StartTime, EndTime, NumberOfGuests, Status) VALUES 
    ('AB1', 'Amn1', 'Res1',  'B1-F01-01', '2026-09-12 18:00:00', '2026-09-12 20:00:00', 10, 'Confirmed'),
    ('AB2', 'Amn2', 'Res2',  'B1-F01-02', '2026-09-13 07:00:00', '2026-09-13 08:00:00', 2,  'Confirmed'),
    ('AB3', 'Amn1', 'Res3',  'B1-F02-01', '2026-09-14 18:30:00', '2026-09-14 20:30:00', 12, 'Confirmed'),
    ('AB4', 'Amn5', 'Res4',  'B1-F02-02', '2026-09-15 14:00:00', '2026-09-15 17:00:00', 30, 'Confirmed'),
    ('AB5', 'Amn6', 'Res5',  'B1-F02-03', '2026-09-16 06:30:00', '2026-09-16 07:30:00', 5,  'Completed'),
    ('AB6', 'Amn7', 'Res6',  'B1-F03-01', '2026-09-17 17:30:00', '2026-09-17 18:30:00', 6,  'Confirmed'),
    ('AB7', 'Amn2', 'Res7',  'B1-F03-02', '2026-09-18 18:00:00', '2026-09-18 19:00:00', 4,  'Confirmed'),
    ('AB8', 'Amn5', 'Res8',  'B1-F04-01', '2026-09-20 09:00:00', '2026-09-20 12:00:00', 15, 'Cancelled'),
    ('AB9', 'Amn1', 'Res9',  'B1-F04-02', '2026-09-21 18:00:00', '2026-09-21 20:00:00', 8,  'Confirmed'),
    ('AB10','Amn2', 'Res10', 'B1-F05-01', '2026-09-22 06:00:00', '2026-09-22 07:00:00', 2,  'Confirmed');

-- 14. MONTHLY INVOICES
INSERT INTO MonthlyInvoices (Id, ApartmentId, InvoiceCode, BillingMonth, BillingYear, TotalAmount, PaidAmount, DueDate, GracePeriodUntil, Status, ReminderSent, ReminderDate) VALUES 
    ('Inv1',  'B1-F01-01', 'INV-202608-RB0101', 8, 2026, 4100000.00, 4100000.00, '2026-09-15', '2026-09-20', 'Paid',          1, '2026-09-12 08:00:00'),
    ('Inv2',  'B1-F01-02', 'INV-202608-RB0102', 8, 2026, 2282000.00, 2282000.00, '2026-09-15', '2026-09-20', 'Paid',          1, '2026-09-12 08:00:00'),
    ('Inv3',  'B1-F01-03', 'INV-202608-RB0103', 8, 2026, 1350000.00, 0.00,       '2026-09-15', '2026-09-20', 'Unpaid',        1, '2026-09-12 08:00:00'),
    ('Inv4',  'B1-F02-01', 'INV-202608-RB0201', 8, 2026, 3634000.00, 3634000.00, '2026-09-15', '2026-09-20', 'Paid',          1, '2026-09-12 08:00:00'),
    ('Inv5',  'B1-F02-02', 'INV-202608-RB0202', 8, 2026, 4866340.00, 2000000.00, '2026-09-15', '2026-09-20', 'PartiallyPaid', 1, '2026-09-12 08:00:00'),
    ('Inv6',  'B1-F02-03', 'INV-202608-RB0203', 8, 2026, 1874000.00, 0.00,       '2026-09-15', '2026-09-20', 'Unpaid',        1, '2026-09-12 08:00:00'),
    ('Inv7',  'B1-F03-01', 'INV-202608-RB0301', 8, 2026, 2756000.00, 0.00,       '2026-08-15', '2026-08-20', 'Overdue',       1, '2026-08-12 08:00:00'),
    ('Inv8',  'B1-F03-02', 'INV-202608-RB0302', 8, 2026, 4170000.00, 0.00,       '2026-08-15', '2026-08-20', 'Overdue',       1, '2026-08-12 08:00:00'),
    ('Inv9',  'B1-F04-01', 'INV-202608-RB0401', 8, 2026, 2300000.00, 2300000.00, '2026-09-15', '2026-09-20', 'Paid',          1, '2026-09-12 08:00:00'),
    ('Inv10', 'B1-F04-02', 'INV-202608-RB0402', 8, 2026, 2150000.00, 2150000.00, '2026-09-15', '2026-09-20', 'Paid',          1, '2026-09-12 08:00:00'),
    ('Inv11', 'B1-F04-03', 'INV-202608-RB0403', 8, 2026, 1710000.00, 0.00,       '2026-09-15', '2026-09-20', 'Unpaid',        0, NULL),
    ('Inv12', 'B1-F05-01', 'INV-202608-RB0501', 8, 2026, 2850000.00, 2850000.00, '2026-09-15', '2026-09-20', 'Paid',          1, '2026-09-12 08:00:00'),
    ('Inv13', 'B1-F05-02', 'INV-202608-RB0502', 8, 2026, 1996000.00, 0.00,       '2026-09-15', '2026-09-20', 'Unpaid',        0, NULL),
    ('Inv14', 'B1-F05-03', 'INV-202608-RB0503', 8, 2026, 3420000.00, 3420000.00, '2026-09-15', '2026-09-20', 'Paid',          1, '2026-09-12 08:00:00'),
    ('Inv15', 'B3-F01-01', 'INV-202608-EM0101', 8, 2026, 2184000.00, 0.00,       '2026-08-15', '2026-08-20', 'Overdue',       1, '2026-08-12 08:00:00'),
    ('Inv16', 'B3-F01-02', 'INV-202608-EM0102', 8, 2026, 1696000.00, 1696000.00, '2026-09-15', '2026-09-20', 'Paid',          1, '2026-09-12 08:00:00');

-- 15. INVOICE DETAILS
INSERT INTO InvoiceDetails (Id, InvoiceId, ItemType, Description, Quantity, UnitPrice, LineTotal) VALUES 
    ('ID1',  'Inv1', 'ManagementFee', N'Phí quản lý căn hộ (95 m2)',      95.00,  18000.00,  1710000.00),
    ('ID2',  'Inv1', 'Electricity',   N'Điện sinh hoạt (270 kWh)',        270.00, 2166.67,   585000.00),
    ('ID3',  'Inv1', 'Water',         N'Nước sinh hoạt (17 m3)',          17.00,  10882.35,  185000.00),
    ('ID4',  'Inv1', 'ParkingFee',    N'Phí giữ xe ô tô 51H-888.66',      1.00,   1500000.00,1500000.00),
    ('ID5',  'Inv1', 'ParkingFee',    N'Phí giữ xe máy 59E1-123.45',      1.00,   120000.00, 120000.00),
    ('ID6',  'Inv4', 'ManagementFee', N'Phí quản lý căn hộ (78.5 m2)',    78.50,  18000.00,  1413000.00),
    ('ID7',  'Inv4', 'Electricity',   N'Điện sinh hoạt (210 kWh)',        210.00, 2323.81,   488000.00),
    ('ID8',  'Inv4', 'Water',         N'Nước sinh hoạt (16 m3)',          16.00,  14562.50,  233000.00),
    ('ID9',  'Inv4', 'ParkingFee',    N'Phí đỗ ô tô 51K-123.99',          1.00,   1500000.00,1500000.00),
    ('ID10', 'Inv5', 'ParkingFee',    N'Phí đỗ ô tô 51G-777.88',          1.00,   1500000.00,1500000.00);

-- 16. PAYMENTS
INSERT INTO Payments (Id, InvoiceId, TransactionCode, PaymentMethod, Amount, ProofReceiptUrl, PaymentDate, Status, PayerNote) VALUES 
    ('Pay1',  'Inv1',  'TXN_VNPAY_082026_001', 'VNPay',        4100000.00, NULL,                                       '2026-09-02 08:30:15', 'Success', N'Nguyen Van An thanh toan phi thang 8'),
    ('Pay2',  'Inv2',  'TXN_MOMO_082026_002',  'MoMo',         2282000.00, NULL,                                       '2026-09-03 14:15:20', 'Success', N'Tran Thi Binh thanh toan can ho RB-0102'),
    ('Pay3',  'Inv4',  'TXN_BANK_082026_003',  'BankTransfer', 3634000.00, 'https://storage.bms.vn/receipts/rec01.jpg', '2026-09-04 10:05:00', 'Success', N'Le Hoang Cuong chuyen khoan Techcombank'),
    ('Pay4',  'Inv5',  'TXN_CASH_082026_004',  'Cash',         2000000.00, NULL,                                       '2026-09-05 16:45:10', 'Success', N'Pham Minh Dung dong truoc mot phan'),
    ('Pay5',  'Inv1',  'TXN_VNPAY_FAIL_005',   'VNPay',        4100000.00, NULL,                                       '2026-09-01 20:10:00', 'Failed',  N'Giao dich loi the het han muc'),
    ('Pay6',  'Inv3',  'TXN_VNPAY_PEND_006',   'VNPay',        1350000.00, NULL,                                       '2026-09-09 22:00:00', 'Pending', N'Dang cho cong thanh toan phan hoi'),
    ('Pay7',  'Inv9',  'TXN_BANK_082026_007',  'BankTransfer', 2300000.00, 'https://storage.bms.vn/receipts/rec02.jpg', '2026-09-06 09:12:33', 'Success', N'Bui Thi Mai thanh toan RB-0401'),
    ('Pay8',  'Inv10', 'TXN_MOMO_082026_008',  'MoMo',         2150000.00, NULL,                                       '2026-09-07 11:22:11', 'Success', N'Trinh Ba Phong thanh toan qua vi MoMo'),
    ('Pay9',  'Inv12', 'TXN_VNPAY_082026_009', 'VNPay',        2850000.00, NULL,                                       '2026-09-08 15:30:00', 'Success', N'Dinh Ngoc Anh thanh toan VNPAY'),
    ('Pay10', 'Inv14', 'TXN_BANK_082026_010',  'BankTransfer', 3420000.00, 'https://storage.bms.vn/receipts/rec03.jpg', '2026-09-08 17:00:00', 'Success', N'Ta Phuong Thao thanh toan chuyen khoan');

-- 17. LATE PAYMENT PENALTIES
INSERT INTO LatePaymentPenalties (Id, InvoiceId, OverdueDays, InterestRate, PenaltyAmount, Reason, IsResolved) VALUES 
    ('Pen1', 'Inv7',  26, 0.05, 35828.00, N'Quá hạn thanh toán 26 ngày kỳ 08/2026', 0),
    ('Pen2', 'Inv8',  26, 0.05, 54210.00, N'Quá hạn thanh toán 26 ngày kỳ 08/2026', 0),
    ('Pen3', 'Inv15', 26, 0.05, 28392.00, N'Quá hạn thanh toán 26 ngày kỳ 08/2026', 0),
    ('Pen4', 'Inv5',  10, 0.05, 14331.00, N'Chậm đóng số tiền nợ còn lại', 0),
    ('Pen5', 'Inv6',  3,  0.05, 2811.00,  N'Trễ hạn thanh toán định kỳ', 0),
    ('Pen6', 'Inv7',  15, 0.05, 20670.00, N'Phạt lũy kế kỳ trước', 1),
    ('Pen7', 'Inv8',  30, 0.05, 62550.00, N'Phạt nợ quá hạn 1 tháng', 1),
    ('Pen8', 'Inv1',  2,  0.05, 4100.00,  N'Chậm quyết toán ban đầu', 1);

-- 18. COMPLAINT REQUESTS
INSERT INTO ComplaintRequests (Id, ResidentId, ApartmentId, Category, Title, Content, AttachedImageUrl, ResolvedImageUrl, Status) VALUES 
    ('CR1',  'Res1',  'B1-F01-01', 'Sanitation',     N'Hành lang tầng 1 có rác chưa thu gom',    N'Khu vực trước cửa căn hộ còn tồn ứ thùng carton từ tối qua.',   'https://storage.bms.vn/complaints/cr1.jpg',  NULL,                                       'Pending'),
    ('CR2',  'Res2',  'B1-F01-02', 'Noise',          N'Tiếng ồn từ căn hộ tầng trên ban đêm',    N'Căn hộ tầng trên thường xuyên mở nhạc lớn sau 23h.',             NULL,                                         NULL,                                       'Processing'),
    ('CR3',  'Res3',  'B1-F02-01', 'FacilityDamage', N'Đèn chiếu sáng sảnh tầng 2 bị nhấp nháy', N'Bóng đèn LED sảnh Ruby tầng 2 bị chớp tắt liên tục.',          'https://storage.bms.vn/complaints/cr3.jpg',  NULL,                                       'Assigned'),
    ('CR4',  'Res4',  'B1-F02-02', 'Security',       N'Kiểm tra camera an ninh tầng hầm B1',     N'Cần trích xuất camera khu vực ô đỗ B1-CAR-03 từ 14h-16h.',       NULL,                                         'https://storage.bms.vn/complaints/res_cr4.jpg', 'Resolved'),
    ('CR5',  'Res5',  'B1-F02-03', 'Sanitation',     N'Mùi hôi bốc lên từ hố ga ngoài sân',      N'Hố ga khu vực sân chơi trẻ em bốc mùi cần xử lý nạo vét.',       'https://storage.bms.vn/complaints/cr5.jpg',  NULL,                                       'Pending'),
    ('CR6',  'Res6',  'B1-F03-01', 'FacilityDamage', N'Cửa chống cháy thoát hiểm tầng 3 bị kẹt', N'Tay nắm cửa chống cháy hướng đông khó mở khi thoát hiểm.',      NULL,                                         NULL,                                       'Assigned'),
    ('CR7',  'Res7',  'B1-F03-02', 'Noise',          N'Chó sủa gây ồn ào giờ nghỉ trưa',         N'Căn hộ bên cạnh nuôi thú cưng sủa lớn vào khoảng 12h-13h.',      NULL,                                         NULL,                                       'Closed'),
    ('CR8',  'Res8',  'B1-F04-01', 'Security',       N'Người lạ vào thang máy không quẹt thẻ',   N'Có người lạ đi nhờ cư dân lên các tầng trên không đăng ký.',     NULL,                                         'https://storage.bms.vn/complaints/res_cr8.jpg', 'Resolved'),
    ('CR9',  'Res9',  'B1-F04-02', 'FacilityDamage', N'Áp lực nước sinh hoạt quá yếu',          N'Vòi sen và bồn rửa tại căn hộ nước chảy rất chậm.',              NULL,                                         NULL,                                       'Pending'),
    ('CR10', 'Res10', 'B1-F05-01', 'Sanitation',     N'Khu tập kết rác tầng 5 bốc mùi',          N'Cần vệ sinh khử mùi phòng chứa rác tầng 5.',                     NULL,                                         NULL,                                       'Processing');

-- 19. ACCOUNTS
INSERT INTO Accounts (Id, ResidentId, Username, PasswordHash, Email, IsActive) VALUES 
    ('Acc1',  NULL,    'superadmin',     '$2a$11$Z8eEw.x7V0pP9Y0s8Z7aCe7.zX9Y0w1W2e3R4t5Y6u7I8o9P0a1B2', 'superadmin@smartbuilding.vn', 1),
    ('Acc2',  NULL,    'bql.manager01',  '$2a$11$Z8eEw.x7V0pP9Y0s8Z7aCe7.zX9Y0w1W2e3R4t5Y6u7I8o9P0a1B2', 'manager@smartbuilding.vn',      1),
    ('Acc3',  NULL,    'ketoan.trang',   '$2a$11$Z8eEw.x7V0pP9Y0s8Z7aCe7.zX9Y0w1W2e3R4t5Y6u7I8o9P0a1B2', 'trang.ketoan@smartbuilding.vn',1),
    ('Acc4',  NULL,    'kythuat.hung',   '$2a$11$Z8eEw.x7V0pP9Y0s8Z7aCe7.zX9Y0w1W2e3R4t5Y6u7I8o9P0a1B2', 'hung.kythuat@smartbuilding.vn', 1),
    ('Acc5',  NULL,    'anninh.tuan',    '$2a$11$Z8eEw.x7V0pP9Y0s8Z7aCe7.zX9Y0w1W2e3R4t5Y6u7I8o9P0a1B2', 'tuan.anninh@smartbuilding.vn',  1),
    ('Acc6',  NULL,    'letan.mai',      '$2a$11$Z8eEw.x7V0pP9Y0s8Z7aCe7.zX9Y0w1W2e3R4t5Y6u7I8o9P0a1B2', 'mai.letan@smartbuilding.vn',    1),
    ('Acc7',  NULL,    'vesinh.lan',     '$2a$11$Z8eEw.x7V0pP9Y0s8Z7aCe7.zX9Y0w1W2e3R4t5Y6u7I8o9P0a1B2', 'lan.vesinh@smartbuilding.vn',   1),
    ('Acc8',  'Res1',  'nguyenvanan',    '$2a$11$Z8eEw.x7V0pP9Y0s8Z7aCe7.zX9Y0w1W2e3R4t5Y6u7I8o9P0a1B2', 'an.nguyen@gmail.com',          1),
    ('Acc9',  'Res2',  'tranbinh88',     '$2a$11$Z8eEw.x7V0pP9Y0s8Z7aCe7.zX9Y0w1W2e3R4t5Y6u7I8o9P0a1B2', 'binh.tran@gmail.com',          1),
    ('Acc10', 'Res3',  'lehoangcuong',   '$2a$11$Z8eEw.x7V0pP9Y0s8Z7aCe7.zX9Y0w1W2e3R4t5Y6u7I8o9P0a1B2', 'cuong.le@outlook.com',         1),
    ('Acc11', 'Res4',  'dungpham90',     '$2a$11$Z8eEw.x7V0pP9Y0s8Z7aCe7.zX9Y0w1W2e3R4t5Y6u7I8o9P0a1B2', 'dung.pham@yahoo.com',          1),
    ('Acc12', 'Res5',  'hoangthutrang',  '$2a$11$Z8eEw.x7V0pP9Y0s8Z7aCe7.zX9Y0w1W2e3R4t5Y6u7I8o9P0a1B2', 'trang.hoang@gmail.com',        1),
    ('Acc13', 'Res6',  'doquocbao',      '$2a$11$Z8eEw.x7V0pP9Y0s8Z7aCe7.zX9Y0w1W2e3R4t5Y6u7I8o9P0a1B2', 'bao.do@fpt.edu.vn',           1),
    ('Acc14', 'Res7',  'vuquockhanh',    '$2a$11$Z8eEw.x7V0pP9Y0s8Z7aCe7.zX9Y0w1W2e3R4t5Y6u7I8o9P0a1B2', 'khanh.vu@techcorp.vn',         1),
    ('Acc15', 'Res8',  'buithimai',      '$2a$11$Z8eEw.x7V0pP9Y0s8Z7aCe7.zX9Y0w1W2e3R4t5Y6u7I8o9P0a1B2', 'mai.bui@gmail.com',            1);

-- 20. ROLES
INSERT INTO Roles (Id, RoleCode, RoleName, Description) VALUES 
    ('R1', 'SuperAdmin',      N'Quản trị viên cấp cao',  N'Toàn quyền cấu hình hệ thống, cơ sở dữ liệu và bảo mật'),
    ('R2', 'BuildingManager', N'Trưởng Ban Quản Lý',    N'Quản lý điều hành vận hành tòa nhà, duyệt đơn từ cư dân'),
    ('R3', 'Accountant',      N'Kế toán trưởng',         N'Quản lý hóa đơn, thu tiền, đối soát và tính phạt trễ hạn'),
    ('R4', 'Technician',      N'Kỹ sư vận hành',         N'Chốt chỉ số điện nước, xử lý khiếu nại hạ tầng kỹ thuật'),
    ('R5', 'SecurityChief',   N'Đội trưởng An ninh',     N'Quản lý bãi đỗ xe, thẻ từ RFID, tuần tra an ninh'),
    ('R6', 'FrontDesk',       N'Lễ tân tòa nhà',         N'Tiếp nhận cư dân, hỗ trợ đăng ký tạm trú, đặt tiện ích'),
    ('R7', 'SanitationLead',  N'Giám sát vệ sinh',       N'Điều phối nhân công dọn dẹp vệ sinh khuôn viên chung'),
    ('R8', 'Resident',        N'Cư dân chính thức',      N'Truy cập ứng dụng cư dân, thanh toán và gửi yêu cầu');

-- 21. USER ROLES
INSERT INTO UserRoles (AccountId, RoleId) VALUES 
    ('Acc1',  'R1'),
    ('Acc2',  'R2'),
    ('Acc3',  'R3'),
    ('Acc4',  'R4'),
    ('Acc5',  'R5'),
    ('Acc6',  'R6'),
    ('Acc7',  'R7'),
    ('Acc8',  'R8'),
    ('Acc9',  'R8'),
    ('Acc10', 'R8'),
    ('Acc11', 'R8'),
    ('Acc12', 'R8'),
    ('Acc13', 'R8'),
    ('Acc14', 'R8'),
    ('Acc15', 'R8');

-- 22. AUDIT TRAILS
INSERT INTO AuditTrails (Id, AccountId, ActionType, TableName, RecordId, OldValues, NewValues, IpAddress) VALUES 
    ('AT1', 'Acc1', 'INSERT', 'Buildings',       'B1',        NULL, JSON_OBJECT('BuildingCode', 'RUBY-01', 'Name', 'Ruby Suites'), '192.168.1.10'),
    ('AT2', 'Acc2', 'UPDATE', 'Apartments',      'B1-F01-03', JSON_OBJECT('Status', 'Occupied'), JSON_OBJECT('Status', 'Available'), '192.168.1.25'),
    ('AT3', 'Acc3', 'INSERT', 'MonthlyInvoices', 'Inv1',      NULL, JSON_OBJECT('InvoiceCode', 'INV-202608-RB0101', 'TotalAmount', 4100000), '192.168.1.30'),
    ('AT4', 'Acc4', 'INSERT', 'UtilityUsages',   'Mtr1',      NULL, JSON_OBJECT('Previous', 420, 'Current', 690, 'Consumption', 270), '10.0.4.15'),
    ('AT5', 'Acc8', 'LOGIN',  'Accounts',        'Acc8',      NULL, JSON_OBJECT('LoginStatus', 'Success', 'Device', 'Web Browser Chrome'), '118.69.182.45'),
    ('AT6', 'Acc9', 'INSERT', 'Payments',        'Inv2',      NULL, JSON_OBJECT('Method', 'MoMo', 'Amount', 2282000), '113.161.72.18'),
    ('AT7', 'Acc10','INSERT', 'ComplaintRequests','Res3',     NULL, JSON_OBJECT('Category', 'FacilityDamage', 'Title', 'Den chieu sang...'), '171.244.30.99'),
    ('AT8', 'Acc3', 'UPDATE', 'MonthlyInvoices', 'Inv4',      JSON_OBJECT('Status', 'Unpaid'), JSON_OBJECT('Status', 'Paid', 'PaidAmount', 3634000), '192.168.1.30');
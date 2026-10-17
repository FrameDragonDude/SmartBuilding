using MySqlConnector;

namespace SmartBuilding.Infrastructure.Data;

public static class DatabaseSeeder
{
    public static async Task EnsureAllBuildingsSeededAsync(string connectionString, CancellationToken cancellationToken = default)
    {
        try
        {
            await using var connection = new MySqlConnection(connectionString);
            await connection.OpenAsync(cancellationToken);

            // Check if apartments for B2 exist
            const string checkSql = "SELECT COUNT(*) FROM Apartments WHERE Id LIKE 'B2-%';";
            await using var checkCmd = new MySqlCommand(checkSql, connection);
            var count = Convert.ToInt64(await checkCmd.ExecuteScalarAsync(cancellationToken));

            if (count > 0)
            {
                // Already seeded
                return;
            }

            const string seedSql = """
                -- 1. FLOORS CHO CÁC TÒA B2 ĐẾN B8
                INSERT IGNORE INTO Floors (Id, BuildingId, FloorNumber, TotalApartments, Description) VALUES 
                    ('B2-F01', 'B2', 1, 3, 'Tòa Aqua - Tầng 1 (Khu căn hộ hướng hồ)'),
                    ('B2-F02', 'B2', 2, 3, 'Tòa Aqua - Tầng 2 (Khu căn hộ hướng sông)'),
                    ('B2-F03', 'B2', 3, 3, 'Tòa Aqua - Tầng 3 (Khu căn hộ view sông)'),
                    ('B2-F04', 'B2', 4, 3, 'Tòa Aqua - Tầng 4 (Khu căn hộ tiêu chuẩn)'),
                    ('B2-F05', 'B2', 5, 3, 'Tòa Aqua - Tầng 5 (Khu Penthouse Aqua)'),
                    ('B3-F01', 'B3', 1, 3, 'Tòa Emerald - Tầng 1 (Khu sân vườn công viên)'),
                    ('B3-F02', 'B3', 2, 3, 'Tòa Emerald - Tầng 2 (Khu căn hộ view công viên)'),
                    ('B3-F03', 'B3', 3, 3, 'Tòa Emerald - Tầng 3 (Khu căn hộ cao cấp)'),
                    ('B3-F04', 'B3', 4, 3, 'Tòa Emerald - Tầng 4 (Khu Penthouse Emerald)'),
                    ('B4-F01', 'B4', 1, 3, 'Tòa Diamond - Tầng 1 (Khu ban công lớn)'),
                    ('B4-F02', 'B4', 2, 3, 'Tòa Diamond - Tầng 2 (Khu căn hộ view quảng trường)'),
                    ('B4-F03', 'B4', 3, 3, 'Tòa Diamond - Tầng 3 (Khu căn hộ tiêu chuẩn)'),
                    ('B4-F04', 'B4', 4, 3, 'Tòa Diamond - Tầng 4 (Khu căn hộ cao cấp)'),
                    ('B4-F05', 'B4', 5, 3, 'Tòa Diamond - Tầng 5 (Khu Diamond Crown Suite)'),
                    ('B5-F01', 'B5', 1, 3, 'Tòa Sapphire - Tầng 1 (Khu tiêu chuẩn)'),
                    ('B5-F02', 'B5', 2, 3, 'Tòa Sapphire - Tầng 2 (Khu căn hộ Sky View)'),
                    ('B5-F03', 'B5', 3, 3, 'Tòa Sapphire - Tầng 3 (Khu căn hộ tiện ích)'),
                    ('B5-F04', 'B5', 4, 3, 'Tòa Sapphire - Tầng 4 (Khu Sapphire Premier)'),
                    ('B6-F01', 'B6', 1, 3, 'Tòa Topaz - Tầng 1 (Khu căn hộ sân vườn)'),
                    ('B6-F02', 'B6', 2, 3, 'Tòa Topaz - Tầng 2 (Khu căn hộ tiêu chuẩn)'),
                    ('B6-F03', 'B6', 3, 3, 'Tòa Topaz - Tầng 3 (Khu Topaz Residence)'),
                    ('B7-F01', 'B7', 1, 3, 'Tòa Opal - Tầng 1 (Khu Opal Garden tiêu chuẩn)'),
                    ('B7-F02', 'B7', 2, 3, 'Tòa Opal - Tầng 2 (Khu căn hộ view vườn hoa)'),
                    ('B7-F03', 'B7', 3, 3, 'Tòa Opal - Tầng 3 (Khu căn hộ tiện nghi)'),
                    ('B7-F04', 'B7', 4, 3, 'Tòa Opal - Tầng 4 (Khu Opal Panorama)'),
                    ('B8-F01', 'B8', 1, 3, 'Tòa Pearl - Tầng 1 (Khu căn hộ thương mại)'),
                    ('B8-F02', 'B8', 2, 3, 'Tòa Pearl - Tầng 2 (Khu Pearl Plaza Suite)'),
                    ('B8-F03', 'B8', 3, 3, 'Tòa Pearl - Tầng 3 (Khu căn hộ cao cấp)'),
                    ('B8-F04', 'B8', 4, 3, 'Tòa Pearl - Tầng 4 (Khu căn hộ tiêu chuẩn)'),
                    ('B8-F05', 'B8', 5, 3, 'Tòa Pearl - Tầng 5 (Khu Penthouse Pearl)');

                -- 2. APARTMENTS CHO B2 ĐẾN B8
                INSERT IGNORE INTO Apartments (Id, FloorId, ApartmentNumber, Area, RoomsCount, BathroomsCount, Status, Version) VALUES 
                    -- Tòa B2 (Aqua Premier - 15 căn)
                    ('B2-F01-01', 'B2-F01', 'AQ-0101', 92.00,  3, 2, 'Occupied', 1),
                    ('B2-F01-02', 'B2-F01', 'AQ-0102', 85.00,  2, 2, 'Occupied', 1),
                    ('B2-F01-03', 'B2-F01', 'AQ-0103', 75.00,  2, 1, 'Available', 1),
                    ('B2-F02-01', 'B2-F02', 'AQ-0201', 88.00,  3, 2, 'Occupied', 1),
                    ('B2-F02-02', 'B2-F02', 'AQ-0202', 78.00,  2, 2, 'Occupied', 1),
                    ('B2-F02-03', 'B2-F02', 'AQ-0203', 72.00,  2, 1, 'Occupied', 1),
                    ('B2-F03-01', 'B2-F03', 'AQ-0301', 95.00,  3, 2, 'Occupied', 1),
                    ('B2-F03-02', 'B2-F03', 'AQ-0302', 105.00, 3, 2, 'Occupied', 1),
                    ('B2-F03-03', 'B2-F03', 'AQ-0303', 80.00,  2, 1, 'Available', 1),
                    ('B2-F04-01', 'B2-F04', 'AQ-0401', 82.00,  2, 2, 'Occupied', 1),
                    ('B2-F04-02', 'B2-F04', 'AQ-0402', 90.00,  3, 2, 'Occupied', 1),
                    ('B2-F04-03', 'B2-F04', 'AQ-0403', 74.00,  2, 1, 'Occupied', 1),
                    ('B2-F05-01', 'B2-F05', 'AQ-0501', 115.00, 4, 3, 'Occupied', 1),
                    ('B2-F05-02', 'B2-F05', 'AQ-0502', 120.00, 4, 3, 'Occupied', 1),
                    ('B2-F05-03', 'B2-F05', 'AQ-0503', 98.00,  3, 2, 'Occupied', 1),

                    -- Tòa B3 (Emerald Park - bổ sung thêm 10 căn thành 12 căn)
                    ('B3-F01-03', 'B3-F01', 'EM-0103', 70.00,  2, 1, 'Available', 1),
                    ('B3-F02-01', 'B3-F02', 'EM-0201', 88.00,  3, 2, 'Occupied', 1),
                    ('B3-F02-02', 'B3-F02', 'EM-0202', 80.00,  2, 2, 'Occupied', 1),
                    ('B3-F02-03', 'B3-F02', 'EM-0203', 75.00,  2, 1, 'Occupied', 1),
                    ('B3-F03-01', 'B3-F03', 'EM-0301', 92.00,  3, 2, 'Occupied', 1),
                    ('B3-F03-02', 'B3-F03', 'EM-0302', 85.00,  2, 2, 'Occupied', 1),
                    ('B3-F03-03', 'B3-F03', 'EM-0303', 78.00,  2, 1, 'Available', 1),
                    ('B3-F04-01', 'B3-F04', 'EM-0401', 105.00, 3, 2, 'Occupied', 1),
                    ('B3-F04-02', 'B3-F04', 'EM-0402', 112.00, 4, 3, 'Occupied', 1),
                    ('B3-F04-03', 'B3-F04', 'EM-0403', 90.00,  3, 2, 'Occupied', 1),

                    -- Tòa B4 (Diamond Crown - 15 căn)
                    ('B4-F01-01', 'B4-F01', 'DM-0101', 95.00,  3, 2, 'Occupied', 1),
                    ('B4-F01-02', 'B4-F01', 'DM-0102', 85.00,  2, 2, 'Occupied', 1),
                    ('B4-F01-03', 'B4-F01', 'DM-0103', 75.00,  2, 1, 'Available', 1),
                    ('B4-F02-01', 'B4-F02', 'DM-0201', 90.00,  3, 2, 'Occupied', 1),
                    ('B4-F02-02', 'B4-F02', 'DM-0202', 82.00,  2, 2, 'Occupied', 1),
                    ('B4-F02-03', 'B4-F02', 'DM-0203', 72.00,  2, 1, 'Occupied', 1),
                    ('B4-F03-01', 'B4-F03', 'DM-0301', 98.00,  3, 2, 'Occupied', 1),
                    ('B4-F03-02', 'B4-F03', 'DM-0302', 110.00, 4, 3, 'Occupied', 1),
                    ('B4-F03-03', 'B4-F03', 'DM-0303', 85.00,  2, 2, 'Available', 1),
                    ('B4-F04-01', 'B4-F04', 'DM-0401', 88.00,  3, 2, 'Occupied', 1),
                    ('B4-F04-02', 'B4-F04', 'DM-0402', 92.00,  3, 2, 'Occupied', 1),
                    ('B4-F04-03', 'B4-F04', 'DM-0403', 76.00,  2, 1, 'Occupied', 1),
                    ('B4-F05-01', 'B4-F05', 'DM-0501', 130.00, 4, 3, 'Occupied', 1),
                    ('B4-F05-02', 'B4-F05', 'DM-0502', 145.00, 5, 4, 'Occupied', 1),
                    ('B4-F05-03', 'B4-F05', 'DM-0503', 105.00, 3, 2, 'Occupied', 1),

                    -- Tòa B5 (Sapphire Sky - 12 căn)
                    ('B5-F01-01', 'B5-F01', 'SP-0101', 90.00,  3, 2, 'Occupied', 1),
                    ('B5-F01-02', 'B5-F01', 'SP-0102', 80.00,  2, 2, 'Occupied', 1),
                    ('B5-F01-03', 'B5-F01', 'SP-0103', 72.00,  2, 1, 'Available', 1),
                    ('B5-F02-01', 'B5-F02', 'SP-0201', 86.00,  3, 2, 'Occupied', 1),
                    ('B5-F02-02', 'B5-F02', 'SP-0202', 78.00,  2, 2, 'Occupied', 1),
                    ('B5-F02-03', 'B5-F02', 'SP-0203', 70.00,  2, 1, 'Occupied', 1),
                    ('B5-F03-01', 'B5-F03', 'SP-0301', 94.00,  3, 2, 'Occupied', 1),
                    ('B5-F03-02', 'B5-F03', 'SP-0302', 102.00, 3, 2, 'Occupied', 1),
                    ('B5-F03-03', 'B5-F03', 'SP-0303', 82.00,  2, 1, 'Available', 1),
                    ('B5-F04-01', 'B5-F04', 'SP-0401', 115.00, 4, 3, 'Occupied', 1),
                    ('B5-F04-02', 'B5-F04', 'SP-0402', 120.00, 4, 3, 'Occupied', 1),
                    ('B5-F04-03', 'B5-F04', 'SP-0403', 95.00,  3, 2, 'Occupied', 1),

                    -- Tòa B6 (Topaz Residence - 9 căn)
                    ('B6-F01-01', 'B6-F01', 'TP-0101', 85.00,  2, 2, 'Occupied', 1),
                    ('B6-F01-02', 'B6-F01', 'TP-0102', 75.00,  2, 1, 'Occupied', 1),
                    ('B6-F01-03', 'B6-F01', 'TP-0103', 68.00,  2, 1, 'Available', 1),
                    ('B6-F02-01', 'B6-F02', 'TP-0201', 88.00,  3, 2, 'Occupied', 1),
                    ('B6-F02-02', 'B6-F02', 'TP-0202', 78.00,  2, 2, 'Occupied', 1),
                    ('B6-F02-03', 'B6-F02', 'TP-0203', 72.00,  2, 1, 'Occupied', 1),
                    ('B6-F03-01', 'B6-F03', 'TP-0301', 95.00,  3, 2, 'Occupied', 1),
                    ('B6-F03-02', 'B6-F03', 'TP-0302', 105.00, 3, 2, 'Occupied', 1),
                    ('B6-F03-03', 'B6-F03', 'TP-0303', 80.00,  2, 1, 'Available', 1),

                    -- Tòa B7 (Opal Garden - 12 căn)
                    ('B7-F01-01', 'B7-F01', 'OP-0101', 90.00,  3, 2, 'Occupied', 1),
                    ('B7-F01-02', 'B7-F01', 'OP-0102', 82.00,  2, 2, 'Occupied', 1),
                    ('B7-F01-03', 'B7-F01', 'OP-0103', 74.00,  2, 1, 'Available', 1),
                    ('B7-F02-01', 'B7-F02', 'OP-0201', 88.00,  3, 2, 'Occupied', 1),
                    ('B7-F02-02', 'B7-F02', 'OP-0202', 80.00,  2, 2, 'Occupied', 1),
                    ('B7-F02-03', 'B7-F02', 'OP-0203', 72.00,  2, 1, 'Occupied', 1),
                    ('B7-F03-01', 'B7-F03', 'OP-0301', 92.00,  3, 2, 'Occupied', 1),
                    ('B7-F03-02', 'B7-F03', 'OP-0302', 100.00, 3, 2, 'Occupied', 1),
                    ('B7-F03-03', 'B7-F03', 'OP-0303', 85.00,  2, 2, 'Available', 1),
                    ('B7-F04-01', 'B7-F04', 'OP-0401', 110.00, 4, 3, 'Occupied', 1),
                    ('B7-F04-02', 'B7-F04', 'OP-0402', 115.00, 4, 3, 'Occupied', 1),
                    ('B7-F04-03', 'B7-F04', 'OP-0403', 95.00,  3, 2, 'Occupied', 1),

                    -- Tòa B8 (Pearl Plaza - 15 căn)
                    ('B8-F01-01', 'B8-F01', 'PL-0101', 95.00,  3, 2, 'Occupied', 1),
                    ('B8-F01-02', 'B8-F01', 'PL-0102', 85.00,  2, 2, 'Occupied', 1),
                    ('B8-F01-03', 'B8-F01', 'PL-0103', 75.00,  2, 1, 'Available', 1),
                    ('B8-F02-01', 'B8-F02', 'PL-0201', 90.00,  3, 2, 'Occupied', 1),
                    ('B8-F02-02', 'B8-F02', 'PL-0202', 80.00,  2, 2, 'Occupied', 1),
                    ('B8-F02-03', 'B8-F02', 'PL-0203', 72.00,  2, 1, 'Occupied', 1),
                    ('B8-F03-01', 'B8-F03', 'PL-0301', 98.00,  3, 2, 'Occupied', 1),
                    ('B8-F03-02', 'B8-F03', 'PL-0302', 108.00, 4, 3, 'Occupied', 1),
                    ('B8-F03-03', 'B8-F03', 'PL-0303', 82.00,  2, 1, 'Available', 1),
                    ('B8-F04-01', 'B8-F04', 'PL-0401', 88.00,  3, 2, 'Occupied', 1),
                    ('B8-F04-02', 'B8-F04', 'PL-0402', 92.00,  3, 2, 'Occupied', 1),
                    ('B8-F04-03', 'B8-F04', 'PL-0403', 76.00,  2, 1, 'Occupied', 1),
                    ('B8-F05-01', 'B8-F05', 'PL-0501', 125.00, 4, 3, 'Occupied', 1),
                    ('B8-F05-02', 'B8-F05', 'PL-0502', 135.00, 5, 4, 'Occupied', 1),
                    ('B8-F05-03', 'B8-F05', 'PL-0503', 100.00, 3, 2, 'Occupied', 1);

                -- 3. RESIDENTS CHO CÁC TÒA KHÁC
                INSERT IGNORE INTO Residents (Id, FullName, IdentityCardNumber, PhoneNumber, Email, DateOfBirth, Gender, AvatarUrl) VALUES 
                    ('Res20', 'Trần Minh Hoàng',   '079092008811', '0908112233', 'hoang.tran@gmail.com',   '1987-04-12', 'Nam', 'https://storage.bms.vn/avatars/res20.jpg'),
                    ('Res21', 'Nguyễn Thúy Nga',   '079194009922', '0919223344', 'nga.nguyen@gmail.com',   '1991-09-25', 'Nữ',  'https://storage.bms.vn/avatars/res21.jpg'),
                    ('Res22', 'Lê Anh Tuấn',       '079085001133', '0928334455', 'tuan.le@fpt.vn',         '1984-12-05', 'Nam', 'https://storage.bms.vn/avatars/res22.jpg'),
                    ('Res23', 'Phạm Quỳnh Chi',    '079196002244', '0937445566', 'chi.pham@yahoo.com',     '1993-07-18', 'Nữ',  'https://storage.bms.vn/avatars/res23.jpg'),
                    ('Res24', 'Đặng Quốc Huy',     '079089003355', '0946556677', 'huy.dang@gmail.com',     '1989-11-20', 'Nam', 'https://storage.bms.vn/avatars/res24.jpg'),
                    ('Res25', 'Vũ Mai Hương',      '079192004466', '0955667788', 'huong.vu@gmail.com',     '1996-03-14', 'Nữ',  'https://storage.bms.vn/avatars/res25.jpg'),
                    ('Res26', 'Hoàng Gia Bảo',     '079098005577', '0964778899', 'bao.hoang@tech.vn',      '1990-08-30', 'Nam', 'https://storage.bms.vn/avatars/res26.jpg'),
                    ('Res27', 'Bùi Kim Ngân',      '079195006688', '0973889900', 'ngan.bui@gmail.com',     '1994-01-22', 'Nữ',  'https://storage.bms.vn/avatars/res27.jpg'),
                    ('Res28', 'Dương Thế Vinh',    '079087007799', '0982990011', 'vinh.duong@gmail.com',    '1985-06-16', 'Nam', 'https://storage.bms.vn/avatars/res28.jpg'),
                    ('Res29', 'Ngô Diễm My',       '079193008800', '0991001122', 'my.ngo@gmail.com',       '1995-10-08', 'Nữ',  'https://storage.bms.vn/avatars/res29.jpg'),
                    ('Res30', 'Lý Tấn Phát',       '079096009911', '0902113355', 'phat.ly@gmail.com',      '1988-02-17', 'Nam', 'https://storage.bms.vn/avatars/res30.jpg'),
                    ('Res31', 'Đỗ Lan Anh',        '079197001122', '0913224466', 'lananh.do@gmail.com',    '1992-05-29', 'Nữ',  'https://storage.bms.vn/avatars/res31.jpg'),
                    ('Res32', 'Chu Đình Trọng',    '079084002233', '0924335577', 'trong.chu@gmail.com',    '1983-10-10', 'Nam', 'https://storage.bms.vn/avatars/res32.jpg'),
                    ('Res33', 'Mai Phương Thảo',   '079191003344', '0935446688', 'thao.mai@gmail.com',     '1997-12-03', 'Nữ',  'https://storage.bms.vn/avatars/res33.jpg');

                -- 4. APARTMENT HISTORIES (HỢP ĐỒNG)
                INSERT IGNORE INTO ApartmentHistories (Id, ApartmentId, ResidentId, ContractType, StartDate, EndDate, ContractFileUrl, IsCurrent) VALUES 
                    ('AH-B2-01', 'B2-F01-01', 'Res20', 'Owner',  '2024-01-01', NULL, 'https://storage.bms.vn/contracts/b2_01.pdf', 1),
                    ('AH-B2-02', 'B2-F01-02', 'Res21', 'Tenant', '2024-03-01', '2026-03-01', 'https://storage.bms.vn/contracts/b2_02.pdf', 1),
                    ('AH-B2-04', 'B2-F02-01', 'Res22', 'Owner',  '2023-09-15', NULL, 'https://storage.bms.vn/contracts/b2_03.pdf', 1),
                    ('AH-B3-01', 'B3-F02-01', 'Res23', 'Tenant', '2024-06-01', '2026-06-01', 'https://storage.bms.vn/contracts/b3_01.pdf', 1),
                    ('AH-B3-02', 'B3-F02-02', 'Res24', 'Owner',  '2023-11-20', NULL, 'https://storage.bms.vn/contracts/b3_02.pdf', 1),
                    ('AH-B4-01', 'B4-F01-01', 'Res25', 'Owner',  '2024-02-10', NULL, 'https://storage.bms.vn/contracts/b4_01.pdf', 1),
                    ('AH-B4-02', 'B4-F01-02', 'Res26', 'Tenant', '2024-05-15', '2026-05-15', 'https://storage.bms.vn/contracts/b4_02.pdf', 1),
                    ('AH-B5-01', 'B5-F01-01', 'Res27', 'Owner',  '2023-10-05', NULL, 'https://storage.bms.vn/contracts/b5_01.pdf', 1),
                    ('AH-B5-02', 'B5-F01-02', 'Res28', 'Tenant', '2024-04-01', '2026-04-01', 'https://storage.bms.vn/contracts/b5_02.pdf', 1),
                    ('AH-B6-01', 'B6-F01-01', 'Res29', 'Owner',  '2024-01-15', NULL, 'https://storage.bms.vn/contracts/b6_01.pdf', 1),
                    ('AH-B6-02', 'B6-F01-02', 'Res30', 'Tenant', '2024-07-01', '2026-07-01', 'https://storage.bms.vn/contracts/b6_02.pdf', 1),
                    ('AH-B7-01', 'B7-F01-01', 'Res31', 'Owner',  '2023-12-01', NULL, 'https://storage.bms.vn/contracts/b7_01.pdf', 1),
                    ('AH-B7-02', 'B7-F01-02', 'Res32', 'Tenant', '2024-08-10', '2026-08-10', 'https://storage.bms.vn/contracts/b7_02.pdf', 1),
                    ('AH-B8-01', 'B8-F01-01', 'Res33', 'Owner',  '2024-03-20', NULL, 'https://storage.bms.vn/contracts/b8_01.pdf', 1);

                -- 5. VEHICLES CHO CÁC TÒA KHÁC
                INSERT IGNORE INTO Vehicles (Id, ResidentId, ApartmentId, VehicleType, LicensePlate, RfidCardCode, Brand, RegistrationPaperUrl, VehicleImageUrl, IsActive) VALUES 
                    ('OT-079092008811-51H99881', 'Res20', 'B2-F01-01', 'Car',       '51H-998.81', 'RFID-CAR-B201', 'Audi A4',         'https://storage.bms.vn/cavet/ot_b201.jpg', 'https://storage.bms.vn/vehicles/ot_b201.jpg', 1),
                    ('XM-079194009922-59K12233', 'Res21', 'B2-F01-02', 'Motorbike', '59K1-223.34', 'RFID-MB-B202',  'Honda Lead',      'https://storage.bms.vn/cavet/xm_b202.jpg', 'https://storage.bms.vn/vehicles/xm_b202.jpg', 1),
                    ('OT-079085001133-51A33445', 'Res22', 'B2-F02-01', 'Car',       '51A-334.45', 'RFID-CAR-B203', 'BMW X3',          'https://storage.bms.vn/cavet/ot_b203.jpg', 'https://storage.bms.vn/vehicles/ot_b203.jpg', 1),
                    ('XM-079196002244-59T55667', 'Res23', 'B3-F02-01', 'Motorbike', '59T1-556.67', 'RFID-MB-B301',  'Yamaha Grande',   'https://storage.bms.vn/cavet/xm_b301.jpg', 'https://storage.bms.vn/vehicles/xm_b301.jpg', 1),
                    ('OT-079089003355-51K77889', 'Res24', 'B3-F02-02', 'Car',       '51K-778.89', 'RFID-CAR-B302', 'Hyundai SantaFe', 'https://storage.bms.vn/cavet/ot_b302.jpg', 'https://storage.bms.vn/vehicles/ot_b302.jpg', 1),
                    ('OT-079098005577-51L11223', 'Res26', 'B4-F01-02', 'Car',       '51L-112.23', 'RFID-CAR-B401', 'Porsche Macan',   'https://storage.bms.vn/cavet/ot_b401.jpg', 'https://storage.bms.vn/vehicles/ot_b401.jpg', 1),
                    ('XM-079192004466-59X44556', 'Res25', 'B4-F01-01', 'Motorbike', '59X2-445.56', 'RFID-MB-B402',  'Honda SH 350i',   'https://storage.bms.vn/cavet/xm_b402.jpg', 'https://storage.bms.vn/vehicles/xm_b402.jpg', 1),
                    ('OT-079087007799-51E99001', 'Res28', 'B5-F01-02', 'Car',       '51E-990.01', 'RFID-CAR-B501', 'VinFast VF9',     'https://storage.bms.vn/cavet/ot_b501.jpg', 'https://storage.bms.vn/vehicles/ot_b501.jpg', 1),
                    ('XM-079096009911-59B77889', 'Res30', 'B6-F01-02', 'Motorbike', '59B3-778.89', 'RFID-MB-B601',  'Honda AirBlade',  'https://storage.bms.vn/cavet/xm_b601.jpg', 'https://storage.bms.vn/vehicles/xm_b601.jpg', 1),
                    ('OT-079084002233-51G66778', 'Res32', 'B7-F01-02', 'Car',       '51G-667.78', 'RFID-CAR-B701', 'Mazda 3',         'https://storage.bms.vn/cavet/ot_b701.jpg', 'https://storage.bms.vn/vehicles/ot_b701.jpg', 1),
                    ('OT-079191003344-51K88990', 'Res33', 'B8-F01-01', 'Car',       '51K-889.90', 'RFID-CAR-B801', 'Lexus RX350',     'https://storage.bms.vn/cavet/ot_b801.jpg', 'https://storage.bms.vn/vehicles/ot_b801.jpg', 1);

                -- 6. PARKING SLOTS CHO CÁC TÒA KHÁC
                INSERT IGNORE INTO ParkingSlots (Id, BuildingId, VehicleId, SlotCode, BasementLevel, SlotType, IsOccupied) VALUES 
                    -- Tòa B2 (Aqua Premier)
                    ('Lot-B2-01', 'B2', 'OT-079092008811-51H99881', 'B2-B1-CAR-01',  'B1', 'Car',       1),
                    ('Lot-B2-02', 'B2', 'XM-079194009922-59K12233', 'B2-B1-MOTO-01', 'B1', 'Motorbike', 1),
                    ('Lot-B2-03', 'B2', 'OT-079085001133-51A33445', 'B2-B2-CAR-01',  'B2', 'Car',       1),
                    ('Lot-B2-04', 'B2', NULL,                        'B2-B1-MOTO-02', 'B1', 'Motorbike', 0),
                    ('Lot-B2-05', 'B2', NULL,                        'B2-B2-CAR-02',  'B2', 'Car',       0),

                    -- Tòa B4 (Diamond Crown)
                    ('Lot-B4-01', 'B4', 'OT-079098005577-51L11223', 'B4-B1-CAR-01',  'B1', 'Car',       1),
                    ('Lot-B4-02', 'B4', 'XM-079192004466-59X44556', 'B4-B1-MOTO-01', 'B1', 'Motorbike', 1),
                    ('Lot-B4-03', 'B4', NULL,                        'B4-B2-CAR-01',  'B2', 'Car',       0),
                    ('Lot-B4-04', 'B4', NULL,                        'B4-B1-MOTO-02', 'B1', 'Motorbike', 0),

                    -- Tòa B5 (Sapphire Sky)
                    ('Lot-B5-01', 'B5', 'OT-079087007799-51E99001', 'B5-B1-CAR-01',  'B1', 'Car',       1),
                    ('Lot-B5-02', 'B5', NULL,                        'B5-B1-MOTO-01', 'B1', 'Motorbike', 0),
                    ('Lot-B5-03', 'B5', NULL,                        'B5-B2-CAR-01',  'B2', 'Car',       0),

                    -- Tòa B6 (Topaz Residence)
                    ('Lot-B6-01', 'B6', 'XM-079096009911-59B77889', 'B6-B1-MOTO-01', 'B1', 'Motorbike', 1),
                    ('Lot-B6-02', 'B6', NULL,                        'B6-B1-CAR-01',  'B1', 'Car',       0),

                    -- Tòa B7 (Opal Garden)
                    ('Lot-B7-01', 'B7', 'OT-079084002233-51G66778', 'B7-B1-CAR-01',  'B1', 'Car',       1),
                    ('Lot-B7-02', 'B7', NULL,                        'B7-B1-MOTO-01', 'B1', 'Motorbike', 0),

                    -- Tòa B8 (Pearl Plaza)
                    ('Lot-B8-01', 'B8', 'OT-079191003344-51K88990', 'B8-B1-CAR-01',  'B1', 'Car',       1),
                    ('Lot-B8-02', 'B8', NULL,                        'B8-B1-MOTO-01', 'B1', 'Motorbike', 0),
                    ('Lot-B8-03', 'B8', NULL,                        'B8-B2-CAR-01',  'B2', 'Car',       0);
                """;

            await using var seedCmd = new MySqlCommand(seedSql, connection);
            await seedCmd.ExecuteNonQueryAsync(cancellationToken);
        }
        catch
        {
            // Seed failure should not crash app startup
        }
    }
}

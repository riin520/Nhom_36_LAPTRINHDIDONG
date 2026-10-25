CREATE TABLE chi_nhanh (
    id SERIAL PRIMARY KEY,
    ten VARCHAR(100) NOT NULL,
    dia_chi VARCHAR(255) NOT NULL,
    phuong_xa VARCHAR(100),
    sdt VARCHAR(20),
    gio_mo TIME,
    gio_dong TIME
);

CREATE TABLE nguoi_dung (
    id SERIAL PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    mat_khau_hash VARCHAR(255) NOT NULL,
    ho_ten VARCHAR(100) NOT NULL,
    sdt VARCHAR(20),
    vai_tro VARCHAR(20) NOT NULL CHECK (vai_tro IN ('CHU_CHUOI', 'QUAN_LY', 'KHACH')),
    chi_nhanh_id INT REFERENCES chi_nhanh(id) ON DELETE SET NULL, -- KHACH và CHU_CHUOI để trống cột này
    diem_tich_luy INT DEFAULT 0
);

CREATE TABLE nhom_mon (
    id SERIAL PRIMARY KEY,
    ten VARCHAR(100) NOT NULL,
    mo_ta TEXT
);

CREATE TABLE mon (
    id SERIAL PRIMARY KEY,
    nhom_id INT REFERENCES nhom_mon(id) ON DELETE SET NULL,
    ten VARCHAR(100) NOT NULL,
    mo_ta TEXT,
    anh_url TEXT,
    gia_goc INT NOT NULL,
    dang_ban BOOLEAN DEFAULT TRUE
);

CREATE TABLE mon_chi_nhanh (
    mon_id INT REFERENCES mon(id) ON DELETE CASCADE,
    chi_nhanh_id INT REFERENCES chi_nhanh(id) ON DELETE CASCADE,
    gia INT NOT NULL,
    con_hang BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (mon_id, chi_nhanh_id)
);

CREATE TABLE tuy_chon (
    id SERIAL PRIMARY KEY,
    ten VARCHAR(100) NOT NULL,
    loai VARCHAR(20) NOT NULL CHECK (loai IN ('SIZE', 'DA', 'DUONG', 'TOPPING')),
    phu_thu INT DEFAULT 0
);

CREATE TABLE ban (
    id SERIAL PRIMARY KEY,
    chi_nhanh_id INT REFERENCES chi_nhanh(id) ON DELETE CASCADE,
    so_ban INT NOT NULL,
    ma_qr VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE ma_giam_gia (
    id SERIAL PRIMARY KEY,
    ma VARCHAR(50) UNIQUE NOT NULL,
    loai VARCHAR(20) CHECK (loai IN ('PHAN_TRAM', 'TIEN_MAT')),
    gia_tri INT NOT NULL,
    han_dung TIMESTAMP,
    so_luot_toi_da INT,
    da_dung INT DEFAULT 0
);

CREATE TABLE don_hang (
    id SERIAL PRIMARY KEY,
    chi_nhanh_id INT REFERENCES chi_nhanh(id),
    ban_id INT REFERENCES ban(id) ON DELETE SET NULL, -- Cho phép NULL nếu khách đặt mua mang đi (Takeaway)
    khach_id INT REFERENCES nguoi_dung(id) ON DELETE SET NULL,
    trang_thai VARCHAR(50) DEFAULT 'CHO_PHA' CHECK (trang_thai IN ('CHO_PHA', 'DANG_PHA', 'HOAN_TAT', 'HUY')),
    tong_tien INT NOT NULL DEFAULT 0,
    ma_giam_gia VARCHAR(50) REFERENCES ma_giam_gia(ma) ON DELETE SET NULL,
    tao_luc TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE chi_tiet_don (
    id SERIAL PRIMARY KEY,
    don_hang_id INT REFERENCES don_hang(id) ON DELETE CASCADE,
    mon_id INT REFERENCES mon(id),
    so_luong INT NOT NULL DEFAULT 1,
    gia_mon INT NOT NULL, -- CỰC KỲ QUAN TRỌNG: Lưu cứng giá món tại thời điểm bấm đặt hàng
    ghi_chu TEXT
);

CREATE TABLE chi_tiet_don_tuy_chon (
    chi_tiet_don_id INT REFERENCES chi_tiet_don(id) ON DELETE CASCADE,
    tuy_chon_id INT REFERENCES tuy_chon(id),
    gia_phu_thu INT DEFAULT 0, -- Lưu cứng giá topping thời điểm mua
    PRIMARY KEY (chi_tiet_don_id, tuy_chon_id)
);

CREATE TABLE ca_lam (
    id SERIAL PRIMARY KEY,
    chi_nhanh_id INT REFERENCES chi_nhanh(id) ON DELETE CASCADE,
    nhan_vien_id INT REFERENCES nguoi_dung(id), 
    mo_luc TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    dong_luc TIMESTAMP,
    tien_dau_ca INT DEFAULT 0,
    tien_mat INT DEFAULT 0,
    chuyen_khoan INT DEFAULT 0
);
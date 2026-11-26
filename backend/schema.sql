-- ============================================================================
-- INT4211 - Hệ thống quản lý chuỗi quán cà phê - trà sữa
-- PostgreSQL 15 (Supabase) · Nhóm 36
--
-- QUY ƯỚC:
--   * Mọi cột tiền là BIGINT, đơn vị ĐỒNG. Không dùng FLOAT/NUMERIC có phần lẻ.
--   * Mọi mốc thời gian là TIMESTAMPTZ (lưu UTC, hiển thị theo Asia/Ho_Chi_Minh).
--   * Tên bảng/cột tiếng Việt không dấu, snake_case.
--   * Cột trạng thái dùng CHECK constraint (không dùng ENUM) để dễ thêm giá trị
--     mà không phải ALTER TYPE.
--
-- CÁCH CHẠY: Supabase > SQL Editor > dán toàn bộ file > Run.
-- ============================================================================


-- ============================================================================
-- 0. RESET (chỉ dùng khi làm mới CSDL — XOÁ SẠCH DỮ LIỆU)
-- ============================================================================
DROP TABLE IF EXISTS don_hang_log        CASCADE;
DROP TABLE IF EXISTS lich_su_diem        CASCADE;
DROP TABLE IF EXISTS danh_gia            CASCADE;
DROP TABLE IF EXISTS chi_tiet_don_tuy_chon CASCADE;
DROP TABLE IF EXISTS chi_tiet_don        CASCADE;
DROP TABLE IF EXISTS don_hang            CASCADE;
DROP TABLE IF EXISTS ma_giam_gia         CASCADE;
DROP TABLE IF EXISTS ca_lam              CASCADE;
DROP TABLE IF EXISTS ban                 CASCADE;
DROP TABLE IF EXISTS mon_topping         CASCADE;
DROP TABLE IF EXISTS topping             CASCADE;
DROP TABLE IF EXISTS mon_tuy_chon        CASCADE;
DROP TABLE IF EXISTS tuy_chon            CASCADE;
DROP TABLE IF EXISTS nhom_tuy_chon       CASCADE;
DROP TABLE IF EXISTS mon_chi_nhanh       CASCADE;
DROP TABLE IF EXISTS mon                 CASCADE;
DROP TABLE IF EXISTS nhom_mon            CASCADE;
DROP TABLE IF EXISTS nguoi_dung          CASCADE;
DROP TABLE IF EXISTS chi_nhanh           CASCADE;
DROP SEQUENCE IF EXISTS seq_ma_don;

CREATE EXTENSION IF NOT EXISTS pgcrypto;   -- dùng gen_random_bytes() cho mã QR


-- ============================================================================
-- 1. CHI_NHANH — 3 đến 10 cửa hàng trong chuỗi
-- ============================================================================
CREATE TABLE chi_nhanh (
    id             BIGSERIAL      PRIMARY KEY,
    ten            VARCHAR(100)   NOT NULL,
    dia_chi        VARCHAR(255)   NOT NULL,
    quan           VARCHAR(50)    NOT NULL,
    sdt            VARCHAR(15),
    gio_mo         TIME           NOT NULL DEFAULT '07:00',
    gio_dong       TIME           NOT NULL DEFAULT '22:00',
    dang_hoat_dong BOOLEAN        NOT NULL DEFAULT TRUE,
    tao_luc        TIMESTAMPTZ    NOT NULL DEFAULT now(),

    CONSTRAINT ck_chi_nhanh_gio   CHECK (gio_dong > gio_mo),
    CONSTRAINT ck_chi_nhanh_sdt   CHECK (sdt IS NULL OR sdt ~ '^0[0-9]{9,10}$'),
    CONSTRAINT uq_chi_nhanh_ten   UNIQUE (ten)
);

COMMENT ON TABLE chi_nhanh IS 'Chi nhánh trong chuỗi. Chủ chuỗi xem tất cả, quản lý ca chỉ thấy chi nhánh mình.';


-- ============================================================================
-- 2. NGUOI_DUNG — 3 vai trò: CHU_CHUOI / QUAN_LY / KHACH
-- ============================================================================
CREATE TABLE nguoi_dung (
    id             BIGSERIAL      PRIMARY KEY,
    ho_ten         VARCHAR(100)   NOT NULL,
    sdt            VARCHAR(15)    NOT NULL,          -- dùng làm tên đăng nhập
    email          VARCHAR(120),
    mat_khau_hash  VARCHAR(72)    NOT NULL,          -- bcrypt (60 ký tự), KHÔNG lưu mật khẩu thô
    vai_tro        VARCHAR(20)    NOT NULL,
    chi_nhanh_id   BIGINT,
    diem_tich_luy  INTEGER        NOT NULL DEFAULT 0,
    bi_khoa        BOOLEAN        NOT NULL DEFAULT FALSE,
    tao_luc        TIMESTAMPTZ    NOT NULL DEFAULT now(),

    CONSTRAINT fk_nguoi_dung_chi_nhanh
        FOREIGN KEY (chi_nhanh_id) REFERENCES chi_nhanh(id) ON DELETE RESTRICT,

    CONSTRAINT ck_nguoi_dung_vai_tro
        CHECK (vai_tro IN ('CHU_CHUOI', 'QUAN_LY', 'KHACH')),
    -- QUAN_LY bắt buộc gắn 1 chi nhánh
    CONSTRAINT ck_nguoi_dung_quan_ly_co_chi_nhanh
        CHECK (vai_tro <> 'QUAN_LY' OR chi_nhanh_id IS NOT NULL),
    -- CHU_CHUOI và KHACH không gắn chi nhánh
    CONSTRAINT ck_nguoi_dung_khong_gan_chi_nhanh
        CHECK (vai_tro NOT IN ('CHU_CHUOI', 'KHACH') OR chi_nhanh_id IS NULL),
    CONSTRAINT ck_nguoi_dung_sdt
        CHECK (sdt ~ '^0[0-9]{9,10}$'),
    CONSTRAINT ck_nguoi_dung_diem
        CHECK (diem_tich_luy >= 0),
    CONSTRAINT uq_nguoi_dung_sdt   UNIQUE (sdt),
    CONSTRAINT uq_nguoi_dung_email UNIQUE (email)
);

CREATE INDEX idx_nguoi_dung_chi_nhanh ON nguoi_dung (chi_nhanh_id);
CREATE INDEX idx_nguoi_dung_vai_tro   ON nguoi_dung (vai_tro) WHERE bi_khoa = FALSE;

COMMENT ON TABLE nguoi_dung IS 'Tài khoản nhân viên và khách hàng. vai_tro quyết định phạm vi dữ liệu được phép đọc/ghi.';


-- ============================================================================
-- 3. NHOM_MON — nhóm thực đơn (Cà phê, Trà sữa, Đá xay, Bánh...)
-- ============================================================================
CREATE TABLE nhom_mon (
    id        BIGSERIAL     PRIMARY KEY,
    ten       VARCHAR(60)   NOT NULL,
    thu_tu    SMALLINT      NOT NULL DEFAULT 0,
    dang_hien BOOLEAN       NOT NULL DEFAULT TRUE,

    CONSTRAINT uq_nhom_mon_ten UNIQUE (ten)
);

COMMENT ON TABLE nhom_mon IS 'Nhóm món dùng để phân nhóm thực đơn trong app khách.';


-- ============================================================================
-- 4. MON — món gốc của toàn chuỗi (giá nằm ở bảng mon_chi_nhanh)
-- ============================================================================
CREATE TABLE mon (
    id          BIGSERIAL     PRIMARY KEY,
    nhom_mon_id BIGINT        NOT NULL,
    ten         VARCHAR(120)  NOT NULL,
    mo_ta       TEXT,
    anh_url     TEXT,                                  -- chỉ lưu URL (Supabase Storage), không base64
    dang_ban    BOOLEAN       NOT NULL DEFAULT TRUE,    -- ngừng bán toàn chuỗi
    tao_luc     TIMESTAMPTZ   NOT NULL DEFAULT now(),

    CONSTRAINT fk_mon_nhom_mon
        FOREIGN KEY (nhom_mon_id) REFERENCES nhom_mon(id) ON DELETE RESTRICT,

    CONSTRAINT ck_mon_anh_url
        CHECK (anh_url IS NULL OR anh_url ~* '^https?://'),
    CONSTRAINT uq_mon_ten_trong_nhom UNIQUE (nhom_mon_id, ten)
);

CREATE INDEX idx_mon_nhom_mon ON mon (nhom_mon_id);

COMMENT ON TABLE mon IS 'Món gốc. Giá bán và trạng thái hết hàng theo từng chi nhánh nằm ở mon_chi_nhanh.';


-- ============================================================================
-- 5. MON_CHI_NHANH — giá bán & hết hàng THEO TỪNG CHI NHÁNH
-- ============================================================================
CREATE TABLE mon_chi_nhanh (
    mon_id       BIGINT     NOT NULL,
    chi_nhanh_id BIGINT     NOT NULL,
    gia_co_ban   BIGINT     NOT NULL,
    het_hang     BOOLEAN    NOT NULL DEFAULT FALSE,

    CONSTRAINT pk_mon_chi_nhanh PRIMARY KEY (mon_id, chi_nhanh_id),
    CONSTRAINT fk_mcn_mon
        FOREIGN KEY (mon_id) REFERENCES mon(id) ON DELETE CASCADE,
    CONSTRAINT fk_mcn_chi_nhanh
        FOREIGN KEY (chi_nhanh_id) REFERENCES chi_nhanh(id) ON DELETE CASCADE,

    CONSTRAINT ck_mcn_gia CHECK (gia_co_ban BETWEEN 0 AND 10000000)
);

CREATE INDEX idx_mon_chi_nhanh_chi_nhanh ON mon_chi_nhanh (chi_nhanh_id);

COMMENT ON TABLE mon_chi_nhanh IS 'Bảng nối món - chi nhánh. Không có dòng ở đây nghĩa là chi nhánh đó không bán món này.';


-- ============================================================================
-- 6. NHOM_TUY_CHON / 7. TUY_CHON — size, mức đường, mức đá
-- ============================================================================
CREATE TABLE nhom_tuy_chon (
    id         BIGSERIAL    PRIMARY KEY,
    ten        VARCHAR(50)  NOT NULL,
    bat_buoc   BOOLEAN      NOT NULL DEFAULT TRUE,   -- khách phải chọn 1
    chon_nhieu BOOLEAN      NOT NULL DEFAULT FALSE,  -- false = chỉ chọn 1 (size, đường, đá)
    thu_tu     SMALLINT     NOT NULL DEFAULT 0,

    CONSTRAINT uq_nhom_tuy_chon_ten UNIQUE (ten)
);

CREATE TABLE tuy_chon (
    id               BIGSERIAL    PRIMARY KEY,
    nhom_tuy_chon_id BIGINT       NOT NULL,
    ten              VARCHAR(50)  NOT NULL,
    phu_thu          BIGINT       NOT NULL DEFAULT 0,   -- phụ thu size L +6.000đ, đường/đá = 0
    mac_dinh         BOOLEAN      NOT NULL DEFAULT FALSE,
    dang_dung        BOOLEAN      NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_tuy_chon_nhom
        FOREIGN KEY (nhom_tuy_chon_id) REFERENCES nhom_tuy_chon(id) ON DELETE CASCADE,

    CONSTRAINT ck_tuy_chon_phu_thu CHECK (phu_thu BETWEEN 0 AND 1000000),
    CONSTRAINT uq_tuy_chon_ten_trong_nhom UNIQUE (nhom_tuy_chon_id, ten)
);

CREATE INDEX idx_tuy_chon_nhom ON tuy_chon (nhom_tuy_chon_id);

COMMENT ON TABLE nhom_tuy_chon IS 'Nhóm tuỳ chọn. chon_nhieu = FALSE nghĩa là chỉ được chọn đúng 1 (mỗi món chỉ 1 size).';


-- ============================================================================
-- 8. MON_TUY_CHON — món nào được chọn nhóm tuỳ chọn nào
-- ============================================================================
CREATE TABLE mon_tuy_chon (
    mon_id           BIGINT NOT NULL,
    nhom_tuy_chon_id BIGINT NOT NULL,

    CONSTRAINT pk_mon_tuy_chon PRIMARY KEY (mon_id, nhom_tuy_chon_id),
    CONSTRAINT fk_mtc_mon
        FOREIGN KEY (mon_id) REFERENCES mon(id) ON DELETE CASCADE,
    CONSTRAINT fk_mtc_nhom
        FOREIGN KEY (nhom_tuy_chon_id) REFERENCES nhom_tuy_chon(id) ON DELETE CASCADE
);

COMMENT ON TABLE mon_tuy_chon IS 'Gán nhóm tuỳ chọn cho món. Ví dụ bánh mì không có nhóm "Mức đá".';


-- ============================================================================
-- 9. TOPPING / 10. MON_TOPPING
-- ============================================================================
CREATE TABLE topping (
    id        BIGSERIAL    PRIMARY KEY,
    ten       VARCHAR(60)  NOT NULL,
    gia       BIGINT       NOT NULL,
    dang_dung BOOLEAN      NOT NULL DEFAULT TRUE,

    CONSTRAINT uq_topping_ten UNIQUE (ten),
    CONSTRAINT ck_topping_gia CHECK (gia BETWEEN 0 AND 1000000)
);

CREATE TABLE mon_topping (
    mon_id     BIGINT NOT NULL,
    topping_id BIGINT NOT NULL,

    CONSTRAINT pk_mon_topping PRIMARY KEY (mon_id, topping_id),
    CONSTRAINT fk_mt_mon
        FOREIGN KEY (mon_id) REFERENCES mon(id) ON DELETE CASCADE,
    CONSTRAINT fk_mt_topping
        FOREIGN KEY (topping_id) REFERENCES topping(id) ON DELETE CASCADE
);

COMMENT ON TABLE mon_topping IS 'Topping nào được phép thêm cho món nào. Server kiểm tra bảng này khi tính tiền.';


-- ============================================================================
-- 11. BAN — bàn + mã QR ngẫu nhiên không đoán được
-- ============================================================================
CREATE TABLE ban (
    id           BIGSERIAL    PRIMARY KEY,
    chi_nhanh_id BIGINT       NOT NULL,
    ten_ban      VARCHAR(30)  NOT NULL,
    ma_qr        VARCHAR(64)  NOT NULL
                 DEFAULT encode(gen_random_bytes(16), 'hex'),   -- 32 ký tự hex ngẫu nhiên
    dang_dung    BOOLEAN      NOT NULL DEFAULT TRUE,
    tao_luc      TIMESTAMPTZ  NOT NULL DEFAULT now(),

    CONSTRAINT fk_ban_chi_nhanh
        FOREIGN KEY (chi_nhanh_id) REFERENCES chi_nhanh(id) ON DELETE RESTRICT,

    CONSTRAINT uq_ban_ma_qr             UNIQUE (ma_qr),
    CONSTRAINT uq_ban_ten_trong_chi_nhanh UNIQUE (chi_nhanh_id, ten_ban),
    CONSTRAINT ck_ban_ma_qr CHECK (char_length(ma_qr) >= 16)
);

CREATE INDEX idx_ban_chi_nhanh ON ban (chi_nhanh_id);

COMMENT ON TABLE ban IS 'Bàn của từng chi nhánh. ma_qr là 16 byte ngẫu nhiên sinh bởi pgcrypto nên không thể đoán.';


-- ============================================================================
-- 12. CA_LAM — mở ca / chốt ca, mỗi chi nhánh chỉ 1 ca mở tại một thời điểm
-- ============================================================================
CREATE TABLE ca_lam (
    id                 BIGSERIAL    PRIMARY KEY,
    chi_nhanh_id       BIGINT       NOT NULL,
    nguoi_dung_id      BIGINT       NOT NULL,
    tien_dau_ca        BIGINT       NOT NULL DEFAULT 0,     -- tiền mặt có sẵn trong két
    mo_luc             TIMESTAMPTZ  NOT NULL DEFAULT now(),
    dong_luc           TIMESTAMPTZ,
    doanh_thu_ca       BIGINT,                              -- snapshot khi chốt
    tien_mat_ky_vong   BIGINT,
    tien_mat_thuc_te   BIGINT,
    tien_ck_thuc_te    BIGINT,
    tien_chenh_lech    BIGINT,
    trang_thai         VARCHAR(10)  NOT NULL DEFAULT 'DANG_MO',
    ghi_chu            TEXT,

    CONSTRAINT fk_ca_lam_chi_nhanh
        FOREIGN KEY (chi_nhanh_id) REFERENCES chi_nhanh(id) ON DELETE RESTRICT,
    CONSTRAINT fk_ca_lam_nguoi_dung
        FOREIGN KEY (nguoi_dung_id) REFERENCES nguoi_dung(id) ON DELETE RESTRICT,

    CONSTRAINT ck_ca_lam_trang_thai
        CHECK (trang_thai IN ('DANG_MO', 'DA_DONG')),
    CONSTRAINT ck_ca_lam_tien_dau_ca
        CHECK (tien_dau_ca >= 0),
    CONSTRAINT ck_ca_lam_thoi_gian
        CHECK (dong_luc IS NULL OR dong_luc >= mo_luc),
    -- Ca đã đóng thì phải có thời điểm đóng
    CONSTRAINT ck_ca_lam_da_dong_co_thoi_diem
        CHECK (trang_thai = 'DANG_MO' OR dong_luc IS NOT NULL),
    CONSTRAINT ck_ca_lam_tien_thuc_te
        CHECK ((tien_mat_thuc_te IS NULL OR tien_mat_thuc_te >= 0)
           AND (tien_ck_thuc_te  IS NULL OR tien_ck_thuc_te  >= 0))
);

-- Mỗi chi nhánh chỉ được có đúng 1 ca đang mở
CREATE UNIQUE INDEX ux_ca_lam_mo_theo_chi_nhanh
    ON ca_lam (chi_nhanh_id) WHERE trang_thai = 'DANG_MO';
-- Mỗi nhân viên chỉ mở 1 ca tại một thời điểm
CREATE UNIQUE INDEX ux_ca_lam_mo_theo_nguoi_dung
    ON ca_lam (nguoi_dung_id) WHERE trang_thai = 'DANG_MO';

CREATE INDEX idx_ca_lam_chi_nhanh_mo_luc ON ca_lam (chi_nhanh_id, mo_luc DESC);

COMMENT ON TABLE ca_lam IS 'Ca làm việc. Mỗi chi nhánh chỉ 1 ca DANG_MO tại một thời điểm (partial unique index).';


-- ============================================================================
-- 13. MA_GIAM_GIA — giảm % hoặc số tiền, có hạn dùng và số lượt tối đa
-- ============================================================================
CREATE TABLE ma_giam_gia (
    id             BIGSERIAL    PRIMARY KEY,
    ma             VARCHAR(20)  NOT NULL,
    loai_giam      VARCHAR(10)  NOT NULL,
    gia_tri        BIGINT       NOT NULL,
    don_toi_thieu  BIGINT       NOT NULL DEFAULT 0,
    giam_toi_da    BIGINT,                          -- chỉ dùng cho loại PHAN_TRAM
    tu_luc         TIMESTAMPTZ  NOT NULL,
    den_luc        TIMESTAMPTZ  NOT NULL,
    so_luot_toi_da INTEGER      NOT NULL,
    da_dung        INTEGER      NOT NULL DEFAULT 0,
    chi_nhanh_id   BIGINT,                          -- NULL = áp dụng toàn chuỗi
    dang_bat       BOOLEAN      NOT NULL DEFAULT TRUE,
    tao_luc        TIMESTAMPTZ  NOT NULL DEFAULT now(),

    CONSTRAINT fk_ma_giam_gia_chi_nhanh
        FOREIGN KEY (chi_nhanh_id) REFERENCES chi_nhanh(id) ON DELETE CASCADE,

    CONSTRAINT ck_ma_giam_gia_loai
        CHECK (loai_giam IN ('PHAN_TRAM', 'SO_TIEN')),
    CONSTRAINT ck_ma_giam_gia_gia_tri
        CHECK (gia_tri > 0 AND (loai_giam <> 'PHAN_TRAM' OR gia_tri <= 100)),
    CONSTRAINT ck_ma_giam_gia_thoi_gian
        CHECK (den_luc > tu_luc),
    CONSTRAINT ck_ma_giam_gia_luot
        CHECK (so_luot_toi_da > 0 AND da_dung >= 0 AND da_dung <= so_luot_toi_da),
    CONSTRAINT ck_ma_giam_gia_don_toi_thieu
        CHECK (don_toi_thieu >= 0),
    CONSTRAINT ck_ma_giam_gia_giam_toi_da
        CHECK (giam_toi_da IS NULL OR giam_toi_da > 0),
    CONSTRAINT uq_ma_giam_gia_ma UNIQUE (ma)
);

CREATE INDEX idx_ma_giam_gia_chi_nhanh ON ma_giam_gia (chi_nhanh_id);

COMMENT ON TABLE ma_giam_gia IS 'Khuyến mãi. da_dung được tăng trong cùng transaction tạo đơn để không vượt số lượt.';


-- ============================================================================
-- 14. DON_HANG
-- ============================================================================
CREATE SEQUENCE seq_ma_don START 1;

CREATE TABLE don_hang (
    id             BIGSERIAL    PRIMARY KEY,
    ma_don         VARCHAR(20)  NOT NULL
                   DEFAULT ('HD' || to_char(now() AT TIME ZONE 'Asia/Ho_Chi_Minh', 'YYMMDD')
                            || lpad(nextval('seq_ma_don')::text, 4, '0')),
    ma_client      UUID,                               -- idempotency key, chống tạo đơn trùng khi mất mạng
    chi_nhanh_id   BIGINT       NOT NULL,
    ban_id         BIGINT       NOT NULL,
    khach_id       BIGINT,                             -- NULL = khách vãng lai
    ca_lam_id      BIGINT,                             -- ca đang mở lúc tạo đơn
    ma_giam_gia_id BIGINT,
    trang_thai     VARCHAR(10)  NOT NULL DEFAULT 'CHO_PHA',
    tong_tien_hang BIGINT       NOT NULL,
    tien_giam      BIGINT       NOT NULL DEFAULT 0,
    thanh_tien     BIGINT       NOT NULL,
    phuong_thuc_tt VARCHAR(15)  NOT NULL,
    ghi_chu        VARCHAR(255),
    ly_do_huy      VARCHAR(255),
    tao_luc        TIMESTAMPTZ  NOT NULL DEFAULT now(),
    hoan_tat_luc   TIMESTAMPTZ,
    huy_luc        TIMESTAMPTZ,

    CONSTRAINT fk_don_hang_chi_nhanh
        FOREIGN KEY (chi_nhanh_id) REFERENCES chi_nhanh(id) ON DELETE RESTRICT,
    CONSTRAINT fk_don_hang_ban
        FOREIGN KEY (ban_id) REFERENCES ban(id) ON DELETE RESTRICT,
    CONSTRAINT fk_don_hang_khach
        FOREIGN KEY (khach_id) REFERENCES nguoi_dung(id) ON DELETE SET NULL,
    CONSTRAINT fk_don_hang_ca_lam
        FOREIGN KEY (ca_lam_id) REFERENCES ca_lam(id) ON DELETE SET NULL,
    CONSTRAINT fk_don_hang_ma_giam_gia
        FOREIGN KEY (ma_giam_gia_id) REFERENCES ma_giam_gia(id) ON DELETE SET NULL,

    CONSTRAINT ck_don_hang_trang_thai
        CHECK (trang_thai IN ('CHO_PHA', 'DANG_PHA', 'HOAN_TAT', 'HUY')),
    CONSTRAINT ck_don_hang_phuong_thuc_tt
        CHECK (phuong_thuc_tt IN ('TIEN_MAT', 'CHUYEN_KHOAN')),
    -- Bất biến kế toán: thành tiền = tổng món - giảm giá, không âm, không lẻ
    CONSTRAINT ck_don_hang_tien
        CHECK (tong_tien_hang >= 0 AND tien_giam >= 0
           AND thanh_tien = tong_tien_hang - tien_giam
           AND thanh_tien >= 0),
    CONSTRAINT ck_don_hang_hoan_tat
        CHECK (trang_thai <> 'HOAN_TAT' OR hoan_tat_luc IS NOT NULL),
    CONSTRAINT ck_don_hang_huy
        CHECK (trang_thai <> 'HUY' OR (huy_luc IS NOT NULL AND ly_do_huy IS NOT NULL)),
    CONSTRAINT uq_don_hang_ma_don   UNIQUE (ma_don),
    CONSTRAINT uq_don_hang_ma_client UNIQUE (ma_client)
);

-- Truy vấn nóng nhất: đơn đang chờ pha của 1 chi nhánh (app admin poll 3 giây/lần)
CREATE INDEX idx_don_hang_chi_nhanh_tt
    ON don_hang (chi_nhanh_id, trang_thai, tao_luc DESC);
CREATE INDEX idx_don_hang_tao_luc  ON don_hang (tao_luc DESC);
CREATE INDEX idx_don_hang_khach    ON don_hang (khach_id);
CREATE INDEX idx_don_hang_ca_lam   ON don_hang (ca_lam_id);
-- Báo cáo doanh thu chỉ đếm đơn HOAN_TAT
CREATE INDEX idx_don_hang_hoan_tat
    ON don_hang (chi_nhanh_id, hoan_tat_luc) WHERE trang_thai = 'HOAN_TAT';

COMMENT ON TABLE don_hang IS 'Đơn hàng. Mọi cột tiền do server tính; CHECK đảm bảo thành tiền luôn khớp.';


-- ============================================================================
-- 15. CHI_TIET_DON — snapshot giá tại thời điểm đặt
-- ============================================================================
CREATE TABLE chi_tiet_don (
    id          BIGSERIAL     PRIMARY KEY,
    don_hang_id BIGINT        NOT NULL,
    mon_id      BIGINT        NOT NULL,
    ten_mon     VARCHAR(120)  NOT NULL,     -- snapshot: đổi tên món sau này không ảnh hưởng đơn cũ
    don_gia     BIGINT        NOT NULL,     -- snapshot giá gốc tại chi nhánh lúc đặt
    phu_thu     BIGINT        NOT NULL DEFAULT 0,  -- tổng phụ thu 1 đơn vị (size + topping)
    so_luong    SMALLINT      NOT NULL,
    thanh_tien  BIGINT        NOT NULL,
    ghi_chu     VARCHAR(255),

    CONSTRAINT fk_chi_tiet_don_don_hang
        FOREIGN KEY (don_hang_id) REFERENCES don_hang(id) ON DELETE CASCADE,
    CONSTRAINT fk_chi_tiet_don_mon
        FOREIGN KEY (mon_id) REFERENCES mon(id) ON DELETE RESTRICT,

    CONSTRAINT ck_chi_tiet_don_so_luong    CHECK (so_luong BETWEEN 1 AND 99),
    CONSTRAINT ck_chi_tiet_don_gia         CHECK (don_gia >= 0 AND phu_thu >= 0),
    CONSTRAINT ck_chi_tiet_don_thanh_tien
        CHECK (thanh_tien = (don_gia + phu_thu) * so_luong)
);

CREATE INDEX idx_chi_tiet_don_don_hang ON chi_tiet_don (don_hang_id);
CREATE INDEX idx_chi_tiet_don_mon      ON chi_tiet_don (mon_id);   -- top 10 món bán chạy

COMMENT ON TABLE chi_tiet_don IS 'Dòng món trong đơn. Lưu snapshot tên + giá nên sửa giá menu không làm sai đơn cũ.';


-- ============================================================================
-- 16. CHI_TIET_DON_TUY_CHON — snapshot tuỳ chọn (size/đường/đá) VÀ topping
--     Một bảng cho cả hai loại; CHECK đảm bảo mỗi dòng chỉ thuộc một loại.
-- ============================================================================
CREATE TABLE chi_tiet_don_tuy_chon (
    id               BIGSERIAL    PRIMARY KEY,
    chi_tiet_don_id  BIGINT       NOT NULL,
    tuy_chon_id      BIGINT,                           -- có giá trị nếu là size/đường/đá
    topping_id       BIGINT,                           -- có giá trị nếu là topping
    ten_snapshot     VARCHAR(60)  NOT NULL,
    phu_thu_snapshot BIGINT       NOT NULL DEFAULT 0,

    CONSTRAINT fk_ctdtc_chi_tiet
        FOREIGN KEY (chi_tiet_don_id) REFERENCES chi_tiet_don(id) ON DELETE CASCADE,
    CONSTRAINT fk_ctdtc_tuy_chon
        FOREIGN KEY (tuy_chon_id) REFERENCES tuy_chon(id) ON DELETE SET NULL,
    CONSTRAINT fk_ctdtc_topping
        FOREIGN KEY (topping_id) REFERENCES topping(id) ON DELETE SET NULL,

    -- Đúng một trong hai khoá ngoại được set (XOR)
    CONSTRAINT ck_ctdtc_xor
        CHECK ((tuy_chon_id IS NULL) <> (topping_id IS NULL)),
    CONSTRAINT ck_ctdtc_phu_thu CHECK (phu_thu_snapshot >= 0)
);

CREATE INDEX idx_ctdtc_chi_tiet ON chi_tiet_don_tuy_chon (chi_tiet_don_id);

-- Mỗi dòng món chỉ được chọn 1 lần mỗi tuỳ chọn / mỗi topping
CREATE UNIQUE INDEX ux_ctdtc_tuy_chon
    ON chi_tiet_don_tuy_chon (chi_tiet_don_id, tuy_chon_id) WHERE tuy_chon_id IS NOT NULL;
CREATE UNIQUE INDEX ux_ctdtc_topping
    ON chi_tiet_don_tuy_chon (chi_tiet_don_id, topping_id) WHERE topping_id IS NOT NULL;

COMMENT ON TABLE chi_tiet_don_tuy_chon IS 'Snapshot tuỳ chọn và topping của từng dòng món. Giữ cả id gốc để thống kê, và tên/giá snapshot để đơn cũ không bị sai.';


-- ============================================================================
-- 17. DANH_GIA — đánh giá món sau khi đơn HOAN_TAT
-- ============================================================================
CREATE TABLE danh_gia (
    id          BIGSERIAL     PRIMARY KEY,
    don_hang_id BIGINT        NOT NULL,
    khach_id    BIGINT        NOT NULL,
    mon_id      BIGINT        NOT NULL,
    so_sao      SMALLINT      NOT NULL,
    nhan_xet    VARCHAR(500),
    tao_luc     TIMESTAMPTZ   NOT NULL DEFAULT now(),

    CONSTRAINT fk_danh_gia_don_hang
        FOREIGN KEY (don_hang_id) REFERENCES don_hang(id) ON DELETE CASCADE,
    CONSTRAINT fk_danh_gia_khach
        FOREIGN KEY (khach_id) REFERENCES nguoi_dung(id) ON DELETE CASCADE,
    CONSTRAINT fk_danh_gia_mon
        FOREIGN KEY (mon_id) REFERENCES mon(id) ON DELETE CASCADE,

    CONSTRAINT ck_danh_gia_so_sao CHECK (so_sao BETWEEN 1 AND 5),
    CONSTRAINT uq_danh_gia_mot_lan UNIQUE (don_hang_id, mon_id)
);

CREATE INDEX idx_danh_gia_mon ON danh_gia (mon_id);

COMMENT ON TABLE danh_gia IS 'Đánh giá 1-5 sao. UNIQUE (don_hang_id, mon_id) chặn đánh giá trùng một món trong cùng một đơn.';


-- ============================================================================
-- 18. LICH_SU_DIEM — sổ cái điểm tích luỹ (cộng khi đơn HOAN_TAT)
-- ============================================================================
CREATE TABLE lich_su_diem (
    id          BIGSERIAL     PRIMARY KEY,
    khach_id    BIGINT        NOT NULL,
    don_hang_id BIGINT,
    thay_doi    INTEGER       NOT NULL,          -- +5 khi hoàn tất đơn, -10 khi đổi quà
    ly_do       VARCHAR(100)  NOT NULL,
    tao_luc     TIMESTAMPTZ   NOT NULL DEFAULT now(),

    CONSTRAINT fk_lsd_khach
        FOREIGN KEY (khach_id) REFERENCES nguoi_dung(id) ON DELETE CASCADE,
    CONSTRAINT fk_lsd_don_hang
        FOREIGN KEY (don_hang_id) REFERENCES don_hang(id) ON DELETE SET NULL,

    CONSTRAINT ck_lsd_thay_doi CHECK (thay_doi <> 0)
);

CREATE INDEX idx_lich_su_diem_khach ON lich_su_diem (khach_id, tao_luc DESC);

COMMENT ON TABLE lich_su_diem IS 'Sổ cái điểm. nguoi_dung.diem_tich_luy là số dư, bảng này là lịch sử để đối soát.';


-- ============================================================================
-- 19. DON_HANG_LOG — vết đổi trạng thái, phục vụ truy vết và báo cáo thời gian pha
-- ============================================================================
CREATE TABLE don_hang_log (
    id            BIGSERIAL    PRIMARY KEY,
    don_hang_id   BIGINT       NOT NULL,
    tu_trang_thai VARCHAR(10),
    den_trang_thai VARCHAR(10) NOT NULL,
    nguoi_dung_id BIGINT,                       -- NULL = khách tự huỷ hoặc hệ thống
    ghi_chu       VARCHAR(255),
    tao_luc       TIMESTAMPTZ  NOT NULL DEFAULT now(),

    CONSTRAINT fk_log_don_hang
        FOREIGN KEY (don_hang_id) REFERENCES don_hang(id) ON DELETE CASCADE,
    CONSTRAINT fk_log_nguoi_dung
        FOREIGN KEY (nguoi_dung_id) REFERENCES nguoi_dung(id) ON DELETE SET NULL,

    CONSTRAINT ck_log_trang_thai
        CHECK (den_trang_thai IN ('CHO_PHA', 'DANG_PHA', 'HOAN_TAT', 'HUY'))
);

CREATE INDEX idx_don_hang_log_don ON don_hang_log (don_hang_id, tao_luc);

COMMENT ON TABLE don_hang_log IS 'Lịch sử chuyển trạng thái đơn. Dùng để tính thời gian pha trung bình.';


-- ============================================================================
-- KIỂM TRA NHANH SAU KHI CHẠY
-- ============================================================================
-- SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public';  -- phải = 19
-- SELECT count(*) FROM pg_constraint WHERE contype = 'f';                          -- phải = 30 khoá ngoại

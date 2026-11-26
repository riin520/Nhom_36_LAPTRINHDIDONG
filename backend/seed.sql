-- ============================================================================
-- INT4211 - Nhóm 36 - Dữ liệu mẫu
-- PostgreSQL 15 (Supabase). Chạy sau schema.sql (db:reset chạy cả hai).
--
-- Quy mô: 3 chi nhánh TP.HCM, 5 nhóm món, 32 món, 3 nhóm tuỳ chọn,
-- 5 topping, 30 bàn, 3 mã giảm giá, 6 tài khoản, 66 đơn / 14 ngày,
-- 42 ca đã đóng + 3 ca đang mở hôm nay.
-- ============================================================================


-- ============================================================================
-- 1. CHI NHÁNH (địa chỉ thật ở TP.HCM)
-- ============================================================================
INSERT INTO chi_nhanh (id, ten, dia_chi, quan, sdt, gio_mo, gio_dong, dang_hoat_dong) VALUES
  (1, 'N36 Quận 1',  '123 Nguyễn Huệ, Phường Bến Nghé', 'Quận 1',  '02838221234', '07:00', '22:00', TRUE),
  (2, 'N36 Quận 3',  '456 Võ Văn Tần, Phường 5',        'Quận 3',  '02839334567', '07:00', '22:00', TRUE),
  (3, 'N36 Thủ Đức', '789 Võ Văn Ngân, Phường Bình Thọ', 'Thủ Đức', '02837228901', '07:00', '22:00', TRUE);

SELECT setval(pg_get_serial_sequence('chi_nhanh', 'id'), 3);


-- ============================================================================
-- 2. NGƯỜI DÙNG (mật khẩu 123456, băm bcrypt bằng pgcrypto)
-- ============================================================================
INSERT INTO nguoi_dung (id, ho_ten, sdt, email, mat_khau_hash, vai_tro, chi_nhanh_id) VALUES
  (1, 'Chủ chuỗi N36',    '0900000001', 'chuchuoi@nhom36.vn', crypt('123456', gen_salt('bf', 10)), 'CHU_CHUOI', NULL),
  (2, 'Nguyễn Tuấn Thành','0900000011', 'ql1@nhom36.vn',      crypt('123456', gen_salt('bf', 10)), 'QUAN_LY',   1),
  (3, 'Phạm Quang Huy',   '0900000012', 'ql2@nhom36.vn',      crypt('123456', gen_salt('bf', 10)), 'QUAN_LY',   2),
  (4, 'Huỳnh Dương Huy',  '0900000013', 'ql3@nhom36.vn',      crypt('123456', gen_salt('bf', 10)), 'QUAN_LY',   3),
  (5, 'Khách Hàng Một',   '0900000101', 'khach1@nhom36.vn',   crypt('123456', gen_salt('bf', 10)), 'KHACH',     NULL),
  (6, 'Khách Hàng Hai',   '0900000102', 'khach2@nhom36.vn',   crypt('123456', gen_salt('bf', 10)), 'KHACH',     NULL);

SELECT setval(pg_get_serial_sequence('nguoi_dung', 'id'), 6);


-- ============================================================================
-- 3. NHÓM MÓN + MÓN
-- ============================================================================
INSERT INTO nhom_mon (id, ten, thu_tu, dang_hien) VALUES
  (1, 'Cà phê',        1, TRUE),
  (2, 'Trà sữa',       2, TRUE),
  (3, 'Đá xay',        3, TRUE),
  (4, 'Trà trái cây',  4, TRUE),
  (5, 'Bánh & Ăn vặt', 5, TRUE);

SELECT setval(pg_get_serial_sequence('nhom_mon', 'id'), 5);

INSERT INTO mon (id, nhom_mon_id, ten, mo_ta, anh_url, dang_ban) VALUES
  (1, 1, 'Cà phê đen đá',       'Cà phê Robusta pha phin, đậm vị', 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=600&q=80', TRUE),
  (2, 1, 'Cà phê sữa đá',       'Cà phê phin với sữa đặc',         'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?auto=format&fit=crop&w=600&q=80', TRUE),
  (3, 1, 'Bạc xỉu',             'Cà phê nhẹ, nhiều sữa',           'https://images.unsplash.com/photo-1572442388796-11668a67e53d?auto=format&fit=crop&w=600&q=80', TRUE),
  (4, 1, 'Cà phê muối',         'Cà phê kem muối béo mịn',         'https://images.unsplash.com/photo-1517701604599-bb29b565090c?auto=format&fit=crop&w=600&q=80', TRUE),
  (5, 1, 'Americano',           'Espresso pha loãng với nước',     'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=600&q=80', TRUE),
  (6, 1, 'Espresso',            'Một shot cà phê đậm đặc',         'https://images.unsplash.com/photo-1510707577719-ae7c14805e3a?auto=format&fit=crop&w=600&q=80', TRUE),

  (7,  2, 'Trà sữa trân châu',  'Trà đen, sữa, trân châu đường đen', 'https://images.unsplash.com/photo-1558857563-b371033873b8?auto=format&fit=crop&w=600&q=80', TRUE),
  (8,  2, 'Trà sữa matcha',     'Matcha Nhật kết hợp sữa tươi',      'https://images.unsplash.com/photo-1515823064-d6e0c04616a7?auto=format&fit=crop&w=600&q=80', TRUE),
  (9,  2, 'Trà sữa khoai môn',  'Khoai môn tím béo ngậy',            'https://images.unsplash.com/photo-1571934811356-5cc061b6821f?auto=format&fit=crop&w=600&q=80', TRUE),
  (10, 2, 'Trà sữa socola',     'Socola đậm vị cùng trà đen',        'https://images.unsplash.com/photo-1541167760496-1628856ab772?auto=format&fit=crop&w=600&q=80', TRUE),
  (11, 2, 'Trà sữa Thái xanh',  'Trà Thái xanh thơm mùi hoa nhài',   'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=600&q=80', TRUE),
  (12, 2, 'Trà sữa ô long',     'Ô long đậm, sữa thanh',             'https://images.unsplash.com/photo-1525385133512-2f3bdd039054?auto=format&fit=crop&w=600&q=80', TRUE),
  (13, 2, 'Trà sữa dâu',        'Trà sữa vị dâu tươi',               'https://images.unsplash.com/photo-1553530666-ba11a7da3888?auto=format&fit=crop&w=600&q=80', TRUE),

  (14, 3, 'Đá xay cookies',     'Cookie giòn xay cùng sữa',          'https://images.unsplash.com/photo-1505252585461-04db1eb84625?auto=format&fit=crop&w=600&q=80', TRUE),
  (15, 3, 'Đá xay matcha',      'Matcha đá xay phủ kem',             'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?auto=format&fit=crop&w=600&q=80', TRUE),
  (16, 3, 'Đá xay socola',      'Socola đá xay đậm đà',              'https://images.unsplash.com/photo-1572490122747-3968b75cc699?auto=format&fit=crop&w=600&q=80', TRUE),
  (17, 3, 'Đá xay việt quất',   'Việt quất chua nhẹ, mát lạnh',      'https://images.unsplash.com/photo-1553530666-ba11a7da3888?auto=format&fit=crop&w=600&q=80', TRUE),
  (18, 3, 'Đá xay xoài',        'Xoài chín xay cùng đá mịn',         'https://images.unsplash.com/photo-1546173159-315724a31696?auto=format&fit=crop&w=600&q=80', TRUE),

  (19, 4, 'Trà đào cam sả',     'Đào ngâm, cam tươi, sả thơm',       'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=600&q=80', TRUE),
  (20, 4, 'Trà vải',            'Vải thiều ngọt thanh',              'https://images.unsplash.com/photo-1544145945-f90425340c7e?auto=format&fit=crop&w=600&q=80', TRUE),
  (21, 4, 'Trà chanh',          'Trà chanh tươi giải nhiệt',         'https://images.unsplash.com/photo-1523677011781-c91d1bbe2f9d?auto=format&fit=crop&w=600&q=80', TRUE),
  (22, 4, 'Trà xoài',           'Xoài tươi cùng trà lài',            'https://images.unsplash.com/photo-1546173159-315724a31696?auto=format&fit=crop&w=600&q=80', TRUE),
  (23, 4, 'Trà dứa',            'Dứa mật vàng, thơm dịu',            'https://images.unsplash.com/photo-1544145945-f90425340c7e?auto=format&fit=crop&w=600&q=80', TRUE),
  (24, 4, 'Trà ổi hồng',        'Ổi hồng giòn, trà nhẹ',             'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=600&q=80', TRUE),
  (25, 4, 'Trà sen vàng',       'Trà sen thanh mát',                 'https://images.unsplash.com/photo-1571934811356-5cc061b6821f?auto=format&fit=crop&w=600&q=80', TRUE),

  (26, 5, 'Bánh flan',          'Flan caramel mềm mịn',              'https://images.unsplash.com/photo-1528975604071-b4dc52a2d18c?auto=format&fit=crop&w=600&q=80', TRUE),
  (27, 5, 'Bánh croissant',     'Croissant bơ Pháp',                 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=600&q=80', TRUE),
  (28, 5, 'Bánh mì que',        'Bánh mì que pate giòn',             'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=600&q=80', TRUE),
  (29, 5, 'Bánh brownie',       'Brownie socola đậm',                'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?auto=format&fit=crop&w=600&q=80', TRUE),
  (30, 5, 'Bánh cheesecake',    'Cheesecake New York',               'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?auto=format&fit=crop&w=600&q=80', TRUE),
  (31, 5, 'Khoai tây chiên',    'Khoai tây chiên giòn',              'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?auto=format&fit=crop&w=600&q=80', TRUE),
  (32, 5, 'Bánh quy bơ',        'Bánh quy bơ thơm',                  'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?auto=format&fit=crop&w=600&q=80', TRUE);

SELECT setval(pg_get_serial_sequence('mon', 'id'), 32);


-- ============================================================================
-- 4. GIÁ THEO CHI NHÁNH
--    - Một số món chỉ bán 1-2 chi nhánh.
--    - Giá chênh nhau giữa các chi nhánh.
--    - Vài món het_hang ở một chi nhánh.
-- ============================================================================
INSERT INTO mon_chi_nhanh (mon_id, chi_nhanh_id, gia_co_ban, het_hang)
SELECT g.id,
       cn.cn,
       g.gia + CASE cn.cn WHEN 1 THEN 0 WHEN 2 THEN 2000 ELSE 1000 END,
       CASE
         WHEN g.id = 4  AND cn.cn = 3 THEN TRUE
         WHEN g.id = 7  AND cn.cn = 1 THEN TRUE
         WHEN g.id = 13 AND cn.cn = 2 THEN TRUE
         WHEN g.id = 18 AND cn.cn = 1 THEN TRUE
         WHEN g.id = 30 AND cn.cn = 2 THEN TRUE
         WHEN g.id = 31 AND cn.cn = 3 THEN TRUE
         ELSE FALSE
       END
  FROM (VALUES
    (1, 25000), (2, 29000), (3, 32000), (4, 35000), (5, 30000), (6, 28000),
    (7, 35000), (8, 40000), (9, 38000), (10, 38000), (11, 36000), (12, 37000), (13, 39000),
    (14, 45000), (15, 43000), (16, 43000), (17, 44000), (18, 44000),
    (19, 39000), (20, 38000), (21, 30000), (22, 39000), (23, 38000), (24, 39000), (25, 40000),
    (26, 20000), (27, 28000), (28, 18000), (29, 30000), (30, 35000), (31, 25000), (32, 22000)
  ) AS g(id, gia)
  CROSS JOIN (VALUES (1), (2), (3)) AS cn(cn)
 WHERE NOT (
        (g.id = 5  AND cn.cn = 3)
     OR (g.id = 6  AND cn.cn IN (2, 3))
     OR (g.id = 12 AND cn.cn = 1)
     OR (g.id = 17 AND cn.cn = 2)
     OR (g.id = 24 AND cn.cn IN (1, 3))
     OR (g.id = 29 AND cn.cn = 3)
     OR (g.id = 32 AND cn.cn = 2)
 );


-- ============================================================================
-- 5. TUỲ CHỌN (Size / Mức đường / Mức đá) + TOPPING
-- ============================================================================
INSERT INTO nhom_tuy_chon (id, ten, bat_buoc, chon_nhieu, thu_tu) VALUES
  (1, 'Size',       TRUE, FALSE, 1),
  (2, 'Mức đường',  TRUE, FALSE, 2),
  (3, 'Mức đá',     TRUE, FALSE, 3);

INSERT INTO tuy_chon (id, nhom_tuy_chon_id, ten, phu_thu, mac_dinh, dang_dung) VALUES
  (1, 1, 'S', 0, TRUE,  TRUE),
  (2, 1, 'M', 0, FALSE, TRUE),
  (3, 1, 'L', 6000, FALSE, TRUE),
  (4, 2, '0% đường',   0, FALSE, TRUE),
  (5, 2, '50% đường',  0, FALSE, TRUE),
  (6, 2, '100% đường', 0, TRUE,  TRUE),
  (7, 3, 'Ít đá',      0, FALSE, TRUE),
  (8, 3, 'Bình thường',0, TRUE,  TRUE),
  (9, 3, 'Nhiều đá',   0, FALSE, TRUE);

INSERT INTO topping (id, ten, gia, dang_dung) VALUES
  (1, 'Trân châu',        5000, TRUE),
  (2, 'Thạch sương sáo',  4000, TRUE),
  (3, 'Kem phô mai',      7000, TRUE),
  (4, 'Pudding trứng',     6000, TRUE),
  (5, 'Thạch cà phê',     5000, TRUE);

SELECT setval(pg_get_serial_sequence('nhom_tuy_chon', 'id'), 3);
SELECT setval(pg_get_serial_sequence('tuy_chon', 'id'), 9);
SELECT setval(pg_get_serial_sequence('topping', 'id'), 5);

-- Đồ uống (1-25) dùng cả 3 nhóm tuỳ chọn.
INSERT INTO mon_tuy_chon (mon_id, nhom_tuy_chon_id)
SELECT m.id, nt.id
  FROM mon m
  CROSS JOIN nhom_tuy_chon nt
 WHERE m.id BETWEEN 1 AND 25;

-- Trà sữa + đá xay (7-18): mọi topping.
INSERT INTO mon_topping (mon_id, topping_id)
SELECT m.id, t.id
  FROM mon m
  CROSS JOIN topping t
 WHERE m.id BETWEEN 7 AND 18;

-- Trà trái cây (19-25): thạch sương sáo + pudding.
INSERT INTO mon_topping (mon_id, topping_id)
SELECT m.id, t.id
  FROM mon m
  JOIN topping t ON t.id IN (2, 4)
 WHERE m.id BETWEEN 19 AND 25;

-- Bạc xỉu và cà phê muối: kem phô mai.
INSERT INTO mon_topping (mon_id, topping_id)
SELECT m.id, t.id
  FROM mon m
  JOIN topping t ON t.id = 3
 WHERE m.id IN (3, 4);


-- ============================================================================
-- 6. 10 BÀN MỖI CHI NHÁNH
-- ============================================================================
INSERT INTO ban (id, chi_nhanh_id, ten_ban)
SELECT (cn.cn - 1) * 10 + n,
       cn.cn,
       'Bàn ' || lpad(n::text, 2, '0')
  FROM (VALUES (1), (2), (3)) AS cn(cn)
  CROSS JOIN generate_series(1, 10) AS n;

SELECT setval(pg_get_serial_sequence('ban', 'id'), 30);


-- ============================================================================
-- 7. MÃ GIẢM GIÁ (1 %, 1 số tiền, 1 đã hết hạn)
-- ============================================================================
INSERT INTO ma_giam_gia
  (id, ma, loai_giam, gia_tri, don_toi_thieu, giam_toi_da, tu_luc, den_luc, so_luot_toi_da, chi_nhanh_id, dang_bat)
VALUES
  (1, 'N36GIAM10', 'PHAN_TRAM', 10,    50000,  20000,
      now() - INTERVAL '30 days', now() + INTERVAL '30 days', 100, NULL, TRUE),
  (2, 'GIAM20K',   'SO_TIEN',   20000, 100000, NULL,
      now() - INTERVAL '30 days', now() + INTERVAL '30 days', 50,  NULL, TRUE),
  (3, 'CHAOHE15K', 'SO_TIEN',   15000, 0,      NULL,
      now() - INTERVAL '40 days', now() - INTERVAL '10 days', 30,  NULL, TRUE);

SELECT setval(pg_get_serial_sequence('ma_giam_gia', 'id'), 3);


-- ============================================================================
-- 8. CA LÀM + ĐƠN HÀNG 14 NGÀY
--    setseed => dữ liệu lặp lại được.
--    Mỗi chi nhánh mỗi ngày 1 ca DA_DONG 07:00-22:00 (giờ VN).
--    66 đơn: 58 HOAN_TAT (87,9%) + 8 HUY (12,1%), rải đều 14 ngày.
--    Giờ cao điểm 7-9h, 12-13h, 17-19h.
-- ============================================================================
DO $$
DECLARE
  v_hom_nay    date := (now() AT TIME ZONE 'Asia/Ho_Chi_Minh')::date;
  v_khach1     bigint;
  v_khach2     bigint;
  v_cn         int;
  v_ngay       date;
  v_thu_tu_ca  int := 0;
  v_don_so     int := 0;
  v_ca_id      bigint;
  v_so_don_ca  int;
  v_ban_id     bigint;
  v_gio        int;
  v_tao        timestamptz;
  v_dong       timestamptz;
  v_hoan       timestamptz;
  v_huy        timestamptz;
  v_trang_thai text;
  v_ly_do      text;
  v_phuong_thuc text;
  v_khach_id   bigint;
  v_don_id     bigint;
  v_so_dong    int;
  v_mon_id     bigint;
  v_mon_ten    text;
  v_gia        bigint;
  v_sl         int;
  v_nhom       bigint;
  v_tc         record;
  v_top        record;
  v_phu_thu    bigint;
  v_thanh_dong bigint;
  v_tong       bigint;
  v_ct_id      bigint;
  v_tc_ids     bigint[];
  v_tc_tens    text[];
  v_tc_phus    bigint[];
  v_top_ids    bigint[];
  v_top_tens   text[];
  v_top_gias   bigint[];
  v_so_top     int;
  v_ma_gg_id   bigint;
  v_giam       bigint;
  v_diem       int;
  v_r          double precision;
  v_mon_cn     bigint[];
BEGIN
  PERFORM setseed(0.36);

  SELECT id INTO v_khach1 FROM nguoi_dung WHERE sdt = '0900000101';
  SELECT id INTO v_khach2 FROM nguoi_dung WHERE sdt = '0900000102';

  FOR i IN 1..14 LOOP
    v_ngay := v_hom_nay - i;
    v_dong := (v_ngay + TIME '22:00') AT TIME ZONE 'Asia/Ho_Chi_Minh';

    FOR v_cn IN 1..3 LOOP
      v_thu_tu_ca := v_thu_tu_ca + 1;
      -- 42 ca: 24 ca đầu có 2 đơn, còn lại 1 đơn => 66 đơn.
      v_so_don_ca := CASE WHEN v_thu_tu_ca <= 24 THEN 2 ELSE 1 END;

      INSERT INTO ca_lam
        (chi_nhanh_id, nguoi_dung_id, tien_dau_ca, mo_luc, dong_luc,
         tien_chenh_lech, trang_thai)
      VALUES
        (v_cn, 1 + v_cn, 500000,
         (v_ngay + TIME '07:00') AT TIME ZONE 'Asia/Ho_Chi_Minh',
         v_dong,
         (floor(random() * 41) - 20) * 1000,
         'DA_DONG')
      RETURNING id INTO v_ca_id;

      FOR k IN 1..v_so_don_ca LOOP
        v_don_so := v_don_so + 1;

        -- Giờ tạo đơn: 45% 7-9h, 15% 12-13h, 25% 17-19h, 15% giờ khác.
        v_r := random();
        IF v_r < 0.45 THEN
          v_gio := 7 + floor(random() * 3)::int;
        ELSIF v_r < 0.60 THEN
          v_gio := 12 + floor(random() * 2)::int;
        ELSIF v_r < 0.85 THEN
          v_gio := 17 + floor(random() * 3)::int;
        ELSE
          v_gio := (ARRAY[10, 11, 14, 15, 16, 20])[1 + floor(random() * 6)::int];
        END IF;

        v_tao := (v_ngay + make_interval(hours => v_gio,
                                         mins  => floor(random() * 50)::int))
                 AT TIME ZONE 'Asia/Ho_Chi_Minh';

        v_trang_thai := CASE WHEN v_don_so % 8 = 0 THEN 'HUY' ELSE 'HOAN_TAT' END;
        IF v_trang_thai = 'HUY' THEN
          v_hoan := NULL;
          v_huy  := v_tao + INTERVAL '5 minutes';
          v_ly_do := (ARRAY['Khách đổi ý', 'Đặt nhầm món', 'Không đến nhận', 'Hết nguyên liệu'])
                     [1 + floor(random() * 4)::int];
        ELSE
          v_hoan := v_tao + make_interval(mins => 5 + floor(random() * 15)::int);
          IF v_hoan > v_dong THEN
            v_hoan := v_dong - INTERVAL '1 minute';
          END IF;
          v_huy := NULL;
          v_ly_do := NULL;
        END IF;

        v_phuong_thuc := CASE WHEN random() < 0.5 THEN 'TIEN_MAT' ELSE 'CHUYEN_KHOAN' END;

        IF random() < 0.45 THEN
          v_khach_id := CASE WHEN random() < 0.5 THEN v_khach1 ELSE v_khach2 END;
        ELSE
          v_khach_id := NULL;
        END IF;

        v_ban_id := (v_cn - 1) * 10 + 1 + floor(random() * 10)::int;

        INSERT INTO don_hang
          (ma_don, ma_client, chi_nhanh_id, ban_id, khach_id, ca_lam_id,
           trang_thai, tong_tien_hang, tien_giam, thanh_tien, phuong_thuc_tt,
           hoan_tat_luc, huy_luc, ly_do_huy, tao_luc)
        VALUES
          ('HD' || to_char(v_ngay, 'YYMMDD') || lpad(v_don_so::text, 4, '0'),
           md5('n36-seed-' || v_don_so)::uuid,
           v_cn, v_ban_id, v_khach_id, v_ca_id,
           v_trang_thai, 0, 0, 0, v_phuong_thuc,
           v_hoan, v_huy, v_ly_do, v_tao)
        RETURNING id INTO v_don_id;

        -- Chọn món đang bán tại chi nhánh, không hết hàng.
        SELECT array_agg(m.id ORDER BY m.id)
          INTO v_mon_cn
          FROM mon m
          JOIN mon_chi_nhanh mcn ON mcn.mon_id = m.id
         WHERE mcn.chi_nhanh_id = v_cn
           AND m.dang_ban
           AND NOT mcn.het_hang;

        v_tong := 0;
        v_so_dong := 1 + floor(random() * 3)::int;

        FOR l IN 1..v_so_dong LOOP
          v_mon_id := v_mon_cn[1 + floor(random() * array_length(v_mon_cn, 1))::int];

          SELECT m.ten, mcn.gia_co_ban
            INTO v_mon_ten, v_gia
            FROM mon m
            JOIN mon_chi_nhanh mcn ON mcn.mon_id = m.id
           WHERE m.id = v_mon_id AND mcn.chi_nhanh_id = v_cn;

          v_sl := CASE WHEN random() < 0.7 THEN 1 ELSE 2 END;

          v_tc_ids := ARRAY[]::bigint[];
          v_tc_tens := ARRAY[]::text[];
          v_tc_phus := ARRAY[]::bigint[];
          v_phu_thu := 0;

          FOR v_nhom IN
            SELECT nhom_tuy_chon_id FROM mon_tuy_chon WHERE mon_id = v_mon_id ORDER BY nhom_tuy_chon_id
          LOOP
            SELECT tc.id, tc.ten, tc.phu_thu
              INTO v_tc
              FROM tuy_chon tc
             WHERE tc.nhom_tuy_chon_id = v_nhom AND tc.dang_dung
             ORDER BY random()
             LIMIT 1;

            v_tc_ids  := v_tc_ids || v_tc.id;
            v_tc_tens := v_tc_tens || v_tc.ten;
            v_tc_phus := v_tc_phus || v_tc.phu_thu;
            v_phu_thu := v_phu_thu + v_tc.phu_thu;
          END LOOP;

          v_top_ids := ARRAY[]::bigint[];
          v_top_tens := ARRAY[]::text[];
          v_top_gias := ARRAY[]::bigint[];

          SELECT count(*) INTO v_so_top FROM mon_topping WHERE mon_id = v_mon_id;
          IF v_so_top > 0 THEN
            v_so_top := floor(random() * 3)::int;  -- 0..2 topping
            FOR v_top IN
              SELECT t.id, t.ten, t.gia
                FROM mon_topping mt
                JOIN topping t ON t.id = mt.topping_id
               WHERE mt.mon_id = v_mon_id AND t.dang_dung
               ORDER BY random()
               LIMIT v_so_top
            LOOP
              v_top_ids  := v_top_ids || v_top.id;
              v_top_tens := v_top_tens || v_top.ten;
              v_top_gias := v_top_gias || v_top.gia;
              v_phu_thu := v_phu_thu + v_top.gia;
            END LOOP;
          END IF;

          v_thanh_dong := (v_gia + v_phu_thu) * v_sl;
          v_tong := v_tong + v_thanh_dong;

          INSERT INTO chi_tiet_don
            (don_hang_id, mon_id, ten_mon, don_gia, phu_thu, so_luong, thanh_tien)
          VALUES
            (v_don_id, v_mon_id, v_mon_ten, v_gia, v_phu_thu, v_sl, v_thanh_dong)
          RETURNING id INTO v_ct_id;

          IF array_length(v_tc_ids, 1) IS NOT NULL THEN
            FOR j IN 1..array_length(v_tc_ids, 1) LOOP
              INSERT INTO chi_tiet_don_tuy_chon
                (chi_tiet_don_id, tuy_chon_id, ten_snapshot, phu_thu_snapshot)
              VALUES
                (v_ct_id, v_tc_ids[j], v_tc_tens[j], v_tc_phus[j]);
            END LOOP;
          END IF;

          IF array_length(v_top_ids, 1) IS NOT NULL THEN
            FOR j IN 1..array_length(v_top_ids, 1) LOOP
              INSERT INTO chi_tiet_don_tuy_chon
                (chi_tiet_don_id, topping_id, ten_snapshot, phu_thu_snapshot)
              VALUES
                (v_ct_id, v_top_ids[j], v_top_tens[j], v_top_gias[j]);
            END LOOP;
          END IF;
        END LOOP;

        -- Mã giảm giá: ~20% đơn đủ điều kiện.
        v_ma_gg_id := NULL;
        v_giam := 0;
        v_r := random();
        IF v_tong >= 50000 AND v_r < 0.20 THEN
          v_ma_gg_id := 1;  -- N36GIAM10: 10%, tối đa 20.000
          v_giam := LEAST((v_tong * 10 / 100)::bigint, 20000::bigint);
          v_giam := (v_giam / 1000) * 1000;
        ELSIF v_tong >= 100000 AND v_r < 0.30 THEN
          v_ma_gg_id := 2;  -- GIAM20K
          v_giam := 20000;
        END IF;
        IF v_giam > v_tong THEN v_giam := v_tong; END IF;

        UPDATE don_hang
           SET tong_tien_hang = v_tong,
               tien_giam = v_giam,
               thanh_tien = v_tong - v_giam,
               ma_giam_gia_id = v_ma_gg_id
         WHERE id = v_don_id;

        -- Điểm tích luỹ khi đơn hoàn tất.
        IF v_trang_thai = 'HOAN_TAT' AND v_khach_id IS NOT NULL THEN
          v_diem := ((v_tong - v_giam) / 10000)::int;
          IF v_diem > 0 THEN
            INSERT INTO lich_su_diem (khach_id, don_hang_id, thay_doi, ly_do, tao_luc)
            VALUES (v_khach_id, v_don_id, v_diem, 'Hoàn tất đơn ' || v_don_id, v_hoan);
          END IF;
        END IF;

        -- Vết trạng thái.
        INSERT INTO don_hang_log (don_hang_id, tu_trang_thai, den_trang_thai, nguoi_dung_id, tao_luc)
        VALUES (v_don_id, NULL, 'CHO_PHA', v_khach_id, v_tao);

        IF v_trang_thai = 'HOAN_TAT' THEN
          INSERT INTO don_hang_log (don_hang_id, tu_trang_thai, den_trang_thai, nguoi_dung_id, tao_luc)
          VALUES (v_don_id, 'CHO_PHA', 'DANG_PHA', 1 + v_cn, v_tao + INTERVAL '2 minutes');
          INSERT INTO don_hang_log (don_hang_id, tu_trang_thai, den_trang_thai, nguoi_dung_id, tao_luc)
          VALUES (v_don_id, 'DANG_PHA', 'HOAN_TAT', 1 + v_cn, v_hoan);
        ELSE
          INSERT INTO don_hang_log (don_hang_id, tu_trang_thai, den_trang_thai, nguoi_dung_id, ghi_chu, tao_luc)
          VALUES (v_don_id, 'CHO_PHA', 'HUY', v_khach_id, v_ly_do, v_huy);
        END IF;
      END LOOP;
    END LOOP;
  END LOOP;

  -- Chốt số liệu từng ca đã đóng (chỉ tính đơn HOAN_TAT).
  UPDATE ca_lam c
     SET doanh_thu_ca     = COALESCE(s.doanh_thu, 0),
         tien_mat_ky_vong = c.tien_dau_ca + COALESCE(s.tien_mat, 0),
         tien_ck_thuc_te  = COALESCE(s.tien_ck, 0)
    FROM (
      SELECT ca_lam_id,
             sum(thanh_tien) FILTER (WHERE trang_thai = 'HOAN_TAT') AS doanh_thu,
             sum(thanh_tien) FILTER (WHERE trang_thai = 'HOAN_TAT' AND phuong_thuc_tt = 'TIEN_MAT') AS tien_mat,
             sum(thanh_tien) FILTER (WHERE trang_thai = 'HOAN_TAT' AND phuong_thuc_tt = 'CHUYEN_KHOAN') AS tien_ck
        FROM don_hang
       WHERE ca_lam_id IS NOT NULL
       GROUP BY ca_lam_id
    ) s
   WHERE c.id = s.ca_lam_id;

  UPDATE ca_lam
     SET tien_mat_thuc_te = COALESCE(tien_mat_ky_vong, 0) + COALESCE(tien_chenh_lech, 0)
   WHERE trang_thai = 'DA_DONG';

  -- Đồng bộ điểm tích luỹ với sổ cái.
  UPDATE nguoi_dung u
     SET diem_tich_luy = COALESCE(
           (SELECT sum(thay_doi) FROM lich_su_diem WHERE khach_id = u.id), 0)
   WHERE u.vai_tro = 'KHACH';

  -- Số lượt đã dùng của mã giảm giá = số đơn tham chiếu.
  UPDATE ma_giam_gia m
     SET da_dung = (SELECT count(*) FROM don_hang d WHERE d.ma_giam_gia_id = m.id);
END $$;


-- ============================================================================
-- 9. HÔM NAY: MỖI CHI NHÁNH 1 CA ĐANG MỞ, CHƯA CÓ ĐƠN
-- ============================================================================
INSERT INTO ca_lam (chi_nhanh_id, nguoi_dung_id, tien_dau_ca, mo_luc, trang_thai)
SELECT cn.id,
       u.id,
       1000000,
       (((now() AT TIME ZONE 'Asia/Ho_Chi_Minh')::date + TIME '07:00')
         AT TIME ZONE 'Asia/Ho_Chi_Minh'),
       'DANG_MO'
  FROM chi_nhanh cn
  JOIN nguoi_dung u ON u.vai_tro = 'QUAN_LY' AND u.chi_nhanh_id = cn.id;


-- ============================================================================
-- KIỂM TRA NHANH
-- ============================================================================
-- SELECT count(*) FROM chi_nhanh;                    -- 3
-- SELECT count(*) FROM mon;                          -- 32
-- SELECT count(*) FROM ban;                          -- 30
-- SELECT count(*) FROM don_hang;                     -- 66
-- SELECT trang_thai, count(*) FROM don_hang GROUP BY 1;
-- SELECT count(*) FROM ca_lam WHERE trang_thai='DANG_MO';  -- 3
-- SELECT count(*) FROM ca_lam WHERE trang_thai='DA_DONG';  -- 42
-- SELECT c.id, c.doanh_thu_ca,
--        (SELECT COALESCE(sum(thanh_tien),0) FROM don_hang
--          WHERE ca_lam_id=c.id AND trang_thai='HOAN_TAT') AS tinh_lai
--   FROM ca_lam c WHERE trang_thai='DA_DONG'
--  ORDER BY c.id;

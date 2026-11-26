# Hợp đồng API (bản nháp v1 – mốc tuần 11)

**Đề 1 – Hệ thống quản lý chuỗi quán cà phê – trà sữa · Nhóm 36**

Đây là thỏa thuận giữa backend (P1, P4) và hai app (P2 Admin, P3 Client).
Muốn đổi thì **sửa file này, mở PR và báo cả nhóm**; không tự đổi trong code.

Base URL: `https://nhom-36-laptrinhdidong-backend-api.onrender.com`

## 1. Quy ước chung

| Mục | Quy ước |
| --- | --- |
| Định dạng | JSON, `Content-Type: application/json`, UTF-8 |
| Tên trường trong body / response | `snake_case`, trùng tên cột trong `schema.sql` |
| Tên tham số truy vấn (`?a=b`) | `camelCase`, đúng như đề (`chiNhanh`, `trangThai`…) |
| Tiền | Số nguyên, đơn vị đồng (VND). Ví dụ `29000` |
| Thời gian | Chuỗi ISO 8601, ví dụ `2026-11-25T08:30:00Z` |
| Xác thực | Header `Authorization: Bearer <token>` |
| Vai trò | `CHU_CHUOI`, `QUAN_LY`, `KHACH` |
| Lỗi | Luôn trả `{ "loi": "Thông báo tiếng Việt" }` kèm mã HTTP đúng |

Mã trạng thái dùng: `200`, `201`, `400` (thiếu/sai dữ liệu), `401` (chưa đăng nhập / token hết hạn), `403` (sai vai trò), `404`, `409`, `500`.

JWT hết hạn sau 7 ngày. Payload token: `{ id, vaiTro, chiNhanhId }` (khớp với middleware mẫu ở Phụ lục 1 của đề). App Admin gặp `401` thì tự đăng xuất.

## 2. Kiểm tra sức khỏe

### `GET /health` — công khai

- `200`: `{ "status": "Healthy", "message": "DOAN_NHOM_36 Backend is running!" }`

## 3. Các API tuần 11

### 3.1 `POST /auth/dang-nhap` — công khai

Request:
```json
{ "email": "quanly1@neko.vn", "mat_khau": "123456" }
```

`200`:
```json
{
  "token": "eyJhbGciOi...",
  "nguoi_dung": { "id": 2, "ho_ten": "Nguyễn Văn A", "vai_tro": "QUAN_LY", "chi_nhanh_id": 1 }
}
```
- `chi_nhanh_id` là `null` với `CHU_CHUOI` và `KHACH`.
- `400`: thiếu `email` hoặc `mat_khau`.
- `401`: `{ "loi": "Email hoặc mật khẩu không đúng" }` (một thông báo chung cho cả hai trường hợp sai).
- Không bao giờ trả `mat_khau_hash` về app.

### 3.2 `GET /mon?chiNhanh=1&nhom=2` — công khai

Khách xem thực đơn không cần đăng nhập, nên API này không đòi token.

| Tham số | Bắt buộc | Ý nghĩa |
| --- | --- | --- |
| `chiNhanh` | có | id chi nhánh |
| `nhom` | không | lọc theo `nhom_id` |

`200` (mảng; chỉ gồm món đang bán, giá lấy theo chi nhánh):
```json
[
  {
    "id": 1,
    "nhom_id": 1,
    "ten": "Cà phê sữa",
    "mo_ta": "Cà phê phin pha sữa đặc",
    "anh_url": "https://.../ca-phe-sua.jpg",
    "gia": 29000,
    "con_hang": true
  }
]
```
- `gia` = `mon_chi_nhanh.gia`; `con_hang` = `mon_chi_nhanh.con_hang`.
- `400`: thiếu `chiNhanh`. `404`: chi nhánh không tồn tại.

### 3.3 `GET /ban/:maQr` — công khai

`maQr` là chuỗi ngẫu nhiên in trên mã QR của bàn.

`200`:
```json
{
  "ban": { "id": 5, "so_ban": 5, "ma_qr": "k3J9xQ2mPz" },
  "chi_nhanh": { "id": 1, "ten": "Neko Coffee Q1", "dia_chi": "12 Lê Lợi, Quận 1" },
  "thuc_don": [ { "id": 1, "nhom_id": 1, "ten": "Cà phê sữa", "mo_ta": "...", "anh_url": "...", "gia": 29000, "con_hang": true } ]
}
```
- `thuc_don` có cùng dạng với phần tử của `GET /mon`.
- `404`: `{ "loi": "Không tìm thấy bàn" }`.

## 4. Sẽ bổ sung sau tuần 11 (chưa chốt, chưa code)

`POST /auth/dang-ky`, `GET /tuy-chon` (size, đường, đá, topping), `POST /don-hang`, `GET /don-hang`, `PATCH /don-hang/:id/trang-thai`, `POST /ca-lam/mo`, `PATCH /ca-lam/:id/chot`, `GET /bao-cao/doanh-thu`, mã giảm giá, nhân viên, đánh giá.
Mỗi API mới thêm vào file này trước khi code.

## 5. Tài khoản test (P1 điền sau khi seed)

| Vai trò | Email | Mật khẩu |
| --- | --- | --- |
| CHU_CHUOI | | |
| QUAN_LY | | |
| KHACH | | |

## 6. Thử nhanh bằng curl

```
curl https://nhom-36-laptrinhdidong-backend-api.onrender.com/health
curl "https://nhom-36-laptrinhdidong-backend-api.onrender.com/mon?chiNhanh=1"
curl -X POST https://nhom-36-laptrinhdidong-backend-api.onrender.com/auth/dang-nhap \
  -H "Content-Type: application/json" \
  -d '{"email":"quanly1@neko.vn","mat_khau":"123456"}'
```
Render gói Free ngủ sau 15 phút: lần gọi đầu có thể mất khoảng 1 phút.

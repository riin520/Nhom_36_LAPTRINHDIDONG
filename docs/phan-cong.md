# Bảng phân công (bản nháp – mốc tuần 9)

**Đề 1 – Hệ thống quản lý chuỗi quán cà phê – trà sữa · Nhóm 36**

Cả nhóm họp chốt lại tỷ lệ đóng góp trước khi ký. Nguyên tắc: không ai sửa file của người khác; cần đổi hợp đồng API thì sửa `docs/api-contract.md` và báo cả nhóm.

## 1. Vai trò và tỷ lệ đóng góp dự kiến

| Người | Họ tên | MSSV | Vai trò | Phụ trách chính | % |
| --- | --- | --- | --- | --- | --- |
| P1 | Huỳnh Anh Tuấn | 231A290052 | Backend core + CSDL | `schema.sql`, `seed.sql`, JWT + bcrypt, middleware phân quyền, engine tính tiền, tạo đơn (transaction), state machine đơn, bàn/QR, ca làm, đánh giá, điểm tích luỹ | 24 |
| P2 | Nguyễn Tuấn Thành | 211A290018 | App Admin (Android) | Đăng nhập theo vai trò, quản lý thực đơn + bật/tắt hết hàng, danh sách đơn (polling 3 giây + âm báo), quản lý bàn & QR, mở–chốt ca | 26 |
| P3 | Phạm Quang Huy | 231A290095 | App Client (Flutter) | Quét QR, thực đơn, tuỳ chọn món, giỏ hàng, mã giảm giá, đặt đơn, theo dõi trạng thái, đăng ký/đăng nhập, lịch sử + điểm, đánh giá | 24 |
| P4 | Huỳnh Dương Gia Huy | 231A010310 | Backend nghiệp vụ + báo cáo + QA/Deploy | API báo cáo / khuyến mãi / nhân viên và các màn hình Admin tương ứng (biểu đồ MPAndroidChart), deploy Render, Postman, test, báo cáo & video | 26 |
| | | | **Tổng** | | **100** |

Ghi chú: P4 phụ trách các màn hình Admin cho báo cáo, khuyến mãi và nhân viên (code trong các Fragment riêng, không sửa file của P2) để đáp ứng yêu cầu app Admin có biểu đồ/bảng báo cáo.

## 2. Phân công theo module

| Module | Backend (API + SQL) | App Admin | App Client |
| --- | --- | --- | --- |
| Xác thực, phân quyền | P1 | P2 | P3 |
| Thực đơn, giá theo chi nhánh, hết hàng | P1 | P2 | P3 (xem thực đơn) |
| Đặt đơn + tính tiền + áp mã giảm giá | P1 | — | P3 |
| Trạng thái đơn, theo dõi, âm báo đơn mới | P1 | P2 | P3 |
| Bàn & mã QR | P1 | P2 | P3 (quét QR) |
| Ca làm (mở / chốt ca) | P1 | P2 | — |
| Báo cáo: doanh thu, top 10 món, giờ cao điểm | P4 | P4 | — |
| Quản lý mã giảm giá | P4 | P4 | P3 (nhập mã) |
| Quản lý nhân viên, số ca đã làm | P4 | P4 | — |
| Đánh giá món, điểm tích luỹ | P1 | — | P3 |
| Deploy Render, Postman, test, README, `api.md` | P4 (P1 hỗ trợ) | — | — |
| Báo cáo đồ án, video demo, slide | Mỗi người viết/quay phần của mình; P4 tổng hợp | | |

## 3. Lịch làm việc theo mốc của đề

| Tuần | Mốc | P1 | P2 | P3 | P4 |
| --- | --- | --- | --- | --- | --- |
| 8 | Đăng ký đề | Tạo repo (3 thư mục `backend/`, `admin-android/`, `client-flutter/`), `.gitignore` có `.env` ngay commit đầu | Dựng project Android, Retrofit skeleton | Dựng project Flutter, màn mock | Danh sách endpoint, Postman rỗng |
| 9 | **Chốt phân tích** | Chạy `schema.sql` trên Supabase, `/health` | Thiết kế màn hình Admin | Thiết kế màn hình Client | Chốt `docs/api-contract.md` |
| 10 | Chuẩn bị giữa kỳ | Auth, menu, engine tính tiền | Login thật + 2 màn hình | Menu + tuỳ chọn món (2 màn hình) | **Deploy Render sớm**, ≥ 3 API thật gọi được |
| 11 | **Giữa kỳ (1,0 điểm, không nộp bù)** | Hoàn thiện API đã có | Hoàn thiện 2 màn hình | Hoàn thiện 2 màn hình | Kiểm tra link API từ máy khác |
| 12 | | Tạo đơn + state machine, ca làm | Quản lý thực đơn, danh sách đơn polling | QR → giỏ → đặt đơn | API báo cáo, khuyến mãi |
| 13 | **Bản chạy được** | Đánh giá, điểm, bàn/QR | Bàn/QR, mở–chốt ca, âm báo | Theo dõi đơn, đăng ký/đăng nhập, lịch sử, đánh giá | Màn Admin báo cáo/khuyến mãi/nhân viên, seed 60 đơn |
| 14 | Feature freeze | Fix bug, index, kiểm tra SQL | Fix bug, APK release | Fix bug, APK release, `flutter analyze` | E2E test, Postman, báo cáo + video |
| 15 | **Bảo vệ** | Dự phòng | Dự phòng | Dự phòng | Bật sẵn dịch vụ, nộp đủ mục D.1 |

## 4. Quy ước làm việc nhóm

- Mỗi thành viên dùng **tài khoản GitHub riêng**, cấu hình `user.email` đúng; tối thiểu **15 commit có ý nghĩa** rải đều 8 tuần. Thông điệp commit mô tả đúng việc đã làm (ví dụ "them API dat don co kiem tra mon het hang"), không dùng "update", "fix", "abc".
- Nhánh git `feat/<ten>-<viec>`, PR nhỏ; `main` chỉ merge qua PR, P4 review.
- `.env` nằm trong `.gitignore` từ commit đầu tiên; không commit khoá `service_role` của Supabase.
- Backend kết nối Supabase bằng Connection pooler, Session mode, cổng 5432 (không dùng Direct connection vì Render chỉ có IPv4).
- Render gói Free ngủ sau 15 phút: gọi thử `/health` 2–3 phút trước khi demo; vào Supabase khôi phục dự án nếu bị tạm dừng sau 7 ngày không hoạt động.
- Tên app, tên gói và TAG log chứa mã nhóm (nhóm 36).
- Dùng AI để sinh mã là được phép, nhưng mỗi người phải giải thích được từng dòng mình commit khi bảo vệ.

## 5. Xác nhận của nhóm

| Họ tên | MSSV | Vai trò | % đóng góp | Chữ ký |
| --- | --- | --- | --- | --- |
| Huỳnh Anh Tuấn | 231A290052 | P1 – Backend core + CSDL | 24 | |
| Nguyễn Tuấn Thành | 211A290018 | P2 – App Admin | 26 | |
| Phạm Quang Huy | 231A290095 | P3 – App Client | 24 | |
| Huỳnh Dương Gia Huy | 231A010310 | P4 – Backend nghiệp vụ + báo cáo + QA/Deploy | 26 | |

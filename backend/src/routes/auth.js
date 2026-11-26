const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const { truyVan } = require("../db");

const router = express.Router();

// POST /auth/dang-nhap  — công khai
router.post("/dang-nhap", async (req, res) => {
  const { sdt, mat_khau } = req.body || {};
  if (!sdt || !mat_khau) {
    return res.status(400).json({ loi: "Thiếu số điện thoại hoặc mật khẩu" });
  }

  const r = await truyVan("SELECT * FROM nguoi_dung WHERE sdt = $1", [sdt]);
  const u = r.rows[0];

  // sdt là tên đăng nhập (theo schema). Cùng một thông báo cho cả "sai sdt" và "sai mật khẩu", tránh lộ sdt nào đã tồn tại
  // Tài khoản bị khóa (bi_khoa) cũng không được đăng nhập
  if (!u || u.bi_khoa || !(await bcrypt.compare(mat_khau, u.mat_khau_hash))) {
    return res
      .status(401)
      .json({ loi: "Số điện thoại hoặc mật khẩu không đúng" });
  }

  const token = jwt.sign(
    { id: u.id, vaiTro: u.vai_tro, chiNhanhId: u.chi_nhanh_id },
    process.env.JWT_SECRET,
    { expiresIn: "7d" },
  );

  // Không bao giờ trả mat_khau_hash về cho app
  res.json({
    token,
    nguoi_dung: {
      id: u.id,
      ho_ten: u.ho_ten,
      vai_tro: u.vai_tro,
      chi_nhanh_id: u.chi_nhanh_id,
    },
  });
});

module.exports = router;

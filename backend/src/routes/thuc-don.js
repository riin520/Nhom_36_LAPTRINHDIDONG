const express = require("express");
const { truyVan } = require("../db");

const router = express.Router();

// Lấy thực đơn của một chi nhánh (chỉ món đang bán, giá theo chi nhánh).
// Dùng chung cho GET /mon và GET /ban/:maQr.
// Đổi tên cột theo schema của P1 cho khớp contract: nhom_mon_id -> nhom_id, gia_co_ban -> gia, NOT het_hang -> con_hang.
async function layThucDon(chiNhanhId, nhomId) {
  let sql = `
    SELECT m.id, m.nhom_mon_id AS nhom_id, m.ten, m.mo_ta, m.anh_url,
           mc.gia_co_ban AS gia, NOT mc.het_hang AS con_hang
    FROM mon m
    JOIN mon_chi_nhanh mc ON mc.mon_id = m.id
    WHERE mc.chi_nhanh_id = $1 AND m.dang_ban = TRUE`;
  const params = [chiNhanhId];

  if (nhomId !== null) {
    sql += " AND m.nhom_mon_id = $2"; // vế cố định, giá trị vẫn truyền bằng tham số
    params.push(nhomId);
  }
  sql += " ORDER BY m.id";

  const r = await truyVan(sql, params);
  return r.rows;
}

// GET /mon?chiNhanh=1&nhom=2  — công khai (khách xem thực đơn không cần đăng nhập)
router.get("/", async (req, res) => {
  const chiNhanhId = parseInt(req.query.chiNhanh, 10);
  if (!Number.isInteger(chiNhanhId)) {
    return res.status(400).json({ loi: "Thiếu hoặc sai tham số chiNhanh" });
  }

  let nhomId = null;
  if (req.query.nhom !== undefined) {
    nhomId = parseInt(req.query.nhom, 10);
    if (!Number.isInteger(nhomId)) {
      return res.status(400).json({ loi: "Tham số nhom không hợp lệ" });
    }
  }

  const cn = await truyVan("SELECT id FROM chi_nhanh WHERE id = $1", [
    chiNhanhId,
  ]);
  if (cn.rows.length === 0) {
    return res.status(404).json({ loi: "Không tìm thấy chi nhánh" });
  }

  res.json(await layThucDon(chiNhanhId, nhomId));
});

module.exports = router;
module.exports.layThucDon = layThucDon;

const express = require("express");
const { truyVan } = require("../db");
const { layThucDon } = require("./thuc-don");

const router = express.Router();

// GET /ban/:maQr  — công khai (ai quét QR cũng xem được thực đơn của bàn đó)
router.get("/:maQr", async (req, res) => {
  const r = await truyVan(
    `SELECT b.id AS ban_id, b.ten_ban, b.ma_qr,
            c.id AS chi_nhanh_id, c.ten AS chi_nhanh_ten, c.dia_chi
     FROM ban b
     JOIN chi_nhanh c ON c.id = b.chi_nhanh_id
     WHERE b.ma_qr = $1 AND b.dang_dung = TRUE`,
    [req.params.maQr],
  );
  const row = r.rows[0];
  if (!row) return res.status(404).json({ loi: "Không tìm thấy bàn" });

  res.json({
    ban: { id: row.ban_id, ten_ban: row.ten_ban, ma_qr: row.ma_qr },
    chi_nhanh: {
      id: row.chi_nhanh_id,
      ten: row.chi_nhanh_ten,
      dia_chi: row.dia_chi,
    },
    thuc_don: await layThucDon(row.chi_nhanh_id, null),
  });
});

module.exports = router;

require("dotenv").config();
const { Pool, types } = require("pg");

// Cột BIGINT / BIGSERIAL (id, tiền) mặc định pg trả về CHUỖI ("29000"). Ép về số cho đúng contract.
types.setTypeParser(20, (v) => parseInt(v, 10));

// Supabase (pooler, session mode, cổng 5432) yêu cầu SSL.
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false },
  max: 5, // gói Free, đừng mở quá nhiều kết nối
});

// Luôn truyền tham số dạng $1, $2 — KHÔNG nối chuỗi SQL
const truyVan = (sql, params) => pool.query(sql, params);

// Dùng cho nghiệp vụ cần transaction (tạo đơn, trừ lượt mã giảm giá...)
async function trongGiaoDich(callback) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const ketQua = await callback(client);
    await client.query("COMMIT");
    return ketQua;
  } catch (e) {
    await client.query("ROLLBACK");
    throw e;
  } finally {
    client.release();
  }
}

module.exports = { pool, truyVan, trongGiaoDich };

const express = require("express");
require("express-async-errors");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(express.json());

// Đây là endpoint bắt buộc để Render kiểm tra sức khỏe hệ thống
app.get("/health", (req, res) => {
  res
    .status(200)
    .json({ status: "Healthy", message: "DOAN_NHOM_36 Backend is running!" });
});

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ loi: "Lỗi máy chủ" });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});

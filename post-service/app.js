import express from "express";
import dotenv from "dotenv";
import connectDB from "./db/dbconn.js";
import postRoutes from "./routes/postRoutes.js";
import cors from "cors";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5001;

// Middleware
app.use(cors());
app.use(express.json());

// DB Connection
connectDB();

// Routes
app.use("/api/post", postRoutes);

app.get("/", (req, res) => {
  res.send("Post Service is running...");
});

app.listen(PORT, () => {
  console.log(`🚀 Post Service running on port ${PORT}`);
});

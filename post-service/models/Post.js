import mongoose from "mongoose";

const postSchema = new mongoose.Schema(
  {
    title: { type: String, required: true },
    author: { type: String, required: true },
    content: { type: String, required: true },
  },
  { timestamps: true } // adds createdAt & updatedAt
);

const Post = mongoose.model("Post", postSchema);

export default Post;

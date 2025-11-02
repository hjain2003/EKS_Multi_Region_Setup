import Post from "../models/Post.js";

// @desc    Create a new post
// @route   POST /api/post
export const createPost = async (req, res) => {
  try {
    const { title, author, content } = req.body;
    if (!title || !author || !content) {
      return res.status(400).json({ message: "All fields are required" });
    }

    const newPost = new Post({ title, author, content });
    await newPost.save();

    res.status(201).json(newPost);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// @desc    Get all posts
// @route   GET /api/post
export const getAllPosts = async (req, res) => {
  try {
    const posts = await Post.find().sort({ createdAt: -1 }); // latest first
    res.json(posts);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

/**
 * CORS Configuration for PlateUp Cloud Functions
 */

const cors = require("cors");

// Configure CORS to allow requests from PlateUp app
export const corsHandler = cors({
  origin: [
    "http://localhost:*",
    "https://plateup-*.web.app",
    "https://plateup-*.firebaseapp.com",
    "plateup://", // iOS app scheme
  ],
  credentials: true,
  methods: ["GET", "POST", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization"],
});

// Helper function to wrap functions with CORS
export function withCors(handler: any) {
  return (req: any, res: any) => {
    corsHandler(req, res, () => {
      handler(req, res);
    });
  };
}
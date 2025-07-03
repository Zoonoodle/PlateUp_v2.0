/**
 * PlateUp v2.0 Cloud Functions
 * 
 * This file contains all Firebase Cloud Functions for PlateUp including:
 * - Health Blueprint generation using Gemini 2.5 Pro
 * - Meal analysis and coaching insights
 * - User data processing
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { generateHealthBlueprint } from "./healthBlueprint";
import { analyzeMealImage, processClarificationAnswers } from "./mealAnalysis";
import { generateCoachingInsights } from "./coachingInsights";
import { AIPerformanceMonitor } from "./aiPerformanceMonitor";
import { generatePersonalizedRecipe, generateWeeklyMealPlan, rateRecipe } from "./recipeGeneration";

// Initialize Firebase Admin
admin.initializeApp();

// Export Cloud Functions
export const healthBlueprint = functions.https.onCall(generateHealthBlueprint);
export const mealAnalysis = functions.https.onCall(analyzeMealImage);
export const processClarifications = functions.https.onCall(processClarificationAnswers);
export const coachingInsights = functions.https.onCall(generateCoachingInsights);
export const generateRecipe = functions.https.onCall(generatePersonalizedRecipe);
export const generateMealPlan = functions.https.onCall(generateWeeklyMealPlan);
export const rateRecipeFunction = functions.https.onCall(rateRecipe);

// AI Performance Monitoring Functions
export const getAIPerformance = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Admin access required");
  }
  
  const monitor = new AIPerformanceMonitor();
  const period = data.period || "daily";
  return await monitor.generatePerformanceReport(period);
});

export const submitFeedback = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
  }
  
  const monitor = new AIPerformanceMonitor();
  await monitor.processFeedback(data.interactionId, {
    rating: data.rating,
    accuracy: data.accuracy,
    helpfulness: data.helpfulness,
    clarificationQuality: data.clarificationQuality,
    specificFeedback: data.feedback,
    timestamp: new Date()
  });
  
  return { success: true };
});

// Scheduled function to generate daily coaching insights
export const dailyCoachingJob = functions.pubsub
  .schedule("every day 08:00")
  .timeZone("America/New_York")
  .onRun(async (_context) => {
    console.log("Running daily coaching insights generation");
    
    // Get all active users
    const usersSnapshot = await admin.firestore()
      .collection("users")
      .where("isActive", "==", true)
      .get();
    
    // Generate insights for each user
    const promises = usersSnapshot.docs.map(async (userDoc) => {
      try {
        const userId = userDoc.id;
        await generateCoachingInsights({ userId }, { auth: { uid: userId } } as any);
      } catch (error) {
        console.error(`Failed to generate insights for user ${userDoc.id}:`, error);
      }
    });
    
    await Promise.all(promises);
    console.log(`Generated insights for ${usersSnapshot.size} users`);
  });

// Clean up old onboarding sessions (older than 30 days)
export const cleanupOnboarding = functions.pubsub
  .schedule("every day 03:00")
  .timeZone("America/New_York")
  .onRun(async (_context) => {
    console.log("Cleaning up old onboarding sessions");
    
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    
    const oldSessionsSnapshot = await admin.firestore()
      .collection("onboarding")
      .where("updatedAt", "<", thirtyDaysAgo)
      .where("isComplete", "==", false)
      .get();
    
    const batch = admin.firestore().batch();
    oldSessionsSnapshot.forEach((doc) => {
      batch.delete(doc.ref);
    });
    
    await batch.commit();
    console.log(`Deleted ${oldSessionsSnapshot.size} old onboarding sessions`);
  });

// Weekly AI performance report generation
export const weeklyAIReport = functions.pubsub
  .schedule("every monday 09:00")
  .timeZone("America/New_York")
  .onRun(async (_context) => {
    console.log("Generating weekly AI performance report");
    
    const monitor = new AIPerformanceMonitor();
    const report = await monitor.generatePerformanceReport("weekly");
    
    // Store report in Firestore
    await admin.firestore().collection("ai_reports").add({
      type: "weekly",
      report,
      generatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    
    // Check for critical issues
    const criticalIssues = report.filter(m => 
      m.metrics.successRate < 0.9 || 
      m.metrics.userSatisfaction < 3.5
    );
    
    if (criticalIssues.length > 0) {
      console.error("Critical AI performance issues detected:", criticalIssues);
      // In production, send alerts to team
    }
    
    console.log("Weekly AI report generated successfully");
  });

// Real-time meal recommendation function
export const getMealRecommendation = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
  }
  
  const { mealType, considerRemaining = true } = data;
  const userId = context.auth.uid;
  
  // Import necessary modules
  const { GeminiClient } = await import("./gemini");
  const gemini = new GeminiClient();
  
  // Get user profile and remaining macros
  const userDoc = await admin.firestore().collection("users").doc(userId).get();
  const userProfile = userDoc.data();
  
  if (!userProfile) {
    throw new functions.https.HttpsError("not-found", "User profile not found");
  }
  
  // Calculate remaining macros if needed
  let remainingMacros = null;
  if (considerRemaining) {
    const { calculateRemainingMacros } = await import("./mealAnalysis");
    remainingMacros = await calculateRemainingMacros(userId, userProfile.healthBlueprint);
  }
  
  // Generate personalized recommendations
  const recommendations = await gemini.generateMealRecommendations(
    userProfile,
    mealType,
    remainingMacros
  );
  
  return recommendations;
});
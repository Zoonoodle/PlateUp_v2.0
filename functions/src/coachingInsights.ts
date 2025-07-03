/**
 * Coaching Insights Generation Function
 * Uses Gemini Flash to generate personalized coaching insights
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
// import { GeminiClient } from "./gemini";
import { CoachingIntelligence, CoachingContext } from "./coachingIntelligence";
import { AIPerformanceMonitor } from "./aiPerformanceMonitor";

interface CoachingRequest {
  userId: string;
  timeframe?: "daily" | "weekly" | "monthly";
}

interface UserData {
  profile: any;
  recentMeals: any[];
  sleepData: any[];
  activityData: any[];
  previousInsights: any[];
}

export async function generateCoachingInsights(
  data: CoachingRequest,
  context: functions.https.CallableContext
): Promise<{ insights: any[] }> {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated"
    );
  }

  const { userId, timeframe = "daily" } = data;
  const coachingIntelligence = new CoachingIntelligence();
  const monitor = new AIPerformanceMonitor();
  const interactionId = `coaching_${userId}_${Date.now()}`;
  const startTime = Date.now();

  try {
    // Gather user data for analysis
    const userData = await gatherUserData(userId, timeframe);
    
    // Get user's health blueprint
    const userDoc = await admin.firestore().collection("users").doc(userId).get();
    const healthBlueprint = userDoc.data()?.healthBlueprint || {};
    
    // Create coaching context
    const coachingContext: CoachingContext = {
      userId,
      userProfile: {
        name: userData.profile?.name || "User",
        primaryGoal: userData.profile?.primaryGoal || "ENERGY_OPTIMIZATION",
        secondaryGoals: userData.profile?.secondaryGoals || [],
        restrictions: userData.profile?.dietaryRestrictions || [],
        preferences: userData.profile?.dietaryPreferences || [],
        currentMetrics: {
          weight: userData.profile?.weight || 0,
          bodyFat: userData.profile?.bodyFat,
          energyAverage: calculateAverageEnergy(userData.recentMeals),
          sleepQualityAverage: calculateAverageSleep(userData.sleepData)
        }
      },
      recentMeals: userData.recentMeals,
      sleepData: userData.sleepData,
      energyLevels: extractEnergyLevels(userData.recentMeals),
      activityData: userData.activityData,
      previousInsights: userData.previousInsights,
      healthBlueprint
    };
    
    // Generate insights using enhanced coaching intelligence
    const insights = await coachingIntelligence.generateCoachingInsights(coachingContext);
    
    // Track AI performance
    await monitor.trackInteraction({
      id: interactionId,
      userId,
      timestamp: new Date(),
      interactionType: "coaching",
      request: {
        input: { timeframe },
        context: coachingContext,
        modelUsed: "gemini-1.5-flash"
      },
      response: {
        output: insights,
        processingTime: Date.now() - startTime
      },
      metrics: {
        responseTime: Date.now() - startTime,
        errorRate: 0,
        retryCount: 0,
        cacheHit: false,
        edgeCases: []
      }
    });
    
    return { insights };
  } catch (error) {
    console.error("Error generating coaching insights:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Failed to generate coaching insights"
    );
  }
}

async function gatherUserData(userId: string, timeframe: string): Promise<UserData> {
  const db = admin.firestore();
  
  // Calculate date range based on timeframe
  const endDate = new Date();
  const startDate = new Date();
  
  switch (timeframe) {
    case "weekly":
      startDate.setDate(startDate.getDate() - 7);
      break;
    case "monthly":
      startDate.setDate(startDate.getDate() - 30);
      break;
    default: // daily
      startDate.setDate(startDate.getDate() - 1);
  }
  
  // Fetch user profile
  const profileDoc = await db.collection("users").doc(userId).get();
  const profile = profileDoc.data();
  
  // Fetch recent meals
  const mealsSnapshot = await db.collection("meals")
    .where("userId", "==", userId)
    .where("timestamp", ">=", startDate)
    .where("timestamp", "<=", endDate)
    .orderBy("timestamp", "desc")
    .get();
  
  const recentMeals = mealsSnapshot.docs.map(doc => doc.data());
  
  // Mock sleep and activity data for now (will be integrated with wearables later)
  const sleepData = generateMockSleepData(startDate, endDate);
  const activityData = generateMockActivityData(startDate, endDate);
  
  // Fetch previous insights to avoid repetition
  const previousInsightsSnapshot = await db.collection("coaching_insights")
    .where("userId", "==", userId)
    .orderBy("createdAt", "desc")
    .limit(10)
    .get();
  
  const previousInsights = previousInsightsSnapshot.docs.map(doc => doc.data());
  
  return {
    profile,
    recentMeals,
    sleepData,
    activityData,
    previousInsights,
  };
}

/* Legacy function - kept for reference
function createCoachingPrompt(userData: UserData, timeframe: string): string {
  const { profile, recentMeals, sleepData, activityData, previousInsights } = userData;
  
  // Calculate meal statistics
  const mealStats = calculateMealStats(recentMeals);
  const sleepStats = calculateSleepStats(sleepData);
  const activityStats = calculateActivityStats(activityData);
  
  return `You are an expert nutrition coach analyzing ${profile.name}'s ${timeframe} data to provide personalized insights.

USER PROFILE:
- Primary Goal: ${profile.primaryGoal}
- Secondary Goals: ${profile.secondaryGoals?.join(", ") || "None"}
- Daily Calorie Target: ${profile.healthBlueprint?.dailyCalorieTarget || "Not set"}
- Macro Targets: Protein ${profile.healthBlueprint?.proteinTarget}g, Carbs ${profile.healthBlueprint?.carbTarget}g, Fat ${profile.healthBlueprint?.fatTarget}g

${timeframe.toUpperCase()} STATISTICS:
${mealStats}
${sleepStats}
${activityStats}

RECENT MEAL PATTERNS:
${analyzeMealPatterns(recentMeals)}

PREVIOUS INSIGHTS (avoid repeating these):
${previousInsights.map(i => i.title).join("\n")}

Generate 3-5 specific, actionable coaching insights based on the data. Each insight should:

1. Have a clear, engaging title
2. Identify a specific pattern or issue in their data
3. Explain why this matters for their ${profile.primaryGoal}
4. Provide a concrete action they can take
5. Be encouraging but honest about areas for improvement

Focus on:
- Meal timing patterns affecting energy/sleep
- Macro balance issues
- Consistency gaps
- Progress blockers
- Small wins to celebrate

Format each insight as a JSON object with:
{
  "title": "Clear, actionable title",
  "category": "nutrition|sleep|activity|timing|consistency",
  "severity": "success|info|warning|critical",
  "description": "2-3 sentences explaining the pattern",
  "action": "Specific action to take",
  "impact": "Expected benefit if they follow the advice",
  "metrics": { relevant data points }
}

Return an array of these insight objects.`;
}
*/

/* Currently unused - kept for reference
function calculateMealStats(meals: any[]): string {
  if (meals.length === 0) return "No meals logged in this period";
  
  const totalCalories = meals.reduce((sum, meal) => sum + (meal.calories || 0), 0);
  const avgCalories = Math.round(totalCalories / meals.length);
  const totalProtein = meals.reduce((sum, meal) => sum + (meal.protein || 0), 0);
  const avgProtein = Math.round(totalProtein / meals.length);
  
  const mealTimes = meals.map(m => new Date(m.timestamp).getHours());
  const avgMealTime = Math.round(mealTimes.reduce((a, b) => a + b, 0) / mealTimes.length);
  
  return `
- Total Meals: ${meals.length}
- Average Calories per Meal: ${avgCalories}
- Average Protein per Meal: ${avgProtein}g
- Most Common Meal Time: ${avgMealTime}:00
- Meal Consistency: ${calculateConsistency(meals)}%`;
}
*/

/* Currently unused - kept for reference
function calculateSleepStats(sleepData: any[]): string {
  if (sleepData.length === 0) return "No sleep data available";
  
  const avgSleep = sleepData.reduce((sum, day) => sum + day.hours, 0) / sleepData.length;
  const quality = sleepData.reduce((sum, day) => sum + day.quality, 0) / sleepData.length;
  
  return `
- Average Sleep: ${avgSleep.toFixed(1)} hours
- Sleep Quality: ${(quality * 100).toFixed(0)}%
- Sleep Consistency: ${calculateSleepConsistency(sleepData)}%`;
}
*/

/* Currently unused - kept for reference
function calculateActivityStats(activityData: any[]): string {
  if (activityData.length === 0) return "No activity data available";
  
  const totalSteps = activityData.reduce((sum, day) => sum + day.steps, 0);
  const avgSteps = Math.round(totalSteps / activityData.length);
  const workoutDays = activityData.filter(day => day.workout).length;
  
  return `
- Average Daily Steps: ${avgSteps}
- Workout Days: ${workoutDays}
- Activity Level: ${determineActivityLevel(avgSteps)}`;
}
*/

/* Currently unused - kept for reference
function analyzeMealPatterns(meals: any[]): string {
  if (meals.length === 0) return "No meal patterns to analyze";
  
  // Group meals by time of day
  const breakfast = meals.filter(m => {
    const hour = new Date(m.timestamp).getHours();
    return hour >= 5 && hour < 11;
  });
  const lunch = meals.filter(m => {
    const hour = new Date(m.timestamp).getHours();
    return hour >= 11 && hour < 15;
  });
  const dinner = meals.filter(m => {
    const hour = new Date(m.timestamp).getHours();
    return hour >= 17 && hour < 21;
  });
  const lateNight = meals.filter(m => {
    const hour = new Date(m.timestamp).getHours();
    return hour >= 21 || hour < 5;
  });
  
  return `
- Breakfast: ${breakfast.length} meals (avg ${avgCalories(breakfast)} cal)
- Lunch: ${lunch.length} meals (avg ${avgCalories(lunch)} cal)
- Dinner: ${dinner.length} meals (avg ${avgCalories(dinner)} cal)
- Late Night: ${lateNight.length} meals ${lateNight.length > 0 ? '⚠️' : '✓'}`;
}
*/

/* Currently unused helper functions - kept for reference
function avgCalories(meals: any[]): number {
  if (meals.length === 0) return 0;
  return Math.round(meals.reduce((sum, m) => sum + (m.calories || 0), 0) / meals.length);
}

function calculateConsistency(meals: any[]): number {
  // Simple consistency metric based on meal frequency
  const expectedMeals = 3; // per day
  const days = new Set(meals.map(m => new Date(m.timestamp).toDateString())).size;
  const actualMealsPerDay = meals.length / days;
  return Math.min(100, Math.round((actualMealsPerDay / expectedMeals) * 100));
}

function calculateSleepConsistency(sleepData: any[]): number {
  if (sleepData.length < 2) return 100;
  
  const bedtimes = sleepData.map(d => d.bedtime);
  const differences = [];
  
  for (let i = 1; i < bedtimes.length; i++) {
    differences.push(Math.abs(bedtimes[i] - bedtimes[i-1]));
  }
  
  const avgDifference = differences.reduce((a, b) => a + b, 0) / differences.length;
  // If average difference is less than 30 minutes, consider it consistent
  return avgDifference < 0.5 ? 100 : Math.round(100 - (avgDifference * 20));
}

function determineActivityLevel(avgSteps: number): string {
  if (avgSteps < 5000) return "Sedentary";
  if (avgSteps < 7500) return "Lightly Active";
  if (avgSteps < 10000) return "Moderately Active";
  if (avgSteps < 12500) return "Active";
  return "Very Active";
}
*/

/* Legacy function - kept for reference
function parseCoachingResponse(response: string, userId: string): any[] {
  try {
    // Try to parse as JSON array
    const insights = JSON.parse(response);
    
    // Add metadata to each insight
    return insights.map((insight: any) => ({
      ...insight,
      id: admin.firestore().collection("coaching_insights").doc().id,
      userId,
      createdAt: new Date(),
      isActive: true,
      expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days
      dismissedAt: null,
      userFeedback: null,
    }));
  } catch (error) {
    console.error("Failed to parse coaching response:", error);
    
    // Fallback: create a generic insight
    return [{
      id: admin.firestore().collection("coaching_insights").doc().id,
      userId,
      title: "Time to Review Your Progress",
      category: "general",
      severity: "info",
      description: "We've analyzed your recent data. Keep logging your meals consistently for more personalized insights.",
      action: "Log your next meal with accurate portions",
      impact: "Better insights lead to faster progress",
      metrics: {},
      createdAt: new Date(),
      isActive: true,
      expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      dismissedAt: null,
      userFeedback: null,
    }];
  }
}
*/

/* Legacy function - kept for reference
async function saveInsights(insights: any[], userId: string): Promise<void> {
  const db = admin.firestore();
  const batch = db.batch();
  
  for (const insight of insights) {
    const docRef = db.collection("coaching_insights").doc(insight.id);
    batch.set(docRef, insight);
  }
  
  await batch.commit();
  console.log(`Saved ${insights.length} insights for user ${userId}`);
}
*/

// Mock data generators (will be replaced with real integrations)
function generateMockSleepData(startDate: Date, endDate: Date): any[] {
  const data = [];
  const current = new Date(startDate);
  
  while (current <= endDate) {
    data.push({
      date: new Date(current),
      hours: 6 + Math.random() * 3, // 6-9 hours
      quality: 0.6 + Math.random() * 0.4, // 60-100% quality
      bedtime: 22 + Math.random() * 2, // 10pm-12am
    });
    current.setDate(current.getDate() + 1);
  }
  
  return data;
}

function generateMockActivityData(startDate: Date, endDate: Date): any[] {
  const data = [];
  const current = new Date(startDate);
  
  while (current <= endDate) {
    data.push({
      date: new Date(current),
      steps: 3000 + Math.random() * 12000, // 3k-15k steps
      workout: Math.random() > 0.6, // 40% chance of workout
      activeMinutes: 10 + Math.random() * 50,
    });
    current.setDate(current.getDate() + 1);
  }
  
  return data;
}

// Helper functions for enhanced coaching
function calculateAverageEnergy(meals: any[]): number {
  const energyLevels = meals
    .filter(m => m.postMealEnergy)
    .map(m => m.postMealEnergy);
  
  if (energyLevels.length === 0) return 5; // Default middle value
  return energyLevels.reduce((sum, level) => sum + level, 0) / energyLevels.length;
}

function calculateAverageSleep(sleepData: any[]): number {
  if (sleepData.length === 0) return 5;
  const qualities = sleepData.map(s => s.quality);
  return qualities.reduce((sum, q) => sum + q, 0) / qualities.length;
}

function extractEnergyLevels(meals: any[]): any[] {
  const energyData: any[] = [];
  
  meals.forEach(meal => {
    if (meal.postMealEnergy) {
      energyData.push({
        timestamp: new Date(meal.timestamp),
        level: meal.postMealEnergy,
        context: `post-${meal.mealType}`,
        affectingFactors: [meal.mealType, `calories-${meal.calories}`]
      });
    }
  });
  
  return energyData;
}
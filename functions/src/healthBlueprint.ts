/**
 * Health Blueprint Generation Function
 * Uses Gemini 2.5 Pro to create personalized nutrition plans
 */

import * as functions from "firebase-functions";
import { GeminiClient } from "./gemini";
import { AIPerformanceMonitor } from "./aiPerformanceMonitor";

interface OnboardingData {
  primaryGoal: string;
  secondaryGoals: string[];
  physicalStats: {
    age?: number;
    weight?: number;
    weightUnit?: string;
    height?: number;
    heightUnit?: string;
    bodyFatPercentage?: number;
    sex?: string;
  };
  dailyActivity: {
    activityLevel?: string;
    workoutFrequency?: number;
    workoutTypes?: string[];
    sleepHours?: number;
    sleepQuality?: string;
  };
  dietaryPreferences: {
    restrictions?: string[];
    allergies?: string[];
    dislikedFoods?: string[];
    mealPrep?: boolean;
    cookingTime?: string;
  };
  lifestyleFactors: {
    workSchedule?: string;
    stressLevel?: string;
    hydrationGoal?: number;
    alcoholFrequency?: string;
  };
}

export async function generateHealthBlueprint(
  data: OnboardingData,
  context: functions.https.CallableContext
): Promise<{ blueprint: any }> {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated"
    );
  }

  const monitor = new AIPerformanceMonitor();
  const interactionId = `blueprint_${context.auth.uid}_${Date.now()}`;
  const startTime = Date.now();

  try {
    // Unit conversions and calculations removed - now handled in blueprint generation

    // Create the prompt for Gemini
    // const prompt = createHealthBlueprintPrompt(data, tdee); // Now handled in gemini.ts

    // Get Gemini client
    const gemini = new GeminiClient();
    
    // Track AI interaction start
    const aiContext = {
      userId: context.auth.uid,
      primaryGoal: data.primaryGoal,
      restrictions: data.dietaryPreferences.restrictions,
      preferences: data.dietaryPreferences.dislikedFoods
    };
    
    // Generate the health blueprint using enhanced Gemini 2.5 Pro
    const response = await gemini.generateHealthBlueprint(data);
    
    // Track AI performance
    await monitor.trackInteraction({
      id: interactionId,
      userId: context.auth.uid,
      timestamp: new Date(),
      interactionType: "blueprint",
      request: {
        input: data,
        context: aiContext,
        modelUsed: "gemini-2.5-pro-thinking"
      },
      response: {
        output: response,
        processingTime: Date.now() - startTime,
        tokensUsed: response.tokensUsed
      },
      metrics: {
        responseTime: Date.now() - startTime,
        errorRate: 0,
        retryCount: 0,
        cacheHit: false,
        edgeCases: []
      }
    });
    
    // Parse and enhance the blueprint
    const blueprint = {
      ...response,
      generatedAt: new Date(),
      version: "2.0",
      aiModel: "gemini-2.5-pro-thinking",
      userId: context.auth.uid,
      onboardingData: data
    };

    return { blueprint };
  } catch (error) {
    console.error("Error generating health blueprint:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Failed to generate health blueprint"
    );
  }
}

// Unit conversion functions removed - now handled in blueprint generation

// calculateBMR function removed - now handled in blueprint generation

// calculateTDEE function removed - now handled in blueprint generation

/* Legacy function - kept for reference
function createHealthBlueprintPrompt(data: OnboardingData, tdee: number): string {
  return `You are an expert nutritionist creating a personalized health blueprint for a client.

CLIENT PROFILE:
Primary Goal: ${data.primaryGoal}
Secondary Goals: ${data.secondaryGoals.join(", ")}
Age: ${data.physicalStats.age} years
Weight: ${data.physicalStats.weight} ${data.physicalStats.weightUnit}
Height: ${data.physicalStats.height} ${data.physicalStats.heightUnit}
Body Fat: ${data.physicalStats.bodyFatPercentage || "Not provided"}%
Sex: ${data.physicalStats.sex}
Activity Level: ${data.dailyActivity.activityLevel}
Workout Frequency: ${data.dailyActivity.workoutFrequency} times/week
Workout Types: ${data.dailyActivity.workoutTypes?.join(", ") || "Not specified"}
Sleep: ${data.dailyActivity.sleepHours} hours (Quality: ${data.dailyActivity.sleepQuality})
Dietary Restrictions: ${data.dietaryPreferences.restrictions?.join(", ") || "None"}
Allergies: ${data.dietaryPreferences.allergies?.join(", ") || "None"}
Work Schedule: ${data.lifestyleFactors.workSchedule}
Stress Level: ${data.lifestyleFactors.stressLevel}
TDEE (calculated): ${tdee} calories

Create a comprehensive health blueprint that includes:

1. DAILY CALORIE TARGET: Based on their goal (weight loss = TDEE - 500, muscle gain = TDEE + 300, maintenance = TDEE)

2. MACRO TARGETS (in grams):
   - Protein: Calculate based on goal and activity level
   - Carbohydrates: Adjust based on workout intensity and timing
   - Fat: Minimum 0.3g per lb body weight, adjust for goals
   - Fiber: 25-35g daily

3. MEAL TIMING RECOMMENDATIONS:
   - Optimal windows for breakfast, lunch, dinner
   - Pre/post workout nutrition if applicable
   - Consider their work schedule and lifestyle

4. PERSONALIZED ADVICE (5-7 specific recommendations):
   - Based on their unique combination of goals, lifestyle, and preferences
   - Address their specific challenges (stress, sleep, schedule)
   - Practical and actionable

5. WEEKLY GOALS (3-5 measurable goals):
   - Specific to their primary goal
   - Realistic and achievable
   - Include nutrition, hydration, and lifestyle factors

6. SUPPLEMENT RECOMMENDATIONS (optional, only if truly beneficial):
   - Based on their diet restrictions and goals
   - Evidence-based suggestions only

Format your response as a structured JSON object with clear sections for each component.`;
}
*/

/* No longer needed - handled in gemini.ts
function parseGeminiResponse(
  response: string,
  tdee: number,
  data: OnboardingData
): any {
  try {
    // Try to parse as JSON first
    const parsed = JSON.parse(response);
    return {
      generatedAt: new Date(),
      ...parsed,
    };
  } catch {
    // If not valid JSON, create a structured response from the text
    return {
      generatedAt: new Date(),
      dailyCalorieTarget: calculateCalorieTarget(tdee, data.primaryGoal),
      macroTargets: {
        protein: Math.round(data.physicalStats.weight! * 0.8), // 0.8g per lb as default
        carbs: Math.round(tdee * 0.4 / 4), // 40% of calories from carbs
        fat: Math.round(tdee * 0.3 / 9), // 30% of calories from fat
        fiber: 30,
      },
      mealTiming: {
        breakfastWindow: "7:00 AM - 9:00 AM",
        lunchWindow: "12:00 PM - 1:30 PM",
        dinnerWindow: "6:00 PM - 7:30 PM",
        snackWindows: ["10:00 AM", "3:00 PM"],
        fastingWindow: data.primaryGoal.includes("weight loss") ? "7:30 PM - 7:00 AM" : null,
      },
      personalizedAdvice: [
        `Focus on ${data.primaryGoal} by maintaining a consistent meal schedule`,
        "Prioritize protein intake to support your fitness goals",
        "Stay hydrated with at least 3 liters of water daily",
        "Consider meal prep on Sundays to stay on track during busy weekdays",
        "Track your progress weekly to ensure you're moving toward your goals",
      ],
      weeklyGoals: [
        "Hit your daily protein target at least 6 days this week",
        "Complete all planned workouts",
        "Get 7+ hours of sleep at least 5 nights",
        "Prep meals for at least 3 days",
        "Log all meals consistently",
      ],
      supplementRecommendations: data.dietaryPreferences.restrictions?.includes("vegan")
        ? ["Vitamin B12", "Vitamin D3", "Omega-3 (algae-based)"]
        : ["Vitamin D3", "Omega-3 fish oil"],
    };
  }
}
*/

/* Legacy function - kept for reference
function calculateCalorieTarget(tdee: number, goal: string): number {
  if (goal.toLowerCase().includes("weight loss") || goal.toLowerCase().includes("fat loss")) {
    return tdee - 500; // 500 calorie deficit for ~1 lb/week loss
  } else if (goal.toLowerCase().includes("muscle") || goal.toLowerCase().includes("gain")) {
    return tdee + 300; // 300 calorie surplus for lean gains
  } else {
    return tdee; // Maintenance
  }
}
*/
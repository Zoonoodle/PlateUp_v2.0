/**
 * Meal Analysis Function
 * Analyzes meal images and provides nutritional information
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { GeminiClient, FoodAnalysis } from "./gemini";
import { AIPerformanceMonitor } from "./aiPerformanceMonitor";
import { CoachingIntelligence } from "./coachingIntelligence";

export async function analyzeMealImage(
  data: { imageBase64?: string; imageUrl?: string; mealType: string; userId: string; voiceDescription?: string },
  context: functions.https.CallableContext
): Promise<{ analysis: FoodAnalysis; coaching?: any }> {
  // Verify authentication
  if (!context.auth || context.auth.uid !== data.userId) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated"
    );
  }

  const gemini = new GeminiClient();
  const monitor = new AIPerformanceMonitor();
  const coachingIntelligence = new CoachingIntelligence();
  const interactionId = `meal_${data.userId}_${Date.now()}`;
  const startTime = Date.now();

  try {
    // Get user context for personalized analysis
    const userDoc = await admin.firestore().collection("users").doc(data.userId).get();
    const userProfile = userDoc.data();
    const userContext = {
      primaryGoal: userProfile?.primaryGoal || "ENERGY_OPTIMIZATION",
      restrictions: userProfile?.dietaryRestrictions || [],
      preferences: userProfile?.dietaryPreferences || [],
      allergies: userProfile?.allergies || [],
      healthBlueprint: userProfile?.healthBlueprint || {}
    };

    let analysis: FoodAnalysis;
    
    if (data.imageBase64 || data.imageUrl) {
      // Image-based analysis
      let imageBase64 = data.imageBase64;
      
      // If URL provided, fetch and convert to base64
      if (data.imageUrl && !imageBase64) {
        // In production, implement image fetching
        throw new functions.https.HttpsError(
          "unimplemented",
          "URL to base64 conversion not yet implemented"
        );
      }
      
      // Analyze image with AI
      analysis = await gemini.analyzeImage(imageBase64!, userContext);
    } else if (data.voiceDescription) {
      // Voice/text-based analysis
      const voicePrompt = createVoiceAnalysisPrompt(data.voiceDescription, userContext);
      const response = await gemini.generateContent(voicePrompt, "flash");
      analysis = parseVoiceAnalysis(response.response);
    } else {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Either image or voice description must be provided"
      );
    }

    // Get remaining macros for the day
    const remainingMacros = await calculateRemainingMacros(data.userId, userProfile?.healthBlueprint);
    
    // Generate meal-specific coaching
    const mealData = {
      id: interactionId,
      timestamp: new Date(),
      foods: analysis.items,
      calories: analysis.totalNutrition.calories,
      protein: analysis.totalNutrition.protein,
      carbs: analysis.totalNutrition.carbs,
      fat: analysis.totalNutrition.fat,
      fiber: analysis.totalNutrition.fiber,
      mealType: data.mealType
    };
    
    const coaching = userProfile ? await coachingIntelligence.generateMealFeedback(
      mealData,
      {
        name: userProfile.name || "User",
        primaryGoal: userProfile.primaryGoal || "ENERGY_OPTIMIZATION",
        secondaryGoals: userProfile.secondaryGoals || [],
        restrictions: userProfile.dietaryRestrictions || [],
        preferences: userProfile.dietaryPreferences || [],
        currentMetrics: {
          weight: userProfile.weight || 0,
          bodyFat: userProfile.bodyFat,
          energyAverage: 5,
          sleepQualityAverage: 5
        }
      },
      remainingMacros
    ) : null;

    // Track AI performance
    await monitor.trackInteraction({
      id: interactionId,
      userId: data.userId,
      timestamp: new Date(),
      interactionType: "food_scan",
      request: {
        input: data,
        context: userContext,
        modelUsed: "gemini-1.5-flash"
      },
      response: {
        output: analysis,
        confidence: analysis.items.reduce((sum, item) => sum + item.confidence, 0) / analysis.items.length,
        processingTime: Date.now() - startTime
      },
      metrics: {
        responseTime: Date.now() - startTime,
        errorRate: 0,
        retryCount: 0,
        cacheHit: false,
        edgeCases: analysis.clarificationQuestions ? ["clarifications_needed"] : []
      }
    });

    // Save to Firestore
    const mealDoc = {
      userId: data.userId,
      mealType: data.mealType,
      analysis,
      coaching,
      remainingMacros,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      aiInteractionId: interactionId
    };
    
    await admin.firestore().collection("meals").doc(interactionId).set(mealDoc);

    return { analysis, coaching };
  } catch (error) {
    console.error("Error analyzing meal:", error);
    
    // Track error in monitoring
    if (monitor && interactionId) {
      await monitor.trackInteraction({
        id: interactionId,
        userId: data.userId,
        timestamp: new Date(),
        interactionType: "food_scan",
        request: {
          input: data,
          context: {},
          modelUsed: "gemini-1.5-flash"
        },
        response: {
          output: null,
          processingTime: Date.now() - startTime
        },
        metrics: {
          responseTime: Date.now() - startTime,
          errorRate: 1,
          retryCount: 0,
          cacheHit: false,
          edgeCases: ["error"]
        }
      });
    }
    
    throw new functions.https.HttpsError(
      "internal",
      "Failed to analyze meal"
    );
  }
}

/**
 * Process clarification answers to improve analysis
 */
export async function processClarificationAnswers(
  data: {
    mealId: string;
    userId: string;
    answers: Array<{
      questionId: string;
      answer: string;
    }>;
  },
  context: functions.https.CallableContext
): Promise<{ updatedAnalysis: FoodAnalysis }> {
  if (!context.auth || context.auth.uid !== data.userId) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated"
    );
  }

  const monitor = new AIPerformanceMonitor();

  try {
    // Get original meal analysis
    const mealDoc = await admin.firestore().collection("meals").doc(data.mealId).get();
    if (!mealDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Meal not found");
    }

    const mealData = mealDoc.data()!;
    const originalAnalysis = mealData.analysis;

    // Create prompt for refining analysis with answers
    const refinementPrompt = createRefinementPrompt(originalAnalysis, data.answers);
    
    const gemini = new GeminiClient();
    const response = await gemini.generateContent(refinementPrompt, "flash");
    const updatedAnalysis = response.response;

    // Track clarification effectiveness
    for (const _answer of data.answers) {
      await monitor.processFeedback(data.mealId, {
        clarificationQuality: 4, // Assume positive since user provided answer
        timestamp: new Date()
      });
    }

    // Update meal document
    await admin.firestore().collection("meals").doc(data.mealId).update({
      analysis: updatedAnalysis,
      clarificationAnswers: data.answers,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    return { updatedAnalysis };
  } catch (error) {
    console.error("Error processing clarifications:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Failed to process clarification answers"
    );
  }
}

// Helper functions
function createVoiceAnalysisPrompt(description: string, userContext: any): string {
  return `Analyze this meal description and provide detailed nutritional information.

USER CONTEXT:
- Goal: ${userContext.primaryGoal}
- Restrictions: ${userContext.restrictions.join(", ") || "None"}
- Allergies: ${userContext.allergies.join(", ") || "None"}

MEAL DESCRIPTION: "${description}"

Provide a detailed nutritional breakdown:
1. Identify all food items mentioned
2. Estimate portions based on typical servings
3. Calculate macros for each item
4. Flag any items that conflict with user restrictions
5. Suggest clarifications only if critical information is missing

Return as FoodAnalysis JSON format.`;
}

function parseVoiceAnalysis(response: any): FoodAnalysis {
  // Ensure response matches FoodAnalysis interface
  return {
    items: response.items || [],
    totalNutrition: response.totalNutrition || {
      calories: 0,
      protein: 0,
      carbs: 0,
      fat: 0,
      fiber: 0
    },
    mealType: response.mealType || "snack",
    healthScore: response.healthScore || 5,
    recommendations: response.recommendations || [],
    clarificationQuestions: response.clarificationQuestions
  };
}

export async function calculateRemainingMacros(userId: string, healthBlueprint: any): Promise<any> {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  
  // Get today's meals
  const mealsSnapshot = await admin.firestore()
    .collection("meals")
    .where("userId", "==", userId)
    .where("createdAt", ">=", today)
    .get();
  
  let consumedCalories = 0;
  let consumedProtein = 0;
  let consumedCarbs = 0;
  let consumedFat = 0;
  let consumedFiber = 0;
  
  mealsSnapshot.forEach(doc => {
    const meal = doc.data();
    if (meal.analysis?.totalNutrition) {
      consumedCalories += meal.analysis.totalNutrition.calories || 0;
      consumedProtein += meal.analysis.totalNutrition.protein || 0;
      consumedCarbs += meal.analysis.totalNutrition.carbs || 0;
      consumedFat += meal.analysis.totalNutrition.fat || 0;
      consumedFiber += meal.analysis.totalNutrition.fiber || 0;
    }
  });
  
  // Calculate remaining based on blueprint or defaults
  const targets = {
    calories: healthBlueprint?.dailyCalorieTarget || 2000,
    protein: healthBlueprint?.macroTargets?.protein || 150,
    carbs: healthBlueprint?.macroTargets?.carbs || 250,
    fat: healthBlueprint?.macroTargets?.fat || 65,
    fiber: healthBlueprint?.macroTargets?.fiber || 30
  };
  
  return {
    calories: Math.max(0, targets.calories - consumedCalories),
    protein: Math.max(0, targets.protein - consumedProtein),
    carbs: Math.max(0, targets.carbs - consumedCarbs),
    fat: Math.max(0, targets.fat - consumedFat),
    fiber: Math.max(0, targets.fiber - consumedFiber),
    consumed: {
      calories: consumedCalories,
      protein: consumedProtein,
      carbs: consumedCarbs,
      fat: consumedFat,
      fiber: consumedFiber
    },
    targets
  };
}

function createRefinementPrompt(originalAnalysis: any, answers: any[]): string {
  return `Refine this meal analysis based on clarification answers.

ORIGINAL ANALYSIS:
${JSON.stringify(originalAnalysis, null, 2)}

CLARIFICATION ANSWERS:
${answers.map(a => `Q: ${a.questionId}\nA: ${a.answer}`).join("\n\n")}

Update the analysis with more accurate information based on the answers provided.
Maintain the same JSON structure but update values as needed.`;
}
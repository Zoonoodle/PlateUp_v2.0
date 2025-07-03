/**
 * AI-Powered Recipe Generation for PlateUp v2.0
 * Creates personalized recipes based on user goals, preferences, and available ingredients
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { GeminiClient } from "./gemini";
import { NUTRITION_CURRICULUM, FOOD_QUALITY_SCORES } from "./nutritionCurriculum";
import { AIPerformanceMonitor } from "./aiPerformanceMonitor";

export interface RecipeRequest {
  userId: string;
  mealType: "breakfast" | "lunch" | "dinner" | "snack";
  servings?: number;
  cookingTime?: "quick" | "medium" | "long"; // <15min, 15-30min, >30min
  complexity?: "simple" | "moderate" | "complex";
  ingredients?: string[]; // Optional: use these ingredients
  avoidIngredients?: string[]; // Don't use these
  cuisine?: string; // Optional cuisine preference
  considerRemainingMacros?: boolean;
}

export interface GeneratedRecipe {
  id: string;
  name: string;
  description: string;
  servings: number;
  prepTime: number;
  cookTime: number;
  totalTime: number;
  difficulty: string;
  cuisine: string;
  ingredients: RecipeIngredient[];
  instructions: RecipeInstruction[];
  nutrition: NutritionPerServing;
  tags: string[];
  whyPersonalized: string[]; // Explains why this recipe fits user's goals
  tips: string[];
  substitutions: Substitution[];
  imagePrompt?: string; // For AI image generation
}

interface RecipeIngredient {
  name: string;
  amount: number;
  unit: string;
  preparation?: string; // e.g., "diced", "minced"
  category: "protein" | "carb" | "fat" | "vegetable" | "seasoning" | "other";
  isOptional?: boolean;
}

interface RecipeInstruction {
  step: number;
  instruction: string;
  duration?: number; // minutes
  technique?: string; // e.g., "sauté", "bake"
  temperature?: string; // e.g., "medium heat", "350°F"
}

interface NutritionPerServing {
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
  fiber: number;
  sugar?: number;
  sodium?: number;
  micronutrients?: { [key: string]: number };
}

interface Substitution {
  original: string;
  alternatives: string[];
  reason: string;
}

export async function generatePersonalizedRecipe(
  data: RecipeRequest,
  context: functions.https.CallableContext
): Promise<{ recipe: GeneratedRecipe }> {
  // Verify authentication
  if (!context.auth || context.auth.uid !== data.userId) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated"
    );
  }

  const gemini = new GeminiClient();
  const monitor = new AIPerformanceMonitor();
  const interactionId = `recipe_${data.userId}_${Date.now()}`;
  const startTime = Date.now();

  try {
    // Get user profile and health blueprint
    const userDoc = await admin.firestore().collection("users").doc(data.userId).get();
    const userProfile = userDoc.data();
    
    if (!userProfile) {
      throw new functions.https.HttpsError("not-found", "User profile not found");
    }

    // Get remaining macros if requested
    let remainingMacros = null;
    if (data.considerRemainingMacros) {
      remainingMacros = await calculateRemainingMacros(data.userId, userProfile.healthBlueprint);
    }

    // Get user's meal history for variety
    const recentMeals = await getRecentMeals(data.userId, 7); // Last 7 days

    // Create comprehensive recipe generation prompt
    const prompt = createRecipeGenerationPrompt({
      request: data,
      userProfile,
      remainingMacros,
      recentMeals,
      nutritionProtocol: NUTRITION_CURRICULUM[userProfile.primaryGoal],
      foodQualityGuidelines: FOOD_QUALITY_SCORES
    });

    // Generate recipe using Gemini Pro for complex reasoning
    const response = await gemini.generateContent(prompt, "pro");
    const recipe = parseRecipeResponse(response.response, interactionId);

    // Track AI performance
    await monitor.trackInteraction({
      id: interactionId,
      userId: data.userId,
      timestamp: new Date(),
      interactionType: "recipe",
      request: {
        input: data,
        context: { userGoal: userProfile.primaryGoal },
        modelUsed: "gemini-1.5-pro"
      },
      response: {
        output: recipe,
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

    // Save recipe to user's collection
    await admin.firestore()
      .collection("users")
      .doc(data.userId)
      .collection("recipes")
      .doc(recipe.id)
      .set({
        ...recipe,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        lastMade: null,
        rating: null,
        notes: null
      });

    return { recipe };
  } catch (error) {
    console.error("Error generating recipe:", error);
    
    // Track error
    await monitor.trackInteraction({
      id: interactionId,
      userId: data.userId,
      timestamp: new Date(),
      interactionType: "recipe",
      request: {
        input: data,
        context: {},
        modelUsed: "gemini-1.5-pro"
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
    
    throw new functions.https.HttpsError(
      "internal",
      "Failed to generate recipe"
    );
  }
}

/**
 * Generate meal plan for the week
 */
export async function generateWeeklyMealPlan(
  data: { userId: string; startDate: Date },
  context: functions.https.CallableContext
): Promise<{ mealPlan: any }> {
  if (!context.auth || context.auth.uid !== data.userId) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated"
    );
  }

  const gemini = new GeminiClient();
  const userDoc = await admin.firestore().collection("users").doc(data.userId).get();
  const userProfile = userDoc.data();

  if (!userProfile) {
    throw new functions.https.HttpsError("not-found", "User profile not found");
  }

  // Create meal plan generation prompt
  const prompt = createMealPlanPrompt({
    userProfile,
    nutritionProtocol: NUTRITION_CURRICULUM[userProfile.primaryGoal],
    startDate: data.startDate,
    preferences: userProfile.mealPlanPreferences || {}
  });

  // Generate comprehensive meal plan
  const response = await gemini.generateContent(prompt, "pro");
  const mealPlan = parseMealPlanResponse(response.response);

  // Save meal plan
  await admin.firestore()
    .collection("users")
    .doc(data.userId)
    .collection("mealPlans")
    .add({
      ...mealPlan,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      startDate: data.startDate,
      userId: data.userId
    });

  return { mealPlan };
}

// Helper functions
function createRecipeGenerationPrompt(context: any): string {
  const {
    request,
    userProfile,
    remainingMacros,
    recentMeals,
    nutritionProtocol,
    foodQualityGuidelines
  } = context;

  const cookingTimeMap: { [key: string]: string } = {
    quick: "under 15 minutes",
    medium: "15-30 minutes",
    long: "30-60 minutes"
  };

  return `You are an expert chef and nutritionist creating a personalized recipe.

USER PROFILE:
- Primary Goal: ${userProfile.primaryGoal}
- Dietary Restrictions: ${userProfile.dietaryRestrictions?.join(", ") || "None"}
- Allergies: ${userProfile.allergies?.join(", ") || "None"}
- Cooking Skill: ${userProfile.cookingSkill || "intermediate"}
- Kitchen Equipment: ${userProfile.kitchenEquipment?.join(", ") || "standard"}

RECIPE REQUEST:
- Meal Type: ${request.mealType}
- Servings: ${request.servings || 1}
- Cooking Time: ${cookingTimeMap[request.cookingTime || "medium"]}
- Complexity: ${request.complexity || "moderate"}
${request.ingredients ? `- Must Include: ${request.ingredients.join(", ")}` : ""}
${request.avoidIngredients ? `- Must Avoid: ${request.avoidIngredients.join(", ")}` : ""}
${request.cuisine ? `- Cuisine Preference: ${request.cuisine}` : ""}

${remainingMacros ? `REMAINING MACROS FOR TODAY:
- Calories: ${remainingMacros.calories}
- Protein: ${remainingMacros.protein}g
- Carbs: ${remainingMacros.carbs}g
- Fat: ${remainingMacros.fat}g
- Fiber: ${remainingMacros.fiber}g` : ""}

NUTRITION PROTOCOL FOR ${userProfile.primaryGoal}:
${JSON.stringify(nutritionProtocol?.keyPrinciples || [], null, 2)}

RECENT MEALS (avoid repetition):
${recentMeals.map((m: any) => m.name).slice(0, 10).join(", ")}

FOOD QUALITY PRIORITIES:
- Use high nutrient density foods: ${foodQualityGuidelines.NUTRIENT_DENSITY.high.join(", ")}
- Prioritize satiety: ${foodQualityGuidelines.SATIETY_INDEX.high.join(", ")}
- Include anti-inflammatory ingredients when possible

CREATE A RECIPE THAT:
1. Perfectly fits the user's ${request.mealType} needs
2. Aligns with their ${userProfile.primaryGoal} goal
3. Respects all restrictions and preferences
4. ${remainingMacros ? "Fits within their remaining macros" : "Provides balanced nutrition"}
5. Uses high-quality, whole food ingredients
6. Is genuinely delicious and satisfying
7. Includes clear, step-by-step instructions
8. Provides helpful tips and substitutions

Return as a JSON object with all required fields for GeneratedRecipe interface.
Include specific reasons why this recipe supports their ${userProfile.primaryGoal}.`;
}

function parseRecipeResponse(response: any, recipeId: string): GeneratedRecipe {
  // Ensure response has all required fields
  return {
    id: recipeId,
    name: response.name || "Personalized Recipe",
    description: response.description || "",
    servings: response.servings || 1,
    prepTime: response.prepTime || 10,
    cookTime: response.cookTime || 20,
    totalTime: response.totalTime || response.prepTime + response.cookTime || 30,
    difficulty: response.difficulty || "moderate",
    cuisine: response.cuisine || "fusion",
    ingredients: response.ingredients || [],
    instructions: response.instructions || [],
    nutrition: response.nutrition || {
      calories: 0,
      protein: 0,
      carbs: 0,
      fat: 0,
      fiber: 0
    },
    tags: response.tags || [],
    whyPersonalized: response.whyPersonalized || ["Tailored to your goals"],
    tips: response.tips || [],
    substitutions: response.substitutions || [],
    imagePrompt: response.imagePrompt
  };
}

async function calculateRemainingMacros(userId: string, healthBlueprint: any): Promise<any> {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  
  const mealsSnapshot = await admin.firestore()
    .collection("meals")
    .where("userId", "==", userId)
    .where("createdAt", ">=", today)
    .get();
  
  let consumed = {
    calories: 0,
    protein: 0,
    carbs: 0,
    fat: 0,
    fiber: 0
  };
  
  mealsSnapshot.forEach(doc => {
    const meal = doc.data();
    if (meal.analysis?.totalNutrition) {
      consumed.calories += meal.analysis.totalNutrition.calories || 0;
      consumed.protein += meal.analysis.totalNutrition.protein || 0;
      consumed.carbs += meal.analysis.totalNutrition.carbs || 0;
      consumed.fat += meal.analysis.totalNutrition.fat || 0;
      consumed.fiber += meal.analysis.totalNutrition.fiber || 0;
    }
  });
  
  const targets = {
    calories: healthBlueprint?.dailyCalorieTarget || 2000,
    protein: healthBlueprint?.macroTargets?.protein || 150,
    carbs: healthBlueprint?.macroTargets?.carbs || 250,
    fat: healthBlueprint?.macroTargets?.fat || 65,
    fiber: healthBlueprint?.macroTargets?.fiber || 30
  };
  
  return {
    calories: Math.max(0, targets.calories - consumed.calories),
    protein: Math.max(0, targets.protein - consumed.protein),
    carbs: Math.max(0, targets.carbs - consumed.carbs),
    fat: Math.max(0, targets.fat - consumed.fat),
    fiber: Math.max(0, targets.fiber - consumed.fiber)
  };
}

async function getRecentMeals(userId: string, days: number): Promise<any[]> {
  const startDate = new Date();
  startDate.setDate(startDate.getDate() - days);
  
  const mealsSnapshot = await admin.firestore()
    .collection("meals")
    .where("userId", "==", userId)
    .where("createdAt", ">=", startDate)
    .orderBy("createdAt", "desc")
    .get();
  
  return mealsSnapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
  }));
}

function createMealPlanPrompt(context: any): string {
  const { userProfile, nutritionProtocol, startDate, preferences } = context;
  
  return `Create a personalized 7-day meal plan starting ${startDate}.

USER PROFILE:
- Goal: ${userProfile.primaryGoal}
- Restrictions: ${userProfile.dietaryRestrictions?.join(", ") || "None"}
- Preferences: ${JSON.stringify(preferences)}

NUTRITION PROTOCOL:
${JSON.stringify(nutritionProtocol, null, 2)}

Create a varied, balanced meal plan that:
1. Follows the nutrition protocol exactly
2. Includes breakfast, lunch, dinner, and snacks
3. Provides shopping lists for each day
4. Includes prep instructions
5. Maximizes variety while being practical
6. Considers meal prep opportunities

Return as structured JSON with daily meals, macros, shopping lists, and prep schedule.`;
}

function parseMealPlanResponse(response: any): any {
  return {
    days: response.days || [],
    shoppingList: response.shoppingList || {},
    prepSchedule: response.prepSchedule || [],
    totalMacros: response.totalMacros || {},
    tips: response.tips || []
  };
}

/**
 * Rate and save user feedback on recipes
 */
export async function rateRecipe(
  data: {
    userId: string;
    recipeId: string;
    rating: number; // 1-5
    feedback?: string;
    wouldMakeAgain?: boolean;
    modifications?: string[];
  },
  context: functions.https.CallableContext
): Promise<{ success: boolean }> {
  if (!context.auth || context.auth.uid !== data.userId) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated"
    );
  }

  // Update recipe with rating
  await admin.firestore()
    .collection("users")
    .doc(data.userId)
    .collection("recipes")
    .doc(data.recipeId)
    .update({
      rating: data.rating,
      feedback: data.feedback,
      wouldMakeAgain: data.wouldMakeAgain,
      modifications: data.modifications,
      lastMade: admin.firestore.FieldValue.serverTimestamp()
    });

  // Track feedback for AI improvement
  const monitor = new AIPerformanceMonitor();
  await monitor.processFeedback(data.recipeId, {
    rating: data.rating >= 4 ? "positive" : data.rating <= 2 ? "negative" : "neutral",
    helpfulness: data.rating,
    specificFeedback: data.feedback,
    timestamp: new Date()
  });

  return { success: true };
}
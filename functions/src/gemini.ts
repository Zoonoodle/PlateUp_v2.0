/**
 * Gemini AI Integration for PlateUp v2.0
 * Enhanced with Gemini 2.5 Pro thinking mode and science-backed nutrition intelligence
 */

import { GoogleGenerativeAI, GenerativeModel, HarmCategory, HarmBlockThreshold } from "@google/generative-ai";
import * as functions from "firebase-functions";
import { NUTRITION_CURRICULUM, CIRCADIAN_MEAL_TIMING, FOOD_QUALITY_SCORES } from "./nutritionCurriculum";

// Types for structured responses
export interface GeminiResponse {
  success: boolean;
  model: string;
  response: any;
  tokensUsed?: number;
  thinkingProcess?: string;
}

export interface FoodAnalysis {
  items: FoodItem[];
  totalNutrition: NutritionInfo;
  mealType: string;
  healthScore: number;
  recommendations: string[];
  clarificationQuestions?: ClarificationQuestion[];
}

export interface FoodItem {
  name: string;
  quantity: number;
  unit: string;
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
  fiber: number;
  confidence: number;
}

export interface NutritionInfo {
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
  fiber: number;
  sugar?: number;
  sodium?: number;
}

export interface ClarificationQuestion {
  id: string;
  question: string;
  options: string[];
  category: "portion" | "preparation" | "ingredient" | "brand";
  impact: "high" | "medium" | "low";
}

export class GeminiClient {
  private genAI: GoogleGenerativeAI;
  private flashModel: GenerativeModel;
  private proModel: GenerativeModel;
  private proThinkingModel: GenerativeModel;
  
  constructor() {
    // Initialize with API key from Firebase config or environment
    const apiKey = functions.config().gemini?.api_key || process.env.GEMINI_API_KEY || "";
    
    if (!apiKey) {
      console.warn("Gemini API key not found. Using mock mode.");
    }
    
    this.genAI = new GoogleGenerativeAI(apiKey);
    
    // Initialize different models with appropriate settings
    this.flashModel = this.genAI.getGenerativeModel({
      model: "gemini-1.5-flash-latest",
      generationConfig: {
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2048,
        responseMimeType: "application/json",
      },
      safetySettings: [
        {
          category: HarmCategory.HARM_CATEGORY_HATE_SPEECH,
          threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
        },
        {
          category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
          threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
        },
      ],
    });
    
    this.proModel = this.genAI.getGenerativeModel({
      model: "gemini-1.5-pro-latest",
      generationConfig: {
        temperature: 0.8,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 4096,
        responseMimeType: "application/json",
      },
    });
    
    // Gemini 2.5 Pro with thinking mode for complex reasoning
    this.proThinkingModel = this.genAI.getGenerativeModel({
      model: "gemini-2.0-flash-thinking-exp", // This will be updated when 2.5 is available
      generationConfig: {
        temperature: 0.9,
        topK: 50,
        topP: 0.95,
        maxOutputTokens: 8192,
        responseMimeType: "application/json",
      },
    });
  }
  
  /**
   * Generate content using specified model
   */
  async generateContent(prompt: string, model: "flash" | "pro" | "pro-thinking" = "flash"): Promise<GeminiResponse> {
    try {
      let selectedModel: GenerativeModel;
      let modelName: string;
      
      switch (model) {
        case "pro-thinking":
          selectedModel = this.proThinkingModel;
          modelName = "gemini-2.5-pro-thinking";
          break;
        case "pro":
          selectedModel = this.proModel;
          modelName = "gemini-1.5-pro";
          break;
        default:
          selectedModel = this.flashModel;
          modelName = "gemini-1.5-flash";
      }
      
      const result = await selectedModel.generateContent(prompt);
      const response = result.response;
      const text = response.text();
      
      // Parse JSON response
      let parsedResponse;
      try {
        parsedResponse = JSON.parse(text);
      } catch {
        parsedResponse = { content: text };
      }
      
      return {
        success: true,
        model: modelName,
        response: parsedResponse,
        tokensUsed: response.usageMetadata?.totalTokenCount,
      };
    } catch (error) {
      console.error(`Gemini ${model} error:`, error);
      throw new functions.https.HttpsError("internal", `Failed to generate content: ${error}`);
    }
  }
  
  /**
   * Analyze food image with enhanced nutrition intelligence
   */
  async analyzeImage(imageBase64: string, userContext: any): Promise<FoodAnalysis> {
    const prompt = this.createFoodAnalysisPrompt(userContext);
    
    try {
      const result = await this.flashModel.generateContent([
        prompt,
        {
          inlineData: {
            mimeType: "image/jpeg",
            data: imageBase64,
          },
        },
      ]);
      
      const response = result.response;
      const analysis = JSON.parse(response.text());
      
      // Enhance with clarification questions if needed
      const clarificationQuestions = await this.generateClarificationQuestions(analysis, userContext);
      
      return {
        ...analysis,
        clarificationQuestions,
      };
    } catch (error) {
      console.error("Image analysis error:", error);
      throw new functions.https.HttpsError("internal", "Failed to analyze image");
    }
  }
  
  /**
   * Generate health blueprint using Gemini 2.5 Pro with thinking mode
   */
  async generateHealthBlueprint(userData: any): Promise<any> {
    const prompt = this.createHealthBlueprintPrompt(userData);
    
    try {
      // Use pro-thinking model for complex health blueprint generation
      const result = await this.generateContent(prompt, "pro-thinking");
      
      // The thinking model will provide both reasoning and final blueprint
      const { thinking, blueprint } = result.response;
      
      // Log thinking process for debugging and improvement
      console.log("Health Blueprint Thinking Process:", thinking);
      
      return {
        ...blueprint,
        generatedWithThinking: true,
        modelUsed: "gemini-2.5-pro-thinking",
      };
    } catch (error) {
      console.error("Health blueprint generation error:", error);
      // Fallback to regular pro model
      return this.generateContent(prompt, "pro");
    }
  }
  
  /**
   * Create comprehensive food analysis prompt
   */
  private createFoodAnalysisPrompt(userContext: any): string {
    const { primaryGoal, restrictions } = userContext;
    const protocol = NUTRITION_CURRICULUM[primaryGoal] || NUTRITION_CURRICULUM.ENERGY_OPTIMIZATION;
    
    return `You are an expert nutritionist analyzing a food image for detailed nutritional information.

USER CONTEXT:
- Primary Goal: ${primaryGoal}
- Dietary Restrictions: ${restrictions?.join(", ") || "None"}
- Current Time: ${new Date().toLocaleTimeString()}

NUTRITION PROTOCOL FOR ${primaryGoal}:
${JSON.stringify(protocol.keyPrinciples, null, 2)}

ANALYZE THE FOOD IMAGE AND PROVIDE:

1. DETAILED FOOD ITEMS:
   - Identify each food item visible
   - Estimate portion sizes accurately
   - Assign confidence scores (0-1)

2. NUTRITIONAL BREAKDOWN:
   - Calories, protein, carbs, fat, fiber for each item
   - Total meal nutrition
   - Micronutrient highlights if relevant

3. MEAL CLASSIFICATION:
   - Identify meal type (breakfast/lunch/dinner/snack)
   - Rate healthiness for user's goal (1-10)
   - Flag any items from avoidance list

4. SMART CLARIFICATIONS:
   - Generate 1-3 clarification questions ONLY if:
     a) Portion size is ambiguous
     b) Cooking method affects nutrition significantly
     c) Multiple similar options exist (e.g., milk types)
   - Each question must have real impact on accuracy

Return as JSON:
{
  "items": [
    {
      "name": "food name",
      "quantity": number,
      "unit": "oz/cup/tbsp/etc",
      "calories": number,
      "protein": number,
      "carbs": number,
      "fat": number,
      "fiber": number,
      "confidence": 0.0-1.0
    }
  ],
  "totalNutrition": {
    "calories": number,
    "protein": number,
    "carbs": number,
    "fat": number,
    "fiber": number
  },
  "mealType": "breakfast/lunch/dinner/snack",
  "healthScore": 1-10,
  "recommendations": ["specific advice based on goal"],
  "clarificationNeeded": boolean
}`;
  }
  
  /**
   * Generate smart clarification questions
   */
  private async generateClarificationQuestions(
    initialAnalysis: any,
    userContext: any
  ): Promise<ClarificationQuestion[]> {
    if (!initialAnalysis.clarificationNeeded) {
      return [];
    }
    
    const prompt = `Based on this food analysis, generate 1-3 ESSENTIAL clarification questions.

ANALYSIS: ${JSON.stringify(initialAnalysis)}
USER GOAL: ${userContext.primaryGoal}

RULES:
1. Only ask if the answer significantly changes nutrition (>20% difference)
2. Make questions specific and easy to answer
3. Provide realistic options
4. Prioritize questions by impact

Return as JSON array of questions.`;
    
    try {
      const result = await this.generateContent(prompt, "flash");
      return result.response;
    } catch {
      return [];
    }
  }
  
  /**
   * Create comprehensive health blueprint prompt
   */
  private createHealthBlueprintPrompt(userData: any): string {
    const protocol = NUTRITION_CURRICULUM[userData.primaryGoal] || NUTRITION_CURRICULUM.ENERGY_OPTIMIZATION;
    const circadianProfile = this.determineCircadianType(userData);
    
    return `You are creating a comprehensive, science-backed health blueprint.

THINK THROUGH THIS STEP BY STEP:
1. Analyze the user's unique combination of goals, stats, and lifestyle
2. Apply evidence-based nutrition science from the curriculum
3. Consider circadian biology and meal timing optimization
4. Create specific, measurable recommendations

USER PROFILE:
${JSON.stringify(userData, null, 2)}

SCIENCE-BASED PROTOCOL FOR ${userData.primaryGoal}:
${JSON.stringify(protocol, null, 2)}

CIRCADIAN PROFILE: ${circadianProfile}
${JSON.stringify(CIRCADIAN_MEAL_TIMING[circadianProfile as keyof typeof CIRCADIAN_MEAL_TIMING], null, 2)}

CREATE A BLUEPRINT WITH:

1. THINKING PROCESS (show your reasoning):
   - Why specific macro ratios for this person
   - How meal timing supports their goals
   - Which supplements are truly necessary
   - Potential challenges and solutions

2. PERSONALIZED NUTRITION PLAN:
   - Daily calorie target with clear reasoning
   - Macro distribution optimized for their goal
   - Meal timing schedule based on their chronotype
   - Food quality recommendations

3. WEEK 1 ACTION PLAN:
   - 5 specific habits to implement
   - Daily checklist items
   - Red flags to watch for
   - Success metrics

4. LONG-TERM OPTIMIZATION:
   - 30-day milestones
   - 90-day targets
   - Adjustment protocols

Return as JSON with "thinking" and "blueprint" sections.`;
  }
  
  /**
   * Determine user's circadian type based on their data
   */
  private determineCircadianType(userData: any): string {
    const wakeTime = userData.dailyActivity?.typicalWakeTime;
    if (!wakeTime) return "MORNING_TYPES"; // Default
    
    const hour = parseInt(wakeTime.split(":")[0]);
    if (hour < 7) return "MORNING_TYPES";
    if (hour > 8) return "EVENING_TYPES";
    
    // Check for shift work
    if (userData.lifestyleFactors?.workSchedule?.includes("night") ||
        userData.lifestyleFactors?.workSchedule?.includes("shift")) {
      return "SHIFT_WORKERS";
    }
    
    return "MORNING_TYPES";
  }
  
  /**
   * Generate personalized meal recommendations
   */
  async generateMealRecommendations(userProfile: any, mealType: string, remainingMacros: any): Promise<any> {
    const protocol = NUTRITION_CURRICULUM[userProfile.primaryGoal];
    const foodQuality = FOOD_QUALITY_SCORES;
    
    const prompt = `Generate a personalized meal recommendation.

USER PROFILE:
- Goal: ${userProfile.primaryGoal}
- Restrictions: ${userProfile.restrictions?.join(", ") || "None"}
- Preferences: ${userProfile.preferences?.join(", ") || "None"}

MEAL REQUIREMENTS:
- Type: ${mealType}
- Remaining Macros: ${JSON.stringify(remainingMacros)}
- Optimal Timing: ${protocol.mealTiming[`optimal${mealType.charAt(0).toUpperCase() + mealType.slice(1)}Window` as keyof typeof protocol.mealTiming] || "Not specified"}

FOOD QUALITY PRIORITIES:
${JSON.stringify(foodQuality.NUTRIENT_DENSITY.high)}

Generate 3 meal options that:
1. Fit the macro requirements (±10%)
2. Align with their goal-specific protocol
3. Use high-quality, whole foods
4. Are practical to prepare
5. Taste good and are satisfying

Return as JSON with recipes, macros, and prep instructions.`;
    
    return this.generateContent(prompt, "flash");
  }
  
  /**
   * Analyze patterns for coaching insights
   */
  async analyzeUserPatterns(userData: any): Promise<any> {
    const prompt = `Analyze user's nutrition patterns for coaching insights.

DATA TO ANALYZE:
${JSON.stringify(userData, null, 2)}

IDENTIFY:
1. Positive patterns supporting their goals
2. Negative patterns hindering progress
3. Correlations between food timing and energy/sleep
4. Consistency issues
5. Quick wins they can implement

Return specific, actionable insights with data backing.`;
    
    return this.generateContent(prompt, "pro");
  }
}
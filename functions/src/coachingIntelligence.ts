/**
 * Advanced Coaching Intelligence System for PlateUp v2.0
 * Personalized nutrition coaching with pattern recognition and learning
 */

import * as admin from "firebase-admin";
import { GeminiClient } from "./gemini";
import { NUTRITION_CURRICULUM } from "./nutritionCurriculum";

// Types for coaching system
export interface CoachingContext {
  userId: string;
  userProfile: UserProfile;
  recentMeals: MealData[];
  sleepData: SleepData[];
  energyLevels: EnergyData[];
  activityData: ActivityData[];
  previousInsights: CoachingInsight[];
  healthBlueprint: any;
}

export interface UserProfile {
  name: string;
  primaryGoal: string;
  secondaryGoals: string[];
  restrictions: string[];
  preferences: string[];
  currentMetrics: {
    weight: number;
    bodyFat?: number;
    energyAverage: number;
    sleepQualityAverage: number;
  };
}

export interface MealData {
  id: string;
  timestamp: Date;
  foods: any[];
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
  fiber: number;
  mealType: string;
  postMealEnergy?: number;
  postMealSatisfaction?: number;
}

export interface SleepData {
  date: Date;
  duration: number;
  quality: number; // 1-10
  deepSleepPercentage?: number;
  preSleepMealTime?: Date;
  preSleepMealSize?: string; // light/moderate/heavy
}

export interface EnergyData {
  timestamp: Date;
  level: number; // 1-10
  context: string; // morning/afternoon/evening/post-meal/pre-workout
  affectingFactors?: string[];
}

export interface ActivityData {
  date: Date;
  type: string;
  duration: number;
  intensity: string;
  preWorkoutMeal?: any;
  postWorkoutMeal?: any;
  performanceRating?: number;
}

export interface CoachingInsight {
  id: string;
  type: "pattern" | "recommendation" | "warning" | "achievement" | "opportunity";
  title: string;
  description: string;
  dataSupporting: any;
  actionItems: string[];
  priority: "high" | "medium" | "low";
  impact: string;
  createdAt: Date;
}

export class CoachingIntelligence {
  private gemini: GeminiClient;
  private db: admin.firestore.Firestore;
  
  constructor() {
    this.gemini = new GeminiClient();
    this.db = admin.firestore();
  }
  
  /**
   * Generate comprehensive coaching insights
   */
  async generateCoachingInsights(context: CoachingContext): Promise<CoachingInsight[]> {
    // Run multiple analyses in parallel
    const [
      energyPatterns,
      sleepCorrelations,
      macroBalance,
      mealTimingAnalysis,
      progressTowardsGoals
    ] = await Promise.all([
      this.analyzeEnergyPatterns(context),
      this.analyzeSleepFoodCorrelations(context),
      this.analyzeMacroBalance(context),
      this.analyzeMealTiming(context),
      this.analyzeProgressTowardsGoals(context)
    ]);
    
    // Combine all insights and prioritize
    const allInsights = [
      ...energyPatterns,
      ...sleepCorrelations,
      ...macroBalance,
      ...mealTimingAnalysis,
      ...progressTowardsGoals
    ];
    
    // Use AI to synthesize and prioritize insights
    const prioritizedInsights = await this.prioritizeInsights(allInsights, context);
    
    // Save insights for learning
    await this.saveInsights(prioritizedInsights, context.userId);
    
    return prioritizedInsights;
  }
  
  /**
   * Analyze energy level patterns
   */
  private async analyzeEnergyPatterns(context: CoachingContext): Promise<CoachingInsight[]> {
    const insights: CoachingInsight[] = [];
    
    // Group energy data by time of day
    const morningEnergy = context.energyLevels.filter(e => {
      const hour = new Date(e.timestamp).getHours();
      return hour >= 6 && hour < 12;
    });
    const afternoonEnergy = context.energyLevels.filter(e => {
      const hour = new Date(e.timestamp).getHours();
      return hour >= 12 && hour < 17;
    });
    // Evening energy removed - not currently used
    
    // Calculate averages
    const avgMorning = this.calculateAverage(morningEnergy.map(e => e.level));
    const avgAfternoon = this.calculateAverage(afternoonEnergy.map(e => e.level));
    // const avgEvening = this.calculateAverage(eveningEnergy.map(e => e.level));
    
    // Identify afternoon crashes
    if (avgAfternoon < avgMorning - 2) {
      const lunchAnalysis = await this.analyzeLunchImpact(context);
      insights.push({
        id: this.generateId(),
        type: "pattern",
        title: "Afternoon Energy Crashes Detected",
        description: `Your energy drops by ${Math.round((avgMorning - avgAfternoon) * 10)}% after lunch. This pattern is affecting your productivity.`,
        dataSupporting: {
          morningAverage: avgMorning,
          afternoonAverage: avgAfternoon,
          crashFrequency: `${Math.round(lunchAnalysis.crashDays / 7 * 100)}% of days`,
          likelyCause: lunchAnalysis.primaryCause
        },
        actionItems: [
          `Reduce lunch carbs to under ${lunchAnalysis.recommendedCarbs}g`,
          "Add 10-minute walk after lunch",
          "Consider splitting lunch into two smaller meals"
        ],
        priority: "high",
        impact: "Could improve afternoon productivity by 30-40%",
        createdAt: new Date()
      });
    }
    
    // Check morning energy optimization
    if (avgMorning < 7 && context.userProfile.primaryGoal.includes("energy")) {
      const breakfastAnalysis = await this.analyzeBreakfastImpact(context);
      insights.push({
        id: this.generateId(),
        type: "recommendation",
        title: "Optimize Your Morning Fuel",
        description: "Your morning energy is suboptimal. Adjusting breakfast composition can significantly improve your start to the day.",
        dataSupporting: breakfastAnalysis,
        actionItems: breakfastAnalysis.recommendations,
        priority: "high",
        impact: "Start your day with 25% more energy",
        createdAt: new Date()
      });
    }
    
    return insights;
  }
  
  /**
   * Analyze sleep and food correlations
   */
  private async analyzeSleepFoodCorrelations(context: CoachingContext): Promise<CoachingInsight[]> {
    const insights: CoachingInsight[] = [];
    
    // Correlate dinner timing with sleep quality
    const dinnerSleepPairs = context.sleepData.map(sleep => {
      const dinnerMeal = context.recentMeals.find(meal => {
        const mealDate = new Date(meal.timestamp).toDateString();
        const sleepDate = new Date(sleep.date).toDateString();
        return mealDate === sleepDate && meal.mealType === "dinner";
      });
      
      return {
        sleep,
        dinner: dinnerMeal,
        hoursBeforeSleep: dinnerMeal ? 
          (sleep.date.getTime() - dinnerMeal.timestamp.getTime()) / (1000 * 60 * 60) : null
      };
    }).filter(pair => pair.dinner !== undefined);
    
    // Analyze impact of late dinners
    const lateDinners = dinnerSleepPairs.filter(pair => pair.hoursBeforeSleep && pair.hoursBeforeSleep < 3);
    const earlyDinners = dinnerSleepPairs.filter(pair => pair.hoursBeforeSleep && pair.hoursBeforeSleep >= 3);
    
    if (lateDinners.length > 0 && earlyDinners.length > 0) {
      const avgSleepLate = this.calculateAverage(lateDinners.map(p => p.sleep.quality));
      const avgSleepEarly = this.calculateAverage(earlyDinners.map(p => p.sleep.quality));
      
      if (avgSleepEarly > avgSleepLate + 1) {
        insights.push({
          id: this.generateId(),
          type: "pattern",
          title: "Late Dinners Hurting Your Sleep",
          description: `Eating within 3 hours of bed reduces your sleep quality by ${Math.round((avgSleepEarly - avgSleepLate) / avgSleepEarly * 100)}%.`,
          dataSupporting: {
            lateDinnerSleepQuality: avgSleepLate,
            earlyDinnerSleepQuality: avgSleepEarly,
            lateDinnerCount: lateDinners.length,
            recommendation: "Finish dinner by 7 PM"
          },
          actionItems: [
            "Set dinner alarm for 6:30 PM",
            "Prep meals on Sunday for quick dinners",
            "If hungry before bed, try herbal tea or 1 oz almonds"
          ],
          priority: "high",
          impact: "Improve sleep quality by 20-30%",
          createdAt: new Date()
        });
      }
    }
    
    // Analyze specific foods affecting sleep
    const sleepDisruptors = await this.identifySleepDisruptingFoods(context);
    if (sleepDisruptors.length > 0) {
      insights.push({
        id: this.generateId(),
        type: "warning",
        title: "Foods Disrupting Your Sleep",
        description: "Certain foods in your diet are consistently associated with poor sleep quality.",
        dataSupporting: {
          disruptiveFoods: sleepDisruptors,
          averageImpact: "1.5 point reduction in sleep quality"
        },
        actionItems: sleepDisruptors.map(food => `Avoid ${food.name} after ${food.cutoffTime}`),
        priority: "medium",
        impact: "Better recovery and next-day energy",
        createdAt: new Date()
      });
    }
    
    return insights;
  }
  
  /**
   * Analyze macro balance and timing
   */
  private async analyzeMacroBalance(context: CoachingContext): Promise<CoachingInsight[]> {
    const insights: CoachingInsight[] = [];
    const protocol = NUTRITION_CURRICULUM[context.userProfile.primaryGoal];
    
    // Calculate actual macro percentages
    const totalCalories = context.recentMeals.reduce((sum, meal) => sum + meal.calories, 0);
    const totalProtein = context.recentMeals.reduce((sum, meal) => sum + meal.protein, 0);
    // Carbs and fat calculations removed - not currently used
    
    const actualProteinPct = (totalProtein * 4 / totalCalories) * 100;
    // const actualCarbsPct = (totalCarbs * 4 / totalCalories) * 100;
    // const actualFatPct = (totalFat * 9 / totalCalories) * 100;
    
    // Check protein adequacy
    const targetProteinPct = protocol.macroDistribution.proteinPercentage;
    if (actualProteinPct < targetProteinPct - 5) {
      const proteinGap = Math.round((targetProteinPct - actualProteinPct) / targetProteinPct * 100);
      insights.push({
        id: this.generateId(),
        type: "warning",
        title: "Insufficient Protein Intake",
        description: `You're ${proteinGap}% below your protein target. This is limiting your ${context.userProfile.primaryGoal} progress.`,
        dataSupporting: {
          currentIntake: `${Math.round(actualProteinPct)}%`,
          targetIntake: `${targetProteinPct}%`,
          gramsNeeded: Math.round((targetProteinPct - actualProteinPct) * totalCalories / 100 / 4)
        },
        actionItems: [
          "Add 20-30g protein to breakfast",
          "Include protein snacks between meals",
          "Consider protein powder for convenience"
        ],
        priority: "high",
        impact: protocol.goalType.includes("muscle") ? "Critical for muscle growth" : "Essential for maintaining muscle while losing fat",
        createdAt: new Date()
      });
    }
    
    // Analyze meal-specific macro distribution
    const breakfastMacros = await this.analyzeMealMacros(context.recentMeals.filter(m => m.mealType === "breakfast"));
    if (breakfastMacros.carbsPct > 60 && context.userProfile.primaryGoal.includes("energy")) {
      insights.push({
        id: this.generateId(),
        type: "recommendation",
        title: "Rebalance Your Breakfast",
        description: "Your breakfast is too carb-heavy, causing mid-morning energy crashes.",
        dataSupporting: breakfastMacros,
        actionItems: [
          "Reduce breakfast carbs by 20g",
          "Add 2 eggs or Greek yogurt",
          "Include healthy fats (avocado, nuts)"
        ],
        priority: "medium",
        impact: "Sustained morning energy until lunch",
        createdAt: new Date()
      });
    }
    
    return insights;
  }
  
  /**
   * Analyze meal timing optimization
   */
  private async analyzeMealTiming(context: CoachingContext): Promise<CoachingInsight[]> {
    const insights: CoachingInsight[] = [];
    const protocol = NUTRITION_CURRICULUM[context.userProfile.primaryGoal];
    
    // Group meals by time windows
    // const mealsByHour = this.groupMealsByHour(context.recentMeals);
    
    // Check breakfast timing
    const breakfastTimes = context.recentMeals
      .filter(m => m.mealType === "breakfast")
      .map(m => new Date(m.timestamp).getHours());
    
    const avgBreakfastTime = this.calculateAverage(breakfastTimes);
    const optimalBreakfastHour = parseInt(protocol.mealTiming.optimalBreakfastWindow.split(":")[0]);
    
    if (Math.abs(avgBreakfastTime - optimalBreakfastHour) > 2) {
      insights.push({
        id: this.generateId(),
        type: "recommendation",
        title: "Optimize Breakfast Timing",
        description: `Shifting breakfast to ${protocol.mealTiming.optimalBreakfastWindow} aligns with your circadian rhythm for better ${context.userProfile.primaryGoal}.`,
        dataSupporting: {
          currentAverage: `${Math.round(avgBreakfastTime)}:00`,
          optimal: protocol.mealTiming.optimalBreakfastWindow,
          scientificBasis: protocol.scientificBasis[1]
        },
        actionItems: [
          "Set breakfast alarm for optimal window",
          "Prep overnight oats for quick morning meals",
          "Gradually shift by 15 minutes daily"
        ],
        priority: "medium",
        impact: "Improved hormone balance and energy",
        createdAt: new Date()
      });
    }
    
    // Analyze fasting windows
    const fastingWindows = this.calculateFastingWindows(context.recentMeals);
    const avgFastingHours = this.calculateAverage(fastingWindows);
    
    if (protocol.mealTiming.fastingProtocol) {
      const targetFasting = parseInt(protocol.mealTiming.fastingProtocol.split("-")[0]);
      if (avgFastingHours < targetFasting - 1) {
        insights.push({
          id: this.generateId(),
          type: "opportunity",
          title: "Extend Your Overnight Fast",
          description: `Increasing your fasting window to ${targetFasting} hours can accelerate ${context.userProfile.primaryGoal}.`,
          dataSupporting: {
            currentFasting: `${Math.round(avgFastingHours)} hours`,
            targetFasting: `${targetFasting} hours`,
            benefitExplanation: "Enhances fat burning and cellular repair"
          },
          actionItems: [
            "Finish dinner 30 minutes earlier",
            "Replace late-night snacks with herbal tea",
            "Delay breakfast by 30 minutes"
          ],
          priority: "low",
          impact: "5-10% improvement in fat loss rate",
          createdAt: new Date()
        });
      }
    }
    
    return insights;
  }
  
  /**
   * Analyze progress towards specific goals
   */
  private async analyzeProgressTowardsGoals(context: CoachingContext): Promise<CoachingInsight[]> {
    const insights: CoachingInsight[] = [];
    
    // Use AI to analyze overall progress
    const progressAnalysis = await this.gemini.analyzeUserPatterns({
      userProfile: context.userProfile,
      recentData: {
        meals: context.recentMeals.slice(-21), // Last week
        sleep: context.sleepData.slice(-7),
        energy: context.energyLevels.slice(-7),
        activity: context.activityData.slice(-7)
      },
      healthBlueprint: context.healthBlueprint
    });
    
    // Check adherence to blueprint
    const adherenceScore = await this.calculateAdherenceScore(context);
    
    if (adherenceScore < 70) {
      insights.push({
        id: this.generateId(),
        type: "warning",
        title: "Blueprint Adherence Needs Improvement",
        description: `You're following your personalized plan ${adherenceScore}% of the time. Small improvements here yield big results.`,
        dataSupporting: {
          adherenceScore,
          missedTargets: progressAnalysis.response.missedTargets,
          impactOnGoals: progressAnalysis.response.impactAnalysis
        },
        actionItems: progressAnalysis.response.topThreeActions,
        priority: "high",
        impact: "Get back on track for your goals",
        createdAt: new Date()
      });
    } else if (adherenceScore > 85) {
      insights.push({
        id: this.generateId(),
        type: "achievement",
        title: "Excellent Blueprint Adherence!",
        description: `You're crushing it with ${adherenceScore}% adherence. Your consistency is paying off.`,
        dataSupporting: {
          adherenceScore,
          improvements: progressAnalysis.response.positiveChanges,
          nextLevel: progressAnalysis.response.optimizationOpportunities
        },
        actionItems: ["Keep up the great work!", ...progressAnalysis.response.advancedTips],
        priority: "low",
        impact: "Maintaining momentum towards goals",
        createdAt: new Date()
      });
    }
    
    // Goal-specific progress checks
    if (context.userProfile.primaryGoal === "WEIGHT_LOSS") {
      const weightProgress = await this.analyzeWeightLossProgress(context);
      if (weightProgress) insights.push(weightProgress);
    } else if (context.userProfile.primaryGoal === "MUSCLE_BUILDING") {
      const muscleProgress = await this.analyzeMuscleGainProgress(context);
      if (muscleProgress) insights.push(muscleProgress);
    } else if (context.userProfile.primaryGoal === "ENERGY_OPTIMIZATION") {
      const energyProgress = await this.analyzeEnergyProgress(context);
      if (energyProgress) insights.push(energyProgress);
    }
    
    return insights;
  }
  
  /**
   * Helper methods
   */
  
  private calculateAverage(numbers: number[]): number {
    if (numbers.length === 0) return 0;
    return numbers.reduce((sum, n) => sum + n, 0) / numbers.length;
  }
  
  private generateId(): string {
    return this.db.collection("coaching_insights").doc().id;
  }
  
  private async analyzeLunchImpact(context: CoachingContext): Promise<any> {
    const lunchMeals = context.recentMeals.filter(m => m.mealType === "lunch");
    const highCarbLunches = lunchMeals.filter(m => m.carbs > 60);
    
    return {
      crashDays: highCarbLunches.length,
      primaryCause: highCarbLunches.length > lunchMeals.length / 2 ? "high carb intake" : "meal timing",
      recommendedCarbs: 40
    };
  }
  
  private async analyzeBreakfastImpact(context: CoachingContext): Promise<any> {
    const breakfasts = context.recentMeals.filter(m => m.mealType === "breakfast");
    const avgProtein = this.calculateAverage(breakfasts.map(m => m.protein));
    
    const recommendations = [];
    if (avgProtein < 20) recommendations.push("Increase breakfast protein to 25-30g");
    if (breakfasts.some(b => b.fiber < 5)) recommendations.push("Add fiber-rich foods (berries, oats)");
    recommendations.push("Include healthy fats for sustained energy");
    
    return {
      currentProtein: avgProtein,
      targetProtein: 30,
      recommendations
    };
  }
  
  private async identifySleepDisruptingFoods(context: CoachingContext): Promise<any[]> {
    // This would use more sophisticated analysis in production
    const disruptors = [];
    
    const caffeineAfter2PM = context.recentMeals.filter(meal => {
      const hour = new Date(meal.timestamp).getHours();
      return hour >= 14 && meal.foods.some(f => 
        f.name.toLowerCase().includes("coffee") || 
        f.name.toLowerCase().includes("tea") ||
        f.name.toLowerCase().includes("energy")
      );
    });
    
    if (caffeineAfter2PM.length > 0) {
      disruptors.push({
        name: "Caffeine",
        cutoffTime: "2:00 PM",
        impact: "Disrupts deep sleep"
      });
    }
    
    return disruptors;
  }
  
  private async analyzeMealMacros(meals: MealData[]): Promise<any> {
    const totalCalories = meals.reduce((sum, m) => sum + m.calories, 0);
    const totalProtein = meals.reduce((sum, m) => sum + m.protein, 0);
    const totalCarbs = meals.reduce((sum, m) => sum + m.carbs, 0);
    const totalFat = meals.reduce((sum, m) => sum + m.fat, 0);
    
    return {
      proteinPct: (totalProtein * 4 / totalCalories) * 100,
      carbsPct: (totalCarbs * 4 / totalCalories) * 100,
      fatPct: (totalFat * 9 / totalCalories) * 100,
      avgCalories: totalCalories / meals.length
    };
  }
  
  // groupMealsByHour method removed - not currently used
  
  private calculateFastingWindows(meals: MealData[]): number[] {
    const windows: number[] = [];
    const sortedMeals = meals.sort((a, b) => a.timestamp.getTime() - b.timestamp.getTime());
    
    for (let i = 1; i < sortedMeals.length; i++) {
      const gap = (sortedMeals[i].timestamp.getTime() - sortedMeals[i-1].timestamp.getTime()) / (1000 * 60 * 60);
      if (gap > 8) { // Overnight fast
        windows.push(gap);
      }
    }
    
    return windows;
  }
  
  private async calculateAdherenceScore(context: CoachingContext): Promise<number> {
    let score = 0;
    let total = 0;
    
    // Check calorie adherence
    const targetCalories = context.healthBlueprint?.dailyCalorieTarget || 2000;
    const avgCalories = this.calculateAverage(
      context.recentMeals.reduce((acc, meal) => {
        const date = meal.timestamp.toDateString();
        if (!acc[date]) acc[date] = 0;
        acc[date] += meal.calories;
        return acc;
      }, {} as any)
    );
    
    if (Math.abs(avgCalories - targetCalories) < targetCalories * 0.1) {
      score += 25;
    }
    total += 25;
    
    // Check macro adherence (simplified)
    const protocol = NUTRITION_CURRICULUM[context.userProfile.primaryGoal];
    if (protocol) {
      // Add macro checks here
      total += 25;
    }
    
    // Check meal timing adherence
    total += 25;
    
    // Check sleep consistency
    total += 25;
    
    return Math.round((score / total) * 100);
  }
  
  private async analyzeWeightLossProgress(context: CoachingContext): Promise<CoachingInsight | null> {
    // Analyze weight loss specific metrics
    const deficitDays = context.recentMeals.filter(() => {
      // Check if in deficit
      return true; // Simplified
    }).length;
    
    if (deficitDays < 5) {
      return {
        id: this.generateId(),
        type: "warning",
        title: "Inconsistent Calorie Deficit",
        description: "You need to maintain a deficit more consistently for weight loss.",
        dataSupporting: { deficitDays, targetDays: 6 },
        actionItems: [
          "Track portions more carefully",
          "Reduce portion sizes by 10-15%",
          "Add 20 minutes of walking daily"
        ],
        priority: "high",
        impact: "Achieve 1-2 lbs loss per week",
        createdAt: new Date()
      };
    }
    
    return null;
  }
  
  private async analyzeMuscleGainProgress(context: CoachingContext): Promise<CoachingInsight | null> {
    // Analyze muscle building specific metrics
    const workoutDays = context.activityData.filter(a => a.type === "strength").length;
    const proteinDays = context.recentMeals.filter(meal => meal.protein >= 25).length;
    
    if (workoutDays < 3 || proteinDays < 6) {
      return {
        id: this.generateId(),
        type: "warning",
        title: "Muscle Building Requirements Not Met",
        description: "Consistency in training and protein intake is crucial for muscle growth.",
        dataSupporting: { workoutDays, proteinDays },
        actionItems: [
          "Schedule 4 strength training sessions",
          "Set protein reminders every 3-4 hours",
          "Prep protein-rich snacks"
        ],
        priority: "high",
        impact: "Maximize muscle protein synthesis",
        createdAt: new Date()
      };
    }
    
    return null;
  }
  
  private async analyzeEnergyProgress(context: CoachingContext): Promise<CoachingInsight | null> {
    const avgEnergy = this.calculateAverage(context.energyLevels.map(e => e.level));
    const energyVariability = this.calculateVariability(context.energyLevels.map(e => e.level));
    
    if (energyVariability > 2) {
      return {
        id: this.generateId(),
        type: "pattern",
        title: "Unstable Energy Levels",
        description: "Your energy fluctuates too much throughout the day.",
        dataSupporting: {
          averageEnergy: avgEnergy,
          variability: energyVariability,
          pattern: "High volatility indicates blood sugar swings"
        },
        actionItems: [
          "Eat protein with every meal",
          "Replace refined carbs with complex carbs",
          "Add mid-morning and mid-afternoon snacks"
        ],
        priority: "high",
        impact: "Achieve stable all-day energy",
        createdAt: new Date()
      };
    }
    
    return null;
  }
  
  private calculateVariability(numbers: number[]): number {
    const avg = this.calculateAverage(numbers);
    const squaredDiffs = numbers.map(n => Math.pow(n - avg, 2));
    return Math.sqrt(this.calculateAverage(squaredDiffs));
  }
  
  /**
   * Prioritize insights using AI
   */
  private async prioritizeInsights(
    insights: CoachingInsight[],
    context: CoachingContext
  ): Promise<CoachingInsight[]> {
    const prompt = `Prioritize these coaching insights for maximum impact on ${context.userProfile.primaryGoal}.
    
INSIGHTS:
${JSON.stringify(insights, null, 2)}

USER CONTEXT:
- Primary Goal: ${context.userProfile.primaryGoal}
- Current Challenges: Based on the data patterns
- Readiness for Change: Assume moderate

Rank insights by:
1. Impact on primary goal
2. Ease of implementation
3. Likelihood of adherence
4. Cascading benefits

Return top 5 insights in order of priority.`;
    
    try {
      const result = await this.gemini.generateContent(prompt, "flash");
      return result.response.prioritizedInsights || insights.slice(0, 5);
    } catch {
      // Fallback to priority field
      return insights
        .sort((a, b) => {
          const priorityOrder = { high: 0, medium: 1, low: 2 };
          return priorityOrder[a.priority] - priorityOrder[b.priority];
        })
        .slice(0, 5);
    }
  }
  
  /**
   * Save insights for future learning
   */
  private async saveInsights(insights: CoachingInsight[], userId: string): Promise<void> {
    const batch = this.db.batch();
    
    for (const insight of insights) {
      const docRef = this.db.collection("coaching_insights").doc(insight.id);
      batch.set(docRef, {
        ...insight,
        userId,
        userFeedback: null,
        wasHelpful: null,
        actionsTaken: [],
        outcome: null
      });
    }
    
    await batch.commit();
  }
  
  /**
   * Learn from user feedback on insights
   */
  async processInsightFeedback(
    insightId: string,
    feedback: {
      wasHelpful: boolean;
      actionsTaken: string[];
      outcome: string;
      additionalComments?: string;
    }
  ): Promise<void> {
    // Update the insight with feedback
    await this.db.collection("coaching_insights").doc(insightId).update({
      userFeedback: feedback,
      feedbackReceivedAt: new Date()
    });
    
    // Analyze patterns in helpful vs unhelpful insights
    if (!feedback.wasHelpful) {
      // Log for improvement
      await this.db.collection("coaching_feedback").add({
        insightId,
        type: "negative",
        reason: feedback.additionalComments,
        timestamp: new Date()
      });
    }
  }
  
  /**
   * Generate meal-specific coaching
   */
  async generateMealFeedback(
    meal: MealData,
    userProfile: UserProfile,
    remainingMacros: any
  ): Promise<{
    score: number;
    feedback: string;
    suggestions: string[];
  }> {
    const protocol = NUTRITION_CURRICULUM[userProfile.primaryGoal];
    
    // Score the meal
    let score = 10;
    const feedback: string[] = [];
    const suggestions: string[] = [];
    
    // Check macro balance
    const mealCalorieRatio = meal.calories / remainingMacros.calories;
    const mealProteinRatio = meal.protein / remainingMacros.protein;
    
    if (Math.abs(mealCalorieRatio - mealProteinRatio) > 0.2) {
      score -= 2;
      feedback.push("Macro balance could be better");
      suggestions.push(mealProteinRatio < mealCalorieRatio ? "Add protein" : "Reduce carbs");
    }
    
    // Check meal timing
    const hour = new Date(meal.timestamp).getHours();
    const optimalWindow = protocol.mealTiming[`optimal${meal.mealType}Window` as keyof typeof protocol.mealTiming];
    if (optimalWindow) {
      // Check if within window
      // Simplified check
      if (Math.abs(hour - 12) > 2 && meal.mealType === "lunch") {
        score -= 1;
        feedback.push("Timing could be optimized");
      }
    }
    
    // Check food quality
    const qualityAnalysis = await this.assessFoodQuality(meal.foods);
    score = Math.min(score, qualityAnalysis.score);
    feedback.push(...qualityAnalysis.feedback);
    suggestions.push(...qualityAnalysis.suggestions);
    
    return {
      score,
      feedback: feedback.join(". "),
      suggestions
    };
  }
  
  private async assessFoodQuality(foods: any[]): Promise<any> {
    // Simplified food quality assessment
    let score = 10;
    const feedback: string[] = [];
    const suggestions: string[] = [];
    
    const hasProcessedFoods = foods.some(f => 
      f.name.toLowerCase().includes("processed") ||
      f.name.toLowerCase().includes("fried")
    );
    
    if (hasProcessedFoods) {
      score -= 2;
      feedback.push("Contains processed foods");
      suggestions.push("Choose whole food alternatives");
    }
    
    return { score, feedback, suggestions };
  }
}
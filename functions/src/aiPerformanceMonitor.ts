/**
 * AI Performance Monitoring & Learning System for PlateUp v2.0
 * Tracks AI accuracy, user satisfaction, and continuous improvement
 */

import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

// Types for monitoring system
export interface AIInteraction {
  id: string;
  userId: string;
  timestamp: Date;
  interactionType: "food_scan" | "voice_input" | "coaching" | "recipe" | "blueprint";
  request: {
    input: any;
    context: any;
    modelUsed: string;
  };
  response: {
    output: any;
    confidence?: number;
    processingTime: number;
    tokensUsed?: number;
  };
  feedback?: UserFeedback;
  metrics: PerformanceMetrics;
}

export interface UserFeedback {
  rating?: "positive" | "negative" | "neutral";
  accuracy?: number; // 1-5 scale
  helpfulness?: number; // 1-5 scale
  clarificationQuality?: number; // 1-5 scale
  specificFeedback?: string;
  correctionsProvided?: any;
  timestamp: Date;
}

export interface PerformanceMetrics {
  responseTime: number;
  errorRate: number;
  retryCount: number;
  cacheHit: boolean;
  edgeCases: string[];
}

export interface ClarificationMetrics {
  questionId: string;
  question: string;
  category: string;
  timesAsked: number;
  thumbsUpRate: number;
  thumbsDownRate: number;
  skipRate: number;
  averageImpactOnAccuracy: number;
  shouldRetire: boolean;
}

export interface ModelPerformance {
  model: string;
  period: "daily" | "weekly" | "monthly";
  metrics: {
    totalRequests: number;
    successRate: number;
    averageResponseTime: number;
    averageTokensUsed: number;
    userSatisfaction: number;
    costPerRequest: number;
  };
  topIssues: string[];
  improvements: string[];
}

export class AIPerformanceMonitor {
  private db: admin.firestore.Firestore;
  
  constructor() {
    this.db = admin.firestore();
  }
  
  /**
   * Track AI interaction
   */
  async trackInteraction(interaction: AIInteraction): Promise<void> {
    try {
      // Store interaction
      await this.db.collection("ai_interactions").doc(interaction.id).set({
        ...interaction,
        timestamp: admin.firestore.FieldValue.serverTimestamp()
      });
      
      // Update real-time metrics
      await this.updateRealtimeMetrics(interaction);
      
      // Log to analytics
      await this.logAnalytics(interaction);
      
      // Check for anomalies
      await this.detectAnomalies(interaction);
      
    } catch (error) {
      console.error("Error tracking AI interaction:", error);
    }
  }
  
  /**
   * Process user feedback on AI responses
   */
  async processFeedback(
    interactionId: string,
    feedback: UserFeedback
  ): Promise<void> {
    try {
      // Update interaction with feedback
      await this.db.collection("ai_interactions").doc(interactionId).update({
        feedback,
        feedbackReceivedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      
      // Analyze feedback patterns
      const interaction = await this.db.collection("ai_interactions").doc(interactionId).get();
      const data = interaction.data();
      
      if (data) {
        // Track clarification effectiveness
        if (data.interactionType === "food_scan" && data.response.output.clarificationQuestions) {
          await this.updateClarificationMetrics(data.response.output.clarificationQuestions, feedback);
        }
        
        // Identify improvement opportunities
        if (feedback.rating === "negative" || (feedback.accuracy !== undefined && feedback.accuracy < 3)) {
          await this.logImprovementOpportunity(data, feedback);
        }
        
        // Update model performance metrics
        // await this.updateModelPerformance(data.request.modelUsed, feedback);
      }
      
    } catch (error) {
      console.error("Error processing feedback:", error);
    }
  }
  
  /**
   * Update real-time metrics dashboard
   */
  private async updateRealtimeMetrics(interaction: AIInteraction): Promise<void> {
    const metricsRef = this.db.collection("ai_metrics").doc("realtime");
    
    await this.db.runTransaction(async (transaction) => {
      const doc = await transaction.get(metricsRef);
      const current = doc.data() || this.initializeMetrics();
      
      // Update counters
      current.totalRequests++;
      current.requestsByType[interaction.interactionType]++;
      
      // Update performance metrics
      current.averageResponseTime = 
        (current.averageResponseTime * (current.totalRequests - 1) + interaction.metrics.responseTime) / 
        current.totalRequests;
      
      if (interaction.metrics.errorRate > 0) {
        current.errorCount++;
      }
      
      // Update hourly stats
      const hour = new Date().getHours();
      current.hourlyDistribution[hour]++;
      
      transaction.set(metricsRef, {
        ...current,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp()
      });
    });
  }
  
  /**
   * Track clarification question effectiveness
   */
  private async updateClarificationMetrics(
    questions: any[],
    feedback: UserFeedback
  ): Promise<void> {
    for (const question of questions) {
      const questionRef = this.db.collection("clarification_metrics").doc(question.id);
      
      await this.db.runTransaction(async (transaction) => {
        const doc = await transaction.get(questionRef);
        const metrics = doc.data() || this.initializeClarificationMetrics(question);
        
        metrics.timesAsked++;
        
        if (feedback.clarificationQuality) {
          if (feedback.clarificationQuality >= 4) {
            metrics.thumbsUpRate = (metrics.thumbsUpRate * (metrics.timesAsked - 1) + 1) / metrics.timesAsked;
          } else if (feedback.clarificationQuality <= 2) {
            metrics.thumbsDownRate = (metrics.thumbsDownRate * (metrics.timesAsked - 1) + 1) / metrics.timesAsked;
          }
        }
        
        // Calculate impact on accuracy
        if (feedback.accuracy) {
          metrics.averageImpactOnAccuracy = 
            (metrics.averageImpactOnAccuracy * (metrics.timesAsked - 1) + feedback.accuracy) / 
            metrics.timesAsked;
        }
        
        // Determine if question should be retired
        metrics.shouldRetire = 
          metrics.thumbsDownRate > 0.5 || 
          (metrics.timesAsked > 100 && metrics.thumbsUpRate < 0.3);
        
        transaction.set(questionRef, {
          ...metrics,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp()
        });
      });
    }
  }
  
  /**
   * Log improvement opportunities
   */
  private async logImprovementOpportunity(
    interaction: any,
    feedback: UserFeedback
  ): Promise<void> {
    const opportunity = {
      id: this.db.collection("improvement_opportunities").doc().id,
      timestamp: new Date(),
      interactionType: interaction.interactionType,
      modelUsed: interaction.request.modelUsed,
      issue: this.categorizeIssue(interaction, feedback),
      userInput: interaction.request.input,
      aiOutput: interaction.response.output,
      userFeedback: feedback,
      suggestedImprovement: await this.generateImprovement(interaction, feedback),
      priority: this.calculatePriority(feedback),
      status: "pending"
    };
    
    await this.db.collection("improvement_opportunities").doc(opportunity.id).set(opportunity);
    
    // Alert if high priority
    if (opportunity.priority === "high") {
      await this.sendAlert(opportunity);
    }
  }
  
  /**
   * Detect anomalies in AI performance
   */
  private async detectAnomalies(interaction: AIInteraction): Promise<void> {
    const anomalies: string[] = [];
    
    // Check response time
    if (interaction.metrics.responseTime > 10000) {
      anomalies.push("slow_response");
    }
    
    // Check token usage
    if (interaction.response.tokensUsed && interaction.response.tokensUsed > 5000) {
      anomalies.push("high_token_usage");
    }
    
    // Check retry count
    if (interaction.metrics.retryCount > 2) {
      anomalies.push("multiple_retries");
    }
    
    // Check confidence
    if (interaction.response.confidence && interaction.response.confidence < 0.5) {
      anomalies.push("low_confidence");
    }
    
    if (anomalies.length > 0) {
      await this.db.collection("ai_anomalies").add({
        interactionId: interaction.id,
        timestamp: new Date(),
        anomalies,
        interaction
      });
    }
  }
  
  /**
   * Generate performance reports
   */
  async generatePerformanceReport(
    period: "daily" | "weekly" | "monthly"
  ): Promise<ModelPerformance[]> {
    const reports: ModelPerformance[] = [];
    const models = ["gemini-1.5-flash", "gemini-1.5-pro", "gemini-2.5-pro-thinking"];
    
    for (const model of models) {
      const metrics = await this.calculateModelMetrics(model, period);
      const issues = await this.identifyTopIssues(model, period);
      const improvements = await this.generateImprovements(model, period);
      
      reports.push({
        model,
        period,
        metrics,
        topIssues: issues,
        improvements
      });
    }
    
    return reports;
  }
  
  /**
   * A/B testing for prompts and strategies
   */
  async runABTest(test: {
    name: string;
    variants: {
      name: string;
      prompt: string;
      model: string;
    }[];
    sampleSize: number;
    successMetric: string;
  }): Promise<any> {
    const testId = this.db.collection("ab_tests").doc().id;
    
    // Initialize test
    await this.db.collection("ab_tests").doc(testId).set({
      ...test,
      status: "running",
      startedAt: new Date(),
      results: {}
    });
    
    // Monitor test results
    return {
      testId,
      message: "A/B test initiated",
      monitoringUrl: `/api/ab-test/${testId}`
    };
  }
  
  /**
   * Helper methods
   */
  
  private initializeMetrics(): any {
    return {
      totalRequests: 0,
      requestsByType: {
        food_scan: 0,
        voice_input: 0,
        coaching: 0,
        recipe: 0,
        blueprint: 0
      },
      averageResponseTime: 0,
      errorCount: 0,
      hourlyDistribution: new Array(24).fill(0)
    };
  }
  
  private initializeClarificationMetrics(question: any): ClarificationMetrics {
    return {
      questionId: question.id,
      question: question.question,
      category: question.category,
      timesAsked: 0,
      thumbsUpRate: 0,
      thumbsDownRate: 0,
      skipRate: 0,
      averageImpactOnAccuracy: 0,
      shouldRetire: false
    };
  }
  
  private categorizeIssue(_interaction: any, feedback: UserFeedback): string {
    if (feedback.accuracy && feedback.accuracy <= 2) {
      return "low_accuracy";
    }
    if (feedback.helpfulness && feedback.helpfulness <= 2) {
      return "not_helpful";
    }
    if (feedback.specificFeedback?.includes("wrong") || feedback.specificFeedback?.includes("incorrect")) {
      return "incorrect_information";
    }
    if (feedback.specificFeedback?.includes("confus") || feedback.specificFeedback?.includes("unclear")) {
      return "confusing_response";
    }
    return "other";
  }
  
  private async generateImprovement(interaction: any, feedback: UserFeedback): Promise<string> {
    const issue = this.categorizeIssue(interaction, feedback);
    
    switch (issue) {
      case "low_accuracy":
        return "Improve training data for this food type or scenario";
      case "not_helpful":
        return "Enhance response relevance and actionability";
      case "incorrect_information":
        return "Update knowledge base and fact-checking";
      case "confusing_response":
        return "Simplify language and structure responses better";
      default:
        return "Review user feedback for specific improvements";
    }
  }
  
  private calculatePriority(feedback: UserFeedback): "high" | "medium" | "low" {
    const score = (feedback.accuracy || 3) + (feedback.helpfulness || 3);
    if (score <= 3) return "high";
    if (score <= 5) return "medium";
    return "low";
  }
  
  private async sendAlert(opportunity: any): Promise<void> {
    // In production, this would send to Slack/Discord/Email
    console.error("HIGH PRIORITY AI ISSUE:", opportunity);
    
    // Log to Firebase Functions logs
    functions.logger.error("AI Performance Alert", {
      issue: opportunity.issue,
      priority: opportunity.priority,
      timestamp: opportunity.timestamp
    });
  }
  
  private async calculateModelMetrics(model: string, period: string): Promise<any> {
    // Query interactions for the period
    const startDate = this.getStartDate(period);
    const interactions = await this.db.collection("ai_interactions")
      .where("request.modelUsed", "==", model)
      .where("timestamp", ">=", startDate)
      .get();
    
    let totalRequests = 0;
    let successCount = 0;
    let totalResponseTime = 0;
    let totalTokens = 0;
    let totalSatisfaction = 0;
    let satisfactionCount = 0;
    
    interactions.forEach(doc => {
      const data = doc.data();
      totalRequests++;
      
      if (data.metrics.errorRate === 0) successCount++;
      totalResponseTime += data.metrics.responseTime;
      if (data.response.tokensUsed) totalTokens += data.response.tokensUsed;
      
      if (data.feedback?.helpfulness) {
        totalSatisfaction += data.feedback.helpfulness;
        satisfactionCount++;
      }
    });
    
    return {
      totalRequests,
      successRate: totalRequests > 0 ? successCount / totalRequests : 0,
      averageResponseTime: totalRequests > 0 ? totalResponseTime / totalRequests : 0,
      averageTokensUsed: totalRequests > 0 ? totalTokens / totalRequests : 0,
      userSatisfaction: satisfactionCount > 0 ? totalSatisfaction / satisfactionCount : 0,
      costPerRequest: this.calculateCost(model, totalTokens / totalRequests)
    };
  }
  
  private async identifyTopIssues(model: string, period: string): Promise<string[]> {
    const startDate = this.getStartDate(period);
    const opportunities = await this.db.collection("improvement_opportunities")
      .where("modelUsed", "==", model)
      .where("timestamp", ">=", startDate)
      .orderBy("timestamp", "desc")
      .limit(10)
      .get();
    
    const issues = new Map<string, number>();
    opportunities.forEach(doc => {
      const issue = doc.data().issue;
      issues.set(issue, (issues.get(issue) || 0) + 1);
    });
    
    return Array.from(issues.entries())
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5)
      .map(([issue]) => issue);
  }
  
  private async generateImprovements(model: string, period: string): Promise<string[]> {
    const issues = await this.identifyTopIssues(model, period);
    const improvements: string[] = [];
    
    for (const issue of issues) {
      switch (issue) {
        case "low_accuracy":
          improvements.push("Enhance training data quality and diversity");
          break;
        case "slow_response":
          improvements.push("Optimize prompt length and complexity");
          break;
        case "high_token_usage":
          improvements.push("Implement response summarization");
          break;
        default:
          improvements.push(`Address ${issue} through targeted improvements`);
      }
    }
    
    return improvements;
  }
  
  private getStartDate(period: string): Date {
    const now = new Date();
    switch (period) {
      case "daily":
        return new Date(now.getTime() - 24 * 60 * 60 * 1000);
      case "weekly":
        return new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
      case "monthly":
        return new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
      default:
        return now;
    }
  }
  
  private calculateCost(model: string, avgTokens: number): number {
    // Simplified cost calculation (actual rates would come from config)
    const rates: { [key: string]: number } = {
      "gemini-1.5-flash": 0.0001,
      "gemini-1.5-pro": 0.001,
      "gemini-2.5-pro-thinking": 0.002
    };
    
    return avgTokens * (rates[model] || 0.001);
  }
  
  private async logAnalytics(interaction: AIInteraction): Promise<void> {
    // Log to Firebase Analytics for dashboards
    try {
      // In production, this would integrate with Firebase Analytics
      // For now, just log to console
      console.log("Analytics Event: ai_interaction", {
        interaction_type: interaction.interactionType,
        model_used: interaction.request.modelUsed,
        response_time: interaction.metrics.responseTime,
        error_rate: interaction.metrics.errorRate,
        user_id: interaction.userId
      });
    } catch (error) {
      console.error("Analytics logging failed:", error);
    }
  }
  
  /**
   * Get clarification questions performance
   */
  async getClarificationPerformance(): Promise<{
    effective: ClarificationMetrics[];
    ineffective: ClarificationMetrics[];
    toRetire: ClarificationMetrics[];
  }> {
    const snapshot = await this.db.collection("clarification_metrics").get();
    const allQuestions: ClarificationMetrics[] = [];
    
    snapshot.forEach(doc => {
      allQuestions.push(doc.data() as ClarificationMetrics);
    });
    
    return {
      effective: allQuestions.filter(q => q.thumbsUpRate > 0.7),
      ineffective: allQuestions.filter(q => q.thumbsDownRate > 0.3),
      toRetire: allQuestions.filter(q => q.shouldRetire)
    };
  }
  
  /**
   * Export metrics for analysis
   */
  async exportMetrics(format: "json" | "csv"): Promise<string> {
    const [
      interactions,
      clarifications,
      opportunities
    ] = await Promise.all([
      this.db.collection("ai_interactions").limit(1000).get(),
      this.db.collection("clarification_metrics").get(),
      this.db.collection("improvement_opportunities").get()
    ]);
    
    const data = {
      interactions: interactions.docs.map(d => d.data()),
      clarifications: clarifications.docs.map(d => d.data()),
      opportunities: opportunities.docs.map(d => d.data()),
      exportedAt: new Date()
    };
    
    if (format === "json") {
      return JSON.stringify(data, null, 2);
    } else {
      // Simplified CSV export
      return "timestamp,type,model,response_time,satisfaction\n" +
        data.interactions.map(i => 
          `${i.timestamp},${i.interactionType},${i.request.modelUsed},${i.metrics.responseTime},${i.feedback?.helpfulness || ""}`
        ).join("\n");
    }
  }
}
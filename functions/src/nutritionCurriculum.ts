/**
 * Science-Backed Nutrition Curriculum for PlateUp v2.0
 * Evidence-based protocols for different health goals
 */

export interface NutritionProtocol {
  goalType: string;
  scientificBasis: string[];
  macroDistribution: {
    proteinPercentage: number;
    carbPercentage: number;
    fatPercentage: number;
    fiberGramsMin: number;
  };
  mealTiming: {
    optimalBreakfastWindow: string;
    optimalLunchWindow: string;
    optimalDinnerWindow: string;
    preworkoutTiming?: string;
    postworkoutTiming?: string;
    fastingProtocol?: string;
  };
  keyPrinciples: string[];
  supplementProtocol: string[];
  avoidanceList: string[];
}

export const NUTRITION_CURRICULUM: { [key: string]: NutritionProtocol } = {
  ENERGY_OPTIMIZATION: {
    goalType: "Sustained Energy & Focus",
    scientificBasis: [
      "Stable blood glucose prevents energy crashes (Jenkins et al., 2021)",
      "Circadian-aligned eating improves metabolic function (Patterson & Sears, 2017)",
      "Balanced macros support sustained neurotransmitter production (Fernstrom, 2013)",
      "Strategic caffeine timing enhances cognitive performance (McLellan et al., 2016)"
    ],
    macroDistribution: {
      proteinPercentage: 25,
      carbPercentage: 40,
      fatPercentage: 35,
      fiberGramsMin: 30
    },
    mealTiming: {
      optimalBreakfastWindow: "7:00 AM - 9:00 AM",
      optimalLunchWindow: "12:00 PM - 1:00 PM",
      optimalDinnerWindow: "5:30 PM - 7:00 PM",
      preworkoutTiming: "90-120 minutes before",
      postworkoutTiming: "Within 45 minutes",
      fastingProtocol: "12-14 hour overnight fast"
    },
    keyPrinciples: [
      "Prioritize complex carbohydrates with fiber to prevent glucose spikes",
      "Include protein at every meal for sustained satiety and focus",
      "Front-load calories earlier in the day for optimal energy",
      "Strategic use of MCT oil or coconut oil for quick brain fuel",
      "Hydrate with electrolytes to maintain cognitive function"
    ],
    supplementProtocol: [
      "Magnesium Glycinate (400mg before bed)",
      "Vitamin D3 (2000-4000 IU with breakfast)",
      "Omega-3 (2-3g EPA/DHA daily)",
      "B-Complex (with breakfast for energy metabolism)",
      "L-Theanine (200mg with caffeine for smooth focus)"
    ],
    avoidanceList: [
      "Refined sugars and high-glycemic foods",
      "Late-night heavy meals (disrupt sleep quality)",
      "Excessive caffeine after 2 PM",
      "Processed foods with artificial additives",
      "Alcohol during weekdays (impairs sleep and recovery)"
    ]
  },

  SLEEP_QUALITY: {
    goalType: "Deep Sleep & Recovery",
    scientificBasis: [
      "Tryptophan-rich foods increase serotonin/melatonin (Bravo et al., 2013)",
      "Avoiding late meals improves sleep quality (Kinsey & Ormsbee, 2015)",
      "Magnesium supplementation enhances sleep depth (Abbasi et al., 2012)",
      "Low evening glycemic load supports stable overnight glucose (Afaghi et al., 2007)"
    ],
    macroDistribution: {
      proteinPercentage: 20,
      carbPercentage: 45,
      fatPercentage: 35,
      fiberGramsMin: 35
    },
    mealTiming: {
      optimalBreakfastWindow: "7:30 AM - 9:30 AM",
      optimalLunchWindow: "12:30 PM - 1:30 PM",
      optimalDinnerWindow: "5:30 PM - 6:30 PM",
      fastingProtocol: "14-16 hour overnight fast (finish dinner early)"
    },
    keyPrinciples: [
      "Finish eating 3-4 hours before bedtime",
      "Include tryptophan-rich foods at dinner (turkey, eggs, cheese)",
      "Complex carbs at dinner to support serotonin production",
      "Avoid stimulants after noon (caffeine half-life is 5-6 hours)",
      "Light protein snack if needed (Greek yogurt, almonds)"
    ],
    supplementProtocol: [
      "Magnesium Glycinate (400-600mg, 30 min before bed)",
      "L-Glycine (3g before bed for deeper sleep)",
      "Melatonin (0.5-1mg, only if needed)",
      "Ashwagandha (300-600mg for stress reduction)",
      "Chamomile tea (1-2 cups in evening)"
    ],
    avoidanceList: [
      "Heavy, fatty meals within 3 hours of bed",
      "Spicy foods at dinner (can cause reflux)",
      "Alcohol (disrupts REM sleep)",
      "Blue light exposure after sunset",
      "Large fluid intake before bed"
    ]
  },

  WEIGHT_LOSS: {
    goalType: "Sustainable Fat Loss",
    scientificBasis: [
      "Protein preserves lean mass during caloric deficit (Westerterp-Plantenga et al., 2012)",
      "Time-restricted feeding enhances fat oxidation (Sutton et al., 2018)",
      "High fiber intake supports satiety and gut health (Slavin, 2013)",
      "Strategic carb timing optimizes insulin sensitivity (Ivy & Kuo, 1998)"
    ],
    macroDistribution: {
      proteinPercentage: 35,
      carbPercentage: 35,
      fatPercentage: 30,
      fiberGramsMin: 35
    },
    mealTiming: {
      optimalBreakfastWindow: "8:00 AM - 10:00 AM",
      optimalLunchWindow: "12:00 PM - 1:00 PM",
      optimalDinnerWindow: "5:00 PM - 6:00 PM",
      preworkoutTiming: "Fasted or 60 min before",
      postworkoutTiming: "Within 30 minutes",
      fastingProtocol: "16:8 intermittent fasting"
    },
    keyPrinciples: [
      "Prioritize protein to 0.8-1g per pound body weight",
      "Volume eating with low-calorie-density foods",
      "Strategic refeeds every 10-14 days",
      "Carb cycling based on activity levels",
      "Track weekly averages, not daily fluctuations"
    ],
    supplementProtocol: [
      "Whey/Plant Protein Powder (fill protein gaps)",
      "Green Tea Extract (EGCG for metabolism)",
      "Fiber supplement (if under 35g from food)",
      "Multivitamin (insurance during deficit)",
      "Omega-3 (reduce inflammation)"
    ],
    avoidanceList: [
      "Liquid calories (except protein shakes)",
      "Hyper-palatable processed foods",
      "Eating while distracted (mindless calories)",
      "Extreme restriction (leads to binging)",
      "Comparing progress to others"
    ]
  },

  MUSCLE_BUILDING: {
    goalType: "Lean Muscle Growth",
    scientificBasis: [
      "Leucine threshold triggers muscle protein synthesis (Norton & Layman, 2006)",
      "Post-workout protein timing enhances recovery (Aragon & Schoenfeld, 2013)",
      "Progressive caloric surplus minimizes fat gain (Garthe et al., 2011)",
      "Sleep quality directly impacts muscle recovery (Dattilo et al., 2011)"
    ],
    macroDistribution: {
      proteinPercentage: 30,
      carbPercentage: 45,
      fatPercentage: 25,
      fiberGramsMin: 30
    },
    mealTiming: {
      optimalBreakfastWindow: "6:30 AM - 8:30 AM",
      optimalLunchWindow: "12:00 PM - 1:00 PM",
      optimalDinnerWindow: "6:00 PM - 7:30 PM",
      preworkoutTiming: "90-120 minutes before",
      postworkoutTiming: "Within 30 minutes (critical)",
      fastingProtocol: "No extended fasting (impairs recovery)"
    },
    keyPrinciples: [
      "4-6 protein feedings daily (25-40g each)",
      "Leucine-rich sources at each meal (2.5-3g leucine)",
      "Strategic carb loading around workouts",
      "300-500 calorie surplus (minimize fat gain)",
      "Consistent meal timing for hormone optimization"
    ],
    supplementProtocol: [
      "Creatine Monohydrate (5g daily)",
      "Whey Protein Isolate (post-workout)",
      "Beta-Alanine (3-5g for endurance)",
      "Citrulline Malate (6-8g pre-workout)",
      "ZMA (zinc, magnesium, B6 for recovery)"
    ],
    avoidanceList: [
      "Excessive cardio (interferes with gains)",
      "Under-eating (halts muscle growth)",
      "Poor sleep habits (kills recovery)",
      "Alcohol excess (impairs protein synthesis)",
      "Neglecting carbs (needed for performance)"
    ]
  },

  STRESS_MANAGEMENT: {
    goalType: "Cortisol Balance & Mental Clarity",
    scientificBasis: [
      "Omega-3 fatty acids reduce inflammatory stress response (Kiecolt-Glaser et al., 2011)",
      "Adaptogenic herbs modulate HPA axis (Panossian & Wikman, 2010)",
      "Stable blood sugar prevents stress-induced cravings (Epel et al., 2001)",
      "Gut health impacts mood via gut-brain axis (Foster & Neufeld, 2013)"
    ],
    macroDistribution: {
      proteinPercentage: 25,
      carbPercentage: 40,
      fatPercentage: 35,
      fiberGramsMin: 40
    },
    mealTiming: {
      optimalBreakfastWindow: "7:00 AM - 9:00 AM",
      optimalLunchWindow: "12:00 PM - 1:30 PM",
      optimalDinnerWindow: "5:30 PM - 7:00 PM",
      fastingProtocol: "12-hour overnight fast (gentle approach)"
    },
    keyPrinciples: [
      "Anti-inflammatory foods (berries, fatty fish, leafy greens)",
      "Prebiotic-rich foods for gut health",
      "Mindful eating practices (reduces cortisol)",
      "Herbal teas throughout day (chamomile, green tea)",
      "Regular meal schedule (prevents stress eating)"
    ],
    supplementProtocol: [
      "Ashwagandha (600mg KSM-66 daily)",
      "Rhodiola (200-400mg for acute stress)",
      "L-Theanine (200-400mg for calm focus)",
      "Probiotics (diverse strains)",
      "Vitamin B-Complex (stress depletes B vitamins)"
    ],
    avoidanceList: [
      "Excessive caffeine (increases cortisol)",
      "Skipping meals (triggers stress response)",
      "Refined sugars (cause mood swings)",
      "Processed foods (increase inflammation)",
      "Eating while stressed (impairs digestion)"
    ]
  },

  ATHLETIC_PERFORMANCE: {
    goalType: "Peak Athletic Performance",
    scientificBasis: [
      "Carb periodization optimizes fuel utilization (Stellingwerff & Cox, 2014)",
      "Nitrate-rich foods enhance oxygen efficiency (Jones, 2014)",
      "Proper hydration maintains performance (Sawka et al., 2007)",
      "Nutrient timing affects training adaptations (Kerksick et al., 2017)"
    ],
    macroDistribution: {
      proteinPercentage: 25,
      carbPercentage: 50,
      fatPercentage: 25,
      fiberGramsMin: 30
    },
    mealTiming: {
      optimalBreakfastWindow: "6:00 AM - 8:00 AM",
      optimalLunchWindow: "12:00 PM - 1:00 PM",
      optimalDinnerWindow: "6:00 PM - 7:30 PM",
      preworkoutTiming: "2-3 hours before (full meal) or 30-60 min (snack)",
      postworkoutTiming: "Within 30 minutes (critical window)",
      fastingProtocol: "No fasting on training days"
    },
    keyPrinciples: [
      "Carb loading for endurance events (2-3 days prior)",
      "Electrolyte balance for optimal hydration",
      "Nitrate-rich foods 2-3 hours pre-competition",
      "Post-workout 3:1 or 4:1 carb:protein ratio",
      "Periodize nutrition with training cycles"
    ],
    supplementProtocol: [
      "Creatine Monohydrate (5g daily)",
      "Beta-Alanine (3-5g for lactate buffering)",
      "Caffeine (3-6mg/kg body weight pre-event)",
      "Sodium Bicarbonate (for high-intensity)",
      "Beetroot juice (nitrates for endurance)"
    ],
    avoidanceList: [
      "New foods before competition",
      "High fiber immediately pre-event",
      "Dehydration (monitor urine color)",
      "Excessive fat pre-workout (slows digestion)",
      "Alcohol during training phases"
    ]
  }
};

// Meal timing optimization based on circadian rhythms
export const CIRCADIAN_MEAL_TIMING = {
  MORNING_TYPES: {
    cortisol_peak: "6:00 AM - 8:00 AM",
    optimal_breakfast: "6:30 AM - 8:30 AM",
    optimal_lunch: "11:30 AM - 12:30 PM",
    optimal_dinner: "5:00 PM - 6:30 PM",
    last_meal_cutoff: "7:00 PM"
  },
  EVENING_TYPES: {
    cortisol_peak: "8:00 AM - 10:00 AM",
    optimal_breakfast: "8:30 AM - 10:30 AM",
    optimal_lunch: "1:00 PM - 2:00 PM",
    optimal_dinner: "6:30 PM - 8:00 PM",
    last_meal_cutoff: "8:30 PM"
  },
  SHIFT_WORKERS: {
    // Adjusted for night shift workers
    pre_shift_meal: "2-3 hours before shift",
    mid_shift_meal: "Halfway through shift",
    post_shift_meal: "Light meal after shift",
    sleep_preparation: "Avoid food 2 hours before sleep"
  }
};

// Evidence-based macro ratios for specific conditions
export const CONDITION_SPECIFIC_MACROS = {
  PCOS: {
    proteinPercentage: 30,
    carbPercentage: 35,
    fatPercentage: 35,
    notes: "Lower glycemic index carbs, anti-inflammatory fats"
  },
  DIABETES_PREVENTION: {
    proteinPercentage: 25,
    carbPercentage: 40,
    fatPercentage: 35,
    notes: "Focus on complex carbs, fiber, and meal timing"
  },
  THYROID_SUPPORT: {
    proteinPercentage: 30,
    carbPercentage: 40,
    fatPercentage: 30,
    notes: "Adequate carbs for T3 conversion, selenium-rich foods"
  },
  IBS_MANAGEMENT: {
    proteinPercentage: 25,
    carbPercentage: 45,
    fatPercentage: 30,
    notes: "Low FODMAP approach, gradual fiber increase"
  }
};

// Food quality scoring system
export const FOOD_QUALITY_SCORES = {
  NUTRIENT_DENSITY: {
    high: ["leafy greens", "berries", "fatty fish", "eggs", "nuts"],
    medium: ["whole grains", "lean meats", "dairy", "legumes"],
    low: ["refined grains", "processed meats", "sugary foods"]
  },
  SATIETY_INDEX: {
    high: ["oatmeal", "potatoes", "eggs", "fish", "apples"],
    medium: ["rice", "pasta", "chicken", "yogurt"],
    low: ["pastries", "candy", "chips", "sugary drinks"]
  },
  INFLAMMATION_SCORE: {
    anti_inflammatory: ["salmon", "walnuts", "blueberries", "turmeric", "green tea"],
    neutral: ["chicken", "rice", "potatoes", "milk"],
    pro_inflammatory: ["fried foods", "processed meats", "refined sugar", "trans fats"]
  }
};

// Performance optimization protocols
export const PERFORMANCE_PROTOCOLS = {
  COGNITIVE_ENHANCEMENT: {
    foods: ["blueberries", "walnuts", "dark chocolate", "green tea", "eggs"],
    timing: "DHA-rich breakfast, antioxidants mid-morning",
    supplements: ["Lion's Mane", "Bacopa Monnieri", "Rhodiola"]
  },
  IMMUNE_SUPPORT: {
    foods: ["garlic", "ginger", "citrus", "mushrooms", "yogurt"],
    timing: "Vitamin C with meals, probiotics on empty stomach",
    supplements: ["Vitamin D3", "Zinc", "Elderberry", "Probiotics"]
  },
  GUT_HEALTH: {
    foods: ["sauerkraut", "kimchi", "kefir", "jerusalem artichokes", "green bananas"],
    timing: "Fermented foods with meals, prebiotics between meals",
    supplements: ["Multi-strain probiotics", "L-Glutamine", "Digestive enzymes"]
  }
};
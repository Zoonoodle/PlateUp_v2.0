# PlateUp Cloud Functions

This directory contains all Firebase Cloud Functions for PlateUp v2.0.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Configure Firebase:
```bash
firebase use --add
# Select your Firebase project
```

3. Set up environment variables:
```bash
firebase functions:config:set gemini.api_key="YOUR_GEMINI_API_KEY"
```

## Development

1. Build TypeScript:
```bash
npm run build
```

2. Run locally with emulator:
```bash
npm run serve
```

3. Deploy to production:
```bash
npm run deploy
```

## Functions

### `generateHealthBlueprint`
- Generates personalized nutrition plans using Gemini 2.5 Pro
- Called during onboarding completion
- Input: User onboarding data
- Output: Health blueprint with calorie/macro targets

### `analyzeMealImage` 
- Analyzes meal images using Gemini Flash
- Provides nutritional information and clarification questions
- Input: Image data, user context
- Output: Meal analysis with macros

### `generateCoachingInsights`
- Creates personalized coaching insights using Gemini Flash
- Runs daily or on-demand
- Input: User ID, timeframe
- Output: Array of coaching insights

### Scheduled Functions

- `dailyCoachingJob`: Runs daily at 8 AM to generate insights for active users
- `cleanupOnboarding`: Runs daily at 3 AM to clean up incomplete onboarding sessions

## Security

- All functions require authentication except scheduled jobs
- User data is scoped to authenticated user only
- See `firestore.rules` and `storage.rules` for security configuration

## Testing

```bash
npm test
```

## Monitoring

View logs:
```bash
firebase functions:log
```
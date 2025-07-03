#!/bin/bash

# PlateUp v2.0 - Comprehensive Test Runner
# This script runs all tests and generates a comprehensive report

set -e

echo "🧪 PlateUp v2.0 - Running Comprehensive Test Suite"
echo "=================================================="
echo ""

# Set up test environment
export TESTING_MODE=true
export FIREBASE_AUTH_EMULATOR_HOST=localhost:9099
export FIRESTORE_EMULATOR_HOST=localhost:8080

# Create test results directory
RESULTS_DIR="test_results_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$RESULTS_DIR"

# Function to run tests and capture results
run_test_suite() {
    local suite_name=$1
    local test_command=$2
    local output_file="$RESULTS_DIR/${suite_name}_results.txt"
    
    echo "▶️  Running $suite_name..."
    
    if $test_command > "$output_file" 2>&1; then
        echo "✅ $suite_name: PASSED"
        echo "PASSED" > "$RESULTS_DIR/${suite_name}_status.txt"
    else
        echo "❌ $suite_name: FAILED"
        echo "FAILED" > "$RESULTS_DIR/${suite_name}_status.txt"
    fi
    
    # Extract key metrics
    grep -E "(passed|failed|skipped)" "$output_file" | tail -1 >> "$RESULTS_DIR/summary.txt" || true
}

# Start Firebase emulators
echo "🔥 Starting Firebase emulators..."
firebase emulators:start --only auth,firestore,functions &
EMULATOR_PID=$!
sleep 5

# Run Unit Tests
echo ""
echo "1️⃣  Unit Tests"
echo "---------------"
run_test_suite "unit_tests" "xcodebuild test -scheme PlateUp -destination 'platform=iOS Simulator,name=iPhone 15 Pro' -only-testing:PlateUpTests"

# Run UI Tests
echo ""
echo "2️⃣  UI Tests"
echo "------------"
run_test_suite "ui_tests" "xcodebuild test -scheme PlateUp -destination 'platform=iOS Simulator,name=iPhone 15 Pro' -only-testing:PlateUpUITests"

# Run Onboarding Flow Tests
echo ""
echo "3️⃣  Onboarding Flow Tests"
echo "-------------------------"
run_test_suite "onboarding_tests" "xcodebuild test -scheme PlateUp -destination 'platform=iOS Simulator,name=iPhone 15 Pro' -only-testing:PlateUpUITests/OnboardingFlowTests"

# Run Integration Tests
echo ""
echo "4️⃣  Integration Tests"
echo "--------------------"
run_test_suite "integration_tests" "xcodebuild test -scheme PlateUp -destination 'platform=iOS Simulator,name=iPhone 15 Pro' -only-testing:PlateUpTests/FirebaseIntegrationTests,PlateUpTests/AIIntegrationTests"

# Run Performance Tests
echo ""
echo "5️⃣  Performance Tests"
echo "---------------------"
run_test_suite "performance_tests" "xcodebuild test -scheme PlateUp -destination 'platform=iOS Simulator,name=iPhone 15 Pro' -only-testing:PlateUpTests/PerformanceMonitoringTests -enablePerformanceTestsDiagnostics YES"

# Stop Firebase emulators
kill $EMULATOR_PID 2>/dev/null || true

# Generate comprehensive report
echo ""
echo "📊 Generating Test Report..."
echo "============================"

cat > "$RESULTS_DIR/comprehensive_report.md" << EOF
# PlateUp v2.0 Test Report
Generated: $(date)

## Test Summary

### Success Metrics
- **Target Onboarding Completion Rate**: 85%
- **Target Day 1 Retention**: 40%
- **Max Onboarding Taps**: 30
- **Max AI Response Time**: 10s
- **Min Clarification Thumbs Up Rate**: 85%

### Test Results

EOF

# Add test results to report
for status_file in "$RESULTS_DIR"/*_status.txt; do
    if [ -f "$status_file" ]; then
        suite_name=$(basename "$status_file" _status.txt)
        status=$(cat "$status_file")
        echo "- **$suite_name**: $status" >> "$RESULTS_DIR/comprehensive_report.md"
    fi
done

# Extract key metrics from test outputs
echo "" >> "$RESULTS_DIR/comprehensive_report.md"
echo "### Key Metrics" >> "$RESULTS_DIR/comprehensive_report.md"
echo "" >> "$RESULTS_DIR/comprehensive_report.md"

# Parse onboarding metrics
if [ -f "$RESULTS_DIR/onboarding_tests_results.txt" ]; then
    taps=$(grep -o "completed in [0-9]* taps" "$RESULTS_DIR/onboarding_tests_results.txt" | grep -o "[0-9]*" | head -1)
    if [ ! -z "$taps" ]; then
        echo "- Onboarding Taps: $taps (Target: <30)" >> "$RESULTS_DIR/comprehensive_report.md"
    fi
fi

# Parse performance metrics
if [ -f "$RESULTS_DIR/performance_tests_results.txt" ]; then
    response_time=$(grep -o "AI response time: [0-9.]*s" "$RESULTS_DIR/performance_tests_results.txt" | grep -o "[0-9.]*" | head -1)
    if [ ! -z "$response_time" ]; then
        echo "- AI Response Time: ${response_time}s (Target: <10s)" >> "$RESULTS_DIR/comprehensive_report.md"
    fi
fi

# Add recommendations
echo "" >> "$RESULTS_DIR/comprehensive_report.md"
echo "## Recommendations" >> "$RESULTS_DIR/comprehensive_report.md"
echo "" >> "$RESULTS_DIR/comprehensive_report.md"

# Check if any tests failed
if grep -q "FAILED" "$RESULTS_DIR"/*_status.txt; then
    echo "⚠️  Some tests failed. Please review the detailed results in: $RESULTS_DIR" >> "$RESULTS_DIR/comprehensive_report.md"
else
    echo "✅ All tests passed! The app meets quality standards for launch." >> "$RESULTS_DIR/comprehensive_report.md"
fi

# Display summary
echo ""
echo "📋 Test Summary"
echo "==============="
cat "$RESULTS_DIR/comprehensive_report.md"

echo ""
echo "✅ Test run complete. Full results saved to: $RESULTS_DIR"
echo ""

# Open report in default editor
open "$RESULTS_DIR/comprehensive_report.md" 2>/dev/null || true

# Return appropriate exit code
if grep -q "FAILED" "$RESULTS_DIR"/*_status.txt; then
    exit 1
else
    exit 0
fi
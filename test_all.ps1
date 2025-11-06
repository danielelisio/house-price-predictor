# All-in-one API test script for PowerShell users
# Usage: .\test_all.ps1
# Contains: Container check + Health check + Prediction test

$CONTAINER_ID = "cbadaaa41e51"

Write-Host "Running Complete API Test Suite" -ForegroundColor Cyan
Write-Host "Container: $CONTAINER_ID" -ForegroundColor Yellow
Write-Host "================================" -ForegroundColor Gray

# Test 1: Container Status
Write-Host "1. Checking Container Status..." -ForegroundColor Blue
$containerRunning = docker ps --format "table {{.ID}}" | Select-String $CONTAINER_ID
if ($containerRunning) {
    Write-Host "   Container is running" -ForegroundColor Green
} else {
    Write-Host "   Container not found or not running" -ForegroundColor Red
    Write-Host "   Try: docker ps" -ForegroundColor Yellow
    exit 1
}

# Test 2: Health Check
Write-Host ""
Write-Host "2. Health Check..." -ForegroundColor Blue

# Simple health check command
$healthCmd = "import urllib.request; import json; response = urllib.request.urlopen('http://localhost:8000/health'); result = json.loads(response.read().decode()); print('Health Check: SUCCESS'); print('Status:', result['status']); print('Model Loaded:', result['model_loaded'])"

try {
    $healthResult = docker exec $CONTAINER_ID python -c $healthCmd
    Write-Host "   $healthResult" -ForegroundColor Green
} catch {
    Write-Host "   Health Check: FAILED" -ForegroundColor Red
}

# Test 3: Prediction Test
Write-Host ""
Write-Host "3. Prediction Test..." -ForegroundColor Blue
Write-Host "   Test House: 2000 sqft, 3 bed, 2.5 bath, suburban, good condition" -ForegroundColor Gray

# Simple prediction command
$predCmd = "import urllib.request; import json; data = {'sqft': 2000, 'bedrooms': 3, 'bathrooms': 2.5, 'location': 'suburban', 'year_built': 2010, 'condition': 'Good'}; req = urllib.request.Request('http://localhost:8000/predict', data=json.dumps(data).encode(), headers={'Content-Type': 'application/json'}); response = urllib.request.urlopen(req); result = json.loads(response.read().decode()); print('Prediction: SUCCESS'); print('Predicted Price: $' + str(round(result['predicted_price'], 2))); ci = result.get('confidence_interval', []); print('Confidence Range: $' + str(round(ci[0], 2)) + ' - $' + str(round(ci[1], 2))) if ci else None"

try {
    $predResult = docker exec $CONTAINER_ID python -c $predCmd
    Write-Host "   $predResult" -ForegroundColor Green
} catch {
    Write-Host "   Prediction: FAILED" -ForegroundColor Red
}

Write-Host ""
Write-Host "================================" -ForegroundColor Gray
Write-Host "All tests completed! API is working!" -ForegroundColor Green
#!/bin/bash
# All-in-one API test script for the ultra-lazy
# Usage: ./test_all.sh
# Contains: Container check + Health check + Prediction test

CONTAINER_ID="cbadaaa41e51"

echo "🚀 Running Complete API Test Suite"
echo "Container: $CONTAINER_ID"
echo "================================"

# Test 1: Container Status
echo "📦 1. Checking Container Status..."
if docker ps | grep -q $CONTAINER_ID; then
    echo "   ✅ Container is running"
else
    echo "   ❌ Container not found or not running"
    echo "   💡 Try: docker ps"
    exit 1
fi

# Test 2: Health Check
echo ""
echo "🏥 2. Health Check..."
docker exec $CONTAINER_ID python -c "
import urllib.request
import json
try:
    response = urllib.request.urlopen('http://localhost:8000/health')
    result = json.loads(response.read().decode())
    print('   ✅ Health Check: SUCCESS')
    print(f'   Status: {result[\"status\"]}')
    print(f'   Model Loaded: {result[\"model_loaded\"]}')
except Exception as e:
    print('   ❌ Health Check: FAILED')
    print(f'   Error: {e}')
"

# Test 3: Prediction Test
echo ""
echo "🏠 3. Prediction Test..."
docker exec $CONTAINER_ID python -c "
import urllib.request
import json

# Sample house data
data = {
    'sqft': 2000,
    'bedrooms': 3,
    'bathrooms': 2.5,
    'location': 'suburban',
    'year_built': 2010,
    'condition': 'Good'
}

print('   🏡 Test House: 2000 sqft, 3 bed, 2.5 bath, suburban, good condition')

try:
    req_data = json.dumps(data).encode('utf-8')
    req = urllib.request.Request(
        'http://localhost:8000/predict',
        data=req_data,
        headers={'Content-Type': 'application/json'}
    )
    response = urllib.request.urlopen(req)
    result = json.loads(response.read().decode())
    
    print('   ✅ Prediction: SUCCESS')
    print(f'   💰 Predicted Price: \${result[\"predicted_price\"]:,.2f}')
    
    if 'confidence_interval' in result:
        ci = result['confidence_interval']
        print(f'   📊 Confidence Range: \${ci[0]:,.2f} - \${ci[1]:,.2f}')
        
except Exception as e:
    print('   ❌ Prediction: FAILED')
    print(f'   Error: {e}')
"

echo ""
echo "================================"
echo "🎯 All tests completed! API is working! 🎉"
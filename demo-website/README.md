# E-Commerce Demo Website

A simple interactive demo website that sends real-time clickstream events to the data pipeline.

## Features

- 🛍️ **Product Browsing**: Browse products and view details
- 🔍 **Search Functionality**: Search for products
- 💳 **Purchase Simulation**: Simulate purchases
- 📊 **Real-time Event Tracking**: All actions are sent to the pipeline
- 🎨 **Modern UI**: Beautiful, responsive design

## How to Use

### Option 1: Open Directly in Browser

1. Make sure API server is running:
   ```powershell
   cd api
   .\venv\Scripts\Activate.ps1
   python server.py
   ```

2. Open `index.html` in your browser:
   - Double-click `index.html`
   - Or right-click → Open with → Browser

3. Start interacting:
   - Click on products
   - Search for items
   - Click "Buy Now" buttons
   - Watch events being sent in real-time!

### Option 2: Serve with Python (Recommended)

1. Navigate to demo-website folder:
   ```powershell
   cd demo-website
   ```

2. Start a simple HTTP server:
   ```powershell
   # Python 3
   python -m http.server 8000
   
   # Or Python 2
   python -m SimpleHTTPServer 8000
   ```

3. Open in browser:
   - Go to: http://localhost:8000
   - This avoids CORS issues

## What Events Are Sent

### 1. Page Load (Click Event)
- **Type**: `click`
- **Page**: `/home`
- **Triggered**: When page loads

### 2. Product View (View Event)
- **Type**: `view`
- **Page**: `/product/{id}`
- **Product**: Product ID
- **Triggered**: When clicking "View Details" or product card

### 3. Search (View Event)
- **Type**: `view`
- **Page**: `/products`
- **Query**: Search term
- **Triggered**: When pressing Enter in search box

### 4. Purchase (Purchase Event)
- **Type**: `purchase`
- **Page**: `/checkout`
- **Product**: Product ID
- **Triggered**: When clicking "Buy Now"

## Viewing Events in Pipeline

1. **Kafka UI**: http://localhost:8080
   - Go to Topics → `acme.clickstream.raw.events`
   - Messages tab → See events appearing in real-time

2. **Event Log**: 
   - Check the "Real-time Event Log" section on the demo website
   - Shows events being sent with timestamps

## Customization

### Change API URL

Edit `index.html` and change:
```javascript
const API_URL = 'http://localhost:60000/collect';
```

### Add More Products

Edit the `products` array in `index.html`:
```javascript
const products = [
    { id: 101, name: 'Laptop Pro', price: 1299, emoji: '💻' },
    // Add more products here
];
```

### Change Customer ID

The customer ID is randomly generated. To use a fixed ID:
```javascript
let customerId = 12345; // Your customer ID
```

## Troubleshooting

### Events Not Sending

1. **Check API Server**: Make sure API is running on port 60000
2. **Check CORS**: If opening file directly, use Python HTTP server instead
3. **Check Browser Console**: Open DevTools (F12) to see errors

### CORS Errors

If you see CORS errors:
- Use Python HTTP server (Option 2) instead of opening file directly
- Or add CORS headers to API server (modify `api/server.py`)

## Demo Flow

1. **Page loads** → Sends "click" event on `/home`
2. **User searches** → Sends "view" event on `/products` with query
3. **User clicks product** → Sends "view" event on `/product/{id}`
4. **User purchases** → Sends "purchase" event on `/checkout`

All events flow through:
```
Demo Website → API → Kafka → Spark → Data Lake
```

## Perfect for Demonstration!

This demo website makes your presentation much more impressive:
- ✅ **Visual**: Real website instead of JSON commands
- ✅ **Interactive**: Audience can see actions in real-time
- ✅ **Realistic**: Simulates actual e-commerce behavior
- ✅ **Engaging**: More interesting than command-line demos

**Show the website, perform actions, then show the events appearing in Kafka UI!**


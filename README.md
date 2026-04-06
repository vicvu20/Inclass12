# Inventory Management App with Firestore

## Overview
This Flutter app manages inventory items using Firebase Firestore. It supports real-time CRUD operations so the UI updates automatically when data changes.

## Features
- Add inventory items
- View live inventory using StreamBuilder
- Edit existing items
- Delete items
- Validation for empty, numeric, and invalid inputs

## Enhanced Features
1. Search items by name or category
2. Filter items by category
3. Low stock indicator for items with quantity 5 or less

## Tech Used
- Flutter
- Firebase Core
- Cloud Firestore

## Architecture
- `models/` for data classes
- `services/` for Firestore CRUD logic
- `widgets/` for reusable UI form dialog
- `main.dart` for app setup and page structure

## Validation
- Prevents empty fields
- Ensures quantity is a whole number
- Ensures price is numeric
- Prevents negative values

## Reflection
See reflection document submitted with this project.
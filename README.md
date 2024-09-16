# Recipes

Recipes is a native visionOS app that allows users to browse recipes using `https://themealdb.com/api.php`.  

<img width="500" alt="Group 2" src="https://github.com/user-attachments/assets/8ae2d53a-6a67-4baf-b148-7117fe87a4b1">
<img width="500" alt="Group 2" src="https://github.com/user-attachments/assets/f9ddda5d-bd4f-45f2-b8ab-53e9c588732c">

## Architecture Overview

This example shows how an app can be built in a modular & scalable way using SPM (Swift-Package-Manager), TCA ([ComposableArchitecture](https://github.com/pointfreeco/swift-composable-architecture)), and Swift Concurrency.

### I. Dependencies

Dependencies are separated between the interface & implementation to keep SwiftUI Previews fast. The live implementations are only imported when the app is ready to built for a device or simulator, and preview implementations provide mock-data for previews.

1. `ApiClient`
    * Defines models & endpoints for the api.
    * Provides a preview implementation with mock-data.

2. `ApiClient+live`
    * Live implementation of the api-client.
    * Wraps a private actor to make api-requests to the meal-db.

### II. Features

Features are defined as Reducers, containing State, Actions, and Dependencies. Actions which can be sent thru the view are defined as their own enum to keep the code easy to read.

1. `AppReducer`
    * Root reducer of the app. You can add more features here if you like.

2. `MealList`
    * Feature that fetches & displays a list of meals from the api.

3. `MealDetails`
    * Feature that displays the details of a meal.

### III. Library

1. `DesignSystem`
    * Contains Colors, Fonts, and View extensions that can be used in other features.

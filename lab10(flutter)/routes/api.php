<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\RegisterController;
use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\UserController;

/*
|----------------------------------------------------------------------
| API Routes
|----------------------------------------------------------------------
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// Register Route
Route::post('/register', [RegisterController::class, 'register']);

// Login Route
Route::post('/login', [LoginController::class, 'login']);

// CRUD Routes for User (Protected)
Route::middleware('auth:sanctum')->group(function () {
    // Create User
    // Route::post('/user', [UserController::class, 'create']);  // Optional, if you need to handle user creation here

    // Read all Users
    Route::get('/users', [UserController::class, 'index']);

    // Read a specific User by ID
    Route::get('/user/{id}', [UserController::class, 'show']);

    // Update User
    Route::put('/user/{id}', [UserController::class, 'update']);

    // Delete User
    Route::delete('/user/{id}', [UserController::class, 'destroy']);

    Route::get('/profile', [UserController::class, 'getProfile']);
});



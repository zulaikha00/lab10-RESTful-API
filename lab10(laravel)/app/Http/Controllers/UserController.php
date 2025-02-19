<?php


namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class UserController extends Controller
{
    // Read all Users
    public function index()
    {
        $users = User::all();
        return response()->json(['users' => $users], 200);
    }

    // Read a specific User by ID
    public function show($id)
    {
        $user = User::find($id);

        if ($user) {
            return response()->json(['user' => $user], 200);
        }

        return response()->json(['error' => 'User not found'], 404);
    }

    // Update User Profile
    public function update(Request $request, $id)
    {
        // Validate the incoming request data
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email,' . $id,
            'oldPassword' => 'nullable|string|min:6',
            'newPassword' => 'nullable|string|min:6',
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()->first()], 400);
        }

        // Find the user by ID
        $user = User::find($id);

        if (!$user) {
            return response()->json(['error' => 'User not found'], 404);
        }

        // Update name and email
        $user->name = $request->name;
        $user->email = $request->email;

        // Check if oldPassword and newPassword are provided and match the current password
        if ($request->has('oldPassword') && $request->has('newPassword')) {
            if (!Hash::check($request->oldPassword, $user->password)) {
                return response()->json(['error' => 'Old password is incorrect'], 400);
            }
            $user->password = Hash::make($request->newPassword);
        }

        // Save the updated user data
        $user->save();

        return response()->json(['user' => $user], 200);
    }

    // Delete User
    public function destroy($id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json(['error' => 'User not found'], 404);
        }

        $user->delete();

        return response()->json(['message' => 'User deleted successfully'], 200);
    }

    // Get Profile of the authenticated user
    public function getProfile(Request $request)
    {
        $user = auth()->user();

        if (!$user) {
            return response()->json(['error' => 'User not authenticated'], 401);
        }

        return response()->json([
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
        ]);
    }
}

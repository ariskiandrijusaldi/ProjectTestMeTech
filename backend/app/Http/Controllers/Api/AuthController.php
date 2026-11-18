<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\LoginRequest;
use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /** Login untuk semua role (dipakai aplikasi mahasiswa). */
    public function login(LoginRequest $request): JsonResponse
    {
        return $this->attempt($request);
    }

    /** Login khusus admin (halaman "Login Admin"). */
    public function adminLogin(LoginRequest $request): JsonResponse
    {
        return $this->attempt($request, 'admin');
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Logout berhasil.']);
    }

    public function me(Request $request): UserResource
    {
        return new UserResource($request->user());
    }

    private function attempt(LoginRequest $request, ?string $role = null): JsonResponse
    {
        $user = User::where('email', $request->email)
            ->orWhere('nim', $request->email)
            ->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Email atau password salah.'],
            ]);
        }

        if ($role && $user->role !== $role) {
            return response()->json(['message' => 'Akun ini tidak memiliki akses admin.'], 403);
        }

        $token = $user->createToken($request->input('device_name', 'mobile'), [$user->role])
            ->plainTextToken;

        return response()->json([
            'message'    => 'Login berhasil.',
            'token'      => $token,
            'token_type' => 'Bearer',
            'user'       => new UserResource($user),
        ]);
    }
}

<?php

namespace Tests\Feature;

use App\Models\Book;
use App\Models\Category;
use App\Models\Loan;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class LibraryFlowTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->admin = User::create([
            'name' => 'Administrator',
            'email' => 'admin@test.ac.id',
            'nim' => null,
            'password' => bcrypt('admin123'),
            'role' => 'admin',
        ]);

        $this->mahasiswa = User::create([
            'name' => 'Mahasiswa Test',
            'email' => 'mhs@test.ac.id',
            'nim' => '2301001',
            'password' => bcrypt('password123'),
            'role' => 'mahasiswa',
        ]);

        $this->category = Category::create(['name' => 'Teknologi', 'slug' => 'teknologi']);

        $this->book = Book::create([
            'category_id' => $this->category->id,
            'isbn' => '978-1234567890',
            'title' => 'Buku Test',
            'author' => 'Penulis Test',
            'stock_total' => 5,
            'stock_available' => 5,
        ]);
    }

    // ---------- LOGIN ----------

    public function test_mahasiswa_can_login_with_email_and_password(): void
    {
        $response = $this->postJson('/api/login', [
            'email' => $this->mahasiswa->email,
            'password' => 'password123',
        ]);
        $response->assertStatus(200);
        $this->assertNotNull($response->json('token'));
        $this->assertSame('mahasiswa', $response->json('user.role'));
    }

    public function test_mahasiswa_can_login_with_nim_as_email(): void
    {
        $response = $this->postJson('/api/login', [
            'email' => $this->mahasiswa->nim,
            'password' => 'password123',
        ]);
        $response->assertStatus(200);
        $this->assertSame('mahasiswa', $response->json('user.role'));
    }

    public function test_admin_login_returns_admin_role(): void
    {
        $response = $this->postJson('/api/login', [
            'email' => $this->admin->email,
            'password' => 'admin123',
        ]);
        $response->assertStatus(200);
        $this->assertSame('admin', $response->json('user.role'));
    }

    public function test_login_fails_with_wrong_password(): void
    {
        $this->postJson('/api/login', [
            'email' => $this->mahasiswa->email,
            'password' => 'salah',
        ])->assertStatus(422);
    }

    // ---------- ME ----------

    public function test_me_endpoint_returns_logged_in_user(): void
    {
        Sanctum::actingAs($this->mahasiswa);
        $response = $this->getJson('/api/me');
        $response->assertStatus(200);
        $content = $response->json();
        // Resource bisa dibungkus 'data' tergantung versi Laravel
        $userData = $content['data'] ?? $content;
        $this->assertArrayHasKey('id', $userData);
        $this->assertSame($this->mahasiswa->id, $userData['id']);
    }

    // ---------- PINJAWAN: AJUKAN ----------

    public function test_mahasiswa_can_request_loan(): void
    {
        Sanctum::actingAs($this->mahasiswa);
        $response = $this->postJson('/api/loans', ['book_id' => $this->book->id]);
        $response->assertStatus(201);
        $this->assertSame('pending', $response->json('data.status'));
        $code = $response->json('data.code');
        $this->assertStringStartsWith('PJ', $code);
        $this->assertStringEndsWith(date('ymd'), substr($code, 2, 6));
    }

    public function test_cannot_request_loan_if_stock_is_zero(): void
    {
        $this->book->update(['stock_available' => 0]);
        Sanctum::actingAs($this->mahasiswa);
        $this->postJson('/api/loans', ['book_id' => $this->book->id])
            ->assertStatus(422);
    }

    public function test_cannot_request_loan_for_same_book_with_active_loan(): void
    {
        Loan::create([
            'user_id' => $this->mahasiswa->id,
            'book_id' => $this->book->id,
            'code' => 'PJ25010101',
            'loan_code' => 'PJ25010101',
            'quantity' => 1,
            'status' => 'pending',
            'loan_date' => Carbon::today(),
        ]);
        Sanctum::actingAs($this->mahasiswa);
        $this->postJson('/api/loans', ['book_id' => $this->book->id])
            ->assertStatus(422);
    }

    public function test_cannot_request_loan_if_max_active_loans_reached(): void
    {
        config(['library.max_active_loans' => 1]);
        Loan::create([
            'user_id' => $this->mahasiswa->id,
            'book_id' => $this->book->id,
            'code' => 'PJ25010101',
            'loan_code' => 'PJ25010101',
            'quantity' => 1,
            'status' => 'pending',
            'loan_date' => Carbon::today(),
        ]);
        $book2 = Book::create([
            'category_id' => $this->category->id,
            'isbn' => '978-1234567891',
            'title' => 'Buku Test 2',
            'author' => 'Penulis Test',
            'stock_total' => 5,
            'stock_available' => 5,
        ]);
        Sanctum::actingAs($this->mahasiswa);
        $this->postJson('/api/loans', ['book_id' => $book2->id])
            ->assertStatus(422);
    }

    public function test_cannot_request_loan_if_unpaid_fine_exists(): void
    {
        Loan::create([
            'user_id' => $this->mahasiswa->id,
            'book_id' => $this->book->id,
            'code' => 'PJ25010101',
            'loan_code' => 'PJ25010101',
            'quantity' => 1,
            'status' => 'returned',
            'loan_date' => Carbon::today(),
            'due_date' => Carbon::today(),
            'returned_at' => Carbon::today(),
            'fine_amount' => 5000,
            'fine_paid' => false,
        ]);
        Sanctum::actingAs($this->mahasiswa);
        $this->postJson('/api/loans', ['book_id' => $this->book->id])
            ->assertStatus(422);
    }

    // ---------- ADMIN: APPROVE / REJECT ----------

    public function test_admin_can_approve_loan(): void
    {
        $loan = Loan::create([
            'user_id' => $this->mahasiswa->id,
            'book_id' => $this->book->id,
            'code' => 'PJ25010101',
            'loan_code' => 'PJ25010101',
            'quantity' => 1,
            'status' => 'pending',
            'loan_date' => Carbon::today(),
        ]);
        Sanctum::actingAs($this->admin);
        $response = $this->patchJson('/api/admin/loans/' . $loan->id . '/approve');
        $response->assertStatus(200);
        $this->assertSame('approved', $response->json('data.status'));
        $this->assertSame($this->admin->id, $response->json('data.approved_by.id'));
    }

    public function test_mahasiswa_cannot_access_admin_endpoint(): void
    {
        $loan = Loan::create([
            'user_id' => $this->mahasiswa->id,
            'book_id' => $this->book->id,
            'code' => 'PJ25010101',
            'loan_code' => 'PJ25010101',
            'quantity' => 1,
            'status' => 'pending',
            'loan_date' => Carbon::today(),
        ]);
        Sanctum::actingAs($this->mahasiswa);
        $this->patchJson('/api/admin/loans/' . $loan->id . '/approve')
            ->assertStatus(403);
    }

    public function test_admin_can_reject_loan_with_reason(): void
    {
        $loan = Loan::create([
            'user_id' => $this->mahasiswa->id,
            'book_id' => $this->book->id,
            'code' => 'PJ25010101',
            'loan_code' => 'PJ25010101',
            'quantity' => 1,
            'status' => 'pending',
            'loan_date' => Carbon::today(),
        ]);
        Sanctum::actingAs($this->admin);
        $response = $this->patchJson('/api/admin/loans/' . $loan->id . '/reject', ['reason' => 'Buku rusak']);
        $response->assertStatus(200);
        $this->assertSame('rejected', $response->json('data.status'));
        $this->assertSame('Buku rusak', $response->json('data.rejected_reason'));
    }

    public function test_admin_cannot_reject_without_reason(): void
    {
        $loan = Loan::create([
            'user_id' => $this->mahasiswa->id,
            'book_id' => $this->book->id,
            'code' => 'PJ25010101',
            'loan_code' => 'PJ25010101',
            'quantity' => 1,
            'status' => 'pending',
            'loan_date' => Carbon::today(),
        ]);
        Sanctum::actingAs($this->admin);
        $this->patchJson('/api/admin/loans/' . $loan->id . '/reject', [])
            ->assertStatus(422);
    }

    // ---------- ADMIN: RETURN ----------

    public function test_admin_can_return_book_on_time_without_fine(): void
    {
        $loan = Loan::create([
            'user_id' => $this->mahasiswa->id,
            'book_id' => $this->book->id,
            'code' => 'PJ25010101',
            'loan_code' => 'PJ25010101',
            'quantity' => 1,
            'status' => 'approved',
            'loan_date' => Carbon::today(),
            'approved_by' => $this->admin->id,
            'approved_at' => Carbon::today(),
            'due_date' => Carbon::today()->addDays(365),
        ]);
        Sanctum::actingAs($this->admin);
        $response = $this->patchJson('/api/admin/loans/' . $loan->id . '/return');
        $response->assertStatus(200);
        $this->assertSame('returned', $response->json('data.status'));
        $this->assertSame(0, $response->json('data.fine_amount'));
        $this->assertSame(true, $response->json('data.fine_paid'));
    }

    public function test_admin_can_return_book_late_with_fine(): void
    {
        $loan = Loan::create([
            'user_id' => $this->mahasiswa->id,
            'book_id' => $this->book->id,
            'code' => 'PJ25010101',
            'loan_code' => 'PJ25010101',
            'quantity' => 1,
            'status' => 'approved',
            'loan_date' => Carbon::today()->subDays(10),
            'approved_by' => $this->admin->id,
            'approved_at' => Carbon::today()->subDays(10),
            'due_date' => Carbon::today()->subDays(2),
        ]);
        Sanctum::actingAs($this->admin);
        $response = $this->patchJson('/api/admin/loans/' . $loan->id . '/return');
        $response->assertStatus(200);
        $this->assertSame('returned', $response->json('data.status'));
        $this->assertGreaterThan(0, $response->json('data.late_days'));
        $this->assertGreaterThan(0, $response->json('data.fine_amount'));
        $this->assertSame(false, $response->json('data.fine_paid'));
    }

    public function test_admin_cannot_return_book_twice(): void
    {
        $loan = Loan::create([
            'user_id' => $this->mahasiswa->id,
            'book_id' => $this->book->id,
            'code' => 'PJ25010101',
            'loan_code' => 'PJ25010101',
            'quantity' => 1,
            'status' => 'returned',
            'loan_date' => Carbon::today(),
            'approved_by' => $this->admin->id,
            'approved_at' => Carbon::today(),
            'due_date' => Carbon::today(),
            'returned_at' => Carbon::today(),
        ]);
        Sanctum::actingAs($this->admin);
        $this->patchJson('/api/admin/loans/' . $loan->id . '/return')
            ->assertStatus(422);
    }

    // ---------- PAY FINE ----------

    public function test_admin_can_mark_fine_as_paid(): void
    {
        $loan = Loan::create([
            'user_id' => $this->mahasiswa->id,
            'book_id' => $this->book->id,
            'code' => 'PJ25010101',
            'loan_code' => 'PJ25010101',
            'quantity' => 1,
            'status' => 'returned',
            'loan_date' => Carbon::today(),
            'approved_by' => $this->admin->id,
            'approved_at' => Carbon::today(),
            'due_date' => Carbon::today(),
            'returned_at' => Carbon::today(),
            'fine_amount' => 5000,
            'fine_paid' => false,
        ]);
        Sanctum::actingAs($this->admin);
        $response = $this->patchJson('/api/admin/loans/' . $loan->id . '/pay-fine');
        $response->assertStatus(200);
        $this->assertSame(true, $response->json('data.fine_paid'));
    }

    public function test_cannot_pay_fine_if_no_fine(): void
    {
        $loan = Loan::create([
            'user_id' => $this->mahasiswa->id,
            'book_id' => $this->book->id,
            'code' => 'PJ25010101',
            'loan_code' => 'PJ25010101',
            'quantity' => 1,
            'status' => 'returned',
            'loan_date' => Carbon::today(),
            'approved_by' => $this->admin->id,
            'approved_at' => Carbon::today(),
            'due_date' => Carbon::today(),
            'returned_at' => Carbon::today(),
            'fine_amount' => 0,
            'fine_paid' => true,
        ]);
        Sanctum::actingAs($this->admin);
        $this->patchJson('/api/admin/loans/' . $loan->id . '/pay-fine')
            ->assertStatus(422);
    }

    // ---------- MY LOANS ----------

    public function test_mahasiswa_can_see_own_loans(): void
    {
        Loan::create([
            'user_id' => $this->mahasiswa->id,
            'book_id' => $this->book->id,
            'code' => 'PJ25010101',
            'loan_code' => 'PJ25010101',
            'quantity' => 1,
            'status' => 'pending',
            'loan_date' => Carbon::today(),
        ]);
        Sanctum::actingAs($this->mahasiswa);
        $response = $this->getJson('/api/loans/me');
        $response->assertStatus(200);
        $this->assertGreaterThan(0, count($response->json('data.data')));
    }

    // ---------- ADMIN: LOANS LIST ----------

    public function test_admin_can_see_all_loans(): void
    {
        Loan::create([
            'user_id' => $this->mahasiswa->id,
            'book_id' => $this->book->id,
            'code' => 'PJ25010101',
            'loan_code' => 'PJ25010101',
            'quantity' => 1,
            'status' => 'pending',
            'loan_date' => Carbon::today(),
        ]);
        Sanctum::actingAs($this->admin);
        $response = $this->getJson('/api/admin/loans');
        $response->assertStatus(200);
        $this->assertGreaterThan(0, count($response->json('data')));
    }

    // ---------- LOGOUT ----------

    public function test_admin_can_logout(): void
    {
        Sanctum::actingAs($this->admin);
        $this->postJson('/api/logout')
            ->assertStatus(200);
        $this->assertSame(0, \Laravel\Sanctum\PersonalAccessToken::where('tokenable_id', $this->admin->id)->count());
    }

    // ---------- BOOKS SEARCH & PAGINATION ----------

    public function test_books_pagination_and_search(): void
    {
        $response = $this->getJson('/api/books?search=Buku&per_page=5');
        $response->assertStatus(200);
        $this->assertNotEmpty($response->json('data'));
        $this->assertNotNull($response->json('meta'));
    }

    public function test_admin_books_search(): void
    {
        Sanctum::actingAs($this->admin);
        $response = $this->getJson('/api/admin/books?search=Buku');
        $response->assertStatus(200);
        $this->assertNotEmpty($response->json('data'));
    }

    public function test_my_loan_detail(): void
    {
        $loan = Loan::create([
            'user_id' => $this->mahasiswa->id,
            'book_id' => $this->book->id,
            'code' => 'PJ25010199',
            'loan_code' => 'PJ25010199',
            'quantity' => 1,
            'status' => 'pending',
            'requested_at' => Carbon::now(),
            'loan_date' => Carbon::today(),
        ]);

        Sanctum::actingAs($this->mahasiswa);
        $res = $this->getJson('/api/my-loans/' . $loan->id);
        $res->assertStatus(200);
        $this->assertSame($loan->id, $res->json('data.id'));
    }
}

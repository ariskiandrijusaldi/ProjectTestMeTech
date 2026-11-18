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

    private User $admin;

    private User $mahasiswa;

    private Category $category;

    private Book $book;

    private int $loanSequence = 0;

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

        $this->category = Category::create(['name' => 'Teknologi']);

        $this->book = $this->createBook();
    }

    private function createBook(array $attributes = []): Book
    {
        return Book::create(array_merge([
            'category_id' => $this->category->id,
            'isbn' => '978-1234567890',
            'title' => 'Buku Test',
            'author' => 'Penulis Test',
            'stock_total' => 5,
            'stock_available' => 5,
        ], $attributes));
    }

    private function createLoan(array $attributes = []): Loan
    {
        $this->loanSequence++;

        return Loan::create(array_merge([
            'user_id' => $this->mahasiswa->id,
            'book_id' => $this->book->id,
            'code' => 'PJ250101'.str_pad((string) $this->loanSequence, 2, '0', STR_PAD_LEFT),
            'status' => 'pending',
            'requested_at' => Carbon::now(),
            'fine_amount' => 0,
            'fine_paid' => true,
        ], $attributes));
    }

    // ---------- LOGIN ----------

    public function test_mahasiswa_can_login_with_email_and_password(): void
    {
        $response = $this->postJson('/api/login', [
            'email' => $this->mahasiswa->email,
            'password' => 'password123',
        ]);

        $response->assertOk()
            ->assertJsonPath('data.user.role', 'mahasiswa')
            ->assertJsonPath('data.token_type', 'Bearer');
        $this->assertNotNull($response->json('data.token'));
    }

    public function test_mahasiswa_can_login_with_nim_as_email(): void
    {
        $this->postJson('/api/login', [
            'email' => $this->mahasiswa->nim,
            'password' => 'password123',
        ])
            ->assertOk()
            ->assertJsonPath('data.user.role', 'mahasiswa');
    }

    public function test_admin_login_returns_admin_role(): void
    {
        $this->postJson('/api/login', [
            'email' => $this->admin->email,
            'password' => 'admin123',
        ])
            ->assertOk()
            ->assertJsonPath('data.user.role', 'admin');
    }

    public function test_login_fails_with_wrong_password(): void
    {
        $this->postJson('/api/login', [
            'email' => $this->mahasiswa->email,
            'password' => 'salah',
        ])
            ->assertUnprocessable()
            ->assertJsonPath('errors.email.0', 'Email atau password salah.');
    }

    public function test_login_token_authenticates_real_bearer_requests(): void
    {
        $token = $this->postJson('/api/login', [
            'email' => $this->mahasiswa->email,
            'password' => 'password123',
        ])->json('data.token');

        $this->withToken($token)
            ->getJson('/api/me')
            ->assertOk()
            ->assertJsonPath('data.email', $this->mahasiswa->email);

        $this->assertDatabaseHas('personal_access_tokens', [
            'tokenable_type' => User::class,
            'tokenable_id' => $this->mahasiswa->id,
        ]);
    }

    public function test_unauthenticated_request_returns_401_with_indonesian_message(): void
    {
        $this->getJson('/api/me')
            ->assertUnauthorized()
            ->assertJsonPath('message', 'Tidak terautentikasi. Silakan login kembali.');
    }

    // ---------- REGISTER ----------

    public function test_mahasiswa_can_register_and_receive_token(): void
    {
        $response = $this->postJson('/api/register', [
            'name' => 'Mahasiswa Baru',
            'nim' => '2309999',
            'email' => 'baru@test.ac.id',
            'password' => 'rahasia123',
            'password_confirmation' => 'rahasia123',
        ]);

        $response->assertCreated()
            ->assertJsonPath('message', 'Registrasi berhasil.')
            ->assertJsonPath('data.user.role', 'mahasiswa')
            ->assertJsonPath('data.token_type', 'Bearer');
        $this->assertNotNull($response->json('data.token'));

        $this->assertDatabaseHas('users', [
            'email' => 'baru@test.ac.id',
            'nim' => '2309999',
            'role' => 'mahasiswa',
        ]);
    }

    public function test_registered_user_can_login_with_new_account(): void
    {
        $this->postJson('/api/register', [
            'name' => 'Mahasiswa Baru',
            'nim' => '2309999',
            'email' => 'baru@test.ac.id',
            'password' => 'rahasia123',
            'password_confirmation' => 'rahasia123',
        ])->assertCreated();

        $this->postJson('/api/login', [
            'email' => 'baru@test.ac.id',
            'password' => 'rahasia123',
        ])
            ->assertOk()
            ->assertJsonPath('data.user.email', 'baru@test.ac.id');
    }

    public function test_register_fails_with_duplicate_email_or_nim(): void
    {
        $this->postJson('/api/register', [
            'name' => 'Mahasiswa Duplikat',
            'nim' => $this->mahasiswa->nim,
            'email' => $this->mahasiswa->email,
            'password' => 'rahasia123',
            'password_confirmation' => 'rahasia123',
        ])
            ->assertUnprocessable()
            ->assertJsonPath('errors.email.0', 'Email sudah terdaftar.')
            ->assertJsonPath('errors.nim.0', 'NIM sudah terdaftar.');
    }

    public function test_register_requires_matching_password_confirmation(): void
    {
        $this->postJson('/api/register', [
            'name' => 'Mahasiswa Baru',
            'nim' => '2309998',
            'email' => 'baru2@test.ac.id',
            'password' => 'rahasia123',
            'password_confirmation' => 'beda123',
        ])
            ->assertUnprocessable()
            ->assertJsonPath('errors.password.0', 'Konfirmasi password tidak cocok.');
    }

    // ---------- ME ----------

    public function test_me_endpoint_returns_logged_in_user(): void
    {
        Sanctum::actingAs($this->mahasiswa);

        $this->getJson('/api/me')
            ->assertOk()
            ->assertJsonPath('data.id', $this->mahasiswa->id);
    }

    // ---------- PEMINJAMAN: AJUKAN ----------

    public function test_mahasiswa_can_request_loan_with_generated_code(): void
    {
        $this->travelTo(Carbon::parse('2026-01-01 09:00:00'));
        Sanctum::actingAs($this->mahasiswa);

        $response = $this->postJson('/api/loans', ['book_id' => $this->book->id]);

        $response->assertCreated()
            ->assertJsonPath('data.status', 'pending')
            ->assertJsonPath('data.code', 'PJ26010101');
        $this->assertDatabaseHas('loans', [
            'user_id' => $this->mahasiswa->id,
            'book_id' => $this->book->id,
            'status' => 'pending',
        ]);
    }

    public function test_request_loan_without_book_returns_422_with_indonesian_message(): void
    {
        Sanctum::actingAs($this->mahasiswa);

        $this->postJson('/api/loans', [])
            ->assertUnprocessable()
            ->assertJsonPath('errors.book_id.0', 'Buku wajib dipilih.');
    }

    public function test_cannot_request_loan_if_stock_is_zero(): void
    {
        $this->book->update(['stock_available' => 0]);
        Sanctum::actingAs($this->mahasiswa);

        $this->postJson('/api/loans', ['book_id' => $this->book->id])
            ->assertUnprocessable()
            ->assertJsonPath('message', 'Stok buku tidak tersedia.');
    }

    public function test_cannot_request_loan_for_same_book_with_active_loan(): void
    {
        $this->createLoan();
        Sanctum::actingAs($this->mahasiswa);

        $this->postJson('/api/loans', ['book_id' => $this->book->id])
            ->assertUnprocessable()
            ->assertJsonPath('message', 'Anda sudah memiliki pengajuan atau peminjaman aktif untuk buku ini.');
    }

    public function test_cannot_request_loan_if_max_active_loans_reached(): void
    {
        config(['library.max_active_loans' => 1]);
        $this->createLoan();
        $book2 = $this->createBook(['isbn' => '978-1234567891', 'title' => 'Buku Test 2']);
        Sanctum::actingAs($this->mahasiswa);

        $this->postJson('/api/loans', ['book_id' => $book2->id])
            ->assertUnprocessable()
            ->assertJsonPath('message', 'Anda sudah mencapai batas pinjaman aktif (1).');
    }

    public function test_cannot_request_loan_if_unpaid_fine_exists(): void
    {
        $this->createLoan([
            'status' => 'returned',
            'due_date' => Carbon::today(),
            'returned_at' => Carbon::today(),
            'fine_amount' => 5000,
            'fine_paid' => false,
        ]);
        Sanctum::actingAs($this->mahasiswa);

        $this->postJson('/api/loans', ['book_id' => $this->book->id])
            ->assertUnprocessable()
            ->assertJsonPath('message', 'Anda memiliki denda yang belum lunas. Silakan lunasi sebelum meminjam lagi.');
    }

    // ---------- ADMIN: APPROVE / REJECT ----------

    public function test_admin_approve_decrements_stock_and_sets_due_date(): void
    {
        $this->travelTo(Carbon::parse('2026-01-01 10:00:00'));
        $loan = $this->createLoan();
        Sanctum::actingAs($this->admin);

        $response = $this->patchJson('/api/admin/loans/'.$loan->id.'/approve');

        $response->assertOk()
            ->assertJsonPath('data.status', 'approved')
            ->assertJsonPath('data.approved_by.id', $this->admin->id);
        $this->assertSame('2026-01-08', Carbon::parse($response->json('data.due_date'))->toDateString());
        $this->assertSame(4, $this->book->fresh()->stock_available);
        $this->assertDatabaseHas('loans', [
            'id' => $loan->id,
            'status' => 'approved',
            'approved_by' => $this->admin->id,
        ]);
    }

    public function test_admin_cannot_approve_already_processed_loan(): void
    {
        $loan = $this->createLoan(['status' => 'approved']);
        Sanctum::actingAs($this->admin);

        $this->patchJson('/api/admin/loans/'.$loan->id.'/approve')
            ->assertUnprocessable()
            ->assertJsonPath('message', 'Pengajuan sudah diproses.');
    }

    public function test_mahasiswa_cannot_access_admin_endpoint(): void
    {
        $loan = $this->createLoan();
        Sanctum::actingAs($this->mahasiswa);

        $this->patchJson('/api/admin/loans/'.$loan->id.'/approve')
            ->assertForbidden()
            ->assertJsonPath('message', 'Akses ditolak. Anda tidak memiliki role yang diperlukan.');
    }

    public function test_admin_can_reject_loan_with_reason(): void
    {
        $loan = $this->createLoan();
        Sanctum::actingAs($this->admin);

        $this->patchJson('/api/admin/loans/'.$loan->id.'/reject', ['reason' => 'Buku rusak'])
            ->assertOk()
            ->assertJsonPath('data.status', 'rejected')
            ->assertJsonPath('data.rejected_reason', 'Buku rusak');
        $this->assertSame(5, $this->book->fresh()->stock_available);
    }

    public function test_admin_cannot_reject_without_reason(): void
    {
        $loan = $this->createLoan();
        Sanctum::actingAs($this->admin);

        $this->patchJson('/api/admin/loans/'.$loan->id.'/reject', [])
            ->assertUnprocessable()
            ->assertJsonPath('errors.reason.0', 'Alasan penolakan wajib diisi.');
    }

    // ---------- ADMIN: RETURN ----------

    public function test_admin_can_return_book_on_time_without_fine_and_restore_stock(): void
    {
        $this->book->update(['stock_available' => 4]);
        $loan = $this->createLoan([
            'status' => 'approved',
            'approved_by' => $this->admin->id,
            'approved_at' => Carbon::today(),
            'due_date' => Carbon::today()->addDays(7),
        ]);
        Sanctum::actingAs($this->admin);

        $response = $this->patchJson('/api/admin/loans/'.$loan->id.'/return');

        $response->assertOk()
            ->assertJsonPath('data.status', 'returned')
            ->assertJsonPath('data.late_days', 0)
            ->assertJsonPath('data.fine_paid', true);
        $this->assertSame(0.0, (float) $response->json('data.fine_amount'));
        $this->assertSame(5, $this->book->fresh()->stock_available);
    }

    public function test_admin_can_return_book_late_with_fine(): void
    {
        $this->travelTo(Carbon::parse('2026-01-10 10:00:00'));
        $this->book->update(['stock_available' => 4]);
        $loan = $this->createLoan([
            'status' => 'approved',
            'approved_by' => $this->admin->id,
            'approved_at' => Carbon::parse('2026-01-01 10:00:00'),
            'due_date' => Carbon::parse('2026-01-08'),
        ]);
        Sanctum::actingAs($this->admin);

        $response = $this->patchJson('/api/admin/loans/'.$loan->id.'/return');

        $response->assertOk()
            ->assertJsonPath('data.status', 'returned')
            ->assertJsonPath('data.late_days', 2)
            ->assertJsonPath('data.fine_paid', false);
        $this->assertSame(2000.0, (float) $response->json('data.fine_amount'));
        $this->assertSame(5, $this->book->fresh()->stock_available);
    }

    public function test_admin_cannot_return_book_twice(): void
    {
        $loan = $this->createLoan([
            'status' => 'returned',
            'approved_by' => $this->admin->id,
            'approved_at' => Carbon::today(),
            'due_date' => Carbon::today(),
            'returned_at' => Carbon::today(),
        ]);
        Sanctum::actingAs($this->admin);

        $this->patchJson('/api/admin/loans/'.$loan->id.'/return')
            ->assertUnprocessable()
            ->assertJsonPath('message', 'Buku tidak sedang dipinjam.');
    }

    // ---------- PAY FINE ----------

    public function test_admin_can_mark_fine_as_paid(): void
    {
        $loan = $this->createLoan([
            'status' => 'returned',
            'approved_by' => $this->admin->id,
            'approved_at' => Carbon::today(),
            'due_date' => Carbon::today(),
            'returned_at' => Carbon::today(),
            'fine_amount' => 5000,
            'fine_paid' => false,
        ]);
        Sanctum::actingAs($this->admin);

        $this->patchJson('/api/admin/loans/'.$loan->id.'/pay-fine')
            ->assertOk()
            ->assertJsonPath('data.fine_paid', true);
        $this->assertDatabaseHas('loans', ['id' => $loan->id, 'fine_paid' => true]);
    }

    public function test_admin_cannot_pay_fine_twice(): void
    {
        $loan = $this->createLoan([
            'status' => 'returned',
            'approved_by' => $this->admin->id,
            'approved_at' => Carbon::today(),
            'due_date' => Carbon::today(),
            'returned_at' => Carbon::today(),
            'fine_amount' => 5000,
            'fine_paid' => false,
        ]);
        Sanctum::actingAs($this->admin);

        $this->patchJson('/api/admin/loans/'.$loan->id.'/pay-fine')->assertOk();

        $this->patchJson('/api/admin/loans/'.$loan->id.'/pay-fine')
            ->assertUnprocessable()
            ->assertJsonPath('message', 'Denda sudah ditandai lunas.');
    }

    public function test_cannot_pay_fine_if_no_fine(): void
    {
        $loan = $this->createLoan([
            'status' => 'returned',
            'approved_by' => $this->admin->id,
            'approved_at' => Carbon::today(),
            'due_date' => Carbon::today(),
            'returned_at' => Carbon::today(),
            'fine_amount' => 0,
            'fine_paid' => true,
        ]);
        Sanctum::actingAs($this->admin);

        $this->patchJson('/api/admin/loans/'.$loan->id.'/pay-fine')
            ->assertUnprocessable()
            ->assertJsonPath('message', 'Tidak ada denda yang perlu dilunasi.');
    }

    // ---------- MY LOANS ----------

    public function test_mahasiswa_can_see_own_loans_with_flat_data(): void
    {
        $this->createLoan();
        $other = User::create([
            'name' => 'Mahasiswa Lain',
            'email' => 'lain@test.ac.id',
            'nim' => '2301002',
            'password' => bcrypt('password123'),
            'role' => 'mahasiswa',
        ]);
        $this->createLoan(['user_id' => $other->id]);
        Sanctum::actingAs($this->mahasiswa);

        $response = $this->getJson('/api/my-loans');

        $response->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('meta.total', 1);
        $this->assertNull($response->json('data.data'));
    }

    public function test_my_loans_tab_active_only_returns_active_loans(): void
    {
        $this->createLoan(['status' => 'pending']);
        $this->createLoan([
            'status' => 'returned',
            'due_date' => Carbon::today(),
            'returned_at' => Carbon::today(),
        ]);
        Sanctum::actingAs($this->mahasiswa);

        $this->getJson('/api/my-loans?tab=active')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.status', 'pending');
    }

    public function test_mahasiswa_can_see_own_loan_detail(): void
    {
        $loan = $this->createLoan();
        Sanctum::actingAs($this->mahasiswa);

        $this->getJson('/api/my-loans/'.$loan->id)
            ->assertOk()
            ->assertJsonPath('data.id', $loan->id);
    }

    public function test_mahasiswa_cannot_see_other_users_loan_detail(): void
    {
        $other = User::create([
            'name' => 'Mahasiswa Lain',
            'email' => 'lain@test.ac.id',
            'nim' => '2301002',
            'password' => bcrypt('password123'),
            'role' => 'mahasiswa',
        ]);
        $loan = $this->createLoan(['user_id' => $other->id]);
        Sanctum::actingAs($this->mahasiswa);

        $this->getJson('/api/my-loans/'.$loan->id)
            ->assertNotFound();
    }

    public function test_mahasiswa_can_cancel_own_pending_loan(): void
    {
        $loan = $this->createLoan();
        Sanctum::actingAs($this->mahasiswa);

        $this->deleteJson('/api/my-loans/'.$loan->id)
            ->assertOk()
            ->assertJsonPath('message', 'Pengajuan peminjaman dibatalkan.');
        $this->assertModelMissing($loan);
    }

    public function test_mahasiswa_cannot_cancel_approved_loan(): void
    {
        $loan = $this->createLoan(['status' => 'approved']);
        Sanctum::actingAs($this->mahasiswa);

        $this->deleteJson('/api/my-loans/'.$loan->id)
            ->assertUnprocessable()
            ->assertJsonPath('message', 'Hanya pengajuan yang masih menunggu yang dapat dibatalkan.');
        $this->assertModelExists($loan);
    }

    // ---------- ADMIN: LOANS LIST ----------

    public function test_admin_can_see_all_loans_with_meta_counts(): void
    {
        $this->createLoan();
        Sanctum::actingAs($this->admin);

        $this->getJson('/api/admin/loans')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('meta_counts.pending', 1);
    }

    public function test_admin_can_filter_loans_by_status(): void
    {
        $this->createLoan(['status' => 'pending']);
        $approved = $this->createLoan(['status' => 'approved']);
        Sanctum::actingAs($this->admin);

        $this->getJson('/api/admin/loans?status=approved')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $approved->id);
    }

    public function test_admin_overdue_route_returns_only_overdue_loans(): void
    {
        $overdue = $this->createLoan([
            'status' => 'approved',
            'due_date' => Carbon::today()->subDay(),
        ]);
        $this->createLoan([
            'status' => 'approved',
            'due_date' => Carbon::today()->addDay(),
        ]);
        Sanctum::actingAs($this->admin);

        $this->getJson('/api/admin/loans/overdue')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $overdue->id);
    }

    public function test_admin_can_find_loan_by_code_case_insensitively(): void
    {
        $loan = $this->createLoan(['code' => 'PJ26010142']);
        Sanctum::actingAs($this->admin);

        $this->getJson('/api/admin/loans/code/pj26010142')
            ->assertOk()
            ->assertJsonPath('data.id', $loan->id);
    }

    public function test_admin_code_lookup_returns_404_for_unknown_code(): void
    {
        Sanctum::actingAs($this->admin);

        $this->getJson('/api/admin/loans/code/PJ99999999')
            ->assertNotFound()
            ->assertJsonPath('message', 'Kode peminjaman tidak ditemukan.');
    }

    // ---------- LOGOUT ----------

    public function test_logout_revokes_current_token(): void
    {
        $token = $this->postJson('/api/login', [
            'email' => $this->admin->email,
            'password' => 'admin123',
        ])->json('data.token');

        $this->withToken($token)->postJson('/api/logout')->assertOk();

        $this->assertDatabaseCount('personal_access_tokens', 0);
        $this->app['auth']->forgetGuards();
        $this->withToken($token)->getJson('/api/me')->assertUnauthorized();
    }

    // ---------- BOOKS ----------

    public function test_books_pagination_and_search(): void
    {
        $response = $this->getJson('/api/books?search=Buku&per_page=5');

        $response->assertOk()
            ->assertJsonPath('message', 'Daftar buku berhasil diambil.');
        $this->assertNotEmpty($response->json('data'));
        $this->assertNotNull($response->json('meta'));
    }

    public function test_books_can_be_filtered_by_category_name(): void
    {
        $this->getJson('/api/books?category=Teknologi')
            ->assertOk()
            ->assertJsonCount(1, 'data');
    }

    public function test_admin_can_create_book_with_available_stock_equal_to_total(): void
    {
        Sanctum::actingAs($this->admin);

        $response = $this->postJson('/api/admin/books', [
            'category_id' => $this->category->id,
            'title' => 'Buku Baru',
            'author' => 'Penulis Baru',
            'stock_total' => 3,
        ]);

        $response->assertCreated()
            ->assertJsonPath('data.stock_available', 3);
        $this->assertDatabaseHas('books', [
            'title' => 'Buku Baru',
            'stock_total' => 3,
            'stock_available' => 3,
        ]);
    }

    public function test_admin_cannot_reduce_stock_below_borrowed_count(): void
    {
        $this->book->update(['stock_total' => 5, 'stock_available' => 3]);
        Sanctum::actingAs($this->admin);

        $this->putJson('/api/admin/books/'.$this->book->id, [
            'category_id' => $this->category->id,
            'title' => $this->book->title,
            'author' => $this->book->author,
            'stock_total' => 1,
        ])
            ->assertUnprocessable()
            ->assertJsonPath('message', 'Stok total tidak boleh kurang dari jumlah buku yang sedang dipinjam (2).');
    }

    public function test_admin_cannot_delete_book_with_active_loan(): void
    {
        $this->createLoan();
        Sanctum::actingAs($this->admin);

        $this->deleteJson('/api/admin/books/'.$this->book->id)
            ->assertUnprocessable()
            ->assertJsonPath('message', 'Buku masih memiliki peminjaman aktif dan tidak bisa dihapus.');
        $this->assertModelExists($this->book);
    }

    public function test_admin_can_delete_book_without_active_loan(): void
    {
        Sanctum::actingAs($this->admin);

        $this->deleteJson('/api/admin/books/'.$this->book->id)->assertOk();

        $this->assertModelMissing($this->book);
    }

    // ---------- CATEGORIES & USERS ----------

    public function test_admin_can_create_update_and_delete_category(): void
    {
        Sanctum::actingAs($this->admin);

        $response = $this->postJson('/api/admin/categories', ['name' => 'Sains']);
        $response->assertCreated()
            ->assertJsonPath('data.name', 'Sains');
        $categoryId = $response->json('data.id');

        $this->putJson('/api/admin/categories/'.$categoryId, ['name' => 'Sains Terapan'])
            ->assertOk()
            ->assertJsonPath('data.name', 'Sains Terapan');

        $this->deleteJson('/api/admin/categories/'.$categoryId)->assertOk();

        $this->assertDatabaseMissing('categories', ['id' => $categoryId]);
    }

    public function test_admin_cannot_create_duplicate_category_name(): void
    {
        Sanctum::actingAs($this->admin);

        $this->postJson('/api/admin/categories', ['name' => $this->category->name])
            ->assertUnprocessable()
            ->assertJsonPath('errors.name.0', 'Nama kategori sudah digunakan.');
    }

    public function test_admin_cannot_delete_category_used_by_book(): void
    {
        Sanctum::actingAs($this->admin);

        $this->deleteJson('/api/admin/categories/'.$this->category->id)
            ->assertUnprocessable()
            ->assertJsonPath('message', 'Kategori masih dipakai oleh buku sehingga tidak bisa dihapus.');
        $this->assertModelExists($this->category);
    }

    public function test_student_can_see_categories(): void
    {
        $this->getJson('/api/categories')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.name', 'Teknologi');
    }

    public function test_admin_can_list_only_mahasiswa_users(): void
    {
        User::create([
            'name' => 'Mahasiswa Dua',
            'email' => 'dua@test.ac.id',
            'nim' => '2301003',
            'password' => bcrypt('password123'),
            'role' => 'mahasiswa',
        ]);
        Sanctum::actingAs($this->admin);

        $this->getJson('/api/admin/users')
            ->assertOk()
            ->assertJsonCount(2, 'data');
    }
}

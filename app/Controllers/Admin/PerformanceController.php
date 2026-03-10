<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\AuditLog;
use App\Models\UserModel;
use App\Models\DepositModel;
use App\Models\WithdrawalModel;
use App\Models\TransactionModel;

class PerformanceController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');

        $metrics = [
            'php_version'    => PHP_VERSION,
            'memory_limit'   => ini_get('memory_limit'),
            'memory_usage'   => round(memory_get_usage(true) / 1024 / 1024, 2),
            'memory_peak'    => round(memory_get_peak_usage(true) / 1024 / 1024, 2),
            'upload_max'     => ini_get('upload_max_filesize'),
            'max_exec_time'  => ini_get('max_execution_time'),
        ];

        $counts = [
            'users'        => (new UserModel())->count(),
            'deposits'     => (new DepositModel())->count(),
            'withdrawals'  => (new WithdrawalModel())->count(),
            'transactions' => (new TransactionModel())->count(),
        ];

        $recentLogs = (new AuditLog())->getRecent(20);

        $this->view('admin/performance/index', [
            'title'       => 'Performance',
            'metrics'     => $metrics,
            'counts'      => $counts,
            'recent_logs' => $recentLogs,
            'admin'       => Auth::user('admin'),
        ]);
    }
}

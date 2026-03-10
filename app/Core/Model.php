<?php
declare(strict_types=1);

namespace App\Core;

abstract class Model
{
    protected Database $db;
    protected string $table = '';
    protected string $primaryKey = 'id';

    public function __construct()
    {
        $this->db = Database::getInstance();
    }

    public function find(int|string $id): ?array
    {
        return $this->db->fetchOne(
            "SELECT * FROM `{$this->table}` WHERE `{$this->primaryKey}` = ?",
            [$id]
        );
    }

    public function findAll(string $where = '', array $params = [], string $order = '', int $limit = 0, int $offset = 0): array
    {
        $sql = "SELECT * FROM `{$this->table}`";
        if ($where) $sql .= " WHERE {$where}";
        if ($order) $sql .= " ORDER BY {$order}";
        if ($limit)  $sql .= " LIMIT {$limit}";
        if ($offset) $sql .= " OFFSET {$offset}";
        return $this->db->fetchAll($sql, $params);
    }

    public function findBy(array $conditions): ?array
    {
        $where  = implode(' AND ', array_map(fn($k) => "`{$k}` = ?", array_keys($conditions)));
        return $this->db->fetchOne(
            "SELECT * FROM `{$this->table}` WHERE {$where}",
            array_values($conditions)
        );
    }

    public function create(array $data): string
    {
        return $this->db->insert($this->table, $data);
    }

    public function update(int|string $id, array $data): int
    {
        return $this->db->update($this->table, $data, [$this->primaryKey => $id]);
    }

    public function delete(int|string $id): int
    {
        return $this->db->delete($this->table, [$this->primaryKey => $id]);
    }

    public function count(string $where = '', array $params = []): int
    {
        $sql = "SELECT COUNT(*) as cnt FROM `{$this->table}`";
        if ($where) $sql .= " WHERE {$where}";
        $row = $this->db->fetchOne($sql, $params);
        return (int)($row['cnt'] ?? 0);
    }

    public function paginate(int $page, int $perPage = 20, string $where = '', array $params = [], string $order = 'id DESC'): array
    {
        $total  = $this->count($where, $params);
        $offset = ($page - 1) * $perPage;
        $items  = $this->findAll($where, $params, $order, $perPage, $offset);
        return [
            'items'       => $items,
            'total'       => $total,
            'page'        => $page,
            'per_page'    => $perPage,
            'total_pages' => (int)ceil($total / $perPage),
        ];
    }
}

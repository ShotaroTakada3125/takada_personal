-- 文字コード設定
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- テーブル作成（v2）

-- タグマスター（新規）
CREATE TABLE tags (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    color VARCHAR(7) DEFAULT '#2196f3',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- カテゴリー（タイムスタンプ追加）
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- チェック観点（tag → tag_id、sort_order追加）
CREATE TABLE check_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    content VARCHAR(255) NOT NULL,
    tag_id INT,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- チェック状態（タイムスタンプ追加）
CREATE TABLE check_states (
    id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL UNIQUE,
    is_checked BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (item_id) REFERENCES check_items(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 初期データ投入

-- タグマスター
INSERT INTO tags (name, color) VALUES
('可読性', '#4caf50'),
('セキュリティ', '#f44336'),
('品質', '#2196f3'),
('プロセス', '#ff9800'),
('確認', '#9c27b0'),
('マナー', '#00bcd4');

-- カテゴリー
INSERT INTO categories (name) VALUES 
('コードレビュー'), ('Slack送信'), ('メール送信');

-- コードレビューの観点
INSERT INTO check_items (category_id, content, tag_id, sort_order) VALUES
(1, 'PRの説明文は分かりやすいか', 1, 1),
(1, '変更理由を記載したか', 1, 2),
(1, '機密情報は含まれていないか', 2, 3),
(1, 'テストは通っているか', 3, 4),
(1, '不要なコードは削除したか', 3, 5),
(1, 'レビュアーは適切か', 4, 6),
(1, '関連チケットをリンクしたか', 4, 7),
(1, 'WIP状態を解除したか', 4, 8);

-- Slack送信の観点
INSERT INTO check_items (category_id, content, tag_id, sort_order) VALUES
(2, '宛先は正しいか', 5, 1),
(2, '敬称・呼び方は適切か', 6, 2),
(2, '機密情報を含んでいないか', 2, 3),
(2, '誤字脱字はないか', 3, 4),
(2, '結論から書いているか', 1, 5);

-- メール送信の観点
INSERT INTO check_items (category_id, content, tag_id, sort_order) VALUES
(3, '宛先（To/Cc/Bcc）は正しいか', 5, 1),
(3, '件名は内容を表しているか', 1, 2),
(3, '添付ファイルは正しいか', 5, 3),
(3, '機密情報の取り扱いは適切か', 2, 4),
(3, '敬語・文体は適切か', 6, 5),
(3, '返信期限を明記したか', 4, 6);

-- チェック状態の初期化（全アイテム分）
INSERT INTO check_states (item_id, is_checked)
SELECT id, FALSE FROM check_items;

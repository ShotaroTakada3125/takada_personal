from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import mysql.connector
import os
import time

app = FastAPI()

# CORS設定（フロントエンドからのアクセスを許可）
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# DB接続設定
def get_db_connection():
    max_retries = 30
    retry_count = 0
    
    while retry_count < max_retries:
        try:
            connection = mysql.connector.connect(
                host=os.getenv("DB_HOST", "db"),
                port=int(os.getenv("DB_PORT", "3306")),
                user=os.getenv("DB_USER", "appuser"),
                password=os.getenv("DB_PASSWORD", "apppass"),
                database=os.getenv("DB_NAME", "self_review"),
                charset='utf8mb4',
                collation='utf8mb4_unicode_ci'
            )
            return connection
        except mysql.connector.Error as err:
            retry_count += 1
            if retry_count < max_retries:
                time.sleep(2)
            else:
                raise err

# リクエストボディのモデル
class CheckUpdateRequest(BaseModel):
    is_checked: bool

class CategoryRequest(BaseModel):
    name: str

class ItemRequest(BaseModel):
    category_id: int
    content: str
    tag_id: int | None = None

class ItemUpdateRequest(BaseModel):
    content: str
    tag_id: int | None = None

class TagRequest(BaseModel):
    name: str
    color: str = '#2196f3'

# ===== タグAPI =====

# タグ一覧取得
@app.get("/api/tags")
def get_tags():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT id, name, color FROM tags ORDER BY id")
        tags = cursor.fetchall()
        cursor.close()
        conn.close()
        return tags
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# タグ追加
@app.post("/api/tags")
def create_tag(request: TagRequest):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO tags (name, color) VALUES (%s, %s)",
            (request.name, request.color)
        )
        conn.commit()
        tag_id = cursor.lastrowid
        cursor.close()
        conn.close()
        return {"id": tag_id, "status": "success"}
    except mysql.connector.IntegrityError:
        raise HTTPException(status_code=400, detail="Tag name already exists")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# タグ編集
@app.put("/api/tags/{tag_id}")
def update_tag(tag_id: int, request: TagRequest):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "UPDATE tags SET name = %s, color = %s WHERE id = %s",
            (request.name, request.color, tag_id)
        )
        conn.commit()
        if cursor.rowcount == 0:
            cursor.close()
            conn.close()
            raise HTTPException(status_code=404, detail="Tag not found")
        cursor.close()
        conn.close()
        return {"status": "success"}
    except mysql.connector.IntegrityError:
        raise HTTPException(status_code=400, detail="Tag name already exists")
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# タグ削除
@app.delete("/api/tags/{tag_id}")
def delete_tag(tag_id: int):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM tags WHERE id = %s", (tag_id,))
        conn.commit()
        if cursor.rowcount == 0:
            cursor.close()
            conn.close()
            raise HTTPException(status_code=404, detail="Tag not found")
        cursor.close()
        conn.close()
        return {"status": "success"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ===== カテゴリーAPI =====

# カテゴリ一覧取得
@app.get("/api/categories")
def get_categories():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT id, name FROM categories ORDER BY id")
        categories = cursor.fetchall()
        cursor.close()
        conn.close()
        return categories
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# カテゴリー追加
@app.post("/api/categories")
def create_category(request: CategoryRequest):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("INSERT INTO categories (name) VALUES (%s)", (request.name,))
        conn.commit()
        category_id = cursor.lastrowid
        cursor.close()
        conn.close()
        return {"id": category_id, "status": "success"}
    except mysql.connector.IntegrityError:
        raise HTTPException(status_code=400, detail="Category name already exists")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# カテゴリー編集
@app.put("/api/categories/{category_id}")
def update_category(category_id: int, request: CategoryRequest):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "UPDATE categories SET name = %s WHERE id = %s",
            (request.name, category_id)
        )
        conn.commit()
        if cursor.rowcount == 0:
            cursor.close()
            conn.close()
            raise HTTPException(status_code=404, detail="Category not found")
        cursor.close()
        conn.close()
        return {"status": "success"}
    except mysql.connector.IntegrityError:
        raise HTTPException(status_code=400, detail="Category name already exists")
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# カテゴリー削除
@app.delete("/api/categories/{category_id}")
def delete_category(category_id: int):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM categories WHERE id = %s", (category_id,))
        conn.commit()
        if cursor.rowcount == 0:
            cursor.close()
            conn.close()
            raise HTTPException(status_code=404, detail="Category not found")
        cursor.close()
        conn.close()
        return {"status": "success"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# カテゴリに紐づく観点＋チェック状態取得
@app.get("/api/categories/{category_id}/items")
def get_category_items(category_id: int):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        query = """
            SELECT 
                ci.id,
                ci.content,
                ci.tag_id,
                t.name as tag_name,
                t.color as tag_color,
                COALESCE(cs.is_checked, FALSE) as is_checked,
                ci.sort_order
            FROM check_items ci
            LEFT JOIN check_states cs ON ci.id = cs.item_id
            LEFT JOIN tags t ON ci.tag_id = t.id
            WHERE ci.category_id = %s
            ORDER BY ci.sort_order, ci.id
        """
        cursor.execute(query, (category_id,))
        items = cursor.fetchall()
        
        # is_checkedをbool型に変換
        for item in items:
            item['is_checked'] = bool(item['is_checked'])
        
        cursor.close()
        conn.close()
        return items
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# カテゴリのチェック状態を一括リセット
@app.post("/api/categories/{category_id}/reset")
def reset_category_checks(category_id: int):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # 該当カテゴリのitem_idを取得して、check_statesを更新
        query = """
            UPDATE check_states cs
            INNER JOIN check_items ci ON cs.item_id = ci.id
            SET cs.is_checked = FALSE
            WHERE ci.category_id = %s
        """
        cursor.execute(query, (category_id,))
        
        conn.commit()
        cursor.close()
        conn.close()
        return {"status": "success"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ===== チェック観点API =====

# 観点追加
@app.post("/api/items")
def create_item(request: ItemRequest):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # sort_orderの最大値を取得
        cursor.execute(
            "SELECT COALESCE(MAX(sort_order), 0) + 1 as next_order FROM check_items WHERE category_id = %s",
            (request.category_id,)
        )
        next_order = cursor.fetchone()[0]
        
        cursor.execute(
            "INSERT INTO check_items (category_id, content, tag_id, sort_order) VALUES (%s, %s, %s, %s)",
            (request.category_id, request.content, request.tag_id, next_order)
        )
        item_id = cursor.lastrowid
        
        # check_statesにも初期値を追加
        cursor.execute(
            "INSERT INTO check_states (item_id, is_checked) VALUES (%s, FALSE)",
            (item_id,)
        )
        
        conn.commit()
        cursor.close()
        conn.close()
        return {"id": item_id, "status": "success"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 観点編集
@app.put("/api/items/{item_id}")
def update_item(item_id: int, request: ItemUpdateRequest):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "UPDATE check_items SET content = %s, tag_id = %s WHERE id = %s",
            (request.content, request.tag_id, item_id)
        )
        conn.commit()
        if cursor.rowcount == 0:
            cursor.close()
            conn.close()
            raise HTTPException(status_code=404, detail="Item not found")
        cursor.close()
        conn.close()
        return {"status": "success"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 観点削除
@app.delete("/api/items/{item_id}")
def delete_item(item_id: int):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM check_items WHERE id = %s", (item_id,))
        conn.commit()
        if cursor.rowcount == 0:
            cursor.close()
            conn.close()
            raise HTTPException(status_code=404, detail="Item not found")
        cursor.close()
        conn.close()
        return {"status": "success"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# チェック状態を更新
@app.put("/api/items/{item_id}/check")
def update_check_state(item_id: int, request: CheckUpdateRequest):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # check_statesレコードが存在するか確認
        cursor.execute("SELECT id FROM check_states WHERE item_id = %s", (item_id,))
        result = cursor.fetchone()
        
        if result:
            # 更新
            cursor.execute(
                "UPDATE check_states SET is_checked = %s WHERE item_id = %s",
                (request.is_checked, item_id)
            )
        else:
            # 挿入
            cursor.execute(
                "INSERT INTO check_states (item_id, is_checked) VALUES (%s, %s)",
                (item_id, request.is_checked)
            )
        
        conn.commit()
        cursor.close()
        conn.close()
        return {"status": "success"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ヘルスチェック
@app.get("/")
def root():
    return {"message": "Self Review Checklist API v2"}

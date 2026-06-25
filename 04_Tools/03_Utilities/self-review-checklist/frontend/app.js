const API_BASE_URL = 'http://localhost:8000/api';

// グローバル状態
let currentCategoryId = null;
let checkItems = [];
let categories = [];
let tags = [];

// ===== 初期化 =====
async function init() {
    try {
        await Promise.all([
            loadCategories(),
            loadTags()
        ]);
        setupEventListeners();
    } catch (error) {
        console.error('初期化エラー:', error);
        alert('通信エラーが発生しました');
    }
}

// イベントリスナー設定
function setupEventListeners() {
    // カテゴリー管理
    document.getElementById('add-category-btn').addEventListener('click', openAddCategoryModal);
    document.getElementById('edit-category-btn')?.addEventListener('click', openEditCategoryModal);
    document.getElementById('delete-category-btn')?.addEventListener('click', deleteCurrentCategory);
    
    // 観点管理
    document.getElementById('add-item-btn')?.addEventListener('click', openAddItemModal);
    document.getElementById('reset-btn')?.addEventListener('click', resetCategoryChecks);
    
    // タグ管理
    document.getElementById('tag-settings-btn').addEventListener('click', openTagManagementModal);
    
    // モーダル
    document.getElementById('modal-overlay').addEventListener('click', (e) => {
        if (e.target.id === 'modal-overlay') closeModal();
    });
    document.getElementById('modal-close').addEventListener('click', closeModal);
    document.getElementById('modal-cancel').addEventListener('click', closeModal);
}

// ===== カテゴリーAPI =====
async function loadCategories() {
    const response = await fetch(`${API_BASE_URL}/categories`);
    if (!response.ok) throw new Error('カテゴリー取得失敗');
    
    categories = await response.json();
    renderCategories();
    
    if (categories.length > 0 && !currentCategoryId) {
        selectCategory(categories[0].id);
    }
}

function renderCategories() {
    const listContainer = document.getElementById('category-list');
    listContainer.innerHTML = '';
    
    categories.forEach(category => {
        const li = document.createElement('li');
        li.className = 'category-item';
        li.dataset.id = category.id;
        if (category.id === currentCategoryId) {
            li.classList.add('active');
        }
        
        li.innerHTML = `
            <span class="category-item-name">${category.name}</span>
            <div class="category-item-actions">
                <button class="icon-button-small" onclick="openEditCategoryModal(${category.id}, '${category.name}')" title="編集">
                    <i class="fas fa-pen"></i>
                </button>
                <button class="icon-button-small danger" onclick="deleteCategory(${category.id})" title="削除">
                    <i class="fas fa-trash"></i>
                </button>
            </div>
        `;
        
        li.addEventListener('click', (e) => {
            if (!e.target.closest('.category-item-actions')) {
                selectCategory(category.id);
            }
        });
        
        listContainer.appendChild(li);
    });
}

async function selectCategory(categoryId) {
    currentCategoryId = categoryId;
    const category = categories.find(c => c.id === categoryId);
    
    document.getElementById('current-category-name').textContent = category.name;
    document.getElementById('category-actions').style.display = 'flex';
    document.getElementById('progress-section').style.display = 'block';
    document.getElementById('list-actions').style.display = 'flex';
    
    renderCategories();
    await loadCategoryItems(categoryId);
}

function openAddCategoryModal() {
    const modalBody = `
        <div class="form-group">
            <label for="category-name">カテゴリー名</label>
            <input type="text" id="category-name" placeholder="例: コードレビュー" maxlength="100" required>
        </div>
    `;
    
    openModal('カテゴリーを追加', modalBody, async () => {
        const name = document.getElementById('category-name').value.trim();
        if (!name) {
            alert('カテゴリー名を入力してください');
            return;
        }
        
        try {
            const response = await fetch(`${API_BASE_URL}/categories`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ name })
            });
            
            if (!response.ok) throw new Error('追加失敗');
            
            await loadCategories();
            closeModal();
        } catch (error) {
            alert('カテゴリーの追加に失敗しました');
        }
    });
}

function openEditCategoryModal() {
    if (!currentCategoryId) return;
    
    const category = categories.find(c => c.id === currentCategoryId);
    const modalBody = `
        <div class="form-group">
            <label for="category-name">カテゴリー名</label>
            <input type="text" id="category-name" value="${category.name}" maxlength="100" required>
        </div>
    `;
    
    openModal('カテゴリーを編集', modalBody, async () => {
        const name = document.getElementById('category-name').value.trim();
        if (!name) {
            alert('カテゴリー名を入力してください');
            return;
        }
        
        try {
            const response = await fetch(`${API_BASE_URL}/categories/${currentCategoryId}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ name })
            });
            
            if (!response.ok) throw new Error('更新失敗');
            
            await loadCategories();
            document.getElementById('current-category-name').textContent = name;
            closeModal();
        } catch (error) {
            alert('カテゴリーの更新に失敗しました');
        }
    });
}

async function deleteCategory(categoryId) {
    const category = categories.find(c => c.id === categoryId);
    if (!confirm(`カテゴリー「${category.name}」を削除しますか？\n紐づくチェック観点もすべて削除されます。`)) {
        return;
    }
    
    try {
        const response = await fetch(`${API_BASE_URL}/categories/${categoryId}`, {
            method: 'DELETE'
        });
        
        if (!response.ok) throw new Error('削除失敗');
        
        if (categoryId === currentCategoryId) {
            currentCategoryId = null;
            document.getElementById('checklist').innerHTML = '';
            document.getElementById('current-category-name').textContent = 'カテゴリーを選択してください';
            document.getElementById('category-actions').style.display = 'none';
            document.getElementById('progress-section').style.display = 'none';
            document.getElementById('list-actions').style.display = 'none';
        }
        
        await loadCategories();
    } catch (error) {
        alert('カテゴリーの削除に失敗しました');
    }
}

async function deleteCurrentCategory() {
    if (currentCategoryId) {
        await deleteCategory(currentCategoryId);
    }
}

// ===== チェック観点API =====
async function loadCategoryItems(categoryId) {
    const response = await fetch(`${API_BASE_URL}/categories/${categoryId}/items`);
    if (!response.ok) throw new Error('チェック観点取得失敗');
    
    checkItems = await response.json();
    renderCheckList();
    updateProgress();
}

function renderCheckList() {
    const checklistContainer = document.getElementById('checklist');
    checklistContainer.innerHTML = '';
    
    if (checkItems.length === 0) {
        checklistContainer.innerHTML = `
            <div class="empty-state">
                <i class="fas fa-clipboard-list"></i>
                <p>チェック観点がありません</p>
            </div>
        `;
        return;
    }
    
    checkItems.forEach(item => {
        const itemDiv = document.createElement('div');
        itemDiv.className = 'check-item';
        
        const checkbox = document.createElement('input');
        checkbox.type = 'checkbox';
        checkbox.checked = item.is_checked;
        checkbox.addEventListener('change', () => handleCheckChange(item.id, checkbox.checked));
        
        const content = document.createElement('span');
        content.className = 'check-item-content';
        content.textContent = item.content;
        
        itemDiv.appendChild(checkbox);
        itemDiv.appendChild(content);
        
        if (item.tag_name) {
            const tag = document.createElement('span');
            tag.className = 'check-item-tag';
            tag.textContent = item.tag_name;
            tag.style.backgroundColor = item.tag_color;
            itemDiv.appendChild(tag);
        }
        
        const actions = document.createElement('div');
        actions.className = 'check-item-actions';
        actions.innerHTML = `
            <button class="icon-button-small" onclick="openEditItemModal(${item.id})" title="編集">
                <i class="fas fa-pen"></i>
            </button>
            <button class="icon-button-small danger" onclick="deleteItem(${item.id})" title="削除">
                <i class="fas fa-trash"></i>
            </button>
        `;
        itemDiv.appendChild(actions);
        
        checklistContainer.appendChild(itemDiv);
    });
}

async function handleCheckChange(itemId, isChecked) {
    try {
        const response = await fetch(`${API_BASE_URL}/items/${itemId}/check`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ is_checked: isChecked })
        });
        
        if (!response.ok) throw new Error('チェック状態更新失敗');
        
        const item = checkItems.find(i => i.id === itemId);
        if (item) {
            item.is_checked = isChecked;
        }
        
        updateProgress();
    } catch (error) {
        alert('チェック状態の更新に失敗しました');
    }
}

function openAddItemModal() {
    if (!currentCategoryId) return;
    
    const tagOptions = tags.map(tag => 
        `<option value="${tag.id}">${tag.name}</option>`
    ).join('');
    
    const modalBody = `
        <div class="form-group">
            <label for="item-content">チェック観点</label>
            <textarea id="item-content" placeholder="例: PRの説明文は分かりやすいか" maxlength="255" required></textarea>
        </div>
        <div class="form-group">
            <label for="item-tag">タグ（任意）</label>
            <select id="item-tag">
                <option value="">なし</option>
                ${tagOptions}
            </select>
        </div>
    `;
    
    openModal('チェック観点を追加', modalBody, async () => {
        const content = document.getElementById('item-content').value.trim();
        const tagId = document.getElementById('item-tag').value || null;
        
        if (!content) {
            alert('チェック観点を入力してください');
            return;
        }
        
        try {
            const response = await fetch(`${API_BASE_URL}/items`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    category_id: currentCategoryId,
                    content,
                    tag_id: tagId ? parseInt(tagId) : null
                })
            });
            
            if (!response.ok) throw new Error('追加失敗');
            
            await loadCategoryItems(currentCategoryId);
            closeModal();
        } catch (error) {
            alert('チェック観点の追加に失敗しました');
        }
    });
}

function openEditItemModal(itemId) {
    const item = checkItems.find(i => i.id === itemId);
    if (!item) return;
    
    const tagOptions = tags.map(tag => 
        `<option value="${tag.id}" ${tag.id === item.tag_id ? 'selected' : ''}>${tag.name}</option>`
    ).join('');
    
    const modalBody = `
        <div class="form-group">
            <label for="item-content">チェック観点</label>
            <textarea id="item-content" maxlength="255" required>${item.content}</textarea>
        </div>
        <div class="form-group">
            <label for="item-tag">タグ（任意）</label>
            <select id="item-tag">
                <option value="">なし</option>
                ${tagOptions}
            </select>
        </div>
    `;
    
    openModal('チェック観点を編集', modalBody, async () => {
        const content = document.getElementById('item-content').value.trim();
        const tagId = document.getElementById('item-tag').value || null;
        
        if (!content) {
            alert('チェック観点を入力してください');
            return;
        }
        
        try {
            const response = await fetch(`${API_BASE_URL}/items/${itemId}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    content,
                    tag_id: tagId ? parseInt(tagId) : null
                })
            });
            
            if (!response.ok) throw new Error('更新失敗');
            
            await loadCategoryItems(currentCategoryId);
            closeModal();
        } catch (error) {
            alert('チェック観点の更新に失敗しました');
        }
    });
}

async function deleteItem(itemId) {
    if (!confirm('このチェック観点を削除しますか？')) {
        return;
    }
    
    try {
        const response = await fetch(`${API_BASE_URL}/items/${itemId}`, {
            method: 'DELETE'
        });
        
        if (!response.ok) throw new Error('削除失敗');
        
        await loadCategoryItems(currentCategoryId);
    } catch (error) {
        alert('チェック観点の削除に失敗しました');
    }
}

async function resetCategoryChecks() {
    if (!currentCategoryId) return;
    
    if (!confirm('このカテゴリーのチェック状態をリセットしますか？')) {
        return;
    }
    
    try {
        const response = await fetch(`${API_BASE_URL}/categories/${currentCategoryId}/reset`, {
            method: 'POST'
        });
        
        if (!response.ok) throw new Error('リセット失敗');
        
        await loadCategoryItems(currentCategoryId);
    } catch (error) {
        alert('リセットに失敗しました');
    }
}

// ===== タグAPI =====
async function loadTags() {
    const response = await fetch(`${API_BASE_URL}/tags`);
    if (!response.ok) throw new Error('タグ取得失敗');
    
    tags = await response.json();
}

function openTagManagementModal() {
    const tagListHtml = tags.map(tag => `
        <div class="tag-list-item">
            <div class="tag-info">
                <div class="tag-color-preview" style="background-color: ${tag.color}"></div>
                <span class="tag-name">${tag.name}</span>
            </div>
            <div class="tag-actions">
                <button class="icon-button-small" onclick="openEditTagModal(${tag.id})" title="編集">
                    <i class="fas fa-pen"></i>
                </button>
                <button class="icon-button-small danger" onclick="deleteTag(${tag.id})" title="削除">
                    <i class="fas fa-trash"></i>
                </button>
            </div>
        </div>
    `).join('');
    
    const modalBody = `
        <div class="tag-list">
            ${tagListHtml}
        </div>
        <button class="btn btn-primary" onclick="openAddTagModal()" style="margin-top: 16px; width: 100%;">
            <i class="fas fa-plus"></i> タグを追加
        </button>
    `;
    
    openModal('タグ管理', modalBody, null, true);
}

function openAddTagModal() {
    const colorPresets = ['#4caf50', '#f44336', '#2196f3', '#ff9800', '#9c27b0', '#00bcd4', '#795548', '#607d8b'];
    const colorOptions = colorPresets.map((color, i) => 
        `<div class="color-option ${i === 0 ? 'selected' : ''}" style="background-color: ${color}" data-color="${color}" onclick="selectColor(this)"></div>`
    ).join('');
    
    const modalBody = `
        <div class="form-group">
            <label for="tag-name">タグ名</label>
            <input type="text" id="tag-name" placeholder="例: セキュリティ" maxlength="50" required>
        </div>
        <div class="form-group">
            <label>色</label>
            <div class="color-preset">
                ${colorOptions}
            </div>
            <input type="hidden" id="tag-color" value="${colorPresets[0]}">
        </div>
    `;
    
    openModal('タグを追加', modalBody, async () => {
        const name = document.getElementById('tag-name').value.trim();
        const color = document.getElementById('tag-color').value;
        
        if (!name) {
            alert('タグ名を入力してください');
            return;
        }
        
        try {
            const response = await fetch(`${API_BASE_URL}/tags`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ name, color })
            });
            
            if (!response.ok) throw new Error('追加失敗');
            
            await loadTags();
            closeModal();
            openTagManagementModal();
        } catch (error) {
            alert('タグの追加に失敗しました');
        }
    });
}

function openEditTagModal(tagId) {
    const tag = tags.find(t => t.id === tagId);
    if (!tag) return;
    
    const colorPresets = ['#4caf50', '#f44336', '#2196f3', '#ff9800', '#9c27b0', '#00bcd4', '#795548', '#607d8b'];
    const colorOptions = colorPresets.map(color => 
        `<div class="color-option ${color === tag.color ? 'selected' : ''}" style="background-color: ${color}" data-color="${color}" onclick="selectColor(this)"></div>`
    ).join('');
    
    const modalBody = `
        <div class="form-group">
            <label for="tag-name">タグ名</label>
            <input type="text" id="tag-name" value="${tag.name}" maxlength="50" required>
        </div>
        <div class="form-group">
            <label>色</label>
            <div class="color-preset">
                ${colorOptions}
            </div>
            <input type="hidden" id="tag-color" value="${tag.color}">
        </div>
    `;
    
    openModal('タグを編集', modalBody, async () => {
        const name = document.getElementById('tag-name').value.trim();
        const color = document.getElementById('tag-color').value;
        
        if (!name) {
            alert('タグ名を入力してください');
            return;
        }
        
        try {
            const response = await fetch(`${API_BASE_URL}/tags/${tagId}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ name, color })
            });
            
            if (!response.ok) throw new Error('更新失敗');
            
            await loadTags();
            if (currentCategoryId) {
                await loadCategoryItems(currentCategoryId);
            }
            closeModal();
            openTagManagementModal();
        } catch (error) {
            alert('タグの更新に失敗しました');
        }
    });
}

async function deleteTag(tagId) {
    const tag = tags.find(t => t.id === tagId);
    if (!confirm(`タグ「${tag.name}」を削除しますか？\n使用中のチェック観点からタグが外れます。`)) {
        return;
    }
    
    try {
        const response = await fetch(`${API_BASE_URL}/tags/${tagId}`, {
            method: 'DELETE'
        });
        
        if (!response.ok) throw new Error('削除失敗');
        
        await loadTags();
        if (currentCategoryId) {
            await loadCategoryItems(currentCategoryId);
        }
        closeModal();
        openTagManagementModal();
    } catch (error) {
        alert('タグの削除に失敗しました');
    }
}

function selectColor(element) {
    document.querySelectorAll('.color-option').forEach(el => el.classList.remove('selected'));
    element.classList.add('selected');
    document.getElementById('tag-color').value = element.dataset.color;
}

// ===== 進捗表示 =====
function updateProgress() {
    const total = checkItems.length;
    const checked = checkItems.filter(item => item.is_checked).length;
    
    const progressText = document.getElementById('progress-text');
    progressText.textContent = `${checked}/${total} 完了`;
    
    const progressBar = document.getElementById('progress-bar');
    const percentage = total > 0 ? (checked / total) * 100 : 0;
    progressBar.style.width = `${percentage}%`;
    
    const completeMessage = document.getElementById('complete-message');
    if (checked === total && total > 0) {
        completeMessage.classList.remove('hidden');
    } else {
        completeMessage.classList.add('hidden');
    }
}

// ===== モーダル制御 =====
function openModal(title, bodyHtml, onConfirm = null, hideFooter = false) {
    document.getElementById('modal-title').textContent = title;
    document.getElementById('modal-body').innerHTML = bodyHtml;
    
    const footer = document.getElementById('modal-footer');
    if (hideFooter) {
        footer.style.display = 'none';
    } else {
        footer.style.display = 'flex';
        const confirmBtn = document.getElementById('modal-confirm');
        confirmBtn.onclick = onConfirm;
    }
    
    document.getElementById('modal-overlay').classList.add('active');
}

function closeModal() {
    document.getElementById('modal-overlay').classList.remove('active');
}

// ===== ページ読み込み時に初期化 =====
window.addEventListener('DOMContentLoaded', init);

const API_BASE = '';

let currentNovel = {
    id: null,
    name: '',
    idea: '',
    genre: '',
    worldbuilding: {
        setting: '',
        characters: [],
        locations: [],
        timeline: [],
        magicSystem: '',
        powerSystem: ''
    },
    chapters: [],
    currentChapter: 0,
    totalChapters: 10,
    model: '',
    timestamp: null
};

let providers = [];
let currentProvider = null;
let chatHistory = [];

async function loadProviders() {
    try {
        const response = await fetch(`${API_BASE}/api/providers`);
        providers = await response.json();
        renderProviders();
        updateModelSelect();
    } catch (error) {
        console.error('Error loading providers:', error);
    }
}

function renderProviders() {
    const list = document.getElementById('providerList');
    if (providers.length === 0) {
        list.innerHTML = '<p style="color: var(--text-secondary); font-size: 0.9em;">暂无提供商</p>';
        return;
    }
    
    list.innerHTML = providers.map(p => `
        <div class="provider-item ${p.id === currentProvider ? 'active' : ''}" data-id="${p.id}">
            <div class="provider-info">
                <div class="provider-name">${p.name}</div>
                <div class="provider-url">${p.baseUrl}</div>
            </div>
            <div class="provider-actions">
                <button class="btn btn-small btn-primary" onclick="setCurrentProvider('${p.id}')">使用</button>
                <button class="btn btn-small btn-secondary" onclick="fetchModels('${p.id}')">获取模型</button>
                <button class="btn btn-small btn-danger" onclick="deleteProvider('${p.id}')">删除</button>
            </div>
        </div>
    `).join('');
}

function updateModelSelect() {
    const select = document.getElementById('modelSelect');
    const provider = providers.find(p => p.id === currentProvider);
    
    if (!provider || !provider.models || provider.models.length === 0) {
        select.innerHTML = '<option value="">请先添加提供商并获取模型</option>';
        return;
    }
    
    select.innerHTML = provider.models.map(m => 
        `<option value="${m.id}">${m.name}</option>`
    ).join('');
}

function showProviderModal() {
    document.getElementById('providerModal').style.display = 'block';
}

function closeModal(modalId) {
    document.getElementById(modalId).style.display = 'none';
}

async function addProvider() {
    const name = document.getElementById('providerName').value;
    const baseUrl = document.getElementById('providerUrl').value;
    const apiKey = document.getElementById('providerKey').value;
    
    if (!name || !baseUrl || !apiKey) {
        alert('请填写所有字段');
        return;
    }
    
    try {
        showLoading('添加提供商...');
        const response = await fetch(`${API_BASE}/api/providers`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ name, baseUrl, apiKey })
        });
        
        const result = await response.json();
        if (result.success) {
            currentProvider = result.provider.id;
            await loadProviders();
            closeModal('providerModal');
            document.getElementById('providerName').value = '';
            document.getElementById('providerUrl').value = '';
            document.getElementById('providerKey').value = '';
        }
    } catch (error) {
        alert('添加失败: ' + error.message);
    } finally {
        hideLoading();
    }
}

async function fetchModels(providerId) {
    try {
        showLoading('获取模型列表...');
        const response = await fetch(`${API_BASE}/api/providers/${providerId}/models`, {
            method: 'POST'
        });
        
        const result = await response.json();
        if (result.success) {
            await loadProviders();
            alert(`成功获取 ${result.models.length} 个模型`);
        }
    } catch (error) {
        alert('获取模型失败: ' + error.message);
    } finally {
        hideLoading();
    }
}

async function setCurrentProvider(providerId) {
    try {
        await fetch(`${API_BASE}/api/providers/${providerId}/set-current`, {
            method: 'POST'
        });
        currentProvider = providerId;
        renderProviders();
        updateModelSelect();
    } catch (error) {
        alert('设置失败: ' + error.message);
    }
}

async function deleteProvider(providerId) {
    if (!confirm('确定要删除此提供商吗？')) return;
    
    try {
        await fetch(`${API_BASE}/api/providers/${providerId}`, {
            method: 'DELETE'
        });
        await loadProviders();
    } catch (error) {
        alert('删除失败: ' + error.message);
    }
}

async function callAI(messages, temperature = 0.8) {
    const model = document.getElementById('modelSelect').value;
    if (!model) {
        throw new Error('请先选择模型');
    }
    
    const response = await fetch(`${API_BASE}/api/chat`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ 
            model, 
            messages,
            temperature,
            max_tokens: 2000
        })
    });
    
    if (!response.ok) {
        const error = await response.json();
        throw new Error(error.error || '调用失败');
    }
    
    const data = await response.json();
    return data.choices[0].message.content;
}

async function initializeNovel() {
    const name = document.getElementById('novelName').value;
    const idea = document.getElementById('novelIdea').value;
    const genre = document.getElementById('novelGenre').value;
    const totalChapters = parseInt(document.getElementById('totalChapters').value);
    
    if (!name || !idea) {
        alert('请填写小说名称和创意');
        return;
    }
    
    try {
        showLoading('初始化小说设定...');
        
        currentNovel.id = Date.now().toString();
        currentNovel.name = name;
        currentNovel.idea = idea;
        currentNovel.genre = genre;
        currentNovel.totalChapters = totalChapters;
        currentNovel.timestamp = new Date().toISOString();
        
        const worldbuildingPrompt = `你是一位资深网文作家。请根据以下信息创建一个详细的小说设定：

小说名称：${name}
类型：${genre}
创意：${idea}

请以JSON格式返回以下内容：
{
  "setting": "世界观和背景设定",
  "characters": [
    {"name": "角色名", "description": "详细描述", "role": "主角/配角/反派"}
  ],
  "locations": [
    {"name": "地点名", "description": "详细描述"}
  ],
  "timeline": [
    {"event": "事件描述", "time": "时间点"}
  ],
  "magicSystem": "力量体系/修炼体系描述",
  "powerSystem": "等级划分和能力系统"
}

要求：
1. 设定要丰富、有深度，符合${genre}类型特色
2. 至少创建5个主要角色
3. 至少描述5个重要地点
4. 时间线要清晰，包含过去、现在、未来的重要事件
5. 力量体系要有特色和层次感`;

        const worldbuildingResponse = await callAI([
            { role: 'system', content: '你是一位资深网文作家，擅长创建丰富的世界观和人物设定。' },
            { role: 'user', content: worldbuildingPrompt }
        ]);
        
        try {
            const jsonMatch = worldbuildingResponse.match(/\{[\s\S]*\}/);
            if (jsonMatch) {
                currentNovel.worldbuilding = JSON.parse(jsonMatch[0]);
            }
        } catch (e) {
            console.error('解析世界观设定失败:', e);
        }
        
        updateNovelInfo();
        renderWorldbuilding();
        switchTab('worldbuilding');
        alert('小说设定初始化成功！可以开始生成章节了。');
        
    } catch (error) {
        alert('初始化失败: ' + error.message);
    } finally {
        hideLoading();
    }
}

async function generateNextChapter() {
    if (!currentNovel.name) {
        alert('请先初始化小说');
        return;
    }
    
    if (currentNovel.chapters.length >= currentNovel.totalChapters) {
        alert('已完成所有章节生成');
        return;
    }
    
    try {
        showLoading(`正在生成第 ${currentNovel.chapters.length + 1} 章...`);
        
        const chapterNumber = currentNovel.chapters.length + 1;
        const previousChapter = currentNovel.chapters[currentNovel.chapters.length - 1];
        
        const prompt = `你是一位资深网文作家。请根据以下信息撰写小说的第${chapterNumber}章：

小说基本信息：
- 名称：${currentNovel.name}
- 类型：${currentNovel.genre}
- 创意：${currentNovel.idea}
- 总章节：${currentNovel.totalChapters}

世界观设定：
${JSON.stringify(currentNovel.worldbuilding, null, 2)}

${previousChapter ? `上一章内容：
标题：${previousChapter.title}
内容概要：${previousChapter.content.substring(0, 500)}...` : '这是第一章，需要精彩的开局。'}

请以JSON格式返回：
{
  "title": "第${chapterNumber}章 章节标题",
  "content": "章节完整内容，至少2000字",
  "summary": "本章概要",
  "plotPoints": ["关键剧情点1", "关键剧情点2", "关键剧情点3"]
}

要求：
1. 内容要精彩、节奏紧凑
2. 符合${currentNovel.genre}类型特色
3. 人物性格要鲜明
4. 对话要自然
5. 描写要生动
6. 留下悬念，吸引读者继续阅读`;

        const response = await callAI([
            { role: 'system', content: '你是一位资深网文作家，擅长创作引人入胜的故事。' },
            { role: 'user', content: prompt }
        ], 0.9);
        
        let chapter = {
            number: chapterNumber,
            title: `第${chapterNumber}章`,
            content: response,
            summary: '',
            plotPoints: []
        };
        
        try {
            const jsonMatch = response.match(/\{[\s\S]*\}/);
            if (jsonMatch) {
                const parsed = JSON.parse(jsonMatch[0]);
                chapter = { ...chapter, ...parsed, number: chapterNumber };
            }
        } catch (e) {
            console.error('解析章节失败，使用原始文本:', e);
        }
        
        currentNovel.chapters.push(chapter);
        currentNovel.currentChapter = chapterNumber;
        
        updateNovelInfo();
        renderChapters();
        switchTab('chapters');
        
    } catch (error) {
        alert('生成章节失败: ' + error.message);
    } finally {
        hideLoading();
    }
}

async function generateAllChapters() {
    if (!currentNovel.name) {
        alert('请先初始化小说');
        return;
    }
    
    if (!confirm(`确定要一次性生成 ${currentNovel.totalChapters} 章吗？这可能需要较长时间。`)) {
        return;
    }
    
    const startChapter = currentNovel.chapters.length + 1;
    
    for (let i = startChapter; i <= currentNovel.totalChapters; i++) {
        try {
            await generateNextChapter();
            await new Promise(resolve => setTimeout(resolve, 1000));
        } catch (error) {
            if (!confirm(`生成第${i}章时出错: ${error.message}\n是否继续？`)) {
                break;
            }
        }
    }
    
    alert('所有章节生成完成！');
}

async function regenerateChapter() {
    if (currentNovel.chapters.length === 0) {
        alert('暂无章节可重新生成');
        return;
    }
    
    if (!confirm('确定要重新生成当前章节吗？')) return;
    
    currentNovel.chapters.pop();
    await generateNextChapter();
}

function renderChapters() {
    const list = document.getElementById('chapterList');
    
    if (currentNovel.chapters.length === 0) {
        list.innerHTML = '<p style="color: var(--text-secondary);">暂无章节，请开始生成</p>';
        return;
    }
    
    list.innerHTML = currentNovel.chapters.map(chapter => `
        <div class="chapter-item">
            <div class="chapter-header">
                <div class="chapter-title">${chapter.title}</div>
                <div>${chapter.content.length} 字</div>
            </div>
            ${chapter.summary ? `<p style="color: var(--text-secondary); margin-bottom: 10px;"><strong>概要：</strong>${chapter.summary}</p>` : ''}
            <div class="chapter-content" id="chapter-${chapter.number}">
                ${chapter.content}
            </div>
            <div class="chapter-actions">
                <button class="btn btn-small btn-secondary" onclick="toggleChapter(${chapter.number})">展开/收起</button>
                <button class="btn btn-small btn-primary" onclick="copyChapter(${chapter.number})">复制</button>
            </div>
        </div>
    `).join('');
}

function toggleChapter(number) {
    const element = document.getElementById(`chapter-${number}`);
    element.classList.toggle('expanded');
}

function copyChapter(number) {
    const chapter = currentNovel.chapters.find(c => c.number === number);
    if (chapter) {
        navigator.clipboard.writeText(`${chapter.title}\n\n${chapter.content}`);
        alert('已复制到剪贴板');
    }
}

function renderWorldbuilding() {
    const content = document.getElementById('worldbuildingContent');
    const wb = currentNovel.worldbuilding;
    
    if (!wb || !wb.setting) {
        content.innerHTML = '<p style="color: var(--text-secondary);">请先初始化小说</p>';
        return;
    }
    
    content.innerHTML = `
        <div class="worldbuilding-section">
            <h3>🌍 世界观设定</h3>
            <p style="color: var(--text-secondary); line-height: 1.8;">${wb.setting}</p>
        </div>
        
        <div class="worldbuilding-section">
            <h3>👥 角色设定</h3>
            ${wb.characters && wb.characters.length > 0 ? wb.characters.map(char => `
                <div class="character-item">
                    <div class="item-title">${char.name} ${char.role ? `(${char.role})` : ''}</div>
                    <div class="item-description">${char.description}</div>
                </div>
            `).join('') : '<p style="color: var(--text-secondary);">暂无角色设定</p>'}
        </div>
        
        <div class="worldbuilding-section">
            <h3>📍 地点设定</h3>
            ${wb.locations && wb.locations.length > 0 ? wb.locations.map(loc => `
                <div class="location-item">
                    <div class="item-title">${loc.name}</div>
                    <div class="item-description">${loc.description}</div>
                </div>
            `).join('') : '<p style="color: var(--text-secondary);">暂无地点设定</p>'}
        </div>
        
        <div class="worldbuilding-section">
            <h3>⏰ 时间线</h3>
            ${wb.timeline && wb.timeline.length > 0 ? wb.timeline.map(event => `
                <div class="timeline-item">
                    <div class="item-title">${event.time || '未知时间'}</div>
                    <div class="item-description">${event.event}</div>
                </div>
            `).join('') : '<p style="color: var(--text-secondary);">暂无时间线</p>'}
        </div>
        
        ${wb.magicSystem ? `
        <div class="worldbuilding-section">
            <h3>✨ 力量体系</h3>
            <p style="color: var(--text-secondary); line-height: 1.8;">${wb.magicSystem}</p>
        </div>
        ` : ''}
        
        ${wb.powerSystem ? `
        <div class="worldbuilding-section">
            <h3>⚡ 等级体系</h3>
            <p style="color: var(--text-secondary); line-height: 1.8;">${wb.powerSystem}</p>
        </div>
        ` : ''}
    `;
}

async function sendChatMessage() {
    const input = document.getElementById('chatInput');
    const message = input.value.trim();
    
    if (!message) return;
    
    if (!currentNovel.name) {
        alert('请先初始化小说');
        return;
    }
    
    chatHistory.push({ role: 'user', content: message });
    renderChatMessage('user', message);
    input.value = '';
    
    try {
        showLoading('AI思考中...');
        
        const systemPrompt = `你是一位资深网文编辑和创作顾问。当前小说信息：
名称：${currentNovel.name}
类型：${currentNovel.genre}
已生成章节：${currentNovel.chapters.length}
世界观：${JSON.stringify(currentNovel.worldbuilding, null, 2)}

你的任务是：
1. 回答作者关于剧情发展的问题
2. 提供创意建议和剧情走向
3. 帮助完善世界观和角色设定
4. 给出专业的写作建议`;

        const response = await callAI([
            { role: 'system', content: systemPrompt },
            ...chatHistory
        ]);
        
        chatHistory.push({ role: 'assistant', content: response });
        renderChatMessage('assistant', response);
        
        await generatePlotChoices();
        
    } catch (error) {
        alert('发送失败: ' + error.message);
    } finally {
        hideLoading();
    }
}

function renderChatMessage(role, content) {
    const container = document.getElementById('chatMessages');
    const messageDiv = document.createElement('div');
    messageDiv.className = `message ${role}`;
    messageDiv.textContent = content;
    container.appendChild(messageDiv);
    container.scrollTop = container.scrollHeight;
}

async function generatePlotChoices() {
    if (!currentNovel.name || currentNovel.chapters.length === 0) return;
    
    try {
        const lastChapter = currentNovel.chapters[currentNovel.chapters.length - 1];
        
        const prompt = `基于当前剧情，为下一章提供3个不同的剧情走向选择。

当前章节：${lastChapter.title}
内容概要：${lastChapter.summary || lastChapter.content.substring(0, 300)}

请以JSON格式返回：
{
  "choices": [
    {"title": "选项1标题", "description": "详细描述这个走向"},
    {"title": "选项2标题", "description": "详细描述这个走向"},
    {"title": "选项3标题", "description": "详细描述这个走向"}
  ]
}

要求每个选项都要有不同的风格和发展方向。`;

        const response = await callAI([
            { role: 'system', content: '你是一位资深网文编辑。' },
            { role: 'user', content: prompt }
        ]);
        
        try {
            const jsonMatch = response.match(/\{[\s\S]*\}/);
            if (jsonMatch) {
                const data = JSON.parse(jsonMatch[0]);
                renderPlotChoices(data.choices);
            }
        } catch (e) {
            console.error('解析剧情选项失败:', e);
        }
        
    } catch (error) {
        console.error('生成剧情选项失败:', error);
    }
}

function renderPlotChoices(choices) {
    const container = document.getElementById('plotChoices');
    
    if (!choices || choices.length === 0) {
        container.innerHTML = '<p style="color: var(--text-secondary);">AI正在为你生成剧情建议...</p>';
        return;
    }
    
    container.innerHTML = `
        <h3 style="margin-bottom: 15px;">🎯 剧情走向建议</h3>
        ${choices.map((choice, index) => `
            <div class="choice-item" onclick="selectPlotChoice(${index}, '${choice.title.replace(/'/g, "\\'")}')">
                <div class="choice-title">${choice.title}</div>
                <div class="choice-description">${choice.description}</div>
            </div>
        `).join('')}
    `;
}

async function selectPlotChoice(index, title) {
    const message = `我选择剧情走向：${title}`;
    document.getElementById('chatInput').value = message;
    await sendChatMessage();
}

async function saveNovel() {
    if (!currentNovel.name) {
        alert('暂无内容可保存');
        return;
    }
    
    try {
        showLoading('保存中...');
        
        currentNovel.timestamp = new Date().toISOString();
        
        const response = await fetch(`${API_BASE}/api/saves`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(currentNovel)
        });
        
        const result = await response.json();
        if (result.success) {
            alert('保存成功！');
        }
    } catch (error) {
        alert('保存失败: ' + error.message);
    } finally {
        hideLoading();
    }
}

async function showLoadModal() {
    try {
        const response = await fetch(`${API_BASE}/api/saves`);
        const saves = await response.json();
        
        const list = document.getElementById('loadSaveList');
        
        if (saves.length === 0) {
            list.innerHTML = '<p style="color: var(--text-secondary);">暂无存档</p>';
        } else {
            list.innerHTML = saves.map(save => `
                <div class="save-item">
                    <div class="provider-info">
                        <div class="provider-name">${save.name}</div>
                        <div class="provider-url">
                            ${new Date(save.timestamp).toLocaleString()} - 
                            ${save.chapterCount} 章
                        </div>
                    </div>
                    <div class="provider-actions">
                        <button class="btn btn-small btn-primary" onclick="loadNovel('${save.id}')">加载</button>
                        <button class="btn btn-small btn-danger" onclick="deleteSave('${save.id}')">删除</button>
                    </div>
                </div>
            `).join('');
        }
        
        document.getElementById('loadModal').style.display = 'block';
    } catch (error) {
        alert('加载存档列表失败: ' + error.message);
    }
}

async function loadNovel(id) {
    try {
        showLoading('加载中...');
        
        const response = await fetch(`${API_BASE}/api/saves/${id}`);
        currentNovel = await response.json();
        
        updateNovelInfo();
        renderChapters();
        renderWorldbuilding();
        
        closeModal('loadModal');
        switchTab('chapters');
        alert('加载成功！');
        
    } catch (error) {
        alert('加载失败: ' + error.message);
    } finally {
        hideLoading();
    }
}

async function deleteSave(id) {
    if (!confirm('确定要删除此存档吗？')) return;
    
    try {
        await fetch(`${API_BASE}/api/saves/${id}`, {
            method: 'DELETE'
        });
        await showLoadModal();
    } catch (error) {
        alert('删除失败: ' + error.message);
    }
}

function updateNovelInfo() {
    document.getElementById('novelTitle').textContent = currentNovel.name || '未命名';
    document.getElementById('chapterCount').textContent = currentNovel.chapters.length;
    
    const totalWords = currentNovel.chapters.reduce((sum, ch) => sum + ch.content.length, 0);
    document.getElementById('wordCount').textContent = totalWords.toLocaleString();
}

function switchTab(tabName) {
    document.querySelectorAll('.tab').forEach(tab => tab.classList.remove('active'));
    document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
    
    event?.target?.classList.add('active');
    document.getElementById(tabName + 'Tab').classList.add('active');
}

function showLoading(text = '处理中...') {
    document.getElementById('loadingText').textContent = text;
    document.getElementById('loadingOverlay').classList.add('active');
}

function hideLoading() {
    document.getElementById('loadingOverlay').classList.remove('active');
}

window.onclick = function(event) {
    if (event.target.classList.contains('modal')) {
        event.target.style.display = 'none';
    }
}

document.getElementById('chatInput')?.addEventListener('keypress', function(e) {
    if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        sendChatMessage();
    }
});

loadProviders();
updateNovelInfo();

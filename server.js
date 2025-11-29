const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const axios = require('axios');
const fs = require('fs').promises;
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(bodyParser.json({ limit: '50mb' }));
app.use(express.static('public'));

const SAVES_DIR = path.join(__dirname, 'saves');
const CONFIG_FILE = path.join(__dirname, 'config.json');

async function ensureDirectories() {
  try {
    await fs.mkdir(SAVES_DIR, { recursive: true });
  } catch (error) {
    console.error('Error creating directories:', error);
  }
}

async function loadConfig() {
  try {
    const data = await fs.readFile(CONFIG_FILE, 'utf8');
    return JSON.parse(data);
  } catch (error) {
    return {
      providers: [],
      currentProvider: null
    };
  }
}

async function saveConfig(config) {
  await fs.writeFile(CONFIG_FILE, JSON.stringify(config, null, 2));
}

app.post('/api/providers', async (req, res) => {
  try {
    const config = await loadConfig();
    const newProvider = {
      id: Date.now().toString(),
      name: req.body.name,
      baseUrl: req.body.baseUrl,
      apiKey: req.body.apiKey,
      models: []
    };
    config.providers.push(newProvider);
    if (!config.currentProvider) {
      config.currentProvider = newProvider.id;
    }
    await saveConfig(config);
    res.json({ success: true, provider: newProvider });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/providers', async (req, res) => {
  try {
    const config = await loadConfig();
    res.json(config.providers || []);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.delete('/api/providers/:id', async (req, res) => {
  try {
    const config = await loadConfig();
    config.providers = config.providers.filter(p => p.id !== req.params.id);
    if (config.currentProvider === req.params.id) {
      config.currentProvider = config.providers.length > 0 ? config.providers[0].id : null;
    }
    await saveConfig(config);
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/providers/:id/models', async (req, res) => {
  try {
    const config = await loadConfig();
    const provider = config.providers.find(p => p.id === req.params.id);
    
    if (!provider) {
      return res.status(404).json({ error: 'Provider not found' });
    }

    const response = await axios.get(`${provider.baseUrl}/v1/models`, {
      headers: {
        'Authorization': `Bearer ${provider.apiKey}`
      }
    });

    provider.models = response.data.data.map(model => ({
      id: model.id,
      name: model.id
    }));

    await saveConfig(config);
    res.json({ success: true, models: provider.models });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/providers/:id/set-current', async (req, res) => {
  try {
    const config = await loadConfig();
    config.currentProvider = req.params.id;
    await saveConfig(config);
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/chat', async (req, res) => {
  try {
    const config = await loadConfig();
    const provider = config.providers.find(p => p.id === config.currentProvider);
    
    if (!provider) {
      return res.status(400).json({ error: 'No provider selected' });
    }

    const response = await axios.post(`${provider.baseUrl}/v1/chat/completions`, {
      model: req.body.model,
      messages: req.body.messages,
      temperature: req.body.temperature || 0.8,
      max_tokens: req.body.max_tokens || 2000
    }, {
      headers: {
        'Authorization': `Bearer ${provider.apiKey}`,
        'Content-Type': 'application/json'
      }
    });

    res.json(response.data);
  } catch (error) {
    console.error('Chat API error:', error.response?.data || error.message);
    res.status(500).json({ error: error.response?.data?.error?.message || error.message });
  }
});

app.post('/api/saves', async (req, res) => {
  try {
    const saveData = req.body;
    const saveId = saveData.id || Date.now().toString();
    const savePath = path.join(SAVES_DIR, `${saveId}.json`);
    
    await fs.writeFile(savePath, JSON.stringify(saveData, null, 2));
    res.json({ success: true, id: saveId });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/saves', async (req, res) => {
  try {
    const files = await fs.readdir(SAVES_DIR);
    const saves = [];
    
    for (const file of files) {
      if (file.endsWith('.json')) {
        const content = await fs.readFile(path.join(SAVES_DIR, file), 'utf8');
        const saveData = JSON.parse(content);
        saves.push({
          id: saveData.id,
          name: saveData.name,
          timestamp: saveData.timestamp,
          chapterCount: saveData.chapters?.length || 0
        });
      }
    }
    
    res.json(saves);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/saves/:id', async (req, res) => {
  try {
    const savePath = path.join(SAVES_DIR, `${req.params.id}.json`);
    const content = await fs.readFile(savePath, 'utf8');
    res.json(JSON.parse(content));
  } catch (error) {
    res.status(404).json({ error: 'Save not found' });
  }
});

app.delete('/api/saves/:id', async (req, res) => {
  try {
    const savePath = path.join(SAVES_DIR, `${req.params.id}.json`);
    await fs.unlink(savePath);
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

ensureDirectories().then(() => {
  app.listen(PORT, () => {
    console.log(`Visual Novel Generator Server running on http://localhost:${PORT}`);
  });
});

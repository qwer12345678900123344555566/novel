#!/bin/bash

echo "================================"
echo "AI长篇小说生成器"
echo "================================"
echo ""

if [ ! -d "node_modules" ]; then
    echo "首次运行，正在安装依赖..."
    npm install
    echo ""
fi

echo "启动服务器..."
echo ""
echo "访问地址: http://localhost:3000"
echo "按 Ctrl+C 停止服务器"
echo ""

node server.js

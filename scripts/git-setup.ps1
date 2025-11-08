# Git 仓库初始化脚本
# 使用方法：在 PowerShell 中运行 .\scripts\git-setup.ps1

Write-Host "=== 星元空间项目 Git 初始化 ===" -ForegroundColor Green

# 检查是否在正确的目录
if (-not (Test-Path "README.md")) {
    Write-Host "错误：请在项目根目录运行此脚本" -ForegroundColor Red
    exit 1
}

# 检查 Git 是否安装
try {
    $gitVersion = git --version
    Write-Host "Git 版本: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "错误：未安装 Git，请先安装 Git" -ForegroundColor Red
    exit 1
}

# 初始化 Git 仓库（如果尚未初始化）
if (-not (Test-Path ".git")) {
    Write-Host "初始化 Git 仓库..." -ForegroundColor Yellow
    git init
    Write-Host "Git 仓库初始化完成" -ForegroundColor Green
} else {
    Write-Host "Git 仓库已存在" -ForegroundColor Green
}

# 检查 Git 用户配置
$userName = git config --global user.name
$userEmail = git config --global user.email

if (-not $userName -or -not $userEmail) {
    Write-Host "`n警告：Git 用户信息未配置" -ForegroundColor Yellow
    Write-Host "请运行以下命令配置（可选）：" -ForegroundColor Yellow
    Write-Host "  git config --global user.name 'Your Name'" -ForegroundColor Cyan
    Write-Host "  git config --global user.email 'your.email@example.com'" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host "Git 用户: $userName <$userEmail>" -ForegroundColor Green
}

# 添加所有文件
Write-Host "`n添加文件到暂存区..." -ForegroundColor Yellow
git add .

# 显示状态
Write-Host "`n文件状态：" -ForegroundColor Yellow
git status --short

# 询问是否提交
Write-Host "`n是否创建初始提交？(Y/N)" -ForegroundColor Yellow
$response = Read-Host

if ($response -eq "Y" -or $response -eq "y") {
    $commitMessage = @"
初始提交：星元空间统一数字门户项目

- 完成前后端核心功能开发
- 实现 SSO 登录认证
- 实现门户入口管理（CRUD）
- 实现工作台拖拽排序功能
- 完善错误处理和响应式设计
- 更新项目文档和 API 接口文档
"@
    
    git commit -m $commitMessage
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n提交成功！" -ForegroundColor Green
        Write-Host "`n提交历史：" -ForegroundColor Yellow
        git log --oneline -5
    } else {
        Write-Host "`n提交失败，请检查错误信息" -ForegroundColor Red
    }
} else {
    Write-Host "`n已取消提交。您可以稍后手动运行：" -ForegroundColor Yellow
    Write-Host "  git commit -m '您的提交信息'" -ForegroundColor Cyan
}

Write-Host "`n=== 完成 ===" -ForegroundColor Green


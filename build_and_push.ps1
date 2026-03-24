# 设置错误处理策略
$ErrorActionPreference = "Stop"

# ================= 配置区域 =================
$RegistryUrl = "office-harbor.haihuman.com"
$RepoPath = "mid/fastgpt"
$ImageName = "fastgpt"
$DockerFilePath = ".\projects\app\Dockerfile"
$BuildContext = "."
$BuildArgName = "app"
$HarborUser = "niren"
$HarborPass = "Niren.nr123"
# ===========================================

# 生成时间戳
$Timestamp = Get-Date -Format "yyyy-MM-dd-HHmmss"
$FullImageName = "${RegistryUrl}/${RepoPath}:${Timestamp}"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "开始执行 Docker 自动化流程" -ForegroundColor Cyan
Write-Host "镜像标签: $Timestamp" -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Cyan

function Run-DockerPipeline {
    Write-Host "`n[1/4] 构建镜像..." -ForegroundColor Green
    docker build -f $DockerFilePath -t "${ImageName}:latest" $BuildContext --build-arg name=$BuildArgName
    if ($LASTEXITCODE -ne 0) { throw "构建失败" }

    Write-Host "`n[2/4] 登录 Harbor..." -ForegroundColor Green
    docker login -u $HarborUser -p $HarborPass $RegistryUrl
    if ($LASTEXITCODE -ne 0) { throw "登录失败" }

    Write-Host "`n[3/4] 标记镜像..." -ForegroundColor Green
    docker tag "${ImageName}:latest" $FullImageName
    if ($LASTEXITCODE -ne 0) { throw "标记失败" }

    Write-Host "`n[4/4] 推送镜像..." -ForegroundColor Green
    docker push $FullImageName
    if ($LASTEXITCODE -ne 0) { throw "推送失败" }

    Write-Host "`n成功！镜像地址: $FullImageName" -ForegroundColor Green
}

try {
    Run-DockerPipeline
} 
catch {
    Write-Host "`n发生错误: $_" -ForegroundColor Red
    Write-Host "脚本已终止。" -ForegroundColor Red
    exit 1
}

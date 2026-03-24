# ================= 配置区域 =================
$RegistryUrl = "office-harbor.haihuman.com"
$RepoPath = "mid/fastgpt"
$ImageName = "fastgpt"
$DockerFilePath = ".\projects\app\Dockerfile"
$BuildContext = "."
$BuildArgName = "app"
$HarborUser = "niren"
$HarborPass = "Niren.nr123"

# 远程服务器配置
$RemoteIP = "192.155.1.124"
$RemoteUser = "root"
$RemotePass = "123456"
$RemoteDir = "/data/dc/fastgpt"

# 【关键修复】填入您报错信息中显示的实际指纹
$HostKeyFingerprint = "ssh-ed25519 255 SHA256:anl7y5yD0ZZiAFvfGeCU2D7h5FJ9IMpMcUTstYTx/ws"
# ===========================================

Write-Host "🚀 开始全流程：构建 -> 推送 -> 远程部署" -ForegroundColor Cyan

# 1. 生成时间戳
$Timestamp = Get-Date -Format "yyyy-MM-dd-HHmmss"
$FullImageName = "${RegistryUrl}/${RepoPath}:${Timestamp}"

# 2. 构建
Write-Host "`n[1/4] 本地构建..." -ForegroundColor Green
docker build -f $DockerFilePath -t "${ImageName}:latest" $BuildContext --build-arg name=$BuildArgName
if ($LASTEXITCODE -ne 0) { Write-Host "❌ 构建失败"; exit 1 }

# 3. 登录并推送
Write-Host "`n[2/4] 推送镜像..." -ForegroundColor Green
docker login -u $HarborUser -p $HarborPass $RegistryUrl
docker tag "${ImageName}:latest" $FullImageName
docker push $FullImageName
if ($LASTEXITCODE -ne 0) { Write-Host "❌ 推送失败"; exit 1 }

# 4. 远程部署 (使用 -hostkey 兼容旧版 plink)
Write-Host "`n[3/4] 连接远程服务器并更新..." -ForegroundColor Green

$RemoteCmd = @"
cd $RemoteDir && `
sed -i 's|image: ${RegistryUrl}/${RepoPath}:.*|image: $FullImageName|g' docker-compose.yml && `
docker-compose up -d
"@

# 【关键修复】使用 -hostkey 参数显式信任该指纹，替代 -acceptnewkeys
# 格式：plink -ssh -hostkey "指纹" -l 用户 -pw 密码 -batch IP 命令
plink -ssh -hostkey "$HostKeyFingerprint" -l $RemoteUser -pw $RemotePass -batch $RemoteIP $RemoteCmd

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n=========================================" -ForegroundColor Cyan
    Write-Host "🎉 全部完成！" -ForegroundColor Green
    Write-Host "远程已更新镜像: $FullImageName" -ForegroundColor White
    Write-Host "=========================================" -ForegroundColor Cyan
} else {
    Write-Host "`n❌ 远程部署失败。" -ForegroundColor Red
    Write-Host "错误代码: $LASTEXITCODE" -ForegroundColor Red
}